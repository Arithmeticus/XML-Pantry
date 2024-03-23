<xsl:stylesheet
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:ucd="http://www.unicode.org/ns/2003/ucd/1.0"
   xmlns:fn4="http://qt4cg.org/ns"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map"
   xmlns:tan="tag:textalign.net,2015:ns"
   expand-text="yes"
   exclude-result-prefixes="#all"
   version="3.0">

   <!-- Playground for testing fn4:unicode-properties() -->
   
   <!-- Primary (catalyzing) input: any XML file, including this one -->
   <!-- Secondary input: none -->
   <!-- Primary output: diagnostic tests -->
   <!-- Secondary output: none -->
   
   <xsl:include href="../src/unicode-properties.xsl"/>
   <!--<xsl:include href="../../../TAN/TAN-2022/functions/TAN-function-library.xsl"/>-->
   
   <xsl:output indent="yes"/>
   <xsl:variable name="curr-codepoints-of-interest" as="xs:integer+" select="65, 91"/>
   <xsl:variable name="maps-of-interest" as="map(*)*" select="$curr-codepoints-of-interest ! fn4:unicode-properties(.)"/>
   <xsl:template match="/">
      <diagnostics>
         <xsl:for-each select="$maps-of-interest">
            <xsl:variable name="curr-map" as="map(*)" select="."/>
            <xsl:element name="map-{position()}">
               <xsl:for-each select="map:keys($curr-map)">
                  <xsl:sort select="lower-case(.)"/>
                  <xsl:variable name="this-key" as="item()" select="."/>
                  <entry key="{$this-key}">{$curr-map($this-key)}</entry>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </diagnostics>
   </xsl:template>

</xsl:stylesheet>