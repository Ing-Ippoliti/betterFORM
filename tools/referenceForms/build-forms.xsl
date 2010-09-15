<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (c) 2010. betterForm Project - http://www.betterform.de
  ~ Licensed under the terms of BSD License
  -->
<!-- TODO:
        - create empty instance see Input

-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xf="http://www.w3.org/2002/xforms"
                xmlns:ev="http://www.w3.org/2001/xml-events"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xpath-default-namespace="">
    <xsl:output method="xhtml" version="1.0" encoding="UTF-8" media-type="text/xml"/>

    <!-- <xsl:strip-space elements="*"/> -->

    <xsl:variable name="samples" select="//samples"/>
    <xsl:variable name="content" select="//content"/>
    <xsl:variable name="models" select="//models/*"/>

    <xsl:template match="/">
        <html>
            <xsl:apply-templates/>
        </html>
    </xsl:template>
    
    <xsl:template match="title">
            <head>
                <xsl:apply-templates select="." mode="title"/>
            </head>    
    </xsl:template>

    <xsl:template match="title" mode="title">
        <title><xsl:value-of select="."/></title>
      
        <link rel="stylesheet" type="text/css" href="../../resources/scripts/dojox/highlight/resources/highlight.css"/>
        <link rel="stylesheet" type="text/css" href="../../resources/styles/reference.css"/>

        <script type="text/javascript">
            dojo.require("dojox.highlight");
            dojo.require("dojox.highlight.languages.xml");
            dojo.addOnLoad(function() {
            dojo.query("code").forEach(dojox.highlight.init);
            });

            dojo.require("dijit.form.Button");
            dojo.require("dijit.TitlePane");
            dojo.require('dijit.layout.ContentPane');
        </script>
    </xsl:template>

    <xsl:template match="page">
        <body class="soria inlineAlert" style="margin:30px;">
            <div id="xforms">
                <div style="display:none;">
                    <xsl:apply-templates mode="model"/>
                </div>
                <div class="pageintro">
                    <xsl:apply-templates mode="ui"/>
                </div>
                <xsl:apply-templates select="$content" mode="content"/>
            </div>
            <div style="text-align:right;" id="copyright">
                <a href="http://www.betterform.de"><img style="vertical-align:text-bottom; margin-right:5px;" src="../../images/betterform_icon16x16.png" alt="betterFORM project"/></a><span>&#xA9; 2010 betterFORM</span>
            </div>
        </body>
    </xsl:template>

    <xsl:template match="content" mode="model">
        <xsl:choose>
            <xsl:when test="string($models)">
               <xsl:copy-of select="./models/*"/>
                <!--
                <xsl:apply-templates select="$models" mode="existingModel"/>
                -->
            </xsl:when>
            <xsl:otherwise>
                <xf:model>
                    <xf:instance>
                        <data xmlns="">
                               <xsl:apply-templates select="$samples" mode="instance"/>
                        </data>
                    </xf:instance>
                    <xsl:apply-templates select="$samples" mode="bind"/>
                </xf:model>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <!--
    ######################################################################################################
                Mode instance
    ######################################################################################################
    -->
    <xsl:template match="xf:*" mode="instance" priority="20">
        <xsl:variable name="name" select="./@ref"/>
        <xsl:variable name="value" select="./@value"/>
        <xsl:if test="string($name)">
            <xsl:element name="{$name}" namespace="">
                <xsl:attribute name="constraint">true</xsl:attribute>
                <xsl:attribute name="readonly">false</xsl:attribute>
                <xsl:attribute name="required">true</xsl:attribute>
                <xsl:attribute name="relevant">true</xsl:attribute>
                <xsl:element name="value" namespace=""><xsl:value-of select="$value"/></xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:apply-templates mode="instance"/>
    </xsl:template>



    <!--
    ######################################################################################################
                Mode bind
    ######################################################################################################
    -->

    <!--
    ###############
       modelless
    ###############
    -->

    <xsl:template match="xf:*" mode="bind" priority="10">
        <xsl:choose>
            <xsl:when test="string($models)">
                <xf:bind nodeset="{./@ref}">
                    <xf:bind nodeset="value"
                             constraint="boolean-from-string(../@constraint)"
                             readonly="boolean-from-string(../@readonly)"
                             required="boolean-from-string(../@required)"
                             relevant="boolean-from-string(../@relevant)"/>

                    <xf:bind nodeset="@constraint" type="boolean"/>
                    <xf:bind nodeset="@readonly" type="boolean"/>
                    <xf:bind nodeset="@required" type="boolean"/>
                    <xf:bind nodeset="@relevant" type="boolean"/>
                </xf:bind>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="string(./@ref)">
                    <xsl:variable name="datatype">
                        <xsl:choose>
                            <xsl:when test="exists(./@datatype)">
                                <xsl:value-of select="./@datatype"/>
                            </xsl:when>
                            <xsl:otherwise>string</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xf:bind nodeset="{./@ref}">
                        <xf:bind nodeset="value"
                                 constraint="boolean-from-string(../@constraint)"
                                 readonly="boolean-from-string(../@readonly)"
                                 required="boolean-from-string(../@required)"
                                 relevant="boolean-from-string(../@relevant)"
                                 type="{$datatype}"/>

                        <xf:bind nodeset="@constraint" type="boolean"/>
                        <xf:bind nodeset="@readonly" type="boolean"/>
                        <xf:bind nodeset="@required" type="boolean"/>
                        <xf:bind nodeset="@relevant" type="boolean"/>
                    </xf:bind>
                </xsl:if>
                <xsl:apply-templates mode="bind"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    ####################
       existing Model
    ####################
    -->

    <xsl:template match="xf:model" mode="existingModel" priority="20">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="existingModel"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="xf:instance" mode="existingModel" priority="20">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="existingModel"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xf:bind" mode="existingModel" priority="20">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="*" mode="existingModel" priority="10">
        <xsl:variable name="name" select="name(.)"/>
        <xsl:variable name="constraint">
            <xsl:choose>
                <xsl:when test="exists(./@constraint)">
                    <xsl:value-of select="./@constraint"/>
                </xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="readonly">
            <xsl:choose>
                <xsl:when test="exists(./@readonly)">
                    <xsl:value-of select="./@readonly"/>
                </xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="required">
            <xsl:choose>
                <xsl:when test="exists(./@required)">
                    <xsl:value-of select="./@required"/>
                </xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="relevant">
            <xsl:choose>
                <xsl:when test="exists(./@relevant)">
                    <xsl:value-of select="./@relevant"/>
                </xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <xsl:element name="{$name}" namespace="">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="constraint"><xsl:value-of select="$constraint"/></xsl:attribute>
            <xsl:attribute name="readonly"><xsl:value-of select="$readonly"/></xsl:attribute>
            <xsl:attribute name="required"><xsl:value-of select="$required"/></xsl:attribute>
            <xsl:attribute name="relevant"><xsl:value-of select="$relevant"/></xsl:attribute>
            <xsl:apply-templates mode="existingModel"/>
        </xsl:element>
    </xsl:template>
    
    <!--
    ######################################################################################################
                Mode ui
    ######################################################################################################
    -->
    <xsl:template match="page/title" mode="ui">
        <div class="pagetitle"><xsl:copy-of select="*|text()"/></div>
    </xsl:template>

    <xsl:template match="page/description" mode="ui">
        <div class="Section">
            <div class="PageDescription">Description</div>
            <p>
            <xsl:value-of select="."/>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="page/references/w3c" mode="ui">
        <xsl:variable name="ref" select="./@ref"/>

        <table>
            <tr>
                <td rowspan="3"><a href="http://www.w3c.org" class="link" id="linkLogo" style="margin-right:25px;" target="_blank"><img id="logo" class="image" src="../../resources/images/w3c_home_nb.png" alt="W3C"/></a></td>
                <td style="color:#005A9C; font-size:16px;">XForms 1.1 Links</td>
            </tr>
            <tr>
                <td><a style="color:#005A9C;" href="http://www.w3.org/MarkUp/Forms/specs/XForms1.1/index-all.html#ui-{$ref}" target="_blank">Recommendation</a></td>
            </tr>
            <tr>
                <td><a style="color:#005A9C;" href="http://www.w3.org/MarkUp/Forms/2010/xforms11-qr.html#elems-form-controls" target="_blank">Quick Reference</a></td>
            </tr>
        </table>
    </xsl:template>

    <xsl:template match="page/specification" mode="ui">
        <xsl:variable name="link" select="./link"/>
        <xsl:variable name="description" select="./description"/>
        <div class="Section">
            <div class="PageDescription"><a style="color:#005A9C;" href="{$link}"><xsl:value-of select="$description"/></a>
            </div>
        </div>
    </xsl:template>

    <!--
    <xsl:template match="section" mode="ui">
            <div class="Section">
               <xsl:apply-templates select="." mode="section"/>
            </div>
    </xsl:template>
    -->
    <xsl:template match="section" mode="content">
        <div class="Section">
            <div class="Headline"><xsl:value-of select="./title"/></div>


            <p class="Description"><xsl:value-of select="./description"/></p>
            <div>
                <div class="Subheadline">XForms Markup</div>
                <div class="Subsection">
