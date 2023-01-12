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
    let $ediromEditions := crAnnot:getEditions()
    for $ediromEdition in $ediromEditions
        let $workIDs := $ediromEdition//edirom:work/string(@xml:id)
        let $ediromEditionName := $ediromEdition//edirom:editionName/text()
        return
            <div>
                <h3>{$ediromEditionName}</h3>
                {for $workID at $n in $workIDs
                    let $mdivs := collection(shared:get-dataCollPath())//crapp:crApp//crapp:setting[.//crapp:work[@xml:id=$workID]]//crapp:mdiv
                    return
                        <div class="accordion accordion-flush" id="accordionWork-{$n}">
                           <h5>Werk Nr. {$n} ({count(crAnnot:getCritRemarks($workID))} Anmerkungen)</h5>
                           <hr/>
                           {for $mdiv at $i in $mdivs
                               let $mdivNo := $mdiv/@no
                               let $remarks := crAnnot:getCritRemarks($workID)[.//crapp:mdiv = $mdivNo]
                               return
                                   <div class="accordion-item">
                                      <h2 class="accordion-header" id="flush-heading-{$i}">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-{$i}" aria-expanded="false" aria-controls="flush-collapse-{$i}">Satz&#160;{$mdiv}</button>
                                      </h2>
                                      <div id="flush-collapse-{$i}" class="accordion-collapse collapse" aria-labelledby="flush-heading-{$i}" data-bs-parent="#accordionWork-{$n}">
                                        <div class="accordion-body">
                                            <div>{crAnnot:styleRemarks($remarks)}</div>
                                        </div>
                                      </div>
                                   </div>
                           }
                        </div>
                }
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
