xquery version "3.1";

declare namespace crapp = "http://baumann-digital.de/ns/crApp";
declare namespace uuid = "java:java.util.UUID";
declare namespace saxon = "http://saxon.sf.net/";

import module namespace functx = "http://www.functx.com" at "../../../modules/functx.xqm";

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "indent=yes";
declare option saxon:output "saxon:line-length=10000";

declare function crapp:isRange($occurance as node()) as xs:boolean {
	exists($occurance/crapp:range)
};

declare function crapp:positionRange($occurance as node()) as xs:string {
	let $startM := if(crapp:isRange($occurance))
									then($occurance/crapp:range[@type='start']/@measure/number())
									else($occurance/crapp:position/@measure/number())
  let $startC := if(crapp:isRange($occurance))
									then($occurance/crapp:range[@type='start']/@count/number())
									else($occurance/crapp:position/@count/number())
  let $endM := $occurance/crapp:range[@type='end']/@measure/number()
  let $endC := $occurance/crapp:range[@type='end']/@count/number()
  return
  	if($startM and $endM)
    then(
         if(($endM - $startM = 0) and ($endC - $startC = 0))
         then(concat($startM,'\textsuperscript{', $startC, '}'))
         else if(($endM - $startM = 0) and ($endC - $startC != 0))
         then(concat($startM,'\textsuperscript{', $startC, '–', if($endC) then($endC)else(), '}'))
         else(concat($startM,'\textsuperscript{', $startC, '}','–',$endM,'\textsuperscript{', $endC, '}'))
        )
    else if ($startM)
    then(concat($startM,'\textsuperscript{', $startC, '}',if($endC)then(concat('–','\textsuperscript{',$endC,'}'))else()))
    else($startM)
};

declare function crapp:formatRemarks($remarks as node()*) as xs:string* {
for $remark in $remarks
		
    let $remarkType := $remark/string(@type)
    let $sectionNo := $remark/crapp:mdiv/text()
    let $class := for $class in $remark/crapp:class
    								return $class/text() => replace('Vortragsbezeichnung','Vortrag')
    let $class := string-join($class, ', ')
    let $startM := if(crapp:isRange($remark//crapp:occurance[1]))
									then($remark//crapp:occurance[1]/crapp:range[@type='start']/@measure/number())
									else($remark//crapp:occurance[1]/crapp:position/@measure/number())
  	let $startC := if(crapp:isRange($remark//crapp:occurance[1]))
									then($remark//crapp:occurance[1]/crapp:range[@type='start']/@count/number())
									else($remark//crapp:occurance[1]/crapp:position/@count/number())
    let $positionRange := for $occurance in $remark//crapp:occurance
    												return
    													crapp:positionRange($occurance)
    let $positionRange := string-join($positionRange, ', ')
    let $layers := 'LAYER' (:local:modifyLayers($remark/layer)[. != ''] => string-join(', '):)
    let $voices := 'VOICE'
    let $text := $remark/crapp:annot//text()
                        
    let $remarkLaTeX := '
    \critAnnot{' || $positionRange || '}{' || $class || '}{' || $layers || '}{' || 'SOURCES' || '}{' || $voices || '}'
    order by $class
    order by $startC
    order by $startM
    return
        $remarkLaTeX

};

let $crColl := collection('../../../../../BauDi/baudi-data/editions/baudi-14-2b84beeb/criticalAnnots?select=*.xml;recurse=yes')
let $workID := 'baudi-02-aedbaef3'
let $critReports := $crColl//crapp:crApp[./crapp:setting/crapp:work[@xml:id=$workID]]

let $sections := $critReports//crapp:mdiv/@no/string() => distinct-values()

for $section in $sections
    let $remarksEditoral := crapp:formatRemarks($critReports//crapp:remark[crapp:mdiv = $section and @type='editorial'])
    let $remarksReading := crapp:formatRemarks($critReports//crapp:remark[crapp:mdiv = $section and @type='reading'])
    let $remarksAnnot := crapp:formatRemarks($critReports//crapp:remark[crapp:mdiv = $section and @type='annotation'])
    let $sectionMod := switch ($section)
                        case '0' return 'Vorspiel'
                        case '1' return 'I – Chor (Männerchor)'
                        case '2' return 'II – Chor (Frauenchor)'
                        case '3' return 'III – Rezitativ'
                        case '4' return 'IV – Arie'
                        case '5' return 'V – Chor (Frauenchor)'
                        case '6' return 'VI – Rezitativ'
                        case '7' return 'VII – Chor (Männerchor)'
                        case '8' return 'VIII – Chor (Frauenchor)'
                        case '9' return 'IX – Rezitativ'
                        case '10' return 'X – Choral'
                        default return $section
    
    let $secHasCrsEdit := count($remarksEditoral) > 0
    let $secCrsEdit := concat('\begin{critapptable}', string-join($remarksEditoral, ''), '
\end{critapptable}')
    
    let $secHasCrsRead := count($remarksReading) > 0
    let $secCrsRead := concat('\begin{critapptable}', string-join($remarksReading, ' '), '
\end{critapptable}')
    
    let $secHasCrsAnnot := count($remarksAnnot) > 0
    let $secCrsAnnot := concat('\begin{critapptable}', string-join($remarksAnnot, ' '), '
\end{critapptable}')
    
    let $latex :=  concat('\subsection{', $sectionMod,'}
',
                          '\subsubsection*{Editorische Eingriffe}
',
                          if($secHasCrsEdit)then($secCrsEdit)else('[keine]'),
(:'
\subsubsection*{Lesarten}
',
                          if($secHasCrsRead)then($secCrsRead)else('[keine]'),:)
'
\subsubsection*{Bemerkungen des Herausgebers}
',
                          if($secHasCrsAnnot)then($secCrsAnnot)else('[keine]')
                         )
    (: \addtocounter{section}{1} \addcontentsline{toc}{section}{Editorische Eingriffe} :)
    order by number($section)
    return
        $latex
