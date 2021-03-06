<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (c) 2010. betterForm Project - http://www.betterform.de
  ~ Licensed under the terms of BSD License
  -->
<xsl:stylesheet version="2.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xf="http://www.w3.org/2002/xforms"
                xmlns:bf="http://betterform.sourceforge.net/xforms"
                exclude-result-prefixes="xf bf"
                xpath-default-namespace= "http://www.w3.org/1999/xhtml">

    <xsl:import href="common.xsl"/>
    <xsl:include href="dojo-ui.xsl"/>
    <xsl:include href="dojo-controls.xsl"/>


    <!-- ####################################################################################################### -->
    <!-- This stylesheet transcodes a XTHML2/XForms input document to HTML 4.0.                                  -->
    <!-- It serves as a reference for customized stylesheets which may import it to overwrite specific templates -->
    <!-- or completely replace it.                                                                               -->
    <!-- This is the most basic transformator for HTML browser clients and assumes support for HTML 4 tagset     -->
    <!-- but does NOT rely on javascript.                                                                        -->
    <!-- author: joern turner                                                                                    -->
    <!-- author: lars windauer                                                                                   -->
    <!-- ####################################################################################################### -->

    <!-- ############################################ PARAMS ################################################### -->
    <xsl:param name="contextroot" select="''"/>

    <xsl:param name="sessionKey" select="''"/>

    <xsl:param name="baseURI" select="''"/>

    <!-- ### this url will be used to build the form action attribute ### -->
    <xsl:param name="action-url" select="'http://localhost:8080/betterform-1.0.0/XFormsServlet'"/>

    <xsl:param name="form-id" select="'betterform'"/>
    <xsl:param name="form-name" select="//title"/>
    <xsl:param name="debug-enabled" select="'false'"/>

    <!-- ### specifies the parameter prefix for repeat selectors ### -->
    <xsl:param name="selector-prefix" select="'s_'"/>

    <!-- ### contains the full user-agent string as received from the servlet ### -->
    <xsl:param name="user-agent" select="'default'"/>

    <!-- will be set by config and passed from WebProcessor -->
    <xsl:param name="resourcesPath" select="'/bfResources/'"/>

    <!--- path to javascript files -->
    <xsl:param name="scriptPath" select="concat($resourcesPath,'scripts/')"/>

    <!-- path to core CSS file -->
    <xsl:param name="CSSPath" select="concat($resourcesPath,'styles/')"/>

    <xsl:param name="keepalive-pulse" select="'0'"/>

    <!-- CDN support is disabled by default -->
    <xsl:param name="useCDN" select="'false'"/>

    <!-- locale Parameter -->
    <xsl:param name="locale" select="'en'"/>

    <!-- Dojo Default Theme -->
    <xsl:param name="defaultTheme" select="'tundra'"/>

    <!-- ############################################ VARIABLES ################################################ -->
    <!-- ### checks, whether this form uses uploads. Used to set form enctype attribute ### -->
    <xsl:variable name="uses-upload" select="exists(//*/xf:upload)"/>

    <!-- ### checks, whether this form makes use of <textarea xf:mediatype='text/html'/> ### -->
    <!--<xsl:variable name="uses-html-textarea" select="boolean(//xf:textarea[@mediatype='text/html'])"/>-->

    <!-- ### the CSS stylesheet to use ### -->
    <xsl:variable name="default-css" select="concat($contextroot,$CSSPath,'xforms.css')"/>
    <xsl:variable name="betterform-css" select="concat($contextroot,$CSSPath,'betterform.css')"/>

    <xsl:variable name="default-hint-appearance" select="'bubble'"/>



    <xsl:output method="xhtml" version="1.0" encoding="UTF-8" indent="no"
                doctype-system="/resources/xsd/xhtml1-transitional.dtd"/>
    <!-- ### transcodes the XHMTL namespaced elements to HTML ### -->
    <!--<xsl:namespace-alias stylesheet-prefix="xhtml" result-prefix="#default"/>-->

    <xsl:preserve-space elements="*"/>
    <xsl:strip-space elements="xf:action"/>


    <!-- ####################################################################################################### -->
    <!-- ##################################### TEMPLATES ####################################################### -->
    <!-- ####################################################################################################### -->
    <xsl:template match="head">

        <xsl:comment> *** powered by betterFORM, &amp;copy; 2011 *** </xsl:comment>

        <head>
            <title>
                <xsl:value-of select="$form-name"/>
            </title>
            <!-- copy all meta tags except 'contenttype' -->
            <xsl:call-template name="getMeta"/>

            <!-- copy base if present -->
