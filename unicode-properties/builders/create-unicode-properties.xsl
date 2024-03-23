<xsl:stylesheet
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:tan="tag:textalign.net,2015:ns" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:ucd="http://www.unicode.org/ns/2003/ucd/1.0"
   expand-text="yes"
   version="3.0">
   
   <!-- Builder of unicode-properties.xsl, as a prototype of how a full Unicode map might be 
      modeled as an XPath function or variable. -->
   <!-- Written March 2024 by Joel Kalvesmaki -->
   
   <!-- Primary (catalyzing) input: the template unicode-properties-template.xsl -->
   <!-- Secondary input: a Unicode Grouped XML database (tested on Unicode 15.1 grouped), some of the Unicode 
      character database files online -->
   <!-- Primary output: the input XSLT file fully fleshed out -->
   <!-- Secondary output: none -->
   
   <xsl:include href="../../../TAN/TAN-2022/functions/TAN-function-library.xsl"/>
   
   
   <!-- Should the property tree that is already in the XSLT template in the appropriate global value be used? If true, then we take up
      from there. Otherwise, we rebuild it. -->
   <xsl:param name="use-existing-property-tree" as="xs:boolean" select="true()"/>
   
   <xsl:variable name="ucd-grouped-url" as="xs:string"
      select="'file:/E:/unicode/ucd.all.grouped.15.1.xml'"/>
   
   <xsl:variable name="ucd-database" as="document-node()" select="doc($ucd-grouped-url)"/>
   
   
   <xsl:variable name="property-aliases-url" as="xs:string"
      select="'https://www.unicode.org/Public/UCD/latest/ucd/PropertyAliases.txt'"/>
   
   <xsl:variable name="relevant-property-aliases" as="xs:string*"
      select="unparsed-text-lines($property-aliases-url)[not(starts-with(., '#'))][contains(., ';')]"
   />

   <xsl:variable name="property-value-aliases-url" as="xs:string"
      select="'https://www.unicode.org/Public/UCD/latest/ucd/PropertyValueAliases.txt'"/>
   
   <xsl:variable name="relevant-property-value-aliases" as="xs:string*"
      select="unparsed-text-lines($property-value-aliases-url)[not(starts-with(., '#'))][contains(., ';')]"
   />
   
   <!-- Authority: https://www.unicode.org/reports/tr44/  2.3.3 Deprecated Properties -->
   <xsl:variable name="deprecated-properties" as="xs:string+"
      select="'Grapheme_Link', 'Hyphen', 'ISO_Comment', 'Expands_On_NFC', 'Expands_On_NFD', 'Expands_On_NFKC', 'Expands_On_NFKD', 'FC_NFKC_Closure'"
   />
   
   <!-- Some properties expect codepoint values, and do not show up in the value alias database. -->
   <xsl:variable name="properties-expecting-zero-or-one-codepoint-value" as="xs:string+"
      select="'bmg', 'bpb', 'kCompatibilityVariant'"/>
   <xsl:variable name="properties-expecting-one-codepoint-value" as="xs:string+"
      select="'EqUIdeo', 'scf', 'slc', 'stc', 'suc'"/>
   <xsl:variable name="properties-expecting-zero-or-more-codepoint-values" as="xs:string+"
      select="'NFKC_CF', 'NFKC_SCF', 'dm'"/>
   <xsl:variable name="properties-expecting-one-or-more-codepoint-values" as="xs:string+"
      select="'cf', 'lc', 'tc', 'uc'"/>
   <xsl:variable name="properties-expecting-zero-or-one-integer-value" as="xs:string+"
      select="'kAccountingNumeric', 'kOtherNumeric', 'kPrimaryNumeric'"/>
   <xsl:variable name="properties-expecting-zero-or-one-string-value" as="xs:string+"
      select="'Name_Alias', 'JSN', 'kIICore', 'kIRG_GSource', 'kIRG_HSource', 'kIRG_JSource', 'kIRG_KPSource', 'kIRG_KSource',
      'kIRG_MSource', 'kIRG_SSource', 'kIRG_TSource', 'kIRG_UKSource', 'kIRG_USource', 'kIRG_VSource', 'kRSUnicode', 'dt', 'na', 'na1',
      'nv', 'scx'"/>
   
   <xsl:variable name="properties-with-default-none" as="xs:string+" select="'EqUIdeo'"/>
   <xsl:variable name="properties-with-default-self" as="xs:string+" select="'NFKC_CF'"/>
   
   <xsl:variable name="property-tree-pass-1" as="element()">
      <property-tree>
         <xsl:if test="not($use-existing-property-tree)">
            <xsl:apply-templates select="$relevant-property-aliases" mode="build-property-tree">
               <xsl:sort/>
            </xsl:apply-templates>
         </xsl:if>
      </property-tree>
   </xsl:variable>
   
   <xsl:mode name="build-property-tree" on-no-match="shallow-skip"/>
   <xsl:template match=".[. instance of xs:string]" mode="build-property-tree">
      <xsl:variable name="property-names" as="xs:string+" select="distinct-values(tokenize(., '\s+;\s+'))"/>
      <xsl:variable name="property-values" as="xs:string*" select="
            $relevant-property-value-aliases[some $i in $property-names
               satisfies matches(., '^' || $i || '\s*;')]"/>
      <xsl:variable name="is-ccc" as="xs:boolean" select="$property-names = 'ccc'"/>
      
      <property>
         <xsl:for-each select="$property-names">
            <name>{.}</name>
         </xsl:for-each>
         <type/>
         <values>
            <xsl:for-each select="$property-values">
               <xsl:variable name="curr-tokenized" as="xs:string+" select="tokenize(., '\s*;\s*')"/>
               <xsl:choose>
                  <xsl:when test="$is-ccc">
                     <val class="{$curr-tokenized[2]}" short="{$curr-tokenized[3]}"
                        long="{$curr-tokenized[4]}"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <val short="{$curr-tokenized[2]}" long="{$curr-tokenized[3]}"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </values>
      </property>
   </xsl:template>
   
   <xsl:variable name="property-tree-pass-2" as="element()">
      <xsl:choose>
         <xsl:when test="$use-existing-property-tree">
            <xsl:copy-of select="/*/xsl:variable[@name eq 'fn4:property-tree']/*"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="$property-tree-pass-1" mode="refine-property-tree"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   
   <xsl:mode name="refine-property-tree" on-no-match="shallow-copy"/>
   
   <xsl:template match="property" priority="1" mode="refine-property-tree">
      <xsl:variable name="is-deprecated" as="xs:boolean" select="name = $deprecated-properties"/>
      <xsl:if test="not($is-deprecated)">
         <xsl:next-match/>
      </xsl:if>
   </xsl:template>
   
   <xsl:template match="property" mode="refine-property-tree">
      <xsl:variable name="short-vals" as="attribute()*" select="values/val/@short"/>
      <xsl:variable name="prop-type" as="xs:string">
         <xsl:choose>
            <xsl:when test="count(values/val) eq 2 and $short-vals = 'N' and $short-vals = 'Y'">boolean</xsl:when>
            <xsl:when test="name = $properties-expecting-zero-or-one-codepoint-value">codepoint?</xsl:when>
            <xsl:when test="name = $properties-expecting-one-codepoint-value">codepoint</xsl:when>
            <xsl:when test="name = $properties-expecting-zero-or-more-codepoint-values">codepoint*</xsl:when>
            <xsl:when test="name = $properties-expecting-one-or-more-codepoint-values">codepoint+</xsl:when>
            <xsl:when test="name = $properties-expecting-zero-or-one-integer-value">integer?</xsl:when>
            <xsl:when test="name = $properties-expecting-zero-or-one-string-value">string?</xsl:when>
            <xsl:otherwise>string</xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="names" as="element()+" select="name"/>
      <xsl:variable name="ucd-group-items" as="attribute()*" select="$ucd-database/*/ucd:repertoire/ucd:group/@*[name(.) = $names]"/>
      
      <xsl:variable name="values-in-ucd-not-in-property-alias" as="xs:string*"
         select="$ucd-group-items[not(. = $short-vals)] => distinct-values()"/>
      <xsl:variable name="values-in-property-alias-not-in-ucd" as="xs:string*"
         select="$short-vals[not(. = $ucd-group-items)] => distinct-values()"/>
      
      <xsl:if test="exists($values-in-ucd-not-in-property-alias)">
         <xsl:message
            select="'Property value options for ' || name[1] || ' in the XML UCD but not in the plain text UCD: ' || string-join($values-in-ucd-not-in-property-alias, ', ')"
         />
      </xsl:if>
      <!--<xsl:if test="exists($values-in-property-alias-not-in-ucd)">
         <xsl:message
            select="'Property value options for ' || name[1] || ' in the plain text UCD but not the XML UCD: ' || string-join($values-in-property-alias-not-in-ucd, ', ')"
         />
      </xsl:if>-->
      <xsl:if test="not(exists($ucd-group-items))">
         <xsl:message select="'No UCD XML entries found on the group level for ' || name[1]"/>
      </xsl:if>
      
      <xsl:variable name="most-frequent-value" as="xs:string?">
         <xsl:for-each-group select="$ucd-group-items" group-by=".">
            <xsl:sort select="sum(current-group() ! count(descendant::ucd:char))" order="descending"
            />
            <xsl:if test="position() eq 1 and string-length(current-grouping-key()) gt 0">
               <xsl:sequence select="current-grouping-key()"/>
            </xsl:if>
         </xsl:for-each-group> 
      </xsl:variable>
      
      <xsl:if test="exists($most-frequent-value) and exists($short-vals) and not(values/val/(@short, @class) = $most-frequent-value)">
         <xsl:message
            select="'Unable to locate ' || $most-frequent-value || ', the most frequent value for ' || name[1] || ' among: ' || string-join(values/val/@short, ', ')"
         />
      </xsl:if>
      
      <xsl:next-match>
         <xsl:with-param name="prop-type" tunnel="yes" select="$prop-type"/>
         <xsl:with-param name="most-frequent-value" tunnel="yes" select="$most-frequent-value"/>
      </xsl:next-match>
      
   </xsl:template>
   
   <xsl:template match="type" mode="refine-property-tree">
      <xsl:param name="prop-type" tunnel="yes" as="xs:string"/>
      <xsl:copy>
         <xsl:value-of select="$prop-type"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="val" mode="refine-property-tree">
      <xsl:param name="prop-type" tunnel="yes" as="xs:string"/>
      <xsl:param name="most-frequent-value" tunnel="yes" as="xs:string?"/>
      
      
      <xsl:variable name="is-most-frequent" as="xs:boolean" select="(@class, @short)[1] = $most-frequent-value"/>

      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:if test="$is-most-frequent">
            <xsl:attribute name="most-frequent"/>
         </xsl:if>
      </xsl:copy>
   </xsl:template>
   
   
   
   <xsl:variable name="pass-1" as="document-node()">
      <xsl:apply-templates select="/" mode="pass-1"/>
   </xsl:variable>
   
   <xsl:mode name="pass-1" on-no-match="shallow-copy"/>
   
   <xsl:template match="xsl:variable[@name='fn4:property-tree']" mode="pass-1">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:copy-of select="$property-tree-pass-2"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="xsl:variable[@name='fn4:unicode-property-map']/xsl:map" mode="pass-1">
      <xsl:copy>
         <xsl:apply-templates select="$ucd-database" mode="build-codepoint-map-entries"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:mode name="build-codepoint-map-entries" on-no-match="shallow-skip"/>
   
   
   <!-- It can be time-consuming to build the map; this parameter allows us to select what codepoints to build. -->
   <xsl:param name="build-only-these-codepoints-of-interest" as="xs:integer+" select="(1 to 127), 143, 163, 288, 768, 1160, 1641, 2418, 12994, 13122, 
      13378, 50466, 132162, 161282"/>
   
   <xsl:template match="ucd:char[@cp]" mode="build-codepoint-map-entries">
      <xsl:variable name="cp" as="xs:integer" select="tan:hex-to-dec(@cp)"/>
      <xsl:if test="$cp = $build-only-these-codepoints-of-interest">
         <xsl:element name="xsl:map-entry" namespace="http://www.w3.org/1999/XSL/Transform">
            <xsl:attribute name="use-when" select="'$codepoints-of-interest = ' || $cp"/>
            <xsl:attribute name="key" select="$cp"/>
            <xsl:element name="xsl:map" namespace="http://www.w3.org/1999/XSL/Transform">
               <xsl:apply-templates select="
                     for $i in (ancestor-or-self::*/@* ! name(.) => distinct-values())[. = $property-tree-pass-2//name]
                     return
                        ancestor-or-self::*[@*[name(.) eq $i]][1]/@*[name(.) eq $i]"
                  mode="build-codepoint-submap-entries">
                  <xsl:sort select="lower-case(name(.))"/>
                  <xsl:with-param name="curr-cp-hex" as="xs:string" select="@cp" tunnel="yes"/>
               </xsl:apply-templates>
               <!--<xsl:apply-templates select="ancestor-or-self::*/@*[name(.) = $property-tree-pass-2//name]" mode="build-codepoint-submap-entries">
                  <xsl:sort select="lower-case(name(.))"/>
               </xsl:apply-templates>-->
            </xsl:element>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   
   <xsl:mode name="build-codepoint-submap-entries" on-no-match="shallow-skip"/>
   
   <!-- Let ancestral attributes be overridden by their descendants -->
   <!-- Ignore attributes with no value, or with the '#' (reflexive reference to the codepoint itself) -->
   <xsl:template match="@*[string-length(.) lt 1] | @*[. eq '#']" priority="1" mode="build-codepoint-submap-entries"/>
   
   <xsl:template match="@*" mode="build-codepoint-submap-entries">
      <xsl:param name="curr-cp-hex" as="xs:string" tunnel="yes"/>
      
      <xsl:variable name="this-name" as="xs:string" select="name(.)"/>
      <xsl:variable name="this-val-norm" as="xs:string">
         <xsl:choose>
            <xsl:when test="$this-name = 'na' and contains(., '#')">
               <!-- The hash in a name is a request to replace with the hex codepoint value. -->
               <xsl:sequence select="replace(., '#', $curr-cp-hex)"/>
            </xsl:when>
            <xsl:when test="$this-name = 'dt' and matches(., '^[a-z]')">
               <!-- The XML file occasionally lowercases, esp. for property dt. -->
               <xsl:sequence select="upper-case(substring(., 1, 1)) || substring(., 2)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="."/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      

      <xsl:variable name="property-entry" as="element()" select="$property-tree-pass-2/property[name = $this-name]"/>
      <xsl:variable name="val-entry" as="element()?" select="$property-entry/values/val[(@short, @class) = $this-val-norm]"/>
      
      <xsl:variable name="is-most-frequent" as="xs:boolean" select="exists($val-entry/@most-frequent)
         or ($this-name = 'nv' and $this-val-norm = 'NaN')"/>
      
      <!--<xsl:message select="$this-val"/>
      <xsl:message select="$property-entry"/>-->
      <xsl:variable name="this-val-adjusted" as="xs:string">
         <xsl:choose>
            <xsl:when test="$property-entry/type = 'boolean' and $this-val-norm eq 'Y'">
               <xsl:sequence select="'true()'"/>
            </xsl:when>
            <xsl:when test="starts-with($property-entry/type, 'integer')">
               <xsl:sequence select="$this-val-norm"/>
            </xsl:when>
            <xsl:when test="starts-with($property-entry/type, 'codepoint')">
               <xsl:sequence
                  select="string-join(tokenize($this-val-norm) ! string(tan:hex-to-dec(.)), ', ')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="'''' || $this-val-norm || ''''"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
         <!-- Omit false boolean values -->
         <xsl:when test="$is-most-frequent"/>
         <xsl:when test="exists($property-entry/values/val) and not(exists($val-entry))">
            <xsl:message
               select="'Cannot find property ' || $this-name || ' with value ' || $this-val-norm"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="xsl:map-entry" namespace="http://www.w3.org/1999/XSL/Transform">
               <xsl:attribute name="key" select="'''' || $this-name || ''''"/>
               <xsl:attribute name="select" select="$this-val-adjusted"/>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   

   <xsl:variable name="pass-2" as="document-node()">
      <xsl:apply-templates select="$pass-1" mode="consolidate-submaps"/>
   </xsl:variable>
   
   <!-- TODO: implement; intended to do things for blocks that have repeated info, e.g., Private Use Area -->
   <xsl:mode name="consolidate-submaps" on-no-match="shallow-copy"/>


   <xsl:output indent="yes"/>
   <xsl:param name="diagnostics-on" static="yes" select="true()"/>
   <xsl:template match="/" use-when="$diagnostics-on">
      <diagnostics>
         <!--<properties count="{count($relevant-properties)}"/>-->
         <!--<xsl:copy-of select="$property-tree-pass-1"/>-->
         <xsl:copy-of select="$property-tree-pass-2"/>
         <!--<xsl:copy-of select="$pass-1"/>-->
         <!--<xsl:copy-of select="$pass-2"/>-->
      </diagnostics>
   </xsl:template>
   <xsl:template match="/" use-when="not($diagnostics-on)">
      <xsl:copy-of select="$pass-2"/>
   </xsl:template>
   
</xsl:stylesheet>