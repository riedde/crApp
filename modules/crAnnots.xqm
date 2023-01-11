xquery version "3.1";

module namespace crAnnot="http://baumann-digital.de/ns/crAnnots";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace crApp="http://www.baumann-digital.de/ns/crApp";
declare namespace edirom="http://www.edirom.de/ns/1.3"; 
declare namespace crapp="http://baumann-digital.de/ns/crApp";

import module namespace functx="http://www.functx.com";
import module namespace shared="http://baumann-digital.de/ns/shared" at "/db/apps/crApp/modules/shared.xql";

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

declare function crAnnot:renderSmufl($annot as node()) as node() {
    let $annotNodes := for $node in $annot/node()
                        return
                            if(local-name($node) = 'artic' and $node/@artic[.='stacc'])
                            then(<span class="musGlyphStaccato"></span>)
                            else if(local-name($node) = 'tie')
                            then(<span>TIE</span>)
                            else($node)
    return
        <annot xmlns="http://www.music-encoding.org/ns/mei">{$annotNodes}</annot>
};

declare function crAnnot:getCritRemarks($workID as xs:string) as node()* {
    collection(shared:get-dataCollPath())//crapp:crApp[.//crapp:setting//crapp:work[@xml:id=$workID]]//crapp:remark
};

declare function crAnnot:getPartLabels($partOrGrp as node(), $lang as xs:string) as xs:string {
    let $setting := $partOrGrp/ancestor::crapp:crApp/crapp:setting
    let $settingParts := $setting//crapp:parts
    let $part := $settingParts//crapp:*/id($partOrGrp)
    let $partLabel := if ($lang)
                      then($part/crapp:label[@xml:lang=$lang])
                      else($part/crapp:label[1])
    
    return
        if($partLabel) then($partLabel) else($partOrGrp)
};

declare function crAnnot:getClassLabels($class as node()?, $lang as xs:string) as xs:string? {
    let $setting := $class/ancestor::crapp:crApp/crapp:setting
    let $settingClasses := $setting//crapp:classifications
    let $classClass := $settingClasses//crapp:*/id($class)
    let $classLabel := if ($classClass/crapp:label[@xml:lang])
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

declare function crAnnot:getLabels($sequence as node()*, $type as xs:string, $lang as xs:string) as xs:string* {
    for $each in ($sequence)
        return
            if($type = 'parts')
            then(crAnnot:getPartLabels($each, $lang))
            else if($type = 'classes')
            then(crAnnot:getClassLabels($each, $lang))
            else()
};

declare function crAnnot:styleRemarks($remarks as node()*) as node()* {

<div class="col">
   <div class="row">
       <div class="col-2">
        <div class="row">
          <div class="col-3">Satz</div>
          <div class="col-9">Takt</div>
        </div>
       </div>
       <div class="col-5">
        <div class="row">
         <div class="col">Kategorie</div>
         <div class="col">Stimmen</div>
         <div class="col">Quellen</div>
         <div class="col">Editionen</div>
        </div>
       </div>
       <div class="col-5">
        <div class="col">Anmerkungen</div>
       </div>
    </div>
{
for $remark in $remarks
    let $lang := shared:get-lang()
    let $remarkType := switch($remark/@type)
                        case 'editorial' return 'success'
                        case 'reading' return 'info'
                        case 'annotation' return 'dark'
                        default return($remark/@type)
    let $mdiv := $remark/crapp:mdiv
    let $occurances := for $occurance in $remark//crapp:occurance
                        return crAnnot:renderOccurance($occurance)
    let $occurancesList := for $occurance in $occurances
                            return
                                ($occurance,<br/>)
    let $sources := for $siglum in $remark//crapp:manifestation
                        return
                            (crAnnot:getSigla($siglum),', ')
    let $editions := for $siglum in $remark//crapp:edition
                        return
                            (crAnnot:getSigla($siglum),', ')
    let $parts := $remark//crapp:part
    let $partGrps := $remark//crapp:partGrp
    let $partsText := if((not($parts) and not($partGrps)) and $remark//crapp:parts/text() != '') then($remark//crapp:parts/text() => normalize-space()) else()
    let $partsLabels := crAnnot:getLabels(($parts | $partGrps), 'parts', $lang)
    let $partsLabels := string-join(($partsLabels, $partsText), ', ')
    let $annots := $remark//crapp:annot
    let $annots := for $annot in $annots
                    return crAnnot:renderSmufl($annot)
    let $annotsList := crAnnot:makeListElements($annots,<br/>)
    let $classes := crAnnot:getLabels($remark//crapp:class, 'classes', $lang)
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
     <div class="row alert alert-{$remarkType}">
       <div class="col-2">
        <div class="row">
           <div class="col-3">{$mdiv}</div>
           <div class="col-9">{$occurancesList}</div>
        </div>
       </div>
       <div class="col-5">
        <div class="row">
            <div class="col">{$classesList}</div>
            <div class="col">{$partsLabels}</div>
            <div class="col">{$sources}</div>
            <div class="col">{$editions}</div>
        </div>
       </div>
       <div class="col-5">
        <div class="col">{$annotsList}</div>
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