<pre><code class="xml">
    <xsl:apply-templates mode="codesectioninstance"/>
    <xsl:apply-templates mode="codesectionbind"/>
&lt;!--XForms UI--&gt;
<xsl:apply-templates mode="escape" select="./xf:*"/>
</code></pre>

                </div>
            </div>
            <div>
                <div class="Subheadline">Sample</div>
                <div class="Sample">
                    <xsl:apply-templates mode="samplesection"/>
                </div>

                <xsl:if test="not(string($models))">
                <div class="Subheadline">Modelitem properties</div>
                <div class="MIPS">
                     <xsl:apply-templates mode="modelitemsection"/>
                </div>
                </xsl:if>

                <xsl:if test="string($models) and string(./mips)">
                <div class="Subheadline">Modelitem properties</div>
                <div class="MIPS">
                     <xsl:copy-of select="./mips/*"/>
                </div>
                </xsl:if>

                <xsl:apply-templates mode="notes"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="mips" mode="codesectionxforms" priority="10"/>
    <xsl:template match="mips" mode="codesectionbind" priority="10"/>
    <xsl:template match="mips" mode="codesectioninstance" priority="10"/>

    <xsl:template match="xf:*" mode="codesectioninstance" priority="10">
        <xsl:if test="string(./@value)">
