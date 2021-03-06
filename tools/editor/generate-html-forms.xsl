<xsl:stylesheet version="2.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:xf="http://www.w3.org/2002/xforms"
                xmlns:ev="http://www.w3.org/2001/xml-events"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xf ev xsd" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>
    <xsl:output method="xhtml" indent="yes" name="xhtml" exclude-result-prefixes="xf"/>
    <!-- author: Joern Turner -->

    <xsl:template match="/">
        <div>
            <xsl:variable name="title"><xsl:value-of select="concat('Property Sheet ',//html:title)"/></xsl:variable>
            <xsl:message><xsl:value-of select="$title"/></xsl:message>
            <div class="propertyTitle"><xsl:value-of select="$title"/></div>
            <form method="post" action="#" enctype="application/x-www-form-urlencoded">
            <xsl:for-each select="//xf:bind">
                <xsl:variable name="attrName">
                    <xsl:choose>
                        <xsl:when test="starts-with(@nodeset,'@')">
                            <xsl:value-of select="substring-after(@nodeset,'@')"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="@nodeset"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:message>attrName is: <xsl:value-of select="$attrName"/> </xsl:message>
                <ul style="list-style-type:none;">
                    <li>
                        <div class="attrEditor">
                            <h4><label for="{$attrName}"><xsl:value-of select="$attrName"/></label></h4>
                            <p>hint text here</p>
                            <xsl:choose>
                                 <xsl:when test="$attrName='xml-event'"/>
                                 <xsl:when test="$attrName='event'">
                                     <select dojoType="dijit.form.FilteringSelect" selection="open" searchAttr="name" name="type" id="{$attrName}" value="" placeholder="" class="xf{$attrName} dojoSelect" >
                                         <xsl:attribute name="onblur">attrEditor.saveProperty(dojo.attr(dojo.byId('xfMount'),'xfId'),'<xsl:value-of select="$attrName"/>')</xsl:attribute>
                                         <xsl:for-each select="//xf:select1[@ref='@event']/xf:item">
                                            <option value="{xf:value}"><xsl:value-of select="xf:label"/></option>
                                         </xsl:for-each>
                                     </select>

                                 </xsl:when>
                                <xsl:when test="$attrName='type'">
                                    <input dojoType="dijit.form.FilteringSelect" store="stateStore" selection="open" searchAttr="name" name="type" id="{$attrName}" value="" placeholder="" class="xf{$attrName} dojoSelect">
                                        <xsl:attribute name="onblur">attrEditor.saveProperty(dojo.attr(dojo.byId('xfMount'),'xfId'),'<xsl:value-of select="$attrName"/>')</xsl:attribute>
                                    </input>
                                </xsl:when>
                                <xsl:otherwise>
                                    <input dojoType="dijit.form.TextBox" id="{$attrName}" name="{$attrName}" type="text" value="" placeholder="" class="xf{$attrName} dojoInput">
                                        <xsl:attribute name="onblur">attrEditor.saveProperty(dojo.attr(dojo.byId('xfMount'),'xfId'),'<xsl:value-of select="$attrName"/>')</xsl:attribute>
                                    </input>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </li>
                </ul>
            </xsl:for-each>
            </form>
        </div>
    </xsl:template>


</xsl:stylesheet>
