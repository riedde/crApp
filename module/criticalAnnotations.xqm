xquery version "3.1";

module namespace baudiAnnots="http://baumann-digital.de/ns/baudiAnnotations";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace baudiCR="http://www.baumann-digital.de/ns/criticalReport";
import module namespace functx="http://www.functx.com";


(: this script extracts the zones from an mei file and provides a link for the image snippet. Specialized for images at BLB-Karlsruhe :)

let $doc := .

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