&lt;!--XForms Instance--&gt;
&lt;item&gt;<xsl:value-of select="./@value"/>&lt;/item&gt;
        </xsl:if>
    </xsl:template>

    <xsl:template match="xf:*" mode="codesectionbind" priority="10">
        <xsl:variable name="nodeset" select="./@ref"/>
        <xsl:variable name="datatype" select="./@datatype"/>

        <xsl:if test="string($datatype)">
&lt;!--XForms Bind--&gt;
&lt;xf:bind nodeset="<xsl:value-of select="$nodeset"/>" type="<xsl:value-of select="$datatype"/>"/&gt;
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="xf:*" mode="codesectionxforms" priority="10">
        <xsl:variable name="ref" select="./@ref"/>
        <xsl:variable name="name" select="name(.)"/>
        <xsl:variable name="text" select="text()"/>

        <xsl:choose>
            <xsl:when test="string($models)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$name}">
                    <xsl:copy-of select="./@*"/>
                    <xsl:if test="string($ref)">
                        <xsl:attribute name="ref">item</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="incremental" select="'true'"/>
                    <xsl:if test="string($text)">
                        <xsl:value-of select="$text"/>
                    </xsl:if>
                    <xsl:apply-templates mode="codesectionxforms"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="escape" priority="10">
<xsl:text>&lt;</xsl:text>
<xsl:value-of select="name()"/>
<xsl:apply-templates mode="escape" select="@*"/>
<xsl:text>&gt;</xsl:text>
<xsl:apply-templates mode="escape"/>
<xsl:text>&lt;/</xsl:text>
<xsl:value-of select="name()"/>
<xsl:text>&gt;</xsl:text>
    </xsl:template>

    <xsl:template match="@*" mode="escape" priority="10">
<xsl:text> </xsl:text>
<xsl:value-of select="name()"/>
<xsl:text>="</xsl:text>
<xsl:value-of select="."/>
<xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="mips" mode="samplesection" priority="10"/>

    <xsl:template match="xf:*" mode="samplesection" priority="10">
        <xsl:variable name="ref" select="./@ref"/>
        <xsl:variable name="name" select="name(.)"/>
        <xsl:variable name="text" select="text()"/>

        <xsl:choose>
            <xsl:when test="string($models)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$name}">
                    <xsl:copy-of select="./@*"/>
                    <xsl:if test="string($ref)">
                        <xsl:attribute name="id" select="$ref"/>
                    </xsl:if>
                    <xsl:if test="string($ref)">
                        <xsl:attribute name="ref" select="concat($ref, '/value')"/>
                    </xsl:if>

                    <xsl:if test="string-join($text, ' ')">
                        <xsl:value-of select="$text"/>
                    </xsl:if>
                    <xsl:apply-templates mode="samplesection"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="xf:*[@ref]" mode="modelitemsection" priority="10">
      <xsl:variable name="ref" select="./@ref"/>
        <xf:group appearance="full">
            <xf:label/>
            <xf:input id="{$ref}-readonly" navindex="-1" ref="{$ref}/@readonly" incremental="true">
                <xf:label>readonly</xf:label>
            </xf:input>
            <xf:input id="{$ref}-required" navindex="-1" ref="{$ref}/@required" incremental="true">
                <xf:label>required</xf:label>
            </xf:input>
            <xf:input id="{$ref}-relevant" navindex="-1" ref="{$ref}/@relevant" incremental="true">
                <xf:label>relevant</xf:label>
            </xf:input>
            <xf:input id="{$ref}-valid" navindex="-1" ref="{$ref}/@constraint" incremental="true">
                <xf:label>valid</xf:label>
            </xf:input>
        </xf:group>
    </xsl:template>

    <xsl:template match="notes" mode="notes" priority="10">
        <div class="Subheadline">Notes</div>
        <xsl:message><xsl:value-of select="."/></xsl:message>
        <xsl:copy-of select="./*"/>
    </xsl:template>

    <xsl:template match="text()" mode="instance"/>
    <xsl:template match="text()" mode="ui"/>
    <xsl:template match="text()" mode="section"/>
    <xsl:template match="text()" mode="codesectioninstance"/>
    <xsl:template match="text()" mode="codesectionbind"/> 
    <xsl:template match="text()" mode="codesectionxforms"/>
    <xsl:template match="text()" mode="notes"/>
    <xsl:template match="text()" mode="samplesection"/>
    <xsl:template match="text()" mode="modelitemsection"/>
    <xsl:template match="text()" mode="bind"/>
    <xsl:template match="text()" mode="modelbind"/>
    <xsl:template match="text()" mode="content"/>
    <xsl:template match="text()" mode="model"/>


</xsl:stylesheet>
