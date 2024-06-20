xquery version "3.1";

module namespace crAnnot="http://baumann-digital.de/ns/crAnnots";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace crApp="http://www.baumann-digital.de/ns/crApp";
declare namespace edirom="http://www.edirom.de/ns/1.3"; 
declare namespace crapp="http://baumann-digital.de/ns/crApp";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace functx="http://www.functx.com";
import module namespace shared="http://baumann-digital.de/ns/shared" at "shared.xql";
import module namespace app="http://baumann-digital.de/ns/templates" at "app.xql";

(:~
 : Processing XML files for display (and download)
 : Comments and not-greenlisted facsimile information will be removed
 :
 : @author Peter Stadler 
 : @param $nodes the nodes to transform
 : @return transformed nodes
~:)
declare function crAnnot:process-xml-for-display($nodes as node()*) as node()* {
    for $node in $nodes
    return
        typeswitch($node)
        case comment() return $node
        case element() return 
            element {node-name($node)} {
                $node/@*,
                crAnnot:process-xml-for-display($node/node())
            }
        case document-node() return document { crAnnot:process-xml-for-display($node/node()) }
        
        default return $node
};

declare function crAnnot:getEditions() as node()* {
    collection(shared:get-dataCollPath())//edirom:edition
};

declare function crAnnot:renderOccurance($occurance as node()) as node() {
    let $position := $occurance/crapp:position
    let $rangeStart := $occurance/crapp:range[@type="start"]
    let $rangeEnd := $occurance/crapp:range[@type="end"]
    
    let $measureStart := ($position | $rangeStart)/string(@measure)
    let $measureEnd := ($rangeEnd)/string(@measure)
    let $countStart := ($position | $rangeStart)/string(@count)
    let $countEnd := ($rangeEnd)/string(@count)
    
    let $start := <span>{$measureStart}<sup>{$countStart}</sup></span>
    let $end := <span>{$measureEnd}<sup>{$countEnd}</sup></span>
    let $startCounts := <span>{$measureStart}<sup>{$countStart}–{$countEnd}</sup></span>
    let $occuranceRendered := if($measureStart = $measureEnd)
                              then($startCounts)
                              else(($start, if($rangeEnd)then(<span>–</span>,$end)else()))
    return
        <span>{$occuranceRendered}</span>
};

