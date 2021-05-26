<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:tan="tag:textalign.net,2015:ns"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map"
   xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
   
   <!-- Hello, and welcome to my XML Pantry experiments on XSLT maps and arrays. This is the
      master template. Suggestions/criticisms are welcome, whether at the XML Slack channel, 
      the GitHub account, or directly, kalvesmaki@gmail.com -->
   
   <!-- Below are some examples of input/output run against functions I am developing for 
      map and array handling, to extend the functionality of the standard XPath 3.1 map 
      and array functions. I intend to deploy them in the 2021 alpha version of the 
      Text Alignment Network, http://textalign.net. The functions illustrate the utility 
      of approaching arrays and maps as invisible XML: treelike data structures. When 
      maps and arrays are shallow copied and shallow skipped like XML nodes good things 
      happen. Or so I argue below.
      -->
   
   <!-- Initial (catalyzing) input: any XML file, including this one -->
   <!-- Secondary input: none -->
   <!-- Primary output: experiment results -->
   <!-- Secondary output: none -->
   <!-- License: GNU General Public License, https://opensource.org/licenses/GPL-3.0 -->
   <!-- Updated 2021-05-26 -->
   
   
   <xsl:output indent="true"/>
   
   <!-- The primary functions are the ones in the arrays and maps subdirectory, with some extra
      help from the support functions -->
   <xsl:include href="arrays/TAN-fn-arrays-extended.xsl"/>
   <xsl:include href="maps/TAN-fn-maps-extended.xsl"/>
   <xsl:include href="support/support-functions.xsl"/>
   
   <!-- Here's our test candidate. Others might get added. -->
   <xsl:variable name="map-1" as="map(*)">
      <xsl:map>
         <xsl:map-entry key="current-dateTime()">
            <xsl:sequence select="
                  [
                     (), (array {1, 2, 3}),
                     map {
                        4: 'four',
                        5.5: true(),
                        false(): [6, (7, 8)]
                     }
                  ]"/>
         </xsl:map-entry>
         <xsl:map-entry key="4" select="'four again'"/>
      </xsl:map>
   </xsl:variable>
   
   <!-- Here we take the map and apply to it shallow copying that treats the map like a tree. 
      (In XSLT 3.0 the default mode shallow-copy actually deep copies the entire map or array.) -->
   <xsl:variable name="map-1-transformed" as="map(*)">
      <xsl:apply-templates select="$map-1" mode="tan:shallow-copy"/>
   </xsl:variable>
   
   <xsl:variable name="array-1" as="array(*)" select="[(), ('singleton'), ('double', 'ton'), ('tri', 'ple', 'ton'), [[], []]]"/>
   
   <!-- There's a fallback default template. This one simply overrides it for a particular
      member in the test map. -->
   <xsl:template match=".[. instance of array(*)][.(1) = 6]" mode="tan:shallow-copy">
      <!-- One advantage to doing shallow copying on maps and arrays qua tree structures is
         that you can pass tunnel parameters to keep track of the line of inheritance.
         That allows you to program choose-when-otherwise branches based on array member 
         numbers or map entry keys as if they were the names of ancestor elements. See
         below for an example.
            This resembles saxon:pedigree(), 
         https://www.saxonica.com/html/documentation10/functions/saxon/pedigree.html
         but provides the entire thread of inheritance as two sequences, mainly because
         I personally find it easier to write and read predicates/XPath expressions against
         sequences than I do on arrays and maps. These two tunnel parameters are, at this 
         stage, mainly proofs of concept, and subject to change.
      -->
      <xsl:param name="array-member-numbers" as="xs:integer*" tunnel="yes"/>
      <xsl:param name="map-entry-keys" tunnel="yes" as="xs:anyAtomicType*"/>
      <xsl:sequence select="."/>
      <array-member-numbers><xsl:copy-of select="$array-member-numbers"/></array-member-numbers>
      <map-entry-keys><xsl:copy-of select="$map-entry-keys"/></map-entry-keys>
      <!-- Here's an example of using the tunnel parameters to test for inheritance. -->
      <xsl:if test="$map-entry-keys[1] eq current-dateTime()">
         <test>Yes, the topmost map entry that contains me has a key tied to the current dateTime, <xsl:value-of select="current-dateTime()"/></test>
      </xsl:if>
   </xsl:template>
   
   <xsl:template match="/">
      <diagnostics>
         <!-- Serialize the map and its arrays. It's nice to be able to read the maps and arrays in a tree structure. -->
         <map-1><xsl:copy-of select="tan:map-to-xml($map-1, true())"/></map-1>
         <!-- Here's the map, transformed using shallow copy -->
         <map-1-transformed><xsl:copy-of select="tan:map-to-xml($map-1-transformed, true())"/></map-1-transformed>
         <!-- Deep-fetch the keys of the map. This is a surrogate function to map:keys(),
            and uses the shallow-skip technique to fetch the keys deeply, even from maps
            that are embedded in an array embedded in the map. Both the standard and the 
            revised are show below. -->
         <map-1-keys-shallow><xsl:copy-of select="map:keys($map-1)"/></map-1-keys-shallow>
         <map-1-keys-deep><xsl:copy-of select="tan:map-keys($map-1)"/></map-1-keys-deep>
         <!-- A map can be converted to an array. -->
         <map-1-as-array><xsl:copy-of select="tan:array-to-xml(tan:map-to-array($map-1, true()))"/></map-1-as-array>
         <!-- And an array can be converted to a map -->
         <array-1-as-map><xsl:copy-of select="tan:map-to-xml(tan:array-to-map($array-1, false()))"/></array-1-as-map>
         <!-- You can toggle between maps and arrays. -->
         <map-1-to-array-back-to-map><xsl:copy-of select="tan:map-to-xml(tan:array-to-map(tan:map-to-array($map-1, false()), true()))"/></map-1-to-array-back-to-map>
         <!-- Using the shallow-copy method on maps, you can remove select entries deeply, even if enmeshed inside an array -->
         <map-remove><xsl:copy-of select="tan:map-to-xml(tan:map-remove($map-1, false()))"/></map-remove>
         
         <!-- map:put() alternatives -->
         <!-- So you want to put one or more map entries deeply into a target map? The standard map:put() 
            is primed only for top-level placements. But the shallow-copy technique, plus a couple of select
            parameters to determine where to make the placement, allows targeted placements.
         -->
         <!-- In this example, we put the new map entry not only into the topmost map, but in every descendant
            map. -->
         <map-1-put-entry-everywhere><xsl:copy-of select="tan:map-to-xml(tan:map-put($map-1, 4, 'woo hoo', 0, ()))"/></map-1-put-entry-everywhere>
         <!-- Now we put the new map entry only in the map of depth 2. -->
         <map-1-put-entry-at-depth-2><xsl:copy-of select="tan:map-to-xml(tan:map-put($map-1, 4, 'woo hoo', 2, ()))"/></map-1-put-entry-at-depth-2>
         <!-- Now we put the new map entry only in a map that has a key of the current date and time, at whatever depth. -->
         <map-1-put-entry-alongside-current-dateTime><xsl:copy-of select="tan:map-to-xml(tan:map-put($map-1, 4, 'woo hoo', 0, current-dateTime()))"/></map-1-put-entry-alongside-current-dateTime>
         <!-- If we specify a depth and key that doesn't exist, nothing happens. -->
         <map-1-put-entry-at-depth-2-alongside-current-dateTime><xsl:copy-of select="tan:map-to-xml(tan:map-put($map-1, 4, 'woo hoo', 2, current-dateTime()))"/></map-1-put-entry-at-depth-2-alongside-current-dateTime>
         <!-- There is a four-arity version of the function that lets us insert at one go all the map entries
            in a specified map. Here we insert the map inside itself, targeting any map that has a key of 5.5.
            In this example, inserting a map of depth 2 at depth 2 results in a map of depth 3. Note also that
            the level-2 map will have its entry with key 4 replaced. -->
         <map-1-put-own-map-entries-alongside-5-5><xsl:copy-of select="tan:map-to-xml(tan:map-put($map-1, $map-1, 0, 5.5))"/></map-1-put-own-map-entries-alongside-5-5>
         
         
         <!-- The examples above illustrate practical benefits I've gotten from incorporating
            these extended map functions in XSLT applications I've been writing. They merely 
            scratch the surface of what's possible, in my opinion. No doubt others can do much 
            better than I have, and I've probably not anticipated certain cases where errors 
            will be thrown. Let the examples above, and the function library itself, catalyze 
            your own ideas.
         -->
         
         
      </diagnostics>
   </xsl:template>
   
</xsl:stylesheet>