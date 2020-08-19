<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
    <!--This file illustrates how a dependent XSLT can be designed to permit self-refactoring, as
        desired. Imagine this stylesheet has been written primarily to provide a global variable to
        a larger package. Perhaps the global variable is under development, or it needs occasional
        maintenance/updating, and it would be a bad idea to do it by hand. The key is a static
        parameter that gets used by @use-when, both in a copy template and a template designed to
        rebuild the global variable. The catalyzing/main input is the XSLT file itself (that is,
        you're running this file against itself).--> 

    <!-- Do you want to refactor $my-complicated-map? -->
    <xsl:param name="refactor-var-my-complicated-map" static="yes" as="xs:boolean" select="true()"/>

    <xsl:template match="node() | @*" use-when="$refactor-var-my-complicated-map">
        <!-- This copy template ensures that the refactored stylesheet is preserved. Note
        the use of @use-when -->
        <xsl:if test="parent::document-node()">
            <!-- Make sure the root element starts at line 2. Of course, we could
            also just use <xsl:output> specifying indentation -->
            <xsl:value-of select="codepoints-to-string(10)"/>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsl:variable[@name = 'my-complicated-map']/xsl:map" use-when="$refactor-var-my-complicated-map">
        <!--The code below provides a simple example of what could be done. In the case that
            inspired this sample, I had to build a map with about 300 entries, based on programmatic
            querying of Unicode codepoints. I wrote a corresponding function that helped me build
            the map. I could have then gotten rid of the static variable and its scaffolding. But I
            opted to keep it, because the map might need to be refactored in light of future
            versions of Unicode.--> 
        <xsl:variable name="database" select="doc('some-file.xml')"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="$database//*[@xml:id]" group-by="@xml:id">
                <xsl:if test="count(current-group()) gt 1">
                    <xsl:message select="'There are ' || string(count(current-group())) || ' entries for ' || current-grouping-key() || '; retrieving only first one.'"/>
                </xsl:if>
                <xsl:element name="xsl:map-entry" namespace="http://www.w3.org/1999/XSL/Transform">
                    <xsl:attribute name="key">
                        <xsl:value-of select="codepoints-to-string(39) || current-grouping-key() || codepoints-to-string(39)"/>
                    </xsl:attribute>
                    <xsl:copy-of select="current-group()[1]"/>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

    <xsl:variable name="my-complicated-map" as="map(*)">
        <xsl:map><xsl:map-entry key="'a1'"><a xml:id="a1">
        <b/>
        <c/>
    </a></xsl:map-entry><xsl:map-entry key="'a2'"><a xml:id="a2">
        <b/>
        <c/>
    </a></xsl:map-entry></xsl:map>
    </xsl:variable>
</xsl:stylesheet>