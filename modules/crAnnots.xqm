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
    let $occuranceRendered := ($start, if($rangeEnd)then(<span>–</span>,$end)else())
    return
        <span>{$occuranceRendered}</span>
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
        $partLabel
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
                        case 'editorial' return 'green'
                        case 'reading' return 'blue'
                        case 'annotation' return 'gray'
                        default return($remark/@type)
    let $mdiv := $remark/crapp:mdiv
    let $occurances := for $occurance in $remark//crapp:occurance
                        return crAnnot:renderOccurance($occurance)
    let $occurancesList := for $occurance in $occurances
                            return
                                ($occurance,<br/>)
    let $sources := $remark//crapp:manifestation => string-join (', ')
    let $editions := $remark//crapp:edition => string-join (', ')
    let $parts := $remark//crapp:part
    let $partGrps := $remark//crapp:partGrp
    let $partsText := if((not($parts) and not($partGrps)) and $remark//crapp:parts/text() != '') then($remark//crapp:parts/text() => normalize-space()) else()
    let $partsLabels := for $each in ($parts | $partGrps)
                            return
                                crAnnot:getPartLabels($each, $lang)
    let $partsLabels := string-join(($partsLabels, $partsText), ', ')
    let $annots := $remark//crapp:annot/text()
    let $annotsList := for $annot in $annots
                        return
                            ($annot,<br/>)
    let $classes := $remark//crapp:class
    let $classesList := for $class in $classes
                        return
                            ($classes,<br/>)
    (:
    <remark type="reading" xml:id="baudi-30-e6309002">
            <editions>
                <edition>BauDi-P</edition>
            </editions>
        </remark>
    :)
    
    return
     <div class="row" style="border-style:solid; border-color: {$remarkType};">
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