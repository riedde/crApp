xquery version "3.1";

declare namespace crapp = "http://baumann-digital.de/ns/crApp";
declare namespace uuid = "java:java.util.UUID";
declare namespace saxon = "http://saxon.sf.net/";

declare option saxon:output "method=xml";
declare option saxon:output "media-type=text/xml";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "indent=yes";
declare option saxon:output "saxon:line-length=10000";

let $collPath := '../../../../../BauDi/baudi-data/editions/baudi-14-2b84beeb/criticalAnnots'

let $existingIDs := collection($collPath || '?select=baudi-14-2b84beeb_mdiv-*.xml;recurse=yes')//crapp:remark/@xml:id

for $document in collection($collPath || '?select=baudi-14-2b84beeb_mdiv-*.xml;recurse=yes')
    let $doc := doc(document-uri($document))
    let $remarks := $doc//crapp:remark
    for $remark in $remarks
        let $remarkID := $remark/@xml:id
        let $xmlID := concat('baudi-30-', substring(fn:string(uuid:randomUUID()), 1, 8))
        where not($remarkID)
        where not($xmlID = ($existingIDs))
        return
            insert node attribute xml:id {$xmlID} into $remark
