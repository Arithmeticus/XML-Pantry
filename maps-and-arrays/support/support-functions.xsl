<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:tan="tag:textalign.net,2015:ns"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map"
   xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
   
   <!-- These are select functions from the TAN library, to support the tests on maps and arrays -->
   
   <xsl:function name="tan:duplicate-items" as="item()*" visibility="public">
      <!-- Input: any sequence of items -->
      <!-- Output: those items that appear in the sequence more than once -->
      <!-- This function parallels the standard fn:distinct-values() -->
      <xsl:param name="sequence" as="item()*"/>
      <xsl:for-each-group select="$sequence" group-by="tan:item-type(.)">
         <xsl:choose>
            <xsl:when test="current-grouping-key() = ('map', 'array', 'function')"/>
            <xsl:otherwise>
               <!-- Here a fingerprint function testing for deep equality would be good;
                  for now, we just use the item itself. -->
               <xsl:for-each-group select="current-group()" group-by=".">
                  <xsl:if test="count(current-group()) gt 1">
                     <xsl:sequence select="current-group()"/>
                  </xsl:if>
               </xsl:for-each-group> 
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each-group> 
   </xsl:function>
   
   <xsl:function name="tan:item-type" as="xs:string*" visibility="public">
      <!-- Input: any XML items -->
      <!-- Output: the type of each item -->
      <xsl:param name="xml-items" as="item()*"/>
      <xsl:for-each select="$xml-items">
         <xsl:choose>
            <xsl:when test=". instance of document-node()">document-node</xsl:when>
            <xsl:when test=". instance of comment()">comment</xsl:when>
            <xsl:when test=". instance of processing-instruction()"
               >processing-instruction</xsl:when>
            <xsl:when test=". instance of element()">element</xsl:when>
            <xsl:when test=". instance of attribute()">attribute</xsl:when>
            <xsl:when test=". instance of text()">text</xsl:when>
            <xsl:when test=". instance of map(*)">map</xsl:when>
            <xsl:when test=". instance of array(*)">array</xsl:when>
            <!--<xsl:when test=". instance of function(*)" use-when="$tan:advanced-processing-available">function</xsl:when>-->
            
            <!-- The atomic types below follows the sequence presented in the chart at 
               http://w3.org/TR/xmlschema11-2/#built-in-datatypes, but derived types are
               tested before the archetypes.
            -->
            
            <xsl:when test=". instance of xs:anyURI">xs:anyURI</xsl:when>
            <xsl:when test=". instance of xs:base64Binary">xs:base64Binary</xsl:when>
            <xsl:when test=". instance of xs:boolean">xs:boolean</xsl:when>
            <xsl:when test=". instance of xs:date">xs:date</xsl:when>
            <xsl:when test=". instance of xs:dateTime">xs:dateTime</xsl:when>
            <xsl:when test=". instance of xs:dateTimeStamp">xs:dateTimeStamp</xsl:when>
            
            <!-- derivation line #3 from decimal -->
            <xsl:when test=". instance of xs:negativeInteger">xs:negativeInteger</xsl:when>
            <xsl:when test=". instance of xs:nonPositiveInteger">xs:nonPositiveInteger</xsl:when>
            <!-- derivation line #2 from decimal -->
            <xsl:when test=". instance of xs:unsignedByte">xs:unsignedByte</xsl:when>
            <xsl:when test=". instance of xs:unsignedShort">xs:unsignedShort</xsl:when>
            <xsl:when test=". instance of xs:unsignedInt">xs:unsignedInt</xsl:when>
            <xsl:when test=". instance of xs:unsignedLong">xs:unsignedLong</xsl:when>
            <xsl:when test=". instance of xs:positiveInteger">xs:positiveInteger</xsl:when>
            <xsl:when test=". instance of xs:nonNegativeInteger">xs:nonNegativeInteger</xsl:when>
            <!-- derivation line #1 from decimal -->
            <xsl:when test=". instance of xs:byte">xs:byte</xsl:when>
            <xsl:when test=". instance of xs:short">xs:short</xsl:when>
            <xsl:when test=". instance of xs:int">xs:int</xsl:when>
            <xsl:when test=". instance of xs:long">xs:long</xsl:when>
            <xsl:when test=". instance of xs:integer">xs:integer</xsl:when>
            <!-- master -->
            <xsl:when test=". instance of xs:decimal">xs:decimal</xsl:when>
            
            <xsl:when test=". instance of xs:double">xs:double</xsl:when>
            
            <!-- derivation line #2 from duration -->
            <xsl:when test=". instance of xs:yearMonthDuration">xs:yearMonthDuration</xsl:when>
            <!-- derivation line #1 from duration -->
            <xsl:when test=". instance of xs:dayTimeDuration">xs:dayTimeDuration</xsl:when>
            <!-- master -->
            <xsl:when test=". instance of xs:duration">xs:duration</xsl:when>
            
            <xsl:when test=". instance of xs:float">xs:float</xsl:when>
            <xsl:when test=". instance of xs:gDay">xs:gDay</xsl:when>
            <xsl:when test=". instance of xs:gMonth">xs:gMonth</xsl:when>
            <xsl:when test=". instance of xs:gMonthDay">xs:gMonthDay</xsl:when>
            <xsl:when test=". instance of xs:gYear">xs:gYear</xsl:when>
            <xsl:when test=". instance of xs:gYearMonth">xs:gYearMonth</xsl:when>
            <xsl:when test=". instance of xs:hexBinary">xs:hexBinary</xsl:when>
            <xsl:when test=". instance of xs:NOTATION">xs:NOTATION</xsl:when>
            <xsl:when test=". instance of xs:QName">xs:QName</xsl:when>
            
            <!-- derivation line #1 from string -->
            <xsl:when test=". instance of xs:NMTOKEN">xs:NMTOKEN</xsl:when>
            <xsl:when test=". instance of xs:IDREF">xs:IDREF</xsl:when>
            <xsl:when test=". instance of xs:ID">xs:ID</xsl:when>
            <xsl:when test=". instance of xs:ENTITY">xs:ENTITY</xsl:when>
            <xsl:when test=". instance of xs:NCName">xs:NCName</xsl:when>
            <xsl:when test=". instance of xs:Name">xs:Name</xsl:when>
            <xsl:when test=". instance of xs:language">xs:language</xsl:when>
            <xsl:when test=". instance of xs:token">xs:token</xsl:when>
            <xsl:when test=". instance of xs:normalizedString">xs:normalizedString</xsl:when>
            <!-- master -->
            <xsl:when test=". instance of xs:string">xs:string</xsl:when>
            
            <xsl:when test=". instance of xs:time">xs:time</xsl:when>
            
            <xsl:when test=". instance of xs:untypedAtomic">xs:untypedAtomic</xsl:when>
            
            <xsl:otherwise>undefined</xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:function>
   
</xsl:stylesheet>