xquery version "3.1";

module namespace app="http://baumann-digital.de/ns/templates";

import module namespace i18n = "http://exist-db.org/xquery/i18n" at "/db/apps/crApp/modules/i18n.xql";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://exist-db.org/xquery/config" at "/db/apps/crApp/modules/config.xqm";
import module namespace shared="http://baumann-digital.de/ns/shared" at "/db/apps/crApp/modules/shared.xql";
import module namespace functx="http://www.functx.com" at "/db/apps/crApp/modules/functx.xqm";
import module namespace crAnnot="http://baumann-digital.de/ns/crAnnots" at "/db/apps/crApp/modules/crAnnots.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace edirom="http://www.edirom.de/ns/1.3";
declare namespace crapp="http://baumann-digital.de/ns/crApp";

declare variable $app:formatText := doc('/db/apps/crApp/resources/xslt/formattingText.xsl');

declare function app:landingPage($node as node(), $model as map(*)) {
    let $ediromEdition := crAnnot:getEditions()
    let $workID := $ediromEdition//edirom:work/string(@xml:id)
    let $remarks := crAnnot:getCritRemarks($workID)
    return
    <div>
    <table>
        <tr>
            <th>Name</th>
            <th>Value</th> 
        </tr>
        <tr>
            <td>Data Collection</td> 
            <td>{shared:get-dataCollPath()}</td>
        </tr>
        <tr>
            <td>Edirom-Editions</td> 
            <td>
                <ol>{for $edition in crAnnot:getEditions()
                    return
                        <li>{$edition//edirom:editionName}</li>}
                </ol>
            </td>
        </tr>
    </table>
    <h3>remarks</h3>
    <div>Count: {crAnnot:styleRemarks($remarks)}</div>
    </div>
};

declare function app:langSwitch($node as node(), $model as map(*)) {
    <li class="nav-item">{
        let $supportedLangVals := ('de', 'en')
        for $lang in $supportedLangVals
            return
                <a id="{concat('lang-switch-', $lang)}"
                   class="nav-link {if(shared:get-lang() = $lang) then('active')else('')}"
                   style="display:inline-block; padding-right: 20px; {if (shared:get-lang() = $lang) then ('color: white!important; font-weight: bold;') else ()}"
                   href="?lang={$lang}"
                   onclick="{response:set-cookie('forceLang', $lang, 'P1D', true())}">{upper-case($lang)}</a>
    }</li>
};
