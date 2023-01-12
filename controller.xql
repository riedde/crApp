xquery version "3.0";

import module namespace i18n="http://exist-db.org/xquery/i18n" at "/db/apps/crApp/modules/i18n.xql";
import module namespace shared="http://baumann-digital.de/ns/shared" at "/db/apps/crApp/modules/shared.xql";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace xdb = "http://exist-db.org/xquery/xmldb";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html?lang={shared:get-browser-lang()}"/>
    </dispatch>

else if (starts-with($exist:resource, "baudi-30-") and ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch
                    xmlns="http://exist.sourceforge.net/NS/exist">
                    <forward
                        url="{$exist:controller}/templates/html/viewRemark.html">
                        <add-parameter
                            name="remark-id"
                            value="{$exist:resource}"/>
                    </forward>
                    <view>
                        <forward
                            url="{$exist:controller}/modules/view.xql">
                            <add-parameter
                                name="remark-id"
                                value="{$exist:resource}"/>
                        </forward>
                    </view>
                    <error-handler>
                        <forward
                            url="{$exist:controller}/templates/html/error-page.html"
                            method="get"/>
                        <forward
                            url="{$exist:controller}/modules/view.xql"/>
                    </error-handler>
                </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)

else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/templates/html/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