declare function crAnnot:getSmuflElem($node as node(), $lang as xs:string) as node() {
    if($node/@artic[.='stacc'])
    then(<span class="smufl">&#xE4A2;</span>)
    else if($node/@artic[.='acc'])
    then(<span class="smufl">&#xE4A0;</span>)
    else if(local-name($node) = 'tie')
    then(<span class="smufl">&#xE1D5;&#xE1FD;&#xE1D5;</span>)
(:    then(<span class="smufl">&#xE0A5;&#xE8E2; &#xE0A5;&#xE8E3;</span>):)
    else if($node/@form[.='cres'])
    then(<span class="smufl">&#xE53E;</span>)
    else if($node/@form[.='dim'])
    then(<span class="smufl">&#xE53F;</span>)
    else if(local-name($node) = 'dynam' and $node/text() = 'p')
    then(<span class="smufl">&#xE520;</span>)
    else if(local-name($node) = 'dynam' and $node/text() = 'pp')
    then(<span class="smufl">&#xE520;&#xE520;</span>)
    else if(local-name($node) = 'dynam' and $node/text() = 'ppp')
    then(<span class="smufl">&#xE520;&#xE520;&#xE520;</span>)
    else if(local-name($node) = 'rest' and $node/@dur = 4)
    then(<span class="smufl">&#xE4E5;</span>)
    else if(local-name($node) = 'rest' and $node/@dur = 8)
    then(<span class="smufl">&#xE4E6;</span>)
    else if(local-name($node) = 'dir')
    then(<i>{$node/node()}</i>)
    else if(local-name($node) = 'anchoredText')
    then(<span class="quote">{$node/text()}</span>)
    else if(local-name($node) = 'clef' and $node/@shape = 'C')
    then(<span class="smufl">&#xE05C;</span>)
    else if(local-name($node) = 'slur')
    then(<span class="smufl">Bogen</span>)
    else if(local-name($node) = 'accid')
    then(if($node/@accid='n')
         then(<span class="smufl">&#xE261;</span>)
         else if($node/@accid='s')
         then(<span class="smufl">&#xE262;</span>)
         else if($node/@accid='ss')
         then(<span class="smufl">&#xE263;</span>)
         else if($node/@accid='f')
         then(<span class="smufl">&#xE260;</span>)
         else if($node/@accid='ff')
         then(<span class="smufl">&#xE264;</span>)
         else()
         )
    else($node)
};

declare function crAnnot:getSmuflApp($app as node(),$lang as xs:string) as item()* {
    let $lem := crAnnot:renderSmufl($app/mei:lem,$lang)
    let $rdg := for $rdg in $app/mei:rdg
                    return
                        ('Lesart: ', crAnnot:renderSmufl($rdg,$lang), <br/>)
    return
        ('Lemma: ',$lem,<br/>,$rdg)
        
    };

declare function crAnnot:renderPtr($ptr as node(), $lang as xs:string) as xs:string {
    (:<ptr type="adapt" target="#ED-P" corresp="#clarinet.ii"/>:)
    let $type := switch($ptr/@type)
                    case 'adapt' return 'angeglichen an'
                    case 'follow' return 'folgt'
                    case 'compare' return 'vergleiche'
                    default return $ptr/@type
    let $targets := for $target in $ptr/@target
                      return
                        substring($target,2)
    let $targets := string-join($targets,', ')
(:    let $corresps := crAnnot:getLabels($ptr/@corresp, 'parts', $lang):)
    let $corresps := for $each in $ptr/@corresp
                        return
                            substring($each,2)
    
    return
        string-join(($type, $targets, $corresps),' ')
};

declare function crAnnot:renderSmufl($annot as node()?, $lang as xs:string) as node() {
    let $annotNodes := for $node in $annot/node()
                        return
                            typeswitch($node)
                            case text() return $node
                            case element() return if(local-name($node) eq 'app') 
                                                  then(crAnnot:getSmuflApp($node,$lang))
                                                  else if(local-name($node) eq 'ptr')
                                                  then(crAnnot:renderPtr($node, $lang))
                                                  else(crAnnot:getSmuflElem($node,$lang))
                            default return $node
    let $annotType := switch($annot/@type)
                        case 'notReal' return 'ohne'
                        case 'ediAdd' return 'Hinzufügung:'
                        case 'ediDel' return 'Tilgung:'
                        case 'finding' return 'Befund:'
                        default return $annot/@type
    return
        <li><span>{$annotType}&#160;</span> {$annotNodes}</li>
};


declare function crAnnot:getCritRemarks($workID as xs:string) as node()* {
    collection(shared:get-dataCollPath())//crapp:crApp[.//crapp:setting//crapp:relWork[@xml:id=$workID]]//crapp:remark
};

(: introduce function to get the setting on remark level and pass it as: param as node() after that this function should work with $partOrGrp as xs:string:)

declare function crAnnot:getPartLabels($partOrGrp as node(), $setting as node(), $lang as xs:string) as xs:string {
    let $settingParts := $setting//crapp:parts
    let $part := $settingParts//crapp:*/id($partOrGrp)
    let $partLabel := if ($part/crapp:label[@xml:lang=$lang])
                      then($part/crapp:label[@xml:lang=$lang]/text())
                      else($part/crapp:label[1]/text())
    
    return
        if($partLabel) then($partLabel) else($partOrGrp)
};


declare function crAnnot:getClassLabels($class as node()?, $lang as xs:string) as xs:string? {
    let $setting := $class/ancestor::crapp:crApp/crapp:setting
    let $settingClasses := $setting//crapp:classifications
    let $classClass := $settingClasses//crapp:*/id($class)
    let $classLabel := if ($classClass/crapp:label[@xml:lang=$lang])
                       then($classClass/crapp:label[@xml:lang=$lang]/text())
                       else($classClass/crapp:label[1]/text())
    
    return
        if($classLabel) then($classLabel) else($class)
};

declare function crAnnot:getSigla($siglum as node()?) as node()? {
    let $siglumTokens := tokenize($siglum,'-')
    let $siglumSeq1 := subsequence($siglumTokens,1,1)
    let $siglumSeq2 := subsequence($siglumTokens,2) => string-join('-')
    return
        <span>{$siglumSeq1}<sup>{$siglumSeq2}</sup></span>
};

declare function crAnnot:makeListElements($sequence as item()*, $delim as node()) as item()* {
    for $each in $sequence
        return
            ($each,$delim)
};

declare function crAnnot:getLabels($sequence as node()*, $type as xs:string, $lang as xs:string, $setting as node()) as xs:string* {
    for $each in ($sequence)
        return
            if($type = 'parts')
            then(crAnnot:getPartLabels($each, $setting, $lang))
            else if($type = 'classes')
            then(crAnnot:getClassLabels($each, $lang))
            else()
};

declare function crAnnot:getOccurances($remark as node()) as node()* {
    for $occurance in $remark//crapp:occurance
        return crAnnot:renderOccurance($occurance)
};

declare function crAnnot:getSources($remark as node()) as xs:string* {
    for $siglum at $pos in $remark//crapp:manifestation
        return
            (crAnnot:getSigla($siglum),if($pos eq count($remark//crapp:manifestation)) then() else(', '))
};

declare function crAnnot:getEditions($remark as node()) as xs:string* {
    for $siglum at $pos in $remark//crapp:edition
        return
            (crAnnot:getSigla($siglum), if($pos = count($remark//crapp:edition)) then() else(', '))
};

declare function crAnnot:getParts($remark as node(), $lang as xs:string) as xs:string* {
    let $parts := $remark//crapp:part
    let $partGrps := $remark//crapp:partGrp
    let $partsText := if((not($parts) and not($partGrps)) and $remark//crapp:parts/text() != '') then($remark//crapp:parts/text() => normalize-space()) else()
    let $partsLabels := crAnnot:getLabels(($parts | $partGrps), 'parts', $lang, $remark/ancestor::crapp:crApp/crapp:setting)
    return
        string-join(($partsLabels, $partsText), ', ')
};

declare function crAnnot:getAnnots($remark as node(), $lang as xs:string) as node()* {
    for $annot in $remark//crapp:annot
        let $annotMod := for $element in $annot return concat('&lt;', local-name($element),'&gt;')
        let $serialisationParam := <output:serialization-parameters><output:method>xml</output:method><output:media-type>application/xml</output:media-type><output:indent>no</output:indent></output:serialization-parameters>
        return
(:            crAnnot:renderSmufl($annot, $lang):)
            <xhtml:span>{serialize(crAnnot:process-xml-for-display($annot), $serialisationParam)}</xhtml:span>
};

declare function crAnnot:getRemarkType($remark as node(), $switched as xs:boolean) as xs:string {
    
    if ($switched = true())
    then(
        switch($remark/@type)
            case 'editorial' return 'success'
            case 'reading' return 'info'
            case 'annotation' return 'dark'
            default return($remark/@type)
        )
    else($remark/@type/string())
};

declare function crAnnot:styleRemarks($remarks as node()*) as node()* {

<div class="col">
   <div class="row bottom-space">
        <div class="row">
          <!--<div class="col-3 font-weight-bold">{shared:translate('crapp.mdiv.short')}</div>-->
          <div class="col-2 font-weight-bold">ID</div>
          <div class="col-1 font-weight-bold">{shared:translate('crapp.critReport.measure.short')}<sup>{shared:translate('crapp.critReport.beat.short')}</sup></div>
         <div class="col-3 font-weight-bold">{shared:translate('crapp.critReport.category')}</div>
         <div class="col-3 font-weight-bold">{shared:translate('crapp.critReport.part')}</div>
         <!--<div class="col font-weight-bold">{shared:translate('crapp.source')}</div>-->
         <div class="col-3 font-weight-bold">{shared:translate('crapp.edition')}</div>
       <!--<div class="col-2">
         <div class="col font-weight-bold">{shared:translate('crapp.critReport.annotation')}</div>
       </div>-->
       </div>
    </div>
{
for $remark in $remarks
    let $lang := shared:get-lang()
    let $setting := $remark/ancestor::crapp:crApp/crapp:setting
    let $remarkID := $remark/@xml:id
    let $remarkType := crAnnot:getRemarkType($remark, true())
    let $mdiv := $remark/crapp:mdiv
    let $occurances := crAnnot:getOccurances($remark)
    let $occurancesList := for $occurance in $occurances
                            return
                                ($occurance,<br/>)
    let $sources := crAnnot:getSources($remark)
    let $editions := crAnnot:getEditions($remark)
    let $partsLabels := crAnnot:getParts($remark, $lang)
    let $annotsList := <ol>{crAnnot:getAnnots($remark, $lang)}</ol>
    let $classes := crAnnot:getLabels($remark//crapp:class, 'classes', $lang, $setting)
    let $classesList := crAnnot:makeListElements($classes, <br/>)
    
    let $sort1 := $remark//crapp:occurance[1]/(crapp:position|crapp:range[@type='start'])/number(@measure)
    let $sort2 := if($remark//crapp:occurance[1]/(crapp:position|crapp:range[@type='start'])/number(@count))
                  then($remark//crapp:occurance[1]/(crapp:position|crapp:range[@type='start'])/number(@count))
                  else(0)
    let $sort3 := if($remark//crapp:occurance[1]/crapp:range[@type='end']/number(@measure))
                  then(
                    if($sort2 = $remark//crapp:occurance[1]/(crapp:range[@type='end'])/number(@measure))
                    then($remark//crapp:occurance[1]/crapp:range[@type='end']/number(@count))
                    else($remark//crapp:occurance[1]/crapp:range[@type='end']/number(@measure))
                    )
                    else(0)
    let $sort4 := if($remark//crapp:occurance[1]/crapp:range[@type='end']/number(@count))
                  then($remark//crapp:occurance[1]/crapp:range[@type='end']/number(@count))
                  else(0)
    
    order by $sort1, $sort2, $sort3, $sort4
    return
     <div class="alert alert-{$remarkType}">
       <div class="row">
            <div class="col-2"><a data-bs-toggle="modal" data-bs-target="#{$remarkID}" href="{$remarkID || '.html'}">{string($remarkID)}</a></div>
           <!--<div class="col-3">{$mdiv}</div>-->
           <div class="col-1">{$occurancesList}</div>
            <div class="col-3">{$classesList}</div>
            <div class="col-3">{$partsLabels}</div>
            <!--<div class="col">{$sources}</div>-->
            <div class="col-3">{$editions}</div>
       </div>
       <!--<div class="col-5">
        <div class="col">{$annotsList}</div>
       </div>-->
       <div class="modal fade" id="{$remarkID}" tabindex="-1" aria-labelledby="{$remarkID}-Label" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable"> <!-- modal-lg -->
            <div class="modal-content">
              <div class="modal-header">
                <h1 class="modal-title fs-5" id="{$remarkID}-Label">{shared:translate('crapp.critReport.annotation')}</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body">
                {crAnnot:styleRemarkSingle($remark)}
              </div>
              <!--<div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
              </div>-->
            </div>
          </div>
        </div>
     </div>
}
</div>
};


(: this script extracts the zones from an mei file and provides a link for the image snippet. Specialized for images at BLB-Karlsruhe :)

declare function crAnnot:getImageSnippets($doc as node()) {

let $surfaces := $doc//mei:surface[mei:zone]

for $surface in $surfaces
    let $width := $surface/mei:graphic/@width
    let $height := $surface/mei:graphic/@height
    let $surfaceN := $surface/@n
    let $vlid := functx:substring-after-last($surface/mei:graphic/@xml:base, '/')
    return
        <surface n="{$surfaceN}">{
            for $zone in $surface//mei:zone
                let $ulx := $zone/@ulx
                let $uly := $zone/@uly
                let $lrx := $zone/@lrx
                let $lry := $zone/@lry
                let $extentX := $lrx - $ulx
                let $extentY := $lry - $uly
                
                let $ulxNew := ($ulx * 100) div $width
                let $ulyNew := ($uly * 100) div $height
                let $lrxNew := ($extentX * 100) div $width
                let $lryNew := ($extentY * 100) div $height
                    return
                        <zone type="iiif">{concat('https://digital.blb-karlsruhe.de/blbihd/i3f/v20/', $vlid, '/pct:', string-join(($ulxNew, $ulyNew, $lrxNew, $lryNew), ','), '/full/0/default.jpg')}</zone>
        }</surface>
};

declare function crAnnot:styleRemarkSingle($remark as node()?) as node() {
    let $lang := shared:get-lang()
    
    return

<div class="container">
    <div class="row">
        <div class="col-2">
            <div class="font-weight-bold">{shared:translate('crapp.critReport.measure.short')}<sup>{shared:translate('crapp.critReport.beat.short')}</sup></div>
        </div>
        <div class="col-10">{crAnnot:getOccurances($remark)}</div>
    </div>
    <div class="row">
        <div class="col-2">
            <div class="font-weight-bold">{shared:translate('crapp.critReport.category')}</div>
        </div>
        <div class="col-10">
            <div class="font-weight-bold">{crAnnot:makeListElements(crAnnot:getLabels($remark//crapp:class, 'classes', $lang, $remark/ancestor::crapp:crApp/crapp:setting), <br/>)}</div>
        </div>
    </div>
    <div class="row">
        <div class="col-2">
            <div class="font-weight-bold">{shared:translate('crapp.critReport.part')}</div>
        </div>
        <div class="col-10">
            <div class="font-weight-bold">{crAnnot:getParts($remark, $lang)}</div>
        </div>
    </div>
    <div class="row">
        <div class="col-2">
            <div class="font-weight-bold">{shared:translate('crapp.source')}</div>
        </div>
        <div class="col-10">
            <div class="font-weight-bold">{crAnnot:getSources($remark)}</div>
        </div>
    </div>
    <div class="row">
        <div class="col-2">
            <div class="font-weight-bold">{shared:translate('crapp.edition')}</div>
        </div>
        <div class="col-10">
            <div class="font-weight-bold">{crAnnot:getEditions($remark)}</div>
        </div>
    </div>
    <div class="row">
        <div class="col-2 font-weight-bold">{shared:translate('crapp.critReport.annotation')}</div>
        <div class="col-10 font-weight-bold">
            {if(count(crAnnot:getAnnots($remark, $lang)) gt 1)
             then(<ol>{for $each in crAnnot:getAnnots($remark, $lang) return <li>{$each}</li>}</ol>)
             else(<ul>{crAnnot:getAnnots($remark, $lang)}</ul>)}
        </div>
    </div>
</div>
};

