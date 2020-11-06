<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:pan="tag:kalvesmaki@gmail.com,2015:ns"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map"
   version="3.0">
   
   <!-- Test XSLT to build a function that finds the deepest node in a tree -->
   <!-- The benefit of this approach is that you can build a map that will let you
   do more than just find the deepest nodes. With the dependent function 
   pan:depth-map() you can build other functions to do other things, e.g., find all
   nodes whose depths are odd, or prime. -->
   
   <!-- Primary (catalyzing) input: any XML file (including this one) -->
   <!-- Secondary input: none -->
   <!-- Primary output: diagnostics -->
   <!-- Secondary output: none -->
   
   <xsl:function name="pan:depth-map" as="map(*)">
      <!-- Input: any items -->
      <!-- Output: a map of depths on the items -->
      <xsl:param name="trees" as="item()*"/>
      <xsl:map>
         <xsl:apply-templates select="$trees" mode="depth-map"/>
      </xsl:map>
   </xsl:function>
   <xsl:mode name="depth-map" on-no-match="shallow-skip"/>
   <xsl:template match="node()" mode="depth-map">
      <xsl:param name="parent-depth" as="xs:integer" select="0"/>
      <xsl:variable name="this-depth" select="$parent-depth + 1"/>
      <xsl:map-entry key="generate-id(.)" select="$this-depth"/>
      <xsl:apply-templates mode="#current">
         <xsl:with-param name="parent-depth" select="$this-depth"/>
      </xsl:apply-templates>
   </xsl:template>
   
   <xsl:function name="pan:find-deepest" as="node()*">
      <!-- Input: any items -->
      <!-- Output: those items that are deepest in the tree -->
      <xsl:param name="trees" as="item()*"/>
      <xsl:variable name="this-depth-map" as="map(*)" select="pan:depth-map($trees)"/>
      <xsl:variable name="these-depth-map-keys" select="map:keys($this-depth-map)"/>
      <xsl:variable name="these-deepest-node-ids" as="xs:string*">
         <xsl:for-each-group select="$these-depth-map-keys" group-by="$this-depth-map(.)">
            <xsl:sort select="current-grouping-key()" order="descending"/>
            <xsl:if test="position() eq 1">
               <xsl:sequence select="current-group()"/>
            </xsl:if>
         </xsl:for-each-group> 
      </xsl:variable>
      
      <xsl:variable name="diagnostics-on" select="true()"/>
      <xsl:if test="$diagnostics-on">
         <xsl:message select="'diagnostics on for pan:find-deepest()'"/>
         <xsl:message select="'Depth map keys: ' || string-join($these-depth-map-keys, ' ')"/>
         <xsl:message
            select="
               'key-value pairs: ' || string-join(for $i in $these-depth-map-keys
               return
                  $i || ':' || string($this-depth-map($i)), ' ')"
         />
         <xsl:message select="'Deepest node ids: ' || string-join($these-deepest-node-ids, ' ')"/>
      </xsl:if>
      
      <xsl:sequence select="$trees//node()[generate-id(.) = $these-deepest-node-ids]"/>
   </xsl:function>
   
   <xsl:template match="/">
      <diagnostics>
         <deepest><xsl:copy-of select="pan:find-deepest(/)"/></deepest>
      </diagnostics>
   </xsl:template>
   
   
</xsl:stylesheet>