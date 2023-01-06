xquery version "3.1";

declare namespace crapp = "http://baumann-digital.de/ns/crApp";

let $collPath := '../../../BauDi/baudi-data/editions/baudi-14-2b84beeb/criticalAnnots'

for $document in collection($collPath || '?select=baudi-14-2b84beeb_mdiv-09.xml;recurse=yes')
    let $doc := doc(document-uri($document))
    let $remarks := $doc//crapp:remark
    let $remarksOrdered := for $remark in $remarks
                                let $occurance := $remark//crapp:occurance[1]
                                let $position := $occurance/crapp:position
                                let $rangeStart := $occurance/crapp:range[@type='start']
                                let $rangeStop := $occurance/crapp:range[@type='stop']
                                let $measure := number(($position | $rangeStart)/@measure)
                                let $count := if(($position | $rangeStart)/number(@count))
                                              then(($position | $rangeStart)/number(@count))
                                              else(0)
                                let $measureStop := if($rangeStop/number(@measure))
                                                    then($rangeStop/number(@measure))
                                                    else(0)
                                let $countStop := if($rangeStop/number(@count))
                                                  then($rangeStop/number(@count))
                                                  else(0)
                            
                                order by $measure, $count, $measureStop, $countStop
                                return
                                    $remark
    return
        replace node $doc//crapp:remarks with
            <remarks xmlns="http://baumann-digital.de/ns/crApp">{$remarksOrdered}</remarks>