<!--
            <xsl:if test="$baseURI != ''">
                <base>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$baseURI"/>
                    </xsl:attribute>
                </base>
            </xsl:if>
-->

            <xsl:choose>
                <xsl:when test="$useCDN='true'">
                    <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/dojo/1.5/dojo/resources/dojo.css"/>
                    <link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/dojo/1.5/dijit/themes/tundra/tundra.css"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="addDojoCSS"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="include-xforms-css"/>

            <!-- copy user-defined stylesheets and inline styles -->
            <xsl:call-template name="getLinkAndStyle"/>

            <!-- include needed javascript files -->
            <xsl:call-template name="addDojoConfig"/>
            <xsl:call-template name="addDojoImport"/>
            <xsl:call-template name="addDWRImports"/>

            <!-- Optional Simile Timeline Javascript Imports -->
            <xsl:if test="exists(//xf:input[@appearance='caSimileTimeline'])">
                <xsl:call-template name="addSimileTimelineImports" />
            </xsl:if>

            <xsl:call-template name="addLocalScript"/>
            <xsl:call-template name="copyInlineScript"/>

        </head>
    </xsl:template>

    <xsl:template name="include-xforms-css">
        <!-- include betterForm default stylesheet -->
        <link rel="stylesheet" type="text/css" href="{$default-css}"/>
        <link rel="stylesheet" type="text/css" href="{$betterform-css}"/>
    </xsl:template>

    <xsl:template name="addLocalScript">
        <script type="text/javascript" defer="defer">
            <xsl:if test="$debug-enabled">function getXFormsDOM(){
                Flux.getXFormsDOM(document.getElementById("bfSessionKey").value,
                function(data){
                console.dirxml(data);
                }
                );
                }

                function getInstanceDocument(instanceId){
                var model = dojo.query(".xfModel", dojo.doc)[0];
                dijit.byId(dojo.attr(model, "id")).getInstanceDocument(instanceId,
                function(data){
                console.dirxml(data);
                });
                }
            </xsl:if>

            <!--
                            function loadBetterFORMJs(pathToRelease, developmentJsClass){
                                if (isBetterFORMRelease) {
                                    var scriptElement = document.createElement('script');
                                    scriptElement.type = 'text/javascript';
                                    scriptElement.src = pathToRelease;
                                    document.getElementsByTagName('head')[0].appendChild(scriptElement);
                                } else {
                                    dojo.require(developmentJsClass);
                                }
                            }
            -->

            dojo.addOnLoad(function(){
            dojo.addOnLoad(function(){
            dojo.parser.parse();
            Flux._path = dojo.attr(dojo.byId("fluxProcessor"), "contextroot") + "/Flux";
            Flux.init( dojo.attr(dojo.byId("fluxProcessor"),"sessionkey"),
            dojo.hitch(fluxProcessor,fluxProcessor.applyChanges));
            });
            });
        </script><xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template name="addDojoCSS"><xsl:text>
