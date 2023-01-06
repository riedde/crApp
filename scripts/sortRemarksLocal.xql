xquery version "3.1";

declare namespace crapp = "http://baumann-digital.de/ns/crApp";

let $collPath := '../../../BauDi/baudi-data/editions/baudi-14-2b84beeb/criticalAnnots'

for $document in collection($collPath || '?select=baudi-14-2b84beeb_mdiv-09.xml;recurse=yes')
    let $doc := doc(document-uri($document))
    let $remarks := $doc//crapp:remarks
    for $remark in $remarks
        let $position := $remark//crapp:position
        let $rangeStart := $remark//crapp:range[@type='start']
        let $rangeStop := $remark//crapp:range[@type='stop']
        let $measure := for $measure at $i in ($position/@measure | $rangeStart/@measure)
                            where $i = 1
                            return
                                $measure
        let $count := for $count at $i in ($position/@count | $rangeStart/@count)
                            where $i = 1
                            return
                                $count
        let $measureStop := for $measureStop at $i in $rangeStop/@measure
                                where $i = 1
                                return
                                    $measureStop
        let $countStop := for $countStop at $i in $rangeStop/@count
                                where $i = 1
                                return
                                    $countStop
    
    order by $measure
    order by $count
    order by $measureStop
    order by $countStop
    return
        replace node $remarks with $remark