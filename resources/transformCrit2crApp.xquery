xquery version "3.1";

declare default element namespace "http://baumann-digital.de/ns/crApp";
declare namespace cr = "http://www.baumann-digital.de/ns/criticalReport";

declare namespace functx = "http://www.functx.com";

declare function functx:escape-for-regex($arg as xs:string?) as xs:string {
   replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
};

declare function functx:substring-after-last($arg as xs:string?, $delim as xs:string) as xs:string {
   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
};
 
declare function local:switch($string as xs:string) as xs:string {
    switch ($string)
        case 'organI' return 'organ.right'
        case 'organII' return 'organ.left'
        case 'organPedal' return 'organ.ped'
        case 'pianoI' return 'piano.right'
        case 'pianoII' return 'piano.left'
        case 'harmoniumI' return 'harmonium.right'
        case 'harmoniumII' return 'harmonium.left'
        case 'piccolo' return 'piccolo'
        case 'flute' return 'flute'
        case 'fluteI' return 'flute.i'
        case 'fluteII' return 'flute.ii'
        case 'oboe' return 'oboe'
        case 'oboeI' return 'oboe.i'
        case 'oboeII' return 'oboe.ii'
        case 'clarinet' return 'clarinet'
        case 'clarinetI' return 'clarinet.i'
        case 'clarinetII' return 'clarinet.ii'
        case 'bassoon' return 'bassoon'
        case 'bassoonI' return 'bassoon.i'
        case 'bassoonII' return 'bassoon.ii'
        case 'corno' return 'corno'
        case 'cornoI' return 'corno.i'
        case 'cornoII' return 'corno.ii'
        case 'cornoIII' return 'corno.iii'
        case 'cornoIV' return 'corno.iv'
        case 'trumpet' return 'trumpet'
        case 'trumpetI' return 'trumpet.i'
        case 'trumpetII' return 'trumpet.ii'
        case 'trombone' return 'trombone'
        case 'tromboneI' return 'trombone.i'
        case 'tromboneII' return 'trombone.ii'
        case 'tromboneIII' return 'trombone.iii'
        case 'tuba' return 'tuba'
        case 'violin' return 'violin'
        case 'violinI' return 'violin.i'
        case 'violinII' return 'violin.ii'
        case 'viola' return 'viola'
        case 'cello' return 'violoncello'
        case 'bassInstr' return 'doubleBass'
        case 'timpani' return 'timpani'
        case 'bells' return 'bells'
        case 'harpa' return 'harp'
        case 'sopranoSolo' return 'soloSopran'
        case 'tenoreSolo' return 'soloTenor'
        case 'soprano' return 'soprano'
        case 'sopranoI' return 'soprano.i'
        case 'sopranoII' return 'soprano.ii'
        case 'alto' return 'alto'
        case 'altoI' return 'alto.i'
        case 'altoII' return 'alto.ii'
        case 'tenore' return 'tenore'
        case 'tenoreI' return 'tenore.i'
        case 'tenoreII' return 'tenore.ii'
        case 'bass' return 'bass'
        case 'bassI' return 'bass.i'
        case 'bassII' return 'bass.ii'
        
        case 'sourceI' return 'A-P3'
        case 'sourceII' return 'A-P3-KA'
        case 'sourceIII' return 'A-P1'
        case 'sourceIV' return 'A-P2'
        case 'sourceV' return 'A-St-Vl'
        case 'sourceVI' return 'A-St-Orch'
        case 'sourceVII' return 'ED-P'
        case 'sourceVIII' return 'ED-KA'
        case 'sourceIX' return 'ED-KA2'
        case 'sourceX' return 'ED-St-Orch'
        case 'sourceXI' return 'ED-St-SSAA'
        case 'sourceXII' return 'ED-St-TTBB'
        
        case 'score' return ''
        case 'pianoReduction' return ''
        case 'harmoniumVoice' return ''
        default return $string
};

