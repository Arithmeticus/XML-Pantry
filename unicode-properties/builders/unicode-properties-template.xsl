<xsl:stylesheet
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:ucd="http://www.unicode.org/ns/2003/ucd/1.0"
   xmlns:fn4="http://qt4cg.org/ns"
   xmlns:map="http://www.w3.org/2005/xpath-functions/map"
   expand-text="yes"
   version="3.0">
   
   <!-- Unicode-properties.xsl, a prototype of how a full Unicode map might be 
      modeled as an XPath function or variable. -->
   <!-- Written March 2024 by Joel Kalvesmaki -->
   
   <!-- This stylesheet was written exclusively to be imported, not to be in itself a primary/main
      stylesheet. -->
   
   <!-- Primary (catalyzing) input: none -->
   <!-- Secondary input: none -->
   <!-- Primary output: none -->
   <!-- Secondary output: none -->
   
   
   <!-- The following static parameter is meant to provide an approximation of how a processor, in optimization, might
      reduce the underlying master map to only what is needed. -->
   <xsl:param name="codepoints-of-interest" static="yes" as="xs:integer*" select="1 to 127"/>
   <!-- 
      
      FUNCTION PROTOTYPE
      
   -->
   <xsl:function name="fn4:unicode-properties" visibility="public" as="map(*)?" cache="yes">
      <!-- Input: any integer, representing the decimal value of a Unicode codepoint. -->
      <!-- Output: a map, each of whose entries consists of a string key identifying a unicode property and 
         a typed value specifying the value of that property for the given codepoint.
      -->
      <!-- This function is currently designed to model how an XPath 4.0 function might work. -->
      <xsl:param name="codepoint" as="xs:integer"/>
      
      <xsl:choose>
         <xsl:when test="$codepoint = $fn4:unicode-property-map-codepoint-keys">
            <xsl:variable name="curr-map" select="$fn4:unicode-property-map($codepoint)"/>
            
            <!-- When you get back a map, you should be able to retrieve a property given its short or long values. If you ask for a property 
               name that doesn't exist in Unicode, then you should get an error. Otherwise you should get the null value of the property is 
               ignorable. Otherwise you should get the property itself. -->
            <xsl:apply-templates select="$fn4:property-tree" mode="expand-map">
               <xsl:with-param name="curr-map" tunnel="yes" select="$curr-map"/>
               <xsl:with-param name="curr-cp" tunnel="yes" select="$codepoint"/>
            </xsl:apply-templates>
         </xsl:when>
         <xsl:when test="$codepoint instance of xs:integer">
            <xsl:message>Codepoint {$codepoint} not in master map.</xsl:message>
         </xsl:when>
      </xsl:choose>
      
      
   </xsl:function>
   <!-- The following variable memoizes all Unicode codepoint properties. For each property there is provided aliases, type, 
      and sometimes possible values. The variable exists mainly to help build and rebuild this stylesheet, because the 
      information is an important starting point to the build process, and it is somewhat time-consuming to assemble. -->
   <xsl:variable name="fn4:property-tree" as="element()">
      <property-tree xmlns:tan="tag:textalign.net,2015:ns">
         <property>
            <name>AHex</name>
            <name>ASCII_Hex_Digit</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Alpha</name>
            <name>Alphabetic</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Bidi_C</name>
            <name>Bidi_Control</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Bidi_M</name>
            <name>Bidi_Mirrored</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CE</name>
            <name>Composition_Exclusion</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CI</name>
            <name>Case_Ignorable</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CWCF</name>
            <name>Changes_When_Casefolded</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CWCM</name>
            <name>Changes_When_Casemapped</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CWKCF</name>
            <name>Changes_When_NFKC_Casefolded</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CWL</name>
            <name>Changes_When_Lowercased</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CWT</name>
            <name>Changes_When_Titlecased</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>CWU</name>
            <name>Changes_When_Uppercased</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Cased</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Comp_Ex</name>
            <name>Full_Composition_Exclusion</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>DI</name>
            <name>Default_Ignorable_Code_Point</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Dash</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Dep</name>
            <name>Deprecated</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Dia</name>
            <name>Diacritic</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>EBase</name>
            <name>Emoji_Modifier_Base</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>EComp</name>
            <name>Emoji_Component</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>EMod</name>
            <name>Emoji_Modifier</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>EPres</name>
            <name>Emoji_Presentation</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Emoji</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>EqUIdeo</name>
            <name>Equivalent_Unified_Ideograph</name>
            <type>codepoint</type>
            <values/>
         </property>
         <property>
            <name>Ext</name>
            <name>Extender</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>ExtPict</name>
            <name>Extended_Pictographic</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>GCB</name>
            <name>Grapheme_Cluster_Break</name>
            <type>string</type>
            <values>
               <val short="CN" long="Control" most-frequent=""/>
               <val short="CR" long="CR"/>
               <val short="EB" long="E_Base"/>
               <val short="EBG" long="E_Base_GAZ"/>
               <val short="EM" long="E_Modifier"/>
               <val short="EX" long="Extend"/>
               <val short="GAZ" long="Glue_After_Zwj"/>
               <val short="L" long="L"/>
               <val short="LF" long="LF"/>
               <val short="LV" long="LV"/>
               <val short="LVT" long="LVT"/>
               <val short="PP" long="Prepend"/>
               <val short="RI" long="Regional_Indicator"/>
               <val short="SM" long="SpacingMark"/>
               <val short="T" long="T"/>
               <val short="V" long="V"/>
               <val short="XX" long="Other"/>
               <val short="ZWJ" long="ZWJ"/>
            </values>
         </property>
         <property>
            <name>Gr_Base</name>
            <name>Grapheme_Base</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Gr_Ext</name>
            <name>Grapheme_Extend</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Hex</name>
            <name>Hex_Digit</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>IDC</name>
            <name>ID_Continue</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>IDS</name>
            <name>ID_Start</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>IDSB</name>
            <name>IDS_Binary_Operator</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>IDST</name>
            <name>IDS_Trinary_Operator</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>IDSU</name>
            <name>IDS_Unary_Operator</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>ID_Compat_Math_Continue</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>ID_Compat_Math_Start</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Ideo</name>
            <name>Ideographic</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>InCB</name>
            <name>Indic_Conjunct_Break</name>
            <type>string</type>
            <values>
               <val short="Consonant" long="Consonant"/>
               <val short="Extend" long="Extend"/>
               <val short="Linker" long="Linker"/>
               <val short="None" long="None" most-frequent=""/>
            </values>
         </property>
         <property>
            <name>InPC</name>
            <name>Indic_Positional_Category</name>
            <type>string</type>
            <values>
               <val short="Bottom" long="Bottom"/>
               <val short="Bottom_And_Left" long="Bottom_And_Left"/>
               <val short="Bottom_And_Right" long="Bottom_And_Right"/>
               <val short="Left" long="Left"/>
               <val short="Left_And_Right" long="Left_And_Right"/>
               <val short="NA" long="NA" most-frequent=""/>
               <val short="Overstruck" long="Overstruck"/>
               <val short="Right" long="Right"/>
               <val short="Top" long="Top"/>
               <val short="Top_And_Bottom" long="Top_And_Bottom"/>
               <val short="Top_And_Bottom_And_Left" long="Top_And_Bottom_And_Left"/>
               <val short="Top_And_Bottom_And_Right" long="Top_And_Bottom_And_Right"/>
               <val short="Top_And_Left" long="Top_And_Left"/>
               <val short="Top_And_Left_And_Right" long="Top_And_Left_And_Right"/>
               <val short="Top_And_Right" long="Top_And_Right"/>
               <val short="Visual_Order_Left" long="Visual_Order_Left"/>
            </values>
         </property>
         <property>
            <name>InSC</name>
            <name>Indic_Syllabic_Category</name>
            <type>string</type>
            <values>
               <val short="Avagraha" long="Avagraha"/>
               <val short="Bindu" long="Bindu"/>
               <val short="Brahmi_Joining_Number" long="Brahmi_Joining_Number"/>
               <val short="Cantillation_Mark" long="Cantillation_Mark"/>
               <val short="Consonant" long="Consonant"/>
               <val short="Consonant_Dead" long="Consonant_Dead"/>
               <val short="Consonant_Final" long="Consonant_Final"/>
               <val short="Consonant_Head_Letter" long="Consonant_Head_Letter"/>
               <val short="Consonant_Initial_Postfixed" long="Consonant_Initial_Postfixed"/>
               <val short="Consonant_Killer" long="Consonant_Killer"/>
               <val short="Consonant_Medial" long="Consonant_Medial"/>
               <val short="Consonant_Placeholder" long="Consonant_Placeholder"/>
               <val short="Consonant_Preceding_Repha" long="Consonant_Preceding_Repha"/>
               <val short="Consonant_Prefixed" long="Consonant_Prefixed"/>
               <val short="Consonant_Subjoined" long="Consonant_Subjoined"/>
               <val short="Consonant_Succeeding_Repha" long="Consonant_Succeeding_Repha"/>
               <val short="Consonant_With_Stacker" long="Consonant_With_Stacker"/>
               <val short="Gemination_Mark" long="Gemination_Mark"/>
               <val short="Invisible_Stacker" long="Invisible_Stacker"/>
               <val short="Joiner" long="Joiner"/>
               <val short="Modifying_Letter" long="Modifying_Letter"/>
               <val short="Non_Joiner" long="Non_Joiner"/>
               <val short="Nukta" long="Nukta"/>
               <val short="Number" long="Number"/>
               <val short="Number_Joiner" long="Number_Joiner"/>
               <val short="Other" long="Other" most-frequent=""/>
               <val short="Pure_Killer" long="Pure_Killer"/>
               <val short="Register_Shifter" long="Register_Shifter"/>
               <val short="Syllable_Modifier" long="Syllable_Modifier"/>
               <val short="Tone_Letter" long="Tone_Letter"/>
               <val short="Tone_Mark" long="Tone_Mark"/>
               <val short="Virama" long="Virama"/>
               <val short="Visarga" long="Visarga"/>
               <val short="Vowel" long="Vowel"/>
               <val short="Vowel_Dependent" long="Vowel_Dependent"/>
               <val short="Vowel_Independent" long="Vowel_Independent"/>
            </values>
         </property>
         <property>
            <name>JSN</name>
            <name>Jamo_Short_Name</name>
            <type>string?</type>
            <values>
               <val short="A" long="A"/>
               <val short="AE" long="AE"/>
               <val short="B" long="B"/>
               <val short="BB" long="BB"/>
               <val short="BS" long="BS"/>
               <val short="C" long="C"/>
               <val short="D" long="D"/>
               <val short="DD" long="DD"/>
               <val short="E" long="E"/>
               <val short="EO" long="EO"/>
               <val short="EU" long="EU"/>
               <val short="G" long="G"/>
               <val short="GG" long="GG"/>
               <val short="GS" long="GS"/>
               <val short="H" long="H"/>
               <val short="I" long="I"/>
               <val short="J" long="J"/>
               <val short="JJ" long="JJ"/>
               <val short="K" long="K"/>
               <val short="L" long="L"/>
               <val short="LB" long="LB"/>
               <val short="LG" long="LG"/>
               <val short="LH" long="LH"/>
               <val short="LM" long="LM"/>
               <val short="LP" long="LP"/>
               <val short="LS" long="LS"/>
               <val short="LT" long="LT"/>
               <val short="M" long="M"/>
               <val short="N" long="N"/>
               <val short="NG" long="NG"/>
               <val short="NH" long="NH"/>
               <val short="NJ" long="NJ"/>
               <val short="O" long="O"/>
               <val short="OE" long="OE"/>
               <val short="P" long="P"/>
               <val short="R" long="R"/>
               <val short="S" long="S"/>
               <val short="SS" long="SS"/>
               <val short="T" long="T"/>
               <val short="U" long="U"/>
               <val short="WA" long="WA"/>
               <val short="WAE" long="WAE"/>
               <val short="WE" long="WE"/>
               <val short="WEO" long="WEO"/>
               <val short="WI" long="WI"/>
               <val short="YA" long="YA"/>
               <val short="YAE" long="YAE"/>
               <val short="YE" long="YE"/>
               <val short="YEO" long="YEO"/>
               <val short="YI" long="YI"/>
               <val short="YO" long="YO"/>
               <val short="YU" long="YU"/>
            </values>
         </property>
         <property>
            <name>Join_C</name>
            <name>Join_Control</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>LOE</name>
            <name>Logical_Order_Exception</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Lower</name>
            <name>Lowercase</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Math</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>NChar</name>
            <name>Noncharacter_Code_Point</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>NFC_QC</name>
            <name>NFC_Quick_Check</name>
            <type>string</type>
            <values>
               <val short="M" long="Maybe"/>
               <val short="N" long="No"/>
               <val short="Y" long="Yes" most-frequent=""/>
            </values>
         </property>
         <property>
            <name>NFD_QC</name>
            <name>NFD_Quick_Check</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No"/>
               <val short="Y" long="Yes" most-frequent=""/>
            </values>
         </property>
         <property>
            <name>NFKC_CF</name>
            <name>NFKC_Casefold</name>
            <type>codepoint*</type>
            <values/>
         </property>
         <property>
            <name>NFKC_QC</name>
            <name>NFKC_Quick_Check</name>
            <type>string</type>
            <values>
               <val short="M" long="Maybe"/>
               <val short="N" long="No"/>
               <val short="Y" long="Yes" most-frequent=""/>
            </values>
         </property>
         <property>
            <name>NFKC_SCF</name>
            <name>NFKC_Simple_Casefold</name>
            <type>codepoint*</type>
            <values/>
         </property>
         <property>
            <name>NFKD_QC</name>
            <name>NFKD_Quick_Check</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No"/>
               <val short="Y" long="Yes" most-frequent=""/>
            </values>
         </property>
         <property>
            <name>Name_Alias</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>OAlpha</name>
            <name>Other_Alphabetic</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>ODI</name>
            <name>Other_Default_Ignorable_Code_Point</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>OGr_Ext</name>
            <name>Other_Grapheme_Extend</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>OIDC</name>
            <name>Other_ID_Continue</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>OIDS</name>
            <name>Other_ID_Start</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>OLower</name>
            <name>Other_Lowercase</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>OMath</name>
            <name>Other_Math</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>OUpper</name>
            <name>Other_Uppercase</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>PCM</name>
            <name>Prepended_Concatenation_Mark</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Pat_Syn</name>
            <name>Pattern_Syntax</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Pat_WS</name>
            <name>Pattern_White_Space</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>QMark</name>
            <name>Quotation_Mark</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>RI</name>
            <name>Regional_Indicator</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Radical</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>SB</name>
            <name>Sentence_Break</name>
            <type>string</type>
            <values>
               <val short="AT" long="ATerm"/>
               <val short="CL" long="Close"/>
               <val short="CR" long="CR"/>
               <val short="EX" long="Extend"/>
               <val short="FO" long="Format"/>
               <val short="LE" long="OLetter"/>
               <val short="LF" long="LF"/>
               <val short="LO" long="Lower"/>
               <val short="NU" long="Numeric"/>
               <val short="SC" long="SContinue"/>
               <val short="SE" long="Sep"/>
               <val short="SP" long="Sp"/>
               <val short="ST" long="STerm"/>
               <val short="UP" long="Upper"/>
               <val short="XX" long="Other" most-frequent=""/>
            </values>
         </property>
         <property>
            <name>SD</name>
            <name>Soft_Dotted</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>STerm</name>
            <name>Sentence_Terminal</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Term</name>
            <name>Terminal_Punctuation</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>UIdeo</name>
            <name>Unified_Ideograph</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>Upper</name>
            <name>Uppercase</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>VS</name>
            <name>Variation_Selector</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>WB</name>
            <name>Word_Break</name>
            <type>string</type>
            <values>
               <val short="CR" long="CR"/>
               <val short="DQ" long="Double_Quote"/>
               <val short="EB" long="E_Base"/>
               <val short="EBG" long="E_Base_GAZ"/>
               <val short="EM" long="E_Modifier"/>
               <val short="EX" long="ExtendNumLet"/>
               <val short="Extend" long="Extend"/>
               <val short="FO" long="Format"/>
               <val short="GAZ" long="Glue_After_Zwj"/>
               <val short="HL" long="Hebrew_Letter"/>
               <val short="KA" long="Katakana"/>
               <val short="LE" long="ALetter"/>
               <val short="LF" long="LF"/>
               <val short="MB" long="MidNumLet"/>
               <val short="ML" long="MidLetter"/>
               <val short="MN" long="MidNum"/>
               <val short="NL" long="Newline"/>
               <val short="NU" long="Numeric"/>
               <val short="RI" long="Regional_Indicator"/>
               <val short="SQ" long="Single_Quote"/>
               <val short="WSegSpace" long="WSegSpace"/>
               <val short="XX" long="Other" most-frequent=""/>
               <val short="ZWJ" long="ZWJ"/>
            </values>
         </property>
         <property>
            <name>WSpace</name>
            <name>White_Space</name>
            <name>space</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>XIDC</name>
            <name>XID_Continue</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>XIDS</name>
            <name>XID_Start</name>
            <type>boolean</type>
            <values>
               <val short="N" long="No" most-frequent=""/>
               <val short="Y" long="Yes"/>
            </values>
         </property>
         <property>
            <name>age</name>
            <name>Age</name>
            <type>string</type>
            <values>
               <val short="1.1" long="V1_1" most-frequent=""/>
               <val short="2.0" long="V2_0"/>
               <val short="2.1" long="V2_1"/>
               <val short="3.0" long="V3_0"/>
               <val short="3.1" long="V3_1"/>
               <val short="3.2" long="V3_2"/>
               <val short="4.0" long="V4_0"/>
               <val short="4.1" long="V4_1"/>
               <val short="5.0" long="V5_0"/>
               <val short="5.1" long="V5_1"/>
               <val short="5.2" long="V5_2"/>
               <val short="6.0" long="V6_0"/>
               <val short="6.1" long="V6_1"/>
               <val short="6.2" long="V6_2"/>
               <val short="6.3" long="V6_3"/>
               <val short="7.0" long="V7_0"/>
               <val short="8.0" long="V8_0"/>
               <val short="9.0" long="V9_0"/>
               <val short="10.0" long="V10_0"/>
               <val short="11.0" long="V11_0"/>
               <val short="12.0" long="V12_0"/>
               <val short="12.1" long="V12_1"/>
               <val short="13.0" long="V13_0"/>
               <val short="14.0" long="V14_0"/>
               <val short="15.0" long="V15_0"/>
               <val short="15.1" long="V15_1"/>
               <val short="NA" long="Unassigned"/>
            </values>
         </property>
         <property>
            <name>bc</name>
            <name>Bidi_Class</name>
            <type>string</type>
            <values>
               <val short="AL" long="Arabic_Letter"/>
               <val short="AN" long="Arabic_Number"/>
               <val short="B" long="Paragraph_Separator"/>
               <val short="BN" long="Boundary_Neutral" most-frequent=""/>
               <val short="CS" long="Common_Separator"/>
               <val short="EN" long="European_Number"/>
               <val short="ES" long="European_Separator"/>
               <val short="ET" long="European_Terminator"/>
               <val short="FSI" long="First_Strong_Isolate"/>
               <val short="L" long="Left_To_Right"/>
               <val short="LRE" long="Left_To_Right_Embedding"/>
               <val short="LRI" long="Left_To_Right_Isolate"/>
               <val short="LRO" long="Left_To_Right_Override"/>
               <val short="NSM" long="Nonspacing_Mark"/>
               <val short="ON" long="Other_Neutral"/>
               <val short="PDF" long="Pop_Directional_Format"/>
               <val short="PDI" long="Pop_Directional_Isolate"/>
               <val short="R" long="Right_To_Left"/>
               <val short="RLE" long="Right_To_Left_Embedding"/>
               <val short="RLI" long="Right_To_Left_Isolate"/>
               <val short="RLO" long="Right_To_Left_Override"/>
               <val short="S" long="Segment_Separator"/>
               <val short="WS" long="White_Space"/>
            </values>
         </property>
         <property>
            <name>blk</name>
            <name>Block</name>
            <type>string</type>
            <values>
               <val short="Adlam" long="Adlam"/>
               <val short="Aegean_Numbers" long="Aegean_Numbers"/>
               <val short="Ahom" long="Ahom"/>
               <val short="Alchemical" long="Alchemical_Symbols"/>
               <val short="Alphabetic_PF" long="Alphabetic_Presentation_Forms"/>
               <val short="Anatolian_Hieroglyphs" long="Anatolian_Hieroglyphs"/>
               <val short="Ancient_Greek_Music" long="Ancient_Greek_Musical_Notation"/>
               <val short="Ancient_Greek_Numbers" long="Ancient_Greek_Numbers"/>
               <val short="Ancient_Symbols" long="Ancient_Symbols"/>
               <val short="Arabic" long="Arabic"/>
               <val short="Arabic_Ext_A" long="Arabic_Extended_A"/>
               <val short="Arabic_Ext_B" long="Arabic_Extended_B"/>
               <val short="Arabic_Ext_C" long="Arabic_Extended_C"/>
               <val short="Arabic_Math" long="Arabic_Mathematical_Alphabetic_Symbols"/>
               <val short="Arabic_PF_A" long="Arabic_Presentation_Forms_A"/>
               <val short="Arabic_PF_B" long="Arabic_Presentation_Forms_B"/>
               <val short="Arabic_Sup" long="Arabic_Supplement"/>
               <val short="Armenian" long="Armenian"/>
               <val short="Arrows" long="Arrows"/>
               <val short="ASCII" long="Basic_Latin" most-frequent=""/>
               <val short="Avestan" long="Avestan"/>
               <val short="Balinese" long="Balinese"/>
               <val short="Bamum" long="Bamum"/>
               <val short="Bamum_Sup" long="Bamum_Supplement"/>
               <val short="Bassa_Vah" long="Bassa_Vah"/>
               <val short="Batak" long="Batak"/>
               <val short="Bengali" long="Bengali"/>
               <val short="Bhaiksuki" long="Bhaiksuki"/>
               <val short="Block_Elements" long="Block_Elements"/>
               <val short="Bopomofo" long="Bopomofo"/>
               <val short="Bopomofo_Ext" long="Bopomofo_Extended"/>
               <val short="Box_Drawing" long="Box_Drawing"/>
               <val short="Brahmi" long="Brahmi"/>
               <val short="Braille" long="Braille_Patterns"/>
               <val short="Buginese" long="Buginese"/>
               <val short="Buhid" long="Buhid"/>
               <val short="Byzantine_Music" long="Byzantine_Musical_Symbols"/>
               <val short="Carian" long="Carian"/>
               <val short="Caucasian_Albanian" long="Caucasian_Albanian"/>
               <val short="Chakma" long="Chakma"/>
               <val short="Cham" long="Cham"/>
               <val short="Cherokee" long="Cherokee"/>
               <val short="Cherokee_Sup" long="Cherokee_Supplement"/>
               <val short="Chess_Symbols" long="Chess_Symbols"/>
               <val short="Chorasmian" long="Chorasmian"/>
               <val short="CJK" long="CJK_Unified_Ideographs"/>
               <val short="CJK_Compat" long="CJK_Compatibility"/>
               <val short="CJK_Compat_Forms" long="CJK_Compatibility_Forms"/>
               <val short="CJK_Compat_Ideographs" long="CJK_Compatibility_Ideographs"/>
               <val short="CJK_Compat_Ideographs_Sup"
                    long="CJK_Compatibility_Ideographs_Supplement"/>
               <val short="CJK_Ext_A" long="CJK_Unified_Ideographs_Extension_A"/>
               <val short="CJK_Ext_B" long="CJK_Unified_Ideographs_Extension_B"/>
               <val short="CJK_Ext_C" long="CJK_Unified_Ideographs_Extension_C"/>
               <val short="CJK_Ext_D" long="CJK_Unified_Ideographs_Extension_D"/>
               <val short="CJK_Ext_E" long="CJK_Unified_Ideographs_Extension_E"/>
               <val short="CJK_Ext_F" long="CJK_Unified_Ideographs_Extension_F"/>
               <val short="CJK_Ext_G" long="CJK_Unified_Ideographs_Extension_G"/>
               <val short="CJK_Ext_H" long="CJK_Unified_Ideographs_Extension_H"/>
               <val short="CJK_Ext_I" long="CJK_Unified_Ideographs_Extension_I"/>
               <val short="CJK_Radicals_Sup" long="CJK_Radicals_Supplement"/>
               <val short="CJK_Strokes" long="CJK_Strokes"/>
               <val short="CJK_Symbols" long="CJK_Symbols_And_Punctuation"/>
               <val short="Compat_Jamo" long="Hangul_Compatibility_Jamo"/>
               <val short="Control_Pictures" long="Control_Pictures"/>
               <val short="Coptic" long="Coptic"/>
               <val short="Coptic_Epact_Numbers" long="Coptic_Epact_Numbers"/>
               <val short="Counting_Rod" long="Counting_Rod_Numerals"/>
               <val short="Cuneiform" long="Cuneiform"/>
               <val short="Cuneiform_Numbers" long="Cuneiform_Numbers_And_Punctuation"/>
               <val short="Currency_Symbols" long="Currency_Symbols"/>
               <val short="Cypriot_Syllabary" long="Cypriot_Syllabary"/>
               <val short="Cypro_Minoan" long="Cypro_Minoan"/>
               <val short="Cyrillic" long="Cyrillic"/>
               <val short="Cyrillic_Ext_A" long="Cyrillic_Extended_A"/>
               <val short="Cyrillic_Ext_B" long="Cyrillic_Extended_B"/>
               <val short="Cyrillic_Ext_C" long="Cyrillic_Extended_C"/>
               <val short="Cyrillic_Ext_D" long="Cyrillic_Extended_D"/>
               <val short="Cyrillic_Sup" long="Cyrillic_Supplement"/>
               <val short="Deseret" long="Deseret"/>
               <val short="Devanagari" long="Devanagari"/>
               <val short="Devanagari_Ext" long="Devanagari_Extended"/>
               <val short="Devanagari_Ext_A" long="Devanagari_Extended_A"/>
               <val short="Diacriticals" long="Combining_Diacritical_Marks"/>
               <val short="Diacriticals_Ext" long="Combining_Diacritical_Marks_Extended"/>
               <val short="Diacriticals_For_Symbols"
                    long="Combining_Diacritical_Marks_For_Symbols"/>
               <val short="Diacriticals_Sup" long="Combining_Diacritical_Marks_Supplement"/>
               <val short="Dingbats" long="Dingbats"/>
               <val short="Dives_Akuru" long="Dives_Akuru"/>
               <val short="Dogra" long="Dogra"/>
               <val short="Domino" long="Domino_Tiles"/>
               <val short="Duployan" long="Duployan"/>
               <val short="Early_Dynastic_Cuneiform" long="Early_Dynastic_Cuneiform"/>
               <val short="Egyptian_Hieroglyph_Format_Controls"
                    long="Egyptian_Hieroglyph_Format_Controls"/>
               <val short="Egyptian_Hieroglyphs" long="Egyptian_Hieroglyphs"/>
               <val short="Elbasan" long="Elbasan"/>
               <val short="Elymaic" long="Elymaic"/>
               <val short="Emoticons" long="Emoticons"/>
               <val short="Enclosed_Alphanum" long="Enclosed_Alphanumerics"/>
               <val short="Enclosed_Alphanum_Sup" long="Enclosed_Alphanumeric_Supplement"/>
               <val short="Enclosed_CJK" long="Enclosed_CJK_Letters_And_Months"/>
               <val short="Enclosed_Ideographic_Sup" long="Enclosed_Ideographic_Supplement"/>
               <val short="Ethiopic" long="Ethiopic"/>
               <val short="Ethiopic_Ext" long="Ethiopic_Extended"/>
               <val short="Ethiopic_Ext_A" long="Ethiopic_Extended_A"/>
               <val short="Ethiopic_Ext_B" long="Ethiopic_Extended_B"/>
               <val short="Ethiopic_Sup" long="Ethiopic_Supplement"/>
               <val short="Geometric_Shapes" long="Geometric_Shapes"/>
               <val short="Geometric_Shapes_Ext" long="Geometric_Shapes_Extended"/>
               <val short="Georgian" long="Georgian"/>
               <val short="Georgian_Ext" long="Georgian_Extended"/>
               <val short="Georgian_Sup" long="Georgian_Supplement"/>
               <val short="Glagolitic" long="Glagolitic"/>
               <val short="Glagolitic_Sup" long="Glagolitic_Supplement"/>
               <val short="Gothic" long="Gothic"/>
               <val short="Grantha" long="Grantha"/>
               <val short="Greek" long="Greek_And_Coptic"/>
               <val short="Greek_Ext" long="Greek_Extended"/>
               <val short="Gujarati" long="Gujarati"/>
               <val short="Gunjala_Gondi" long="Gunjala_Gondi"/>
               <val short="Gurmukhi" long="Gurmukhi"/>
               <val short="Half_And_Full_Forms" long="Halfwidth_And_Fullwidth_Forms"/>
               <val short="Half_Marks" long="Combining_Half_Marks"/>
               <val short="Hangul" long="Hangul_Syllables"/>
               <val short="Hanifi_Rohingya" long="Hanifi_Rohingya"/>
               <val short="Hanunoo" long="Hanunoo"/>
               <val short="Hatran" long="Hatran"/>
               <val short="Hebrew" long="Hebrew"/>
               <val short="High_PU_Surrogates" long="High_Private_Use_Surrogates"/>
               <val short="High_Surrogates" long="High_Surrogates"/>
               <val short="Hiragana" long="Hiragana"/>
               <val short="IDC" long="Ideographic_Description_Characters"/>
               <val short="Ideographic_Symbols" long="Ideographic_Symbols_And_Punctuation"/>
               <val short="Imperial_Aramaic" long="Imperial_Aramaic"/>
               <val short="Indic_Number_Forms" long="Common_Indic_Number_Forms"/>
               <val short="Indic_Siyaq_Numbers" long="Indic_Siyaq_Numbers"/>
               <val short="Inscriptional_Pahlavi" long="Inscriptional_Pahlavi"/>
               <val short="Inscriptional_Parthian" long="Inscriptional_Parthian"/>
               <val short="IPA_Ext" long="IPA_Extensions"/>
               <val short="Jamo" long="Hangul_Jamo"/>
               <val short="Jamo_Ext_A" long="Hangul_Jamo_Extended_A"/>
               <val short="Jamo_Ext_B" long="Hangul_Jamo_Extended_B"/>
               <val short="Javanese" long="Javanese"/>
               <val short="Kaithi" long="Kaithi"/>
               <val short="Kaktovik_Numerals" long="Kaktovik_Numerals"/>
               <val short="Kana_Ext_A" long="Kana_Extended_A"/>
               <val short="Kana_Ext_B" long="Kana_Extended_B"/>
               <val short="Kana_Sup" long="Kana_Supplement"/>
               <val short="Kanbun" long="Kanbun"/>
               <val short="Kangxi" long="Kangxi_Radicals"/>
               <val short="Kannada" long="Kannada"/>
               <val short="Katakana" long="Katakana"/>
               <val short="Katakana_Ext" long="Katakana_Phonetic_Extensions"/>
               <val short="Kawi" long="Kawi"/>
               <val short="Kayah_Li" long="Kayah_Li"/>
               <val short="Kharoshthi" long="Kharoshthi"/>
               <val short="Khitan_Small_Script" long="Khitan_Small_Script"/>
               <val short="Khmer" long="Khmer"/>
               <val short="Khmer_Symbols" long="Khmer_Symbols"/>
               <val short="Khojki" long="Khojki"/>
               <val short="Khudawadi" long="Khudawadi"/>
               <val short="Lao" long="Lao"/>
               <val short="Latin_1_Sup" long="Latin_1_Supplement"/>
               <val short="Latin_Ext_A" long="Latin_Extended_A"/>
               <val short="Latin_Ext_Additional" long="Latin_Extended_Additional"/>
               <val short="Latin_Ext_B" long="Latin_Extended_B"/>
               <val short="Latin_Ext_C" long="Latin_Extended_C"/>
               <val short="Latin_Ext_D" long="Latin_Extended_D"/>
               <val short="Latin_Ext_E" long="Latin_Extended_E"/>
               <val short="Latin_Ext_F" long="Latin_Extended_F"/>
               <val short="Latin_Ext_G" long="Latin_Extended_G"/>
               <val short="Lepcha" long="Lepcha"/>
               <val short="Letterlike_Symbols" long="Letterlike_Symbols"/>
               <val short="Limbu" long="Limbu"/>
               <val short="Linear_A" long="Linear_A"/>
               <val short="Linear_B_Ideograms" long="Linear_B_Ideograms"/>
               <val short="Linear_B_Syllabary" long="Linear_B_Syllabary"/>
               <val short="Lisu" long="Lisu"/>
               <val short="Lisu_Sup" long="Lisu_Supplement"/>
               <val short="Low_Surrogates" long="Low_Surrogates"/>
               <val short="Lycian" long="Lycian"/>
               <val short="Lydian" long="Lydian"/>
               <val short="Mahajani" long="Mahajani"/>
               <val short="Mahjong" long="Mahjong_Tiles"/>
               <val short="Makasar" long="Makasar"/>
               <val short="Malayalam" long="Malayalam"/>
               <val short="Mandaic" long="Mandaic"/>
               <val short="Manichaean" long="Manichaean"/>
               <val short="Marchen" long="Marchen"/>
               <val short="Masaram_Gondi" long="Masaram_Gondi"/>
               <val short="Math_Alphanum" long="Mathematical_Alphanumeric_Symbols"/>
               <val short="Math_Operators" long="Mathematical_Operators"/>
               <val short="Mayan_Numerals" long="Mayan_Numerals"/>
               <val short="Medefaidrin" long="Medefaidrin"/>
               <val short="Meetei_Mayek" long="Meetei_Mayek"/>
               <val short="Meetei_Mayek_Ext" long="Meetei_Mayek_Extensions"/>
               <val short="Mende_Kikakui" long="Mende_Kikakui"/>
               <val short="Meroitic_Cursive" long="Meroitic_Cursive"/>
               <val short="Meroitic_Hieroglyphs" long="Meroitic_Hieroglyphs"/>
               <val short="Miao" long="Miao"/>
               <val short="Misc_Arrows" long="Miscellaneous_Symbols_And_Arrows"/>
               <val short="Misc_Math_Symbols_A" long="Miscellaneous_Mathematical_Symbols_A"/>
               <val short="Misc_Math_Symbols_B" long="Miscellaneous_Mathematical_Symbols_B"/>
               <val short="Misc_Pictographs" long="Miscellaneous_Symbols_And_Pictographs"/>
               <val short="Misc_Symbols" long="Miscellaneous_Symbols"/>
               <val short="Misc_Technical" long="Miscellaneous_Technical"/>
               <val short="Modi" long="Modi"/>
               <val short="Modifier_Letters" long="Spacing_Modifier_Letters"/>
               <val short="Modifier_Tone_Letters" long="Modifier_Tone_Letters"/>
               <val short="Mongolian" long="Mongolian"/>
               <val short="Mongolian_Sup" long="Mongolian_Supplement"/>
               <val short="Mro" long="Mro"/>
               <val short="Multani" long="Multani"/>
               <val short="Music" long="Musical_Symbols"/>
               <val short="Myanmar" long="Myanmar"/>
               <val short="Myanmar_Ext_A" long="Myanmar_Extended_A"/>
               <val short="Myanmar_Ext_B" long="Myanmar_Extended_B"/>
               <val short="Nabataean" long="Nabataean"/>
               <val short="Nag_Mundari" long="Nag_Mundari"/>
               <val short="Nandinagari" long="Nandinagari"/>
               <val short="NB" long="No_Block"/>
               <val short="New_Tai_Lue" long="New_Tai_Lue"/>
               <val short="Newa" long="Newa"/>
               <val short="NKo" long="NKo"/>
               <val short="Number_Forms" long="Number_Forms"/>
               <val short="Nushu" long="Nushu"/>
               <val short="Nyiakeng_Puachue_Hmong" long="Nyiakeng_Puachue_Hmong"/>
               <val short="OCR" long="Optical_Character_Recognition"/>
               <val short="Ogham" long="Ogham"/>
               <val short="Ol_Chiki" long="Ol_Chiki"/>
               <val short="Old_Hungarian" long="Old_Hungarian"/>
               <val short="Old_Italic" long="Old_Italic"/>
               <val short="Old_North_Arabian" long="Old_North_Arabian"/>
               <val short="Old_Permic" long="Old_Permic"/>
               <val short="Old_Persian" long="Old_Persian"/>
               <val short="Old_Sogdian" long="Old_Sogdian"/>
               <val short="Old_South_Arabian" long="Old_South_Arabian"/>
               <val short="Old_Turkic" long="Old_Turkic"/>
               <val short="Old_Uyghur" long="Old_Uyghur"/>
               <val short="Oriya" long="Oriya"/>
               <val short="Ornamental_Dingbats" long="Ornamental_Dingbats"/>
               <val short="Osage" long="Osage"/>
               <val short="Osmanya" long="Osmanya"/>
               <val short="Ottoman_Siyaq_Numbers" long="Ottoman_Siyaq_Numbers"/>
               <val short="Pahawh_Hmong" long="Pahawh_Hmong"/>
               <val short="Palmyrene" long="Palmyrene"/>
               <val short="Pau_Cin_Hau" long="Pau_Cin_Hau"/>
               <val short="Phags_Pa" long="Phags_Pa"/>
               <val short="Phaistos" long="Phaistos_Disc"/>
               <val short="Phoenician" long="Phoenician"/>
               <val short="Phonetic_Ext" long="Phonetic_Extensions"/>
               <val short="Phonetic_Ext_Sup" long="Phonetic_Extensions_Supplement"/>
               <val short="Playing_Cards" long="Playing_Cards"/>
               <val short="Psalter_Pahlavi" long="Psalter_Pahlavi"/>
               <val short="PUA" long="Private_Use_Area"/>
               <val short="Punctuation" long="General_Punctuation"/>
               <val short="Rejang" long="Rejang"/>
               <val short="Rumi" long="Rumi_Numeral_Symbols"/>
               <val short="Runic" long="Runic"/>
               <val short="Samaritan" long="Samaritan"/>
               <val short="Saurashtra" long="Saurashtra"/>
               <val short="Sharada" long="Sharada"/>
               <val short="Shavian" long="Shavian"/>
               <val short="Shorthand_Format_Controls" long="Shorthand_Format_Controls"/>
               <val short="Siddham" long="Siddham"/>
               <val short="Sinhala" long="Sinhala"/>
               <val short="Sinhala_Archaic_Numbers" long="Sinhala_Archaic_Numbers"/>
               <val short="Small_Forms" long="Small_Form_Variants"/>
               <val short="Small_Kana_Ext" long="Small_Kana_Extension"/>
               <val short="Sogdian" long="Sogdian"/>
               <val short="Sora_Sompeng" long="Sora_Sompeng"/>
               <val short="Soyombo" long="Soyombo"/>
               <val short="Specials" long="Specials"/>
               <val short="Sundanese" long="Sundanese"/>
               <val short="Sundanese_Sup" long="Sundanese_Supplement"/>
               <val short="Sup_Arrows_A" long="Supplemental_Arrows_A"/>
               <val short="Sup_Arrows_B" long="Supplemental_Arrows_B"/>
               <val short="Sup_Arrows_C" long="Supplemental_Arrows_C"/>
               <val short="Sup_Math_Operators" long="Supplemental_Mathematical_Operators"/>
               <val short="Sup_PUA_A" long="Supplementary_Private_Use_Area_A"/>
               <val short="Sup_PUA_B" long="Supplementary_Private_Use_Area_B"/>
               <val short="Sup_Punctuation" long="Supplemental_Punctuation"/>
               <val short="Sup_Symbols_And_Pictographs"
                    long="Supplemental_Symbols_And_Pictographs"/>
               <val short="Super_And_Sub" long="Superscripts_And_Subscripts"/>
               <val short="Sutton_SignWriting" long="Sutton_SignWriting"/>
               <val short="Syloti_Nagri" long="Syloti_Nagri"/>
               <val short="Symbols_And_Pictographs_Ext_A"
                    long="Symbols_And_Pictographs_Extended_A"/>
               <val short="Symbols_For_Legacy_Computing"
                    long="Symbols_For_Legacy_Computing"/>
               <val short="Syriac" long="Syriac"/>
               <val short="Syriac_Sup" long="Syriac_Supplement"/>
               <val short="Tagalog" long="Tagalog"/>
               <val short="Tagbanwa" long="Tagbanwa"/>
               <val short="Tags" long="Tags"/>
               <val short="Tai_Le" long="Tai_Le"/>
               <val short="Tai_Tham" long="Tai_Tham"/>
               <val short="Tai_Viet" long="Tai_Viet"/>
               <val short="Tai_Xuan_Jing" long="Tai_Xuan_Jing_Symbols"/>
               <val short="Takri" long="Takri"/>
               <val short="Tamil" long="Tamil"/>
               <val short="Tamil_Sup" long="Tamil_Supplement"/>
               <val short="Tangsa" long="Tangsa"/>
               <val short="Tangut" long="Tangut"/>
               <val short="Tangut_Components" long="Tangut_Components"/>
               <val short="Tangut_Sup" long="Tangut_Supplement"/>
               <val short="Telugu" long="Telugu"/>
               <val short="Thaana" long="Thaana"/>
               <val short="Thai" long="Thai"/>
               <val short="Tibetan" long="Tibetan"/>
               <val short="Tifinagh" long="Tifinagh"/>
               <val short="Tirhuta" long="Tirhuta"/>
               <val short="Toto" long="Toto"/>
               <val short="Transport_And_Map" long="Transport_And_Map_Symbols"/>
               <val short="UCAS" long="Unified_Canadian_Aboriginal_Syllabics"/>
               <val short="UCAS_Ext" long="Unified_Canadian_Aboriginal_Syllabics_Extended"/>
               <val short="UCAS_Ext_A"
                    long="Unified_Canadian_Aboriginal_Syllabics_Extended_A"/>
               <val short="Ugaritic" long="Ugaritic"/>
               <val short="Vai" long="Vai"/>
               <val short="Vedic_Ext" long="Vedic_Extensions"/>
               <val short="Vertical_Forms" long="Vertical_Forms"/>
               <val short="Vithkuqi" long="Vithkuqi"/>
               <val short="VS" long="Variation_Selectors"/>
               <val short="VS_Sup" long="Variation_Selectors_Supplement"/>
               <val short="Wancho" long="Wancho"/>
               <val short="Warang_Citi" long="Warang_Citi"/>
               <val short="Yezidi" long="Yezidi"/>
               <val short="Yi_Radicals" long="Yi_Radicals"/>
               <val short="Yi_Syllables" long="Yi_Syllables"/>
               <val short="Yijing" long="Yijing_Hexagram_Symbols"/>
               <val short="Zanabazar_Square" long="Zanabazar_Square"/>
               <val short="Znamenny_Music" long="Znamenny_Musical_Notation"/>
            </values>
         </property>
         <property>
            <name>bmg</name>
            <name>Bidi_Mirroring_Glyph</name>
            <type>codepoint?</type>
            <values/>
         </property>
         <property>
            <name>bpb</name>
            <name>Bidi_Paired_Bracket</name>
            <type>codepoint?</type>
            <values/>
         </property>
         <property>
            <name>bpt</name>
            <name>Bidi_Paired_Bracket_Type</name>
            <type>string</type>
            <values>
               <val short="c" long="Close"/>
               <val short="n" long="None" most-frequent=""/>
               <val short="o" long="Open"/>
            </values>
         </property>
         <property>
            <name>ccc</name>
            <name>Canonical_Combining_Class</name>
            <type>string</type>
            <values>
               <val class="0" short="NR" long="Not_Reordered" most-frequent=""/>
               <val class="1" short="OV" long="Overlay"/>
               <val class="6" short="HANR" long="Han_Reading"/>
               <val class="7" short="NK" long="Nukta"/>
               <val class="8" short="KV" long="Kana_Voicing"/>
               <val class="9" short="VR" long="Virama"/>
               <val class="10" short="CCC10" long="CCC10"/>
               <val class="11" short="CCC11" long="CCC11"/>
               <val class="12" short="CCC12" long="CCC12"/>
               <val class="13" short="CCC13" long="CCC13"/>
               <val class="14" short="CCC14" long="CCC14"/>
               <val class="15" short="CCC15" long="CCC15"/>
               <val class="16" short="CCC16" long="CCC16"/>
               <val class="17" short="CCC17" long="CCC17"/>
               <val class="18" short="CCC18" long="CCC18"/>
               <val class="19" short="CCC19" long="CCC19"/>
               <val class="20" short="CCC20" long="CCC20"/>
               <val class="21" short="CCC21" long="CCC21"/>
               <val class="22" short="CCC22" long="CCC22"/>
               <val class="23" short="CCC23" long="CCC23"/>
               <val class="24" short="CCC24" long="CCC24"/>
               <val class="25" short="CCC25" long="CCC25"/>
               <val class="26" short="CCC26" long="CCC26"/>
               <val class="27" short="CCC27" long="CCC27"/>
               <val class="28" short="CCC28" long="CCC28"/>
               <val class="29" short="CCC29" long="CCC29"/>
               <val class="30" short="CCC30" long="CCC30"/>
               <val class="31" short="CCC31" long="CCC31"/>
               <val class="32" short="CCC32" long="CCC32"/>
               <val class="33" short="CCC33" long="CCC33"/>
               <val class="34" short="CCC34" long="CCC34"/>
               <val class="35" short="CCC35" long="CCC35"/>
               <val class="36" short="CCC36" long="CCC36"/>
               <val class="84" short="CCC84" long="CCC84"/>
               <val class="91" short="CCC91" long="CCC91"/>
               <val class="103" short="CCC103" long="CCC103"/>
               <val class="107" short="CCC107" long="CCC107"/>
               <val class="118" short="CCC118" long="CCC118"/>
               <val class="122" short="CCC122" long="CCC122"/>
               <val class="129" short="CCC129" long="CCC129"/>
               <val class="130" short="CCC130" long="CCC130"/>
               <val class="132" short="CCC132" long="CCC132"/>
               <val class="133" short="CCC133" long="CCC133 # RESERVED"/>
               <val class="200" short="ATBL" long="Attached_Below_Left"/>
               <val class="202" short="ATB" long="Attached_Below"/>
               <val class="214" short="ATA" long="Attached_Above"/>
               <val class="216" short="ATAR" long="Attached_Above_Right"/>
               <val class="218" short="BL" long="Below_Left"/>
               <val class="220" short="B" long="Below"/>
               <val class="222" short="BR" long="Below_Right"/>
               <val class="224" short="L" long="Left"/>
               <val class="226" short="R" long="Right"/>
               <val class="228" short="AL" long="Above_Left"/>
               <val class="230" short="A" long="Above"/>
               <val class="232" short="AR" long="Above_Right"/>
               <val class="233" short="DB" long="Double_Below"/>
               <val class="234" short="DA" long="Double_Above"/>
               <val class="240" short="IS" long="Iota_Subscript"/>
            </values>
         </property>
         <property>
            <name>cf</name>
            <name>Case_Folding</name>
            <type>codepoint+</type>
            <values/>
         </property>
         <property>
            <name>cjkAccountingNumeric</name>
            <name>kAccountingNumeric</name>
            <type>integer?</type>
            <values/>
         </property>
         <property>
            <name>cjkCompatibilityVariant</name>
            <name>kCompatibilityVariant</name>
            <type>codepoint?</type>
            <values/>
         </property>
         <property>
            <name>cjkIICore</name>
            <name>kIICore</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_GSource</name>
            <name>kIRG_GSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_HSource</name>
            <name>kIRG_HSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_JSource</name>
            <name>kIRG_JSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_KPSource</name>
            <name>kIRG_KPSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_KSource</name>
            <name>kIRG_KSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_MSource</name>
            <name>kIRG_MSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_SSource</name>
            <name>kIRG_SSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_TSource</name>
            <name>kIRG_TSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_UKSource</name>
            <name>kIRG_UKSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_USource</name>
            <name>kIRG_USource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkIRG_VSource</name>
            <name>kIRG_VSource</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>cjkOtherNumeric</name>
            <name>kOtherNumeric</name>
            <type>integer?</type>
            <values/>
         </property>
         <property>
            <name>cjkPrimaryNumeric</name>
            <name>kPrimaryNumeric</name>
            <type>integer?</type>
            <values/>
         </property>
         <property>
            <name>cjkRSUnicode</name>
            <name>kRSUnicode</name>
            <name>Unicode_Radical_Stroke; URS</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>dm</name>
            <name>Decomposition_Mapping</name>
            <type>codepoint*</type>
            <values/>
         </property>
         <property>
            <name>dt</name>
            <name>Decomposition_Type</name>
            <type>string?</type>
            <values>
               <val short="Can" long="Canonical"/>
               <val short="Com" long="Compat"/>
               <val short="Enc" long="Circle"/>
               <val short="Fin" long="Final"/>
               <val short="Font" long="Font"/>
               <val short="Fra" long="Fraction"/>
               <val short="Init" long="Initial"/>
               <val short="Iso" long="Isolated"/>
               <val short="Med" long="Medial"/>
               <val short="Nar" long="Narrow"/>
               <val short="Nb" long="Nobreak"/>
               <val short="None" long="None"/>
               <val short="Sml" long="Small"/>
               <val short="Sqr" long="Square"/>
               <val short="Sub" long="Sub"/>
               <val short="Sup" long="Super"/>
               <val short="Vert" long="Vertical"/>
               <val short="Wide" long="Wide"/>
            </values>
         </property>
         <property>
            <name>ea</name>
            <name>East_Asian_Width</name>
            <type>string</type>
            <values>
               <val short="A" long="Ambiguous"/>
               <val short="F" long="Fullwidth"/>
               <val short="H" long="Halfwidth"/>
               <val short="N" long="Neutral" most-frequent=""/>
               <val short="Na" long="Narrow"/>
               <val short="W" long="Wide"/>
            </values>
         </property>
         <property>
            <name>gc</name>
            <name>General_Category</name>
            <type>string</type>
            <values>
               <val short="C"
                    long="Other                            # Cc | Cf | Cn | Co | Cs"/>
               <val short="Cc" long="Control" most-frequent=""/>
               <val short="Cf" long="Format"/>
               <val short="Cn" long="Unassigned"/>
               <val short="Co" long="Private_Use"/>
               <val short="Cs" long="Surrogate"/>
               <val short="L"
                    long="Letter                           # Ll | Lm | Lo | Lt | Lu"/>
               <val short="LC" long="Cased_Letter                     # Ll | Lt | Lu"/>
               <val short="Ll" long="Lowercase_Letter"/>
               <val short="Lm" long="Modifier_Letter"/>
               <val short="Lo" long="Other_Letter"/>
               <val short="Lt" long="Titlecase_Letter"/>
               <val short="Lu" long="Uppercase_Letter"/>
               <val short="M" long="Mark"/>
               <val short="Mc" long="Spacing_Mark"/>
               <val short="Me" long="Enclosing_Mark"/>
               <val short="Mn" long="Nonspacing_Mark"/>
               <val short="N" long="Number                           # Nd | Nl | No"/>
               <val short="Nd" long="Decimal_Number"/>
               <val short="Nl" long="Letter_Number"/>
               <val short="No" long="Other_Number"/>
               <val short="P" long="Punctuation"/>
               <val short="Pc" long="Connector_Punctuation"/>
               <val short="Pd" long="Dash_Punctuation"/>
               <val short="Pe" long="Close_Punctuation"/>
               <val short="Pf" long="Final_Punctuation"/>
               <val short="Pi" long="Initial_Punctuation"/>
               <val short="Po" long="Other_Punctuation"/>
               <val short="Ps" long="Open_Punctuation"/>
               <val short="S" long="Symbol                           # Sc | Sk | Sm | So"/>
               <val short="Sc" long="Currency_Symbol"/>
               <val short="Sk" long="Modifier_Symbol"/>
               <val short="Sm" long="Math_Symbol"/>
               <val short="So" long="Other_Symbol"/>
               <val short="Z" long="Separator                        # Zl | Zp | Zs"/>
               <val short="Zl" long="Line_Separator"/>
               <val short="Zp" long="Paragraph_Separator"/>
               <val short="Zs" long="Space_Separator"/>
            </values>
         </property>
         <property>
            <name>hst</name>
            <name>Hangul_Syllable_Type</name>
            <type>string</type>
            <values>
               <val short="L" long="Leading_Jamo"/>
               <val short="LV" long="LV_Syllable"/>
               <val short="LVT" long="LVT_Syllable"/>
               <val short="NA" long="Not_Applicable" most-frequent=""/>
               <val short="T" long="Trailing_Jamo"/>
               <val short="V" long="Vowel_Jamo"/>
            </values>
         </property>
         <property>
            <name>jg</name>
            <name>Joining_Group</name>
            <type>string</type>
            <values>
               <val short="African_Feh" long="African_Feh"/>
               <val short="African_Noon" long="African_Noon"/>
               <val short="African_Qaf" long="African_Qaf"/>
               <val short="Ain" long="Ain"/>
               <val short="Alaph" long="Alaph"/>
               <val short="Alef" long="Alef"/>
               <val short="Beh" long="Beh"/>
               <val short="Beth" long="Beth"/>
               <val short="Burushaski_Yeh_Barree" long="Burushaski_Yeh_Barree"/>
               <val short="Dal" long="Dal"/>
               <val short="Dalath_Rish" long="Dalath_Rish"/>
               <val short="E" long="E"/>
               <val short="Farsi_Yeh" long="Farsi_Yeh"/>
               <val short="Fe" long="Fe"/>
               <val short="Feh" long="Feh"/>
               <val short="Final_Semkath" long="Final_Semkath"/>
               <val short="Gaf" long="Gaf"/>
               <val short="Gamal" long="Gamal"/>
               <val short="Hah" long="Hah"/>
               <val short="Hanifi_Rohingya_Kinna_Ya" long="Hanifi_Rohingya_Kinna_Ya"/>
               <val short="Hanifi_Rohingya_Pa" long="Hanifi_Rohingya_Pa"/>
               <val short="He" long="He"/>
               <val short="Heh" long="Heh"/>
               <val short="Heh_Goal" long="Heh_Goal"/>
               <val short="Heth" long="Heth"/>
               <val short="Kaf" long="Kaf"/>
               <val short="Kaph" long="Kaph"/>
               <val short="Khaph" long="Khaph"/>
               <val short="Knotted_Heh" long="Knotted_Heh"/>
               <val short="Lam" long="Lam"/>
               <val short="Lamadh" long="Lamadh"/>
               <val short="Malayalam_Bha" long="Malayalam_Bha"/>
               <val short="Malayalam_Ja" long="Malayalam_Ja"/>
               <val short="Malayalam_Lla" long="Malayalam_Lla"/>
               <val short="Malayalam_Llla" long="Malayalam_Llla"/>
               <val short="Malayalam_Nga" long="Malayalam_Nga"/>
               <val short="Malayalam_Nna" long="Malayalam_Nna"/>
               <val short="Malayalam_Nnna" long="Malayalam_Nnna"/>
               <val short="Malayalam_Nya" long="Malayalam_Nya"/>
               <val short="Malayalam_Ra" long="Malayalam_Ra"/>
               <val short="Malayalam_Ssa" long="Malayalam_Ssa"/>
               <val short="Malayalam_Tta" long="Malayalam_Tta"/>
               <val short="Manichaean_Aleph" long="Manichaean_Aleph"/>
               <val short="Manichaean_Ayin" long="Manichaean_Ayin"/>
               <val short="Manichaean_Beth" long="Manichaean_Beth"/>
               <val short="Manichaean_Daleth" long="Manichaean_Daleth"/>
               <val short="Manichaean_Dhamedh" long="Manichaean_Dhamedh"/>
               <val short="Manichaean_Five" long="Manichaean_Five"/>
               <val short="Manichaean_Gimel" long="Manichaean_Gimel"/>
               <val short="Manichaean_Heth" long="Manichaean_Heth"/>
               <val short="Manichaean_Hundred" long="Manichaean_Hundred"/>
               <val short="Manichaean_Kaph" long="Manichaean_Kaph"/>
               <val short="Manichaean_Lamedh" long="Manichaean_Lamedh"/>
               <val short="Manichaean_Mem" long="Manichaean_Mem"/>
               <val short="Manichaean_Nun" long="Manichaean_Nun"/>
               <val short="Manichaean_One" long="Manichaean_One"/>
               <val short="Manichaean_Pe" long="Manichaean_Pe"/>
               <val short="Manichaean_Qoph" long="Manichaean_Qoph"/>
               <val short="Manichaean_Resh" long="Manichaean_Resh"/>
               <val short="Manichaean_Sadhe" long="Manichaean_Sadhe"/>
               <val short="Manichaean_Samekh" long="Manichaean_Samekh"/>
               <val short="Manichaean_Taw" long="Manichaean_Taw"/>
               <val short="Manichaean_Ten" long="Manichaean_Ten"/>
               <val short="Manichaean_Teth" long="Manichaean_Teth"/>
               <val short="Manichaean_Thamedh" long="Manichaean_Thamedh"/>
               <val short="Manichaean_Twenty" long="Manichaean_Twenty"/>
               <val short="Manichaean_Waw" long="Manichaean_Waw"/>
               <val short="Manichaean_Yodh" long="Manichaean_Yodh"/>
               <val short="Manichaean_Zayin" long="Manichaean_Zayin"/>
               <val short="Meem" long="Meem"/>
               <val short="Mim" long="Mim"/>
               <val short="No_Joining_Group" long="No_Joining_Group" most-frequent=""/>
               <val short="Noon" long="Noon"/>
               <val short="Nun" long="Nun"/>
               <val short="Nya" long="Nya"/>
               <val short="Pe" long="Pe"/>
               <val short="Qaf" long="Qaf"/>
               <val short="Qaph" long="Qaph"/>
               <val short="Reh" long="Reh"/>
               <val short="Reversed_Pe" long="Reversed_Pe"/>
               <val short="Rohingya_Yeh" long="Rohingya_Yeh"/>
               <val short="Sad" long="Sad"/>
               <val short="Sadhe" long="Sadhe"/>
               <val short="Seen" long="Seen"/>
               <val short="Semkath" long="Semkath"/>
               <val short="Shin" long="Shin"/>
               <val short="Straight_Waw" long="Straight_Waw"/>
               <val short="Swash_Kaf" long="Swash_Kaf"/>
               <val short="Syriac_Waw" long="Syriac_Waw"/>
               <val short="Tah" long="Tah"/>
               <val short="Taw" long="Taw"/>
               <val short="Teh_Marbuta" long="Teh_Marbuta"/>
               <val short="Teh_Marbuta_Goal" long="Hamza_On_Heh_Goal"/>
               <val short="Teth" long="Teth"/>
               <val short="Thin_Yeh" long="Thin_Yeh"/>
               <val short="Vertical_Tail" long="Vertical_Tail"/>
               <val short="Waw" long="Waw"/>
               <val short="Yeh" long="Yeh"/>
               <val short="Yeh_Barree" long="Yeh_Barree"/>
               <val short="Yeh_With_Tail" long="Yeh_With_Tail"/>
               <val short="Yudh" long="Yudh"/>
               <val short="Yudh_He" long="Yudh_He"/>
               <val short="Zain" long="Zain"/>
               <val short="Zhain" long="Zhain"/>
            </values>
         </property>
         <property>
            <name>jt</name>
            <name>Joining_Type</name>
            <type>string</type>
            <values>
               <val short="C" long="Join_Causing"/>
               <val short="D" long="Dual_Joining"/>
               <val short="L" long="Left_Joining"/>
               <val short="R" long="Right_Joining"/>
               <val short="T" long="Transparent"/>
               <val short="U" long="Non_Joining" most-frequent=""/>
            </values>
         </property>
         <property>
            <name>lb</name>
            <name>Line_Break</name>
            <type>string</type>
            <values>
               <val short="AI" long="Ambiguous"/>
               <val short="AK" long="Aksara"/>
               <val short="AL" long="Alphabetic"/>
               <val short="AP" long="Aksara_Prebase"/>
               <val short="AS" long="Aksara_Start"/>
               <val short="B2" long="Break_Both"/>
               <val short="BA" long="Break_After"/>
               <val short="BB" long="Break_Before"/>
               <val short="BK" long="Mandatory_Break"/>
               <val short="CB" long="Contingent_Break"/>
               <val short="CJ" long="Conditional_Japanese_Starter"/>
               <val short="CL" long="Close_Punctuation"/>
               <val short="CM" long="Combining_Mark" most-frequent=""/>
               <val short="CP" long="Close_Parenthesis"/>
               <val short="CR" long="Carriage_Return"/>
               <val short="EB" long="E_Base"/>
               <val short="EM" long="E_Modifier"/>
               <val short="EX" long="Exclamation"/>
               <val short="GL" long="Glue"/>
               <val short="H2" long="H2"/>
               <val short="H3" long="H3"/>
               <val short="HL" long="Hebrew_Letter"/>
               <val short="HY" long="Hyphen"/>
               <val short="ID" long="Ideographic"/>
               <val short="IN" long="Inseparable"/>
               <val short="IS" long="Infix_Numeric"/>
               <val short="JL" long="JL"/>
               <val short="JT" long="JT"/>
               <val short="JV" long="JV"/>
               <val short="LF" long="Line_Feed"/>
               <val short="NL" long="Next_Line"/>
               <val short="NS" long="Nonstarter"/>
               <val short="NU" long="Numeric"/>
               <val short="OP" long="Open_Punctuation"/>
               <val short="PO" long="Postfix_Numeric"/>
               <val short="PR" long="Prefix_Numeric"/>
               <val short="QU" long="Quotation"/>
               <val short="RI" long="Regional_Indicator"/>
               <val short="SA" long="Complex_Context"/>
               <val short="SG" long="Surrogate"/>
               <val short="SP" long="Space"/>
               <val short="SY" long="Break_Symbols"/>
               <val short="VF" long="Virama_Final"/>
               <val short="VI" long="Virama"/>
               <val short="WJ" long="Word_Joiner"/>
               <val short="XX" long="Unknown"/>
               <val short="ZW" long="ZWSpace"/>
               <val short="ZWJ" long="ZWJ"/>
            </values>
         </property>
         <property>
            <name>lc</name>
            <name>Lowercase_Mapping</name>
            <type>codepoint+</type>
            <values/>
         </property>
         <property>
            <name>na</name>
            <name>Name</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>na1</name>
            <name>Unicode_1_Name</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>nt</name>
            <name>Numeric_Type</name>
            <type>string</type>
            <values>
               <val short="De" long="Decimal"/>
               <val short="Di" long="Digit"/>
               <val short="None" long="None" most-frequent=""/>
               <val short="Nu" long="Numeric"/>
            </values>
         </property>
         <property>
            <name>nv</name>
            <name>Numeric_Value</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>sc</name>
            <name>Script</name>
            <type>string</type>
            <values>
               <val short="Adlm" long="Adlam"/>
               <val short="Aghb" long="Caucasian_Albanian"/>
               <val short="Ahom" long="Ahom"/>
               <val short="Arab" long="Arabic"/>
               <val short="Armi" long="Imperial_Aramaic"/>
               <val short="Armn" long="Armenian"/>
               <val short="Avst" long="Avestan"/>
               <val short="Bali" long="Balinese"/>
               <val short="Bamu" long="Bamum"/>
               <val short="Bass" long="Bassa_Vah"/>
               <val short="Batk" long="Batak"/>
               <val short="Beng" long="Bengali"/>
               <val short="Bhks" long="Bhaiksuki"/>
               <val short="Bopo" long="Bopomofo"/>
               <val short="Brah" long="Brahmi"/>
               <val short="Brai" long="Braille"/>
               <val short="Bugi" long="Buginese"/>
               <val short="Buhd" long="Buhid"/>
               <val short="Cakm" long="Chakma"/>
               <val short="Cans" long="Canadian_Aboriginal"/>
               <val short="Cari" long="Carian"/>
               <val short="Cham" long="Cham"/>
               <val short="Cher" long="Cherokee"/>
               <val short="Chrs" long="Chorasmian"/>
               <val short="Copt" long="Coptic"/>
               <val short="Cpmn" long="Cypro_Minoan"/>
               <val short="Cprt" long="Cypriot"/>
               <val short="Cyrl" long="Cyrillic"/>
               <val short="Deva" long="Devanagari"/>
               <val short="Diak" long="Dives_Akuru"/>
               <val short="Dogr" long="Dogra"/>
               <val short="Dsrt" long="Deseret"/>
               <val short="Dupl" long="Duployan"/>
               <val short="Egyp" long="Egyptian_Hieroglyphs"/>
               <val short="Elba" long="Elbasan"/>
               <val short="Elym" long="Elymaic"/>
               <val short="Ethi" long="Ethiopic"/>
               <val short="Geor" long="Georgian"/>
               <val short="Glag" long="Glagolitic"/>
               <val short="Gong" long="Gunjala_Gondi"/>
               <val short="Gonm" long="Masaram_Gondi"/>
               <val short="Goth" long="Gothic"/>
               <val short="Gran" long="Grantha"/>
               <val short="Grek" long="Greek"/>
               <val short="Gujr" long="Gujarati"/>
               <val short="Guru" long="Gurmukhi"/>
               <val short="Hang" long="Hangul"/>
               <val short="Hani" long="Han"/>
               <val short="Hano" long="Hanunoo"/>
               <val short="Hatr" long="Hatran"/>
               <val short="Hebr" long="Hebrew"/>
               <val short="Hira" long="Hiragana"/>
               <val short="Hluw" long="Anatolian_Hieroglyphs"/>
               <val short="Hmng" long="Pahawh_Hmong"/>
               <val short="Hmnp" long="Nyiakeng_Puachue_Hmong"/>
               <val short="Hrkt" long="Katakana_Or_Hiragana"/>
               <val short="Hung" long="Old_Hungarian"/>
               <val short="Ital" long="Old_Italic"/>
               <val short="Java" long="Javanese"/>
               <val short="Kali" long="Kayah_Li"/>
               <val short="Kana" long="Katakana"/>
               <val short="Kawi" long="Kawi"/>
               <val short="Khar" long="Kharoshthi"/>
               <val short="Khmr" long="Khmer"/>
               <val short="Khoj" long="Khojki"/>
               <val short="Kits" long="Khitan_Small_Script"/>
               <val short="Knda" long="Kannada"/>
               <val short="Kthi" long="Kaithi"/>
               <val short="Lana" long="Tai_Tham"/>
               <val short="Laoo" long="Lao"/>
               <val short="Latn" long="Latin"/>
               <val short="Lepc" long="Lepcha"/>
               <val short="Limb" long="Limbu"/>
               <val short="Lina" long="Linear_A"/>
               <val short="Linb" long="Linear_B"/>
               <val short="Lisu" long="Lisu"/>
               <val short="Lyci" long="Lycian"/>
               <val short="Lydi" long="Lydian"/>
               <val short="Mahj" long="Mahajani"/>
               <val short="Maka" long="Makasar"/>
               <val short="Mand" long="Mandaic"/>
               <val short="Mani" long="Manichaean"/>
               <val short="Marc" long="Marchen"/>
               <val short="Medf" long="Medefaidrin"/>
               <val short="Mend" long="Mende_Kikakui"/>
               <val short="Merc" long="Meroitic_Cursive"/>
               <val short="Mero" long="Meroitic_Hieroglyphs"/>
               <val short="Mlym" long="Malayalam"/>
               <val short="Modi" long="Modi"/>
               <val short="Mong" long="Mongolian"/>
               <val short="Mroo" long="Mro"/>
               <val short="Mtei" long="Meetei_Mayek"/>
               <val short="Mult" long="Multani"/>
               <val short="Mymr" long="Myanmar"/>
               <val short="Nagm" long="Nag_Mundari"/>
               <val short="Nand" long="Nandinagari"/>
               <val short="Narb" long="Old_North_Arabian"/>
               <val short="Nbat" long="Nabataean"/>
               <val short="Newa" long="Newa"/>
               <val short="Nkoo" long="Nko"/>
               <val short="Nshu" long="Nushu"/>
               <val short="Ogam" long="Ogham"/>
               <val short="Olck" long="Ol_Chiki"/>
               <val short="Orkh" long="Old_Turkic"/>
               <val short="Orya" long="Oriya"/>
               <val short="Osge" long="Osage"/>
               <val short="Osma" long="Osmanya"/>
               <val short="Ougr" long="Old_Uyghur"/>
               <val short="Palm" long="Palmyrene"/>
               <val short="Pauc" long="Pau_Cin_Hau"/>
               <val short="Perm" long="Old_Permic"/>
               <val short="Phag" long="Phags_Pa"/>
               <val short="Phli" long="Inscriptional_Pahlavi"/>
               <val short="Phlp" long="Psalter_Pahlavi"/>
               <val short="Phnx" long="Phoenician"/>
               <val short="Plrd" long="Miao"/>
               <val short="Prti" long="Inscriptional_Parthian"/>
               <val short="Rjng" long="Rejang"/>
               <val short="Rohg" long="Hanifi_Rohingya"/>
               <val short="Runr" long="Runic"/>
               <val short="Samr" long="Samaritan"/>
               <val short="Sarb" long="Old_South_Arabian"/>
               <val short="Saur" long="Saurashtra"/>
               <val short="Sgnw" long="SignWriting"/>
               <val short="Shaw" long="Shavian"/>
               <val short="Shrd" long="Sharada"/>
               <val short="Sidd" long="Siddham"/>
               <val short="Sind" long="Khudawadi"/>
               <val short="Sinh" long="Sinhala"/>
               <val short="Sogd" long="Sogdian"/>
               <val short="Sogo" long="Old_Sogdian"/>
               <val short="Sora" long="Sora_Sompeng"/>
               <val short="Soyo" long="Soyombo"/>
               <val short="Sund" long="Sundanese"/>
               <val short="Sylo" long="Syloti_Nagri"/>
               <val short="Syrc" long="Syriac"/>
               <val short="Tagb" long="Tagbanwa"/>
               <val short="Takr" long="Takri"/>
               <val short="Tale" long="Tai_Le"/>
               <val short="Talu" long="New_Tai_Lue"/>
               <val short="Taml" long="Tamil"/>
               <val short="Tang" long="Tangut"/>
               <val short="Tavt" long="Tai_Viet"/>
               <val short="Telu" long="Telugu"/>
               <val short="Tfng" long="Tifinagh"/>
               <val short="Tglg" long="Tagalog"/>
               <val short="Thaa" long="Thaana"/>
               <val short="Thai" long="Thai"/>
               <val short="Tibt" long="Tibetan"/>
               <val short="Tirh" long="Tirhuta"/>
               <val short="Tnsa" long="Tangsa"/>
               <val short="Toto" long="Toto"/>
               <val short="Ugar" long="Ugaritic"/>
               <val short="Vaii" long="Vai"/>
               <val short="Vith" long="Vithkuqi"/>
               <val short="Wara" long="Warang_Citi"/>
               <val short="Wcho" long="Wancho"/>
               <val short="Xpeo" long="Old_Persian"/>
               <val short="Xsux" long="Cuneiform"/>
               <val short="Yezi" long="Yezidi"/>
               <val short="Yiii" long="Yi"/>
               <val short="Zanb" long="Zanabazar_Square"/>
               <val short="Zinh" long="Inherited"/>
               <val short="Zyyy" long="Common" most-frequent=""/>
               <val short="Zzzz" long="Unknown"/>
            </values>
         </property>
         <property>
            <name>scf</name>
            <name>Simple_Case_Folding</name>
            <name>sfc</name>
            <type>codepoint</type>
            <values/>
         </property>
         <property>
            <name>scx</name>
            <name>Script_Extensions</name>
            <type>string?</type>
            <values/>
         </property>
         <property>
            <name>slc</name>
            <name>Simple_Lowercase_Mapping</name>
            <type>codepoint</type>
            <values/>
         </property>
         <property>
            <name>stc</name>
            <name>Simple_Titlecase_Mapping</name>
            <type>codepoint</type>
            <values/>
         </property>
         <property>
            <name>suc</name>
            <name>Simple_Uppercase_Mapping</name>
            <type>codepoint</type>
            <values/>
         </property>
         <property>
            <name>tc</name>
            <name>Titlecase_Mapping</name>
            <type>codepoint+</type>
            <values/>
         </property>
         <property>
            <name>uc</name>
            <name>Uppercase_Mapping</name>
            <type>codepoint+</type>
            <values/>
         </property>
         <property>
            <name>vo</name>
            <name>Vertical_Orientation</name>
            <type>string</type>
            <values>
               <val short="R" long="Rotated" most-frequent=""/>
               <val short="Tr" long="Transformed_Rotated"/>
               <val short="Tu" long="Transformed_Upright"/>
               <val short="U" long="Upright"/>
            </values>
         </property>
      </property-tree>
   </xsl:variable>
   <!-- When a core map is delivered, it has only a few of the uncommon values present. We expand to all aliases and
      populate missing items with their most frequent value. -->
   <xsl:mode name="expand-map" on-no-match="shallow-skip"/>
   
   <xsl:template match="property-tree" mode="expand-map">
      <xsl:map>
         <xsl:apply-templates mode="#current"/>
      </xsl:map>
   </xsl:template>
   
   <xsl:template match="property" mode="expand-map">
      <xsl:param name="curr-map" as="map(*)" tunnel="yes"/>
      <xsl:param name="curr-cp" as="xs:integer" tunnel="yes"/>
      
      <xsl:variable name="names" as="element()+" select="name"/>
      <xsl:variable name="curr-map-keys" as="xs:string+" select="map:keys($curr-map)"/>
      <xsl:variable name="curr-map-key-of-interest" as="xs:string?" select="$curr-map-keys[. = $names]"/>
      <xsl:variable name="default-val" as="item()?">
         <xsl:choose>
            <xsl:when test="type = 'boolean' and values/val[@most-frequent] = 'Y'">
               <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="type = 'boolean' and values/val[@most-frequent] = 'N'">
               <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="type = 'boolean'">
               <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="exists(values/val[@most-frequent])">
               <xsl:sequence select="values/val[@most-frequent]/@short"/>
            </xsl:when>
            <xsl:when test="starts-with(type, 'codepoint')">
               <xsl:sequence select="$curr-cp"/>
            </xsl:when>
            <!-- Currently we can ignore integer and string, because they are currently available
               only as zero or more, which means the default is null. -->
         </xsl:choose>
      </xsl:variable>
      
      <xsl:apply-templates mode="#current">
         <xsl:with-param name="curr-map-key-of-interest" tunnel="yes" select="$curr-map-key-of-interest"/>
         <xsl:with-param name="default-val" tunnel="yes" select="$default-val"/>
      </xsl:apply-templates>
   </xsl:template>
   
   <xsl:template match="name" mode="expand-map">
      <xsl:param name="curr-map" as="map(*)" tunnel="yes"/>
      <xsl:param name="curr-map-key-of-interest" as="xs:string?" tunnel="yes"/>
      <xsl:param name="default-val" as="item()*" tunnel="yes"/>
      
      <xsl:map-entry key="." select="
            if (exists($curr-map-key-of-interest)) then
               $curr-map($curr-map-key-of-interest)
            else
               $default-val"/>
   </xsl:template>
   <!-- 
   
         MASTER MAP
   
   -->
   <xsl:variable name="fn4:unicode-property-map-codepoint-keys" as="xs:integer*"
      select="map:keys($fn4:unicode-property-map)[. instance of xs:integer]"/>
   <xsl:variable name="fn4:unicode-property-map" as="map(*)">
      <xsl:map>
         <xsl:map-entry use-when="$codepoints-of-interest = 33" key="33">
            <!-- This is a sample entry of what will get built. -->
            <xsl:map>
               <xsl:map-entry key="'bc'" select="'ON'"/>
               <xsl:map-entry key="'dt'" select="'None'"/>
               <xsl:map-entry key="'gc'" select="'Po'"/>
               <xsl:map-entry key="'lb'" select="'EX'"/>
               <xsl:map-entry key="'na'" select="'EXCLAMATION MARK'"/>
               <xsl:map-entry key="'Pat_Syn'" select="true()"/>
               <xsl:map-entry key="'SB'" select="'ST'"/>
               <xsl:map-entry key="'scx'" select="'Zyyy'"/>
               <xsl:map-entry key="'STerm'" select="true()"/>
               <xsl:map-entry key="'Term'" select="true()"/>
            </xsl:map>
         </xsl:map-entry>
      </xsl:map>
   </xsl:variable>
   
   
</xsl:stylesheet>