</xsl:text>
        <xsl:variable name="cssTheme">
                    <xsl:choose>
                        <xsl:when test="contains(//body/@class, 'tundra')">tundra</xsl:when>
                        <xsl:when test="contains(//body/@class, 'soria')">soria</xsl:when>
                        <xsl:when test="contains(//body/@class, 'nihilo')">nihilo</xsl:when>
                        <xsl:when test="contains(//body/@class, 'claro')">claro</xsl:when>
                        <xsl:when test="contains(//body/@class, 'a11y')">a11y</xsl:when>
                        <xsl:otherwise><xsl:value-of select="$defaultTheme"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <style type="text/css">
                    @import "<xsl:value-of select="concat($contextroot,$scriptPath, 'dijit/themes/', $cssTheme, '/', $cssTheme,'.css')"/>";
                    @import "<xsl:value-of select="concat($contextroot,$scriptPath, 'dojo/resources/dojo.css')"/>";
                    @import "<xsl:value-of select="concat($contextroot,$scriptPath, 'dojox/widget/Toaster/Toaster.css')"/>";
                    @import "<xsl:value-of select="concat($contextroot,$scriptPath, 'dojox/layout/resources/FloatingPane.css')"/>";
                    @import "<xsl:value-of select="concat($contextroot,$scriptPath, 'dojox/layout/resources/ResizeHandle.css')"/>";
                </style><xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template name="addDojoConfig">
        <xsl:choose>
            <xsl:when test="$useCDN='true'">
                <script type="text/javascript">
                    var djConfig = {
                    debugAtAllCosts:false,
                    locale:'<xsl:value-of select="$locale"/>',
                    isDebug:false,
                    baseUrl:"<xsl:value-of select="concat($contextroot,$scriptPath)"/>",
                    modulePaths:{"betterform":"betterform"},
                    xWaitSeconds:10,
                    parseOnLoad:false
                    };
                </script><xsl:text>
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <script type="text/javascript">
                    var djConfig = {
                        debugAtAllCosts:<xsl:value-of select="$debug-enabled"/>,
                        locale:'<xsl:value-of select="$locale"/>',
                        isDebug:<xsl:value-of select="$debug-enabled"/>,
                        parseOnLoad:false
                    };
                </script><xsl:text>
</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="addDojoImport">
        <script type="text/javascript">
            var isBetterFORMRelease = true;
        </script>
        <xsl:choose>
            <xsl:when test="$useCDN='true'">
                <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/dojo/1.5/dojo/dojo.xd.js"> </script><xsl:text>
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <script type="text/javascript" src="{concat($contextroot,$scriptPath,'dojo/dojo.js')}"> </script><xsl:text>
</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="exists(//script[@id='betterformJs'])">
                <!-- do nothin if id 'betterformJs' is available (means betterform.js is allready importet -->
            </xsl:when>
<!--
            <xsl:when test="not(exists(//xf:select)) and not(exists(//xf:select1)) and not(exists(//xf:upload)) and not(exists(//xf:repeat)) and not(exists(//xf:switch)) and not(exists(//xf:range))  and not(exists(//xf:textarea))">
                <script type="text/javascript" src="{concat($contextroot,$scriptPath,'betterform/betterform-Minimal.js')}">&#160;</script>
            </xsl:when>
            <xsl:when test="not(exists(//xf:range)) and not(exists(//xf:textarea))">
                <script type="text/javascript" src="{concat($contextroot,$scriptPath,'betterform/betterform-Compact.js')}">&#160;</script>
            </xsl:when>
-->
            <xsl:otherwise>
                <script type="text/javascript" src="{concat($contextroot,$scriptPath,'betterform/betterform-Full.js')}">&#160;</script>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>
</xsl:text>
    </xsl:template>

    <!-- todo: move this template out to e.g. 'dojoPlus.xsl' -->
    <xsl:template name="addSimileTimelineImports" >
            <script type="text/javascript" src="{concat($contextroot,$scriptPath, 'simile/timeline/simile-ajax-api.js')}">&#160;</script><xsl:text>
</xsl:text>
            <script type="text/javascript" src="{concat($contextroot,$scriptPath, 'simile/timeline/simile-ajax-bundle.js')}">&#160;</script><xsl:text>
</xsl:text>
            <script type="text/javascript" src="{concat($contextroot,$scriptPath, 'simile/timeline/timeline-api.js?timeline-use-local-resources=true&amp;bundle=true&amp;forceLocale=en')}">&#160;</script><xsl:text>
</xsl:text>
    </xsl:template>



    <xsl:template match="body">
        <!-- todo: add 'overflow:hidden' to @style here -->
        <xsl:variable name="theme">
            <xsl:choose>
                <xsl:when test="not(exists(//body/@class)) or string-length(//body/@class) = 0"><xsl:value-of select="$defaultTheme"/></xsl:when>
                <xsl:when test="not(contains(//body/@class, $defaultTheme)) and
                                not(contains(//body/@class, 'tundra')) and
                                not(contains(//body/@class, 'soria'))  and
                                not(contains(//body/@class, 'claro'))  and
                                not(contains(//body/@class, 'nihilo')) and
                                not(contains(//body/@class, 'ally'))">
                    <xsl:value-of select="concat($defaultTheme, ' ', //body/@class)"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="//body/@class"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <body class="{$theme} bf">
            <xsl:copy-of select="@*[name() != 'class']"/>
            <div id="bfLoading" class="disabled">
                <img src="{concat($contextroot,$resourcesPath,'images/indicator.gif')}" class="xfDisabled" id="indicator"
                     alt="loading"/>
            </div>
            <!-- Toaster widget for ephemeral messages -->

            <div dojoType="dojox.widget.Toaster"
                 id="betterformMessageToaster"
                 positionDirection="bl-up"
                 duration="8000"
                 separator="&lt;div style='height:1px;border-top:thin dotted;width:100%;'&gt;&lt;/div&gt;"
                 messageTopic="testMessageTopic">
            </div>
            <noscript>
                <div id="noScript">
                    Sorry, you don't have Javascript enabled in your browser. Click here for a non-scripted version
                    of this form.
                </div>
            </noscript>
            <div id="formWrapper">
                <div dojotype="betterform.FluxProcessor" jsId="fluxProcessor" id="fluxProcessor" sessionkey="{$sessionKey}" contextroot="{$contextroot}">

                    <xsl:for-each select="//xf:model">
                        <div class="xfModel" style="display:none" id="{@id}" jsId="{@id}" dojoType="betterform.XFormsModelElement"/>
                     </xsl:for-each>

                     <xsl:variable name="outermostNodeset"
                                  select=".//xf:*[not(xf:model)][not(ancestor::xf:*)]"/>

                    <!-- detect how many outermost XForms elements we have in the body -->
                    <xsl:choose>
                        <xsl:when test="count($outermostNodeset) = 1">
                            <!-- match any body content and defer creation of form tag for XForms processing.
                             This option allows to mix HTML forms with XForms markup. -->
                            <!-- todo: issue to revisit: this obviously does not work in case there's only one xforms control in the document. In that case the necessary form tag is not written. -->
                            <!-- hack solution: add an output that you style invisible to the form to make it work again. -->
                            <xsl:apply-templates mode="inline"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- in case there are multiple outermost xforms elements we are forced to create
                             the form tag for the XForms processing.-->
                            <xsl:call-template name="createForm"/>
                        </xsl:otherwise>
                    </xsl:choose>
<!--
                    <xsl:if test="exists(//xf:help)">
                        <div id="bfHelpTrigger">
                            <a href="javascript:fluxProcessor.showHelp();"><img id="bfHelpIcon" src="{concat($contextroot,$resourcesPath,'images/helpBubble.png')}" alt="Help"/></a>
                            <div dojotype="dijit.Tooltip" connectid="bfHelpIcon">Focus control and click here for help</div>
                        </div>
                    </xsl:if>
-->
                    <div id="helpWindow" style="display:none"/>
<!--
                    <div id="bfCopyright">
                        <xsl:text disable-output-escaping="yes">powered by betterFORM, &amp;copy; 2010</xsl:text>
                    </div>
-->
                </div>
            </div>

            <div id="bfMessageDialog" dojotype="dijit.Dialog" style="text-align:center;display:none;">
                <div id="messageContent"></div>
                <button dojotype="dijit.form.Button" type="button" style="margin:10px;">OK
                    <script type="dojo/method" event="onClick" args="evt">
                        dijit.byId("bfMessageDialog").hide();
                    </script>
                </button>
            </div>

            <xsl:if test="$debug-enabled='true'">
                <!-- z-index of 1000 so it is also in front of shim for modal dialogs -->
                <div id="debug-pane" context="{concat($contextroot,'/inspector/',$sessionKey,'/')}">
                    <div style="float:right;margin-right:20px;text-align:right;" id="copyright">
                        <a href="http://www.betterform.de">
                            <img style="vertical-align:text-bottom; margin-right:5px;"
                                 src="{concat($contextroot,'/bfResources/images/betterform_icon16x16.png')}" alt="betterFORM project"/>
                        </a>
                        <span>&#xA9; 2011 betterFORM</span>
                    </div>
                    <span id="debug-pane-links" style="float:left;width:80%;">
                        <a href="{concat($contextroot,'/inspector/',$sessionKey,'/','hostDOM')}" target="_blank">Host Document</a>
                    </span>
                </div>
            </xsl:if>
        </body>
    </xsl:template>

    <!--
    match outermost group of XForms markup. An outermost group is necessary to allow standard HTML forms
    to coexist with XForms markup and still produce non-nested form tags in the output.
    -->
    <xsl:template
            match="xf:group[not(ancestor::xf:*)][1] | xf:repeat[not(ancestor::xf:*)][1] | xf:switch[not(ancestor::xf:*)][1]"
            mode="inline">
        <!-- ##### the XFormsProcessor itself is always reachable via id 'fluxProcessor' ##### -->
        <xsl:element name="form">
            <xsl:call-template name="createFormAttributes"/>
            <xsl:apply-templates select="."/>
        </xsl:element>
    </xsl:template>

    <!-- this template is called when there's no single outermost XForms element meaning there are
     several blocks of XForms markup scattered in the body of the host document. -->
    <xsl:template name="createForm">
        <!-- ##### the XFormsProcessor itself is always reachable via id 'fluxProcessor' ##### -->
        <!--<div dojotype="betterform.FluxProcessor" jsId="fluxProcessor" id="fluxProcessor" sessionkey="{$sessionKey}"/>-->
        <xsl:element name="form">
            <xsl:call-template name="createFormAttributes"/>
            <xsl:for-each select="*">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template name="createFormAttributes">
        <xsl:attribute name="name">
            <xsl:value-of select="$form-id"/>
        </xsl:attribute>

        <xsl:attribute name="onSubmit">return false;</xsl:attribute>
        <xsl:attribute name="method">POST</xsl:attribute>

        <xsl:choose>
            <xsl:when test="$uses-upload = false()">
                <xsl:attribute name="enctype">application/x-www-form-urlencoded</xsl:attribute>
                <xsl:attribute name="action">javascript:submitFunction();</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="enctype">multipart/form-data</xsl:attribute>
                <xsl:attribute name="action">
                    <xsl:value-of select="concat($action-url,'?sessionKey=',$sessionKey,'&#38;isUpload=true')"/>
                </xsl:attribute>
                <input type="hidden" name="isUpload" value=""/>
                <iframe id="UploadTarget" name="UploadTarget" src="" style="width:0px;height:0px;border:0"></iframe>
            </xsl:otherwise>
        </xsl:choose>
        <input type="hidden" id="bfSessionKey" name="sessionKey" value="{$sessionKey}"/>
    </xsl:template>
    <!-- ######################################################################################################## -->
    <!-- #####################################  CONTROLS ######################################################## -->
    <!-- ######################################################################################################## -->

    <!-- todo: restructure to use a mode to build the widget instead of buildControl -->
    <xsl:template match="xf:input|xf:range|xf:secret|xf:select|xf:select1|xf:textarea|xf:upload">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="control-classes">
            <xsl:call-template name="assemble-control-classes">
                <!--<xsl:with-param name="appearance" select="@appearance"/>-->
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="label-classes">
            <xsl:call-template name="assemble-label-classes"/>
        </xsl:variable>

        <div id="{$id}" dojoType="betterform.ui.Control" class="{$control-classes}">

            <xsl:call-template name="copy-style-attribute"/>
            <xsl:if test="@bf:incremental-delay">
            	<xsl:attribute name="bf:incremental-delay" select="@bf:incremental-delay"/>
            </xsl:if>

            <label for="{$id}-value" id="{$id}-label" class="{$label-classes}">
                <xsl:call-template name="create-label">
                    <xsl:with-param name="label-elements" select="xf:label"/>
                </xsl:call-template>
            </label>

            <xsl:call-template name="buildControl"/>
            <xsl:apply-templates select="xf:alert"/>
            <xsl:apply-templates select="xf:hint"/>
            <!--<xsl:apply-templates select="xf:help"/>-->

            <xsl:copy-of select="script"/>
        </div>
    </xsl:template>

    <!-- cause outputs can be inline they should not use a block element wrapper -->
    <xsl:template match="xf:output">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="control-classes">
            <xsl:call-template name="assemble-control-classes">
                <!--<xsl:with-param name="appearance" select="@appearance"/>-->
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="label-classes">
            <xsl:call-template name="assemble-label-classes"/>
        </xsl:variable>

        <span id="{$id}" class="{$control-classes}" dojoType="betterform.ui.Control">
            <xsl:call-template name="copy-style-attribute"/>
                <label for="{$id}-value" id="{$id}-label" class="{$label-classes}">
                <xsl:call-template name="create-label">
                    <xsl:with-param name="label-elements" select="xf:label"/>
                </xsl:call-template>
                </label>
            <xsl:call-template name="buildControl"/>

            <xsl:apply-templates select="xf:alert"/>
            <xsl:apply-templates select="xf:hint"/>
            <!--<xsl:apply-templates select="xf:help"/>-->

            <xsl:copy-of select="script"/>
        </span>
    </xsl:template>

    <xsl:template match="xf:output" mode="prototype">
       <xsl:variable name="id" select="@id"/>
        <xsl:variable name="control-classes">
            <xsl:call-template name="assemble-control-classes">
                <!--<xsl:with-param name="appearance" select="@appearance"/>-->
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="label-classes">
            <xsl:call-template name="assemble-label-classes"/>
        </xsl:variable>

        <span id="{$id}" class="{$control-classes}" controlType="{local-name()}-control">
            <xsl:call-template name="copy-style-attribute"/>
                <label for="{$id}-value" id="{$id}-label" class="{$label-classes}">
                <xsl:call-template name="create-label">
                    <xsl:with-param name="label-elements" select="xf:label"/>
                </xsl:call-template>
                </label>
            <xsl:call-template name="buildControl"/>
            <span id="{$id}-alertAttachPoint" style="display:none;" class="alertAttachPoint"/>
            <xsl:apply-templates select="xf:hint"/>
            <!--<xsl:apply-templates select="xf:help"/>-->

            <xsl:copy-of select="script"/>
        </span>
    </xsl:template>

    <!-- ##### TRIGGER / SUBMIT ##### -->
    <!-- ##### TRIGGER / SUBMIT ##### -->
    <!-- ##### TRIGGER / SUBMIT ##### -->
    <!-- ##### TRIGGER / SUBMIT ##### -->
    <xsl:template match="xf:trigger|xf:submit">
        <xsl:variable name="control-classes">
            <xsl:call-template name="assemble-control-classes">
                <!--<xsl:with-param name="appearance" select="@appearance"/>-->
            </xsl:call-template>
        </xsl:variable>

        <xsl:call-template name="trigger">
            <xsl:with-param name="classes" select="$control-classes"/>
        </xsl:call-template>
    </xsl:template>

    <!-- ######################################################################################################## -->
    <!-- #####################################  CHILD ELEMENTS ################################################## -->
    <!-- ######################################################################################################## -->

    <!-- ##### LABEL ##### -->
    <!-- ##### LABEL ##### -->
    <!-- ##### LABEL ##### -->
    <!-- ##### LABEL ##### -->
    <xsl:template match="xf:label">
        <!-- match all inline markup and content -->
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="xf:label" mode="prototype">
        <xsl:choose>
            <xsl:when test="exists(*)">
                <xsl:for-each select="*">
                    <xsl:choose>
                        <xsl:when test="local-name(.)='output'">
                            <xsl:apply-templates select="." mode="prototype"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ##### HELP ##### -->
    <!-- ##### HELP ##### -->
    <!-- ##### HELP ##### -->
    <xsl:template match="xf:help">
        <!--<span id="{../@id}-help" class="xfHelp" style="display:none;">-->
            <!--<div id="{../@id}-help" class="xfHelp">-->
        <div id="{../@id}-help-text" class="bfHelpText" style="display:none;">
            <xsl:apply-templates/>
        </div>
        <!--</div>-->
        <!--</span>-->
    </xsl:template>

    <!-- ##### ALERT ##### -->
    <!-- ##### ALERT ##### -->
    <!-- ##### ALERT ##### -->
    <xsl:template match="xf:alert">
        <span id="{../@id}-alert" class="xfAlert" style="display:none;">
            <xsl:apply-templates/>
            <span class="closeAlertIcon"> </span>
        </span>
    </xsl:template>

    <!-- ##### HINT ##### -->
    <!-- ##### HINT ##### -->
    <!-- ##### HINT ##### -->
    <xsl:template match="xf:hint">
        <xsl:variable name="parentId" select="../@id"/>
        <!--<xsl:message terminate="no">parentId: <xsl:value-of select="../@id"/>  id: <xsl:value-of select="@id"/> </xsl:message>-->
        <div id="{../@id}-hint" class="xfHint" style="display:none">
            <xsl:apply-templates/>

            <!-- if help exists we output the linking icon here -->
            <xsl:if test="exists(../xf:help)">
                <a tabindex="-1" onmouseover="dojo.style(dojo.byId('{$parentId}'+'-help-text'),'display','inline-block');"
                                 onmouseout="dojo.style(dojo.byId('{$parentId}'+'-help-text'),'display','none');"
                   href=""
                   id="{$parentId}-help"
                   class="xfHelp">
                    <img id="{$parentId}-help-HelpIcon" src="{concat($contextroot,$resourcesPath,'images/helpBubble.png')}"
                         alt="Help" width="16" height="16"/>
                </a>
            </xsl:if>
            <xsl:apply-templates select="../xf:help"/>

        </div>
    </xsl:template>




    <!-- ####################################################################################################### -->
    <!-- #####################################  HELPER TEMPLATES '############################################## -->
    <!-- ####################################################################################################### -->

    <xsl:template name="buildControl">
        <xsl:variable name="id" select="@id"/>

        <xsl:variable name="datatype">
            <xsl:call-template name="getType"/>
        </xsl:variable>
        <xsl:variable name="lname" select="local-name()"/>
        <xsl:variable name="name" select="concat($data-prefix,@id)"/>
       <!-- TODO: DateTime -->
        <xsl:variable name="incremental">
            <xsl:choose>
                <xsl:when test="$lname='input' and
                            $datatype='date'
                            ">
                    <xsl:value-of select="if (exists(@incremental)) then @incremental else 'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="if (exists(@incremental)) then @incremental else 'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="incrementaldelay">
        	<xsl:value-of select="if (exists(@bf:incremental-delay)) then @bf:incremental-delay else '0'"/>
        </xsl:variable>

		<xsl:if test="$incrementaldelay ne '0'">
			 <xsl:message><xsl:value-of select="concat(' incremental-delay: ', $incrementaldelay)" /></xsl:message>
		</xsl:if>
        <xsl:variable name="navindex" select="if (exists(@navindex)) then @navindex else '0'"/>
        <xsl:variable name="accesskey" select="if (exists(@accesskey)) then @accesskey else 'none'"/>

        <xsl:choose>
            <xsl:when test="$lname='input' or
                            $lname='output' or
                            $lname='secret' or
                            $lname='submit' or
                            $lname='textarea' or
                            $lname='upload'">

                <div id="{concat($id,'-value')}"
                     class="xfValue"
                     dataType="{$datatype}"
                     controlType="{$lname}"
                     appearance="{@appearance}"
                     name="{$name}"
                     incremental="{$incremental}"
                     delay="{$incrementaldelay}"
                     tabindex="{$navindex}"
                     title="{normalize-space(xf:hint)}">

                    <xsl:if test="$accesskey != 'none'">
                        <xsl:attribute name="accessKey"><xsl:value-of select="$accesskey"/></xsl:attribute>
                    </xsl:if>
                    <!-- TODO: move mediatype to bf:data for all Controls -->
                    <xsl:if test="$lname='output' and exists(bf:data/@bf:mediatype)">
                        <xsl:attribute name="mediatype">
                            <xsl:value-of select="bf:data/@bf:mediatype"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="not($lname='output') and exists(@mediatype)">
                        <xsl:attribute name="mediatype">
                            <xsl:value-of select="@mediatype"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@appearance='caOPMLTree' or @appearance='caSimileTimeline'" >
                        <xsl:message select="@ref"/>
                        <xsl:variable name="tmpInstanceId1"><xsl:value-of select="substring(@ref,11,string-length(@ref))"/></xsl:variable>
                        <xsl:variable name="tmpInstanceId2"><xsl:value-of select="substring-before($tmpInstanceId1,')')"/></xsl:variable>
                        <xsl:variable name="instanceId"><xsl:value-of select="substring($tmpInstanceId2,1,string-length($tmpInstanceId2)-1)"/></xsl:variable>
                        <xsl:variable name="modelId"><xsl:value-of select="//xf:model[//xf:instance/@id=$instanceId]/@id"/></xsl:variable>

                        <xsl:attribute name="instanceId"><xsl:value-of select="$instanceId" /></xsl:attribute>
                        <xsl:attribute name="modelId"><xsl:value-of select="$modelId" /></xsl:attribute>
                    </xsl:if>

                    <xsl:choose>
                        <xsl:when test="contains(@mediatype,'text/html')">
                            <xsl:attribute name="tabindex" select="-1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="tabindex" select="$navindex"/>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:if test="$datatype !='string'">
                        <xsl:attribute name="schemaValue">
                            <xsl:value-of select="bf:data/@bf:schema-value"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$lname='upload'">
                        <xsl:attribute name="fileId">
                            <xsl:value-of select="xf:filename/@id"/>
                        </xsl:attribute>
                        <xsl:attribute name="fileValue">
                            <xsl:value-of select="xf:filename/bf:data"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="contains(@mediatype,'text/html')">
                            <xsl:value-of select="bf:data/text()" disable-output-escaping="yes"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="bf:data/text()"/>
                        </xsl:otherwise>
                    </xsl:choose>

                </div>
                <!--<div style="display:none;" id="{concat($id,'-hint')}"><xsl:value-of select="xf:hint"/></div>-->
            </xsl:when>


            <xsl:when test="local-name()='trigger'">
                <!--xsl:variable name="value" select="bf:data/text()"/-->
                <xsl:variable name="value">
                    <xsl:call-template name="create-label">
                        <xsl:with-param name="label-elements" select="xf:label"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="appearance" select="@appearance"/>

                <button
                     id="{concat(@id,'-value')}"
                     class="xfValue"
                     dataType="{$datatype}"
                     controlType="{local-name()}"
                     appearance="{$appearance}"
                     name="{$name}"
                     tabindex="{$navindex}"
                     value="{$value}"
                     title="{normalize-space(xf:hint)}"
                     type="button">
                    <xsl:if test="$accesskey != ' none'">
                        <xsl:attribute name="accessKey"><xsl:value-of select="$accesskey"/></xsl:attribute>
                    </xsl:if>
                </button>
                <!--<div style="display:none;" id="{concat($id,'-hint')}"><xsl:value-of select="xf:hint"/></div>-->
                <xsl:apply-templates select="xf:hint"/>
            </xsl:when>

            <xsl:when test="local-name()='range'">
                <xsl:variable name="value" select="bf:data/@bf:value"/>
                <xsl:variable name="start" select="bf:data/@bf:start"/>
                <xsl:variable name="end" select="bf:data/@bf:end"/>
                <xsl:variable name="step" select="bf:data/@bf:step"/>
                <xsl:variable name="appearance" select="@appearance"/>

                <div id="{concat(@id,'-value')}"
                     class="xfValue"
                     dataType="{$datatype}"
                     controlType="{local-name()}"
                     appearance="{$appearance}"
                     name="{$name}"
                     incremental="{$incremental}"
                     tabindex="{$navindex}"
                     start="{$start}"
                     end="{$end}"
                     step="{$step}"
                     value="{$value}"
                     title="{normalize-space(xf:hint)}">
                    <xsl:if test="$accesskey != ' none'">
                        <xsl:attribute name="accessKey"><xsl:value-of select="$accesskey"/></xsl:attribute>
                    </xsl:if>

<!--                  <ol dojoType="dijit.form.HorizontalRuleLabels" container="topDecoration"
                        style="height:1em;font-size:75%;color:gray;">
                        <xsl:if test="$start">
                            <li><xsl:value-of select="$start"/></li>
                            <li> </li>
                        </xsl:if>
                        <xsl:if test="$end">
                            <li><xsl:value-of select="$end"/></li>
                        </xsl:if>
                    </ol>-->
                </div>
            </xsl:when>
            <xsl:when test="local-name()='select'">
                <xsl:call-template name="select"/>
            </xsl:when>
            <xsl:when test="local-name()='select1'">
                <xsl:call-template name="select1"/>
            </xsl:when>
            <xsl:when test="local-name()='repeat'">
                <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:when test="local-name()='group'">
                <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:when test="local-name()='switch'">
                <xsl:apply-templates select="."/>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <!-- What's this?? -->
    <xsl:template match="pre">
        <span class="abc"/>
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