declare function local:switchAnnot($note as node()) {
    let $annotText := $note/text() => normalize-space()
    let $annotTextSwitched := 
    for $token in tokenize($annotText,' ')
    return
        switch($token)
        case '@' return <accid accid="b"/>
        case '#' return <accid accid="s"/>
        case '$' return <accid accid="n"/>
        case '\crescHairpin' return <hairpin form="cres"/>
        case '\decrescHairpin' return <hairpin form="dim"/>
        case'\pianisissimo' return <dynam>ppp</dynam>
        case'\pianissimo' return <dynam>pp</dynam>
        case'\piano' return <dynam>p</dynam>
        case'\fortisissimo' return <dynam>fff</dynam>
        case'\fortissimo' return <dynam>ff</dynam>
        case'\fortepiano' return <dynam>fp</dynam>
        case'\forte' return <dynam>f</dynam>
        case'\mezzopiano' return <dynam>mp</dynam>
        case'\mezzoforte' return <dynam>mf</dynam>
        case'\sforzato' return <dynam>sf</dynam>
        case'\lilyAccent' return <artic artic="acc"/>
        case'\lilyStaccato' return <artic artic="stacc"/>
        case'\clefFInline' return '\clefFInline\, '
        case'\pause1\.' return <rest dur="1" dots="1"/>
        case'\pause1' return <rest dur="1"/>
        case'\pause2\.' return <rest dur="2" dots="1"/>
        case'\pause2' return <rest dur="2"/>
        case'\pause4\.' return <rest dur="4" dots="1"/>
        case'\pause4' return <rest dur="4"/>
        case'\pause8\.' return <rest dur="8" dots="1"/>
        case'\pause8' return <rest dur="8"/>
        case'\pause16\.' return <rest dur="16" dots="1"/>
        case'\pause16' return <rest dur="16"/>
        case'\note1.' return <note dur="1" dots="1"/>
        case'\note1' return <note dur="1"/>
        case'\note2.' return <note dur="2" dots="1"/>
        case'\note2' return <note dur="2"/>
        case'\note4.' return <note dur="4" dots="1"/>
        case'\note4' return <note dur="4"/>
        case'\note8.' return <note dur="8" dots="1"/>
        case'\note8' return <note dur="8"/>
        case'\note16.' return <note dur="16" dots="1"/>
        case'\note16' return <note dur="16"/>
        
        default return $token
    return
        $annotTextSwitched
};

declare function local:getParts($remark as node()) as node()* {
    let $layerAtts := $remark/cr:layer/@*
    for $attr in $layerAtts
        where $attr = 'true'
        let $attrName := local-name($attr)
        order by $attrName
        return
            <part>{local:switch($attrName)}</part>
};

declare function local:getSources($remark as node()) as node()* {
    let $layerAtts := $remark/cr:sources/@*
    for $attr in $layerAtts
        where $attr = 'true'
        let $attrName := local-name($attr)
        order by $attrName
        return
            <source>{local:switch($attrName)}</source>
};

declare function local:getEditions($remark as node()) as node()* {
    let $layerAtts := $remark/cr:editions/@*
    for $attr in $layerAtts
        where $attr = 'true'
        let $attrName := local-name($attr)
        order by $attrName
        return
            <edition>{local:switch($attrName)}</edition>
};

declare function local:getAnnots($remark as node()) as node()* {
    let $notes := $remark/cr:note
    for $note in $notes
        let $noteType := $note/@type
        where $note != ''
        return
            element annot {
                if($noteType) then(attribute type {$noteType/string()}) else(),
                local:switchAnnot($note)
            }
};

let $collection := collection('../../../BauDi/baudi-data/editions/baudi-14-2b84beeb/criticalAnnots?select=*.xml;recurse=yes')

for $document in $collection
    let $docUri := document-uri($document)
    let $docName := functx:substring-after-last($docUri,'/')
    let $doc := doc($docUri)
    
    let $remarks := $doc//cr:remark
    let $remarksNew := for $remark at $i in $remarks
                        let $remarkID := $remark/string(@xml:id)
                        let $remarkType := $remark/string(@type)
                        let $class := $remark/cr:item/@category/string()
                        let $mdiv := $remark/cr:mdiv/text()
                        let $mStart := $remark/number(cr:measureStart)
                        let $mStartCount := $remark/number(cr:countTimeStart)
                        let $mStop := $remark/number(cr:measureEnd)
                        let $mStopCount := $remark/number(cr:countTimeEnd)
                        let $mIsRange := not($mStop - $mStart = 0) or not($mStopCount - $mStartCount eq 0)
                        let $occurance := if ($mIsRange)
                                          then(<range type="start" measure="{$mStart}" count="{$mStartCount}"/>,
                                               <range type="stop" measure="{$mStop}" count="{$mStopCount}"/>)
                                          else(<position measure="{$mStart}" count="{$mStartCount}"/>)
                        let $note := $remark/cr:note
                        let $remarkNew := <remark type="{$remarkType}" xml:id="{$remarkID}">
                                <class>{$class}</class>
                                <mdiv>{$mdiv}</mdiv>
                                <occurances>
                                    <occurance>{$occurance}</occurance>
                                </occurances>
                                <parts>
                                    {local:getParts($remark)}
                                </parts>
                                <annots>
                                    {local:getAnnots($remark)}
                                </annots>
                                <sources>
                                    {local:getSources($remark)}
                                </sources>
                                <editions>
                                    {local:getEditions($remark)}
                                </editions>
                            </remark>
                        
                        return
                            $remarkNew
        let $crApp := <crApp xmlns="http://baumann-digital.de/ns/crApp" xml:id="crApp-file-ID">
                          <include xmlns="http://www.w3.org/2001/XInclude" href="setting.xml"/>
                          <remarks>
                              {$remarksNew}
                          </remarks>
                       </crApp>
       return
        put($crApp,'../../../BauDi/baudi-data/editions/baudi-14-2b84beeb/criticalAnnots/' || $docName)