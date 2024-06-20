xquery version "3.1";

module namespace app="http://baumann-digital.de/ns/templates";

import module namespace i18n = "http://exist-db.org/xquery/i18n" at "i18n.xql";
import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://exist-db.org/xquery/config" at "config.xqm";
import module namespace shared="http://baumann-digital.de/ns/shared" at "shared.xql";
import module namespace functx="http://www.functx.com";
import module namespace crAnnot="http://baumann-digital.de/ns/crAnnots" at "crAnnots.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace mei = "http://www.music-encoding.org/ns/mei";
declare namespace edirom="http://www.edirom.de/ns/1.3";
declare namespace crapp="http://baumann-digital.de/ns/crApp";

declare variable $app:formatText := doc('/db/apps/crApp/resources/xslt/formattingText.xsl');

declare function app:editionFilterBar($mdiv as node(), $lang as xs:string) as node()? {
    let $editions := $mdiv/ancestor::crapp:setting//crapp:relEditions/crapp:edition
    
    let $filters := for $edition in $editions
                        let $siglum := $edition/@xml:id/string()
                        let $label := $edition/crapp:label[if(@xml:lang) then(@xml:lang=$lang) else(true())]
                        return
                            <div class="custom-control custom-switch" >
                               <input class="custom-control-input" type="checkbox" id="{$siglum}" oninput="filterEdition('{$siglum}')"/>
                               <label class="custom-control-label" style="padding-right:20px;" for="{$siglum}">{$label}</label>
                            </div>
    return
       <div class="alert alert-dark" role="alert">
           <div class="row">
               {$filters}
           </div>
       </div>
};

declare function app:landingPage($node as node(), $model as map(*)) {
    let $ediromEditions := crAnnot:getEditions()
    let $lang := shared:get-lang()
    for $ediromEdition in $ediromEditions
        let $workIDs := $ediromEdition//edirom:work/@xml:id/string()
        let $ediromEditionName := $ediromEdition//edirom:editionName/text()
        return
            <div>
                <div class="container">
                {for $workID at $n in $workIDs
                    let $mdivs := collection(shared:get-dataCollPath())//crapp:crApp//crapp:setting[.//crapp:relWork[@xml:id=$workID]]//crapp:mdiv
                    return
                       (<h5 style="margin-top: 2em; margin-bottom: 1em;">{$ediromEditionName}&#160;({count(crAnnot:getCritRemarks($workID))}&#160;{shared:translate('crapp.critReport.annotations')})</h5>,
                        <hr class="m-0"/>,
                        <div class="accordion accordion-flush" id="accordionWork-{$n}">
                           {for $mdiv at $i in $mdivs
                               let $mdivNo := $mdiv/@num
                               let $mdivTitle := $mdiv/crapp:label[@xml:lang = $lang]
                               let $remarks := crAnnot:getCritRemarks($workID)[.//crapp:mdiv = $mdivNo]
                               let $mdivRemarkCount := count($remarks)
                               order by number($mdivNo)
                               return
                                   <div class="accordion-item">
                                      <h2 class="accordion-header" id="flush-heading-{$i}">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-{$i}" aria-expanded="false" aria-controls="flush-collapse-{$i}">{$mdivTitle}&#160;({$mdivRemarkCount}&#160;{shared:translate('crapp.critReport.annotations')})</button>
                                      </h2>
                                      <div id="flush-collapse-{$i}" class="accordion-collapse collapse" aria-labelledby="flush-heading-{$i}" data-bs-parent="#accordionWork-{$n}">
                                        <div class="accordion-body">
                                            {app:editionFilterBar($mdiv, $lang)}
                                            <div>{crAnnot:styleRemarks($remarks)}</div>
                                        </div>
                                      </div>
                                   </div>
                           }
                        </div>
                        )
                }
            </div>
       </div>
};

declare function app:langSwitch($node as node(), $model as map(*)) {
    <div class="nav-item">{
        let $supportedLangVals := ('de', 'en')
        for $lang in $supportedLangVals
            return
                <a id="{concat('lang-switch-', $lang)}"
                   class="nav-link {if(shared:get-lang() = $lang) then('active')else('')} font-weight-bold"
                   style="display:inline-block; padding-right: 20px; {if (shared:get-lang() = $lang) then ('color: green!important;') else ()}"
                   href="?lang={$lang}">{upper-case($lang)}</a>
    }</div>
};

declare function app:remark($node as node(), $model as map(*)) as map(){
    let $remarkID := request:get-parameter('remark-id', ())
    let $remark := collection(shared:get-dataCollPath())//crapp:remark/id($remarkID)
    return
        crAnnot:styleRemarkSingle($remark)
};