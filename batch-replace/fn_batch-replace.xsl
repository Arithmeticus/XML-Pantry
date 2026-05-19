<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:fr="http://gpo.gov/franklin"
    xmlns:saxon="http://saxon.sf.net/"
    expand-text="yes"
    exclude-result-prefixes="#all" version="3.0">

    <!-- Names of elements that should remain untouched by global changes -->
    <xsl:param name="fr:stet-inside" as="xs:string*" select="'AUTH', 'quoted-block', 'quote'"/>
    <!-- Names of elements that designate the beginning of a range text that should not be changed. -->
    <xsl:param name="fr:stet-start" as="xs:string*" select="'_stet', '_stet-start'"/>
    <!-- Names of elements that designate the end of a range text that should not be changed. -->
    <xsl:param name="fr:stet-end" as="xs:string*" select="'_stet-end'"/>
    
    <xsl:function name="fr:batch-replace" as="item()*" visibility="public">
        <!-- Input: 
            1. any items; 
            2. a sequence of elements declaring the replacements to be applied:
         <[ANY NAME] pattern="" [replacement=""] [flags=""] [message=""] [exclude-pattern=""]
         [context=""] [exclude-context=""] [respect-stet=""]>[ANY CONTENT]</[ANY NAME]> 
        -->
        <!-- Output: a sequence of items, with instances of @pattern replaced by the content of the elements -->
        <!-- 
            @pattern : a regular expression to be matched; follows the same rules as `pattern` in XPath matches().
            @replacement : a string; follows the same rules as `replacement` in XPath matches(). IT IS NOT ALLOWED
                FOR @REPLACEMENT TO EXIST AT THE SAME TIME AS [ANY CONTENT] WITHIN THE REPLACE ELEMENT.
            @replacement-type : a keyword indicating how the @replacement should be interpreted. Supported values:
                function : evaluate the content as an XPath expression 
            @flags : a string; follows the same rules as `flags` in XPath matches().
            [ANY CONTENT] : the content that should replace the current text. Any instances of $0, $1, etc. within
                the content will be replaced by the capture groups from @pattern. Within the content, if @_message 
                is encountered, a message will be returned and the shadow attribute dropped. 
            @exclude-pattern : same as pattern, but defines a text that must be exempt from the replacement process.
            @context : take as values an XPath expression. When a given text node is processed, the expression 
                will be checked and converted to the expression's effective boolean value. If @context evaluates 
                to true then the replacement pattern will be applied and otherwise not;
            @exclude-context : same value type, but opposite effect, of @context.  If @exclude-context is evaluated 
                to true the replacement pattern will not be applied, otherwise it will. If both @context and 
                @exclude-context are present, the former must be true and the latter false for the text node to 
                be processed.
            @respect-stet : boolean, default true. If false, then changes will be made even in places marked
                as stet / follow lit.
        -->
        <!-- Examples:
            Input: 
                $items-to-be-changed :=
                <source>Some text.</source>
                $replace-elements :=
                <replace pattern=" text" replacement="body"/>
                
            Output:
                <source>Somebody.</source>
                
                
            Input: 
                $items-to-be-changed :=
                <books>
                    <book>Moby Dick, by Melville</book>
                    <book>Great Expectations, by Dickens</book>
                </books>
                $replace-elements :=
                <replace pattern="^(.+)(, by)"><title _message="Processing $1">$1</title>$2</replace>
                <replace pattern=", by (.+)$"><author>$1</author></replace>
                
            Output:
            <books>
                <book><title>Moby Dick</title><author>Melville</author></book>
                <book><title>Great Expectations</title><author>Dickens</author></book>
            </books>
                message: Processing Moby Dick
                message: Processing Great Expectations
        -->
        <!-- This function adapted from the TAN function library, version 2021 -->
        <!-- It is assumed during the course of changing the input, if there are fragmented adjacent string 
            or text nodes, they should be string-joined before the next replacement. The first round of input
            is not so merged. -->
        

        <xsl:param name="items-to-be-changed" as="item()*"/>
        <xsl:param name="replace-elements" as="element()*"/>

        <xsl:variable name="replace-elements-of-interest" as="element()*"
            select="$replace-elements[@pattern]"/>

        <xsl:variable name="replace-elements-ignored" as="element()*"
            select="$replace-elements except $replace-elements-of-interest"/>

        <xsl:if test="exists($replace-elements-ignored)">
            <xsl:message
                select="string(count($replace-elements-ignored)) || ' replace elements are ignored, because they are missing @pattern.'"
            />
        </xsl:if>
        <xsl:choose>
            <xsl:when test="not(exists($replace-elements-of-interest))">
                <xsl:sequence select="$items-to-be-changed"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:iterate select="$replace-elements-of-interest">
                    <xsl:param name="results-so-far" as="item()*" select="$items-to-be-changed"/>

                    <xsl:on-completion select="$results-so-far"/>

                    <xsl:variable name="new-items" as="item()*">
                        <xsl:apply-templates select="$results-so-far" mode="fr:batch-replace-step-1">
                            <xsl:with-param name="replace-element" tunnel="yes" select="."/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    
                    <xsl:variable name="new-items-rev" as="item()*">
                        <xsl:for-each-group select="$new-items" group-adjacent=". instance of xs:string or . instance of text()">
                            <xsl:choose>
                                <xsl:when test="current-grouping-key() eq true()">
                                    <xsl:sequence select="string-join(current-group())"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="current-group()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each-group> 
                    </xsl:variable>

                    <xsl:next-iteration>
                        <xsl:with-param name="results-so-far" as="item()*" select="$new-items-rev"/>
                    </xsl:next-iteration>
                </xsl:iterate>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>
    
    
    <!-- Step 1: go through the source items, looking for matches. -->
    
    <xsl:accumulator name="stet" as="xs:boolean" initial-value="false()">
        <xsl:accumulator-rule match="*[name(.) = ($fr:stet-start, $fr:stet-inside)]" select="true()"/>
        <xsl:accumulator-rule phase="end" match="*[name(.) = ($fr:stet-inside)]" select="false()"/>
        <xsl:accumulator-rule match="*[name(.) = $fr:stet-end]" select="false()"/>
    </xsl:accumulator>
    
    <xsl:mode name="fr:batch-replace-step-1" on-no-match="shallow-copy" use-accumulators="stet"/>
    
    <!-- 
        When capturing a whitespace-only text node, we find that some alternatives are clearly
            more performant. The following are all equivalent, but have different times to process
            (here tested on a single file):
        [not(normalize-space(.))] 12.8 sec
        [not(matches(., '\S'))] 15.0 / 16.1 sec
        [string-length(normalize-space(.)) lt 1] 16.2 / 17.3
        string-length(normalize-space(.)) eq 0
        [normalize-space(.) eq ''] 16.5 / 17.3
    -->
    <xsl:template match="text()[not(normalize-space(.))]" priority="2" mode="fr:batch-replace-step-1">
        <!-- Batch replacements should not be applied to white space indent text nodes. -->
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- Any text that is marked "stet" should not be touched. -->
    <xsl:template match="text()[accumulator-before('stet')]" priority="1" mode="fr:batch-replace-step-1">
        <xsl:param name="replace-element" tunnel="yes" as="element()"/>
        <xsl:choose>
            <xsl:when test="exists($replace-element/@respect-stet) and xs:boolean($replace-element/@respect-stet) = false()">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()" mode="fr:batch-replace-step-1">
        <xsl:param name="replace-element" tunnel="yes" as="element()"/>
        
        <xsl:variable name="context-norm" as="xs:string"
            select="($replace-element/@context, 'true()')[1]"/>
        
        <xsl:variable name="exclude-context-norm" as="xs:string"
            select="($replace-element/@exclude-context, 'false()')[1]"/>
        
        <xsl:variable name="context-is-of-interest" as="xs:boolean">
            <xsl:evaluate xpath="'if (' || $context-norm || ') then true() else false()'" context-item=".">
                <xsl:fallback>
                    <xsl:sequence select="true()"/>
                </xsl:fallback>
            </xsl:evaluate>
        </xsl:variable>

        <xsl:variable name="context-should-be-ignored" as="xs:boolean">
            <xsl:evaluate xpath="'if (' || $exclude-context-norm || ') then true() else false()'" context-item=".">
                <xsl:fallback>
                    <xsl:sequence select="false()"/>
                </xsl:fallback>
            </xsl:evaluate>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$context-is-of-interest and not($context-should-be-ignored)">
                <xsl:apply-templates select="string(.)" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match=".[. instance of xs:string]" mode="fr:batch-replace-step-1">
        <xsl:param name="replace-element" tunnel="yes" as="element()"/>
        
        <xsl:variable name="exclude-pattern" as="xs:string?" select="$replace-element/@exclude-pattern"/>
        
        <xsl:choose>
            <xsl:when test="string-length($exclude-pattern) gt 0">
                <xsl:variable name="new-replace-element" as="element()">
                    <xsl:apply-templates select="$replace-element" mode="drop-exclude-pattern"/>
                </xsl:variable>
                <xsl:analyze-string select="." regex="{$replace-element/@exclude-pattern}" flags="{$replace-element/@flags}">
                    <xsl:matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:apply-templates select="." mode="#current">
                            <xsl:with-param name="replace-element" tunnel="yes" select="$new-replace-element"/>
                        </xsl:apply-templates>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="$replace-element/@replacement-type = 'function'">
                <xsl:analyze-string select="." regex="{$replace-element/@pattern}" flags="{$replace-element/@flags}">
                    <xsl:matching-substring>
                        <xsl:try>
                            <xsl:evaluate xpath="$replace-element/@replacement" context-item="."/>
                            <xsl:catch>
                                <xsl:message>Unable to evaluate
                                    {$replace-element/@replacement}</xsl:message>
                                <xsl:value-of select="."/>
                            </xsl:catch>
                        </xsl:try>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                
            </xsl:when>
            <xsl:when test="exists($replace-element/@replacement-type)">
                <xsl:message>{$replace-element/@replacement-type} not supported.</xsl:message>
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="replacement-as-element-node" as="element()">
                    <replacement>
                        <xsl:value-of select="$replace-element/@replacement"/>
                    </replacement>
                </xsl:variable>
                <xsl:analyze-string select="." regex="{$replace-element/@pattern}" flags="{$replace-element/@flags}">
                    <xsl:matching-substring>
                        <xsl:variable name="regex-groups" as="xs:string*">
                            <xsl:for-each select="0 to 20">
                                <xsl:try select="regex-group(.)">
                                    <xsl:catch select="''"/>
                                </xsl:try>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:apply-templates select="$replacement-as-element-node/node(), $replace-element/node()"
                            mode="fr:batch-replace-step-2">
                            <xsl:with-param name="regex-groups" as="xs:string*" tunnel="yes" select="$regex-groups"/>
                        </xsl:apply-templates>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:mode name="drop-exclude-pattern" on-no-match="shallow-copy"/>
    <xsl:template match="@exclude-pattern" mode="drop-exclude-pattern"/>
    
    
    
    <!-- Step 2: Examine the <replace> command, with the regex groups captured, and make any
        requested replacements. -->
    
    <xsl:mode name="fr:batch-replace-step-2" on-no-match="shallow-copy"/>
    
    <xsl:template match="@*" mode="fr:batch-replace-step-2">
        <!-- Attributes have a special feature: you can report back messages with @_message="", very helpful
            for diagnostics. And they too respond to regex groups. -->
        <xsl:param name="regex-groups" as="xs:string*" tunnel="yes"/>
        <xsl:variable name="new-value" as="xs:string*">
            <xsl:analyze-string select="." regex="\$(\d+)">
                <xsl:matching-substring>
                    <xsl:variable name="this-regex-no" select="number(regex-group(1))"/>
                    <xsl:value-of select="$regex-groups[$this-regex-no + 1]"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="name(.) eq '_message'">
                <xsl:message select="string-join($new-value, '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{name(.)}" select="string-join($new-value)"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="text()" mode="fr:batch-replace-step-2">
        <xsl:param name="regex-groups" as="xs:string*" tunnel="yes"/>

        <xsl:analyze-string select="." regex="\$(\d+)">
            <xsl:matching-substring>
                <xsl:variable name="this-regex-no" select="number(regex-group(1))"/>
                <xsl:value-of select="$regex-groups[$this-regex-no + 1]"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="processing-instruction()" mode="fr:batch-replace-step-2">
        <xsl:param name="regex-groups" as="xs:string*" tunnel="yes"/>

        <xsl:processing-instruction name="{name(.)}">
            <xsl:analyze-string select="." regex="\$(\d+)">
                <xsl:matching-substring>
                    <xsl:variable name="this-regex-no" select="number(regex-group(1))"/>
                    <xsl:value-of select="$regex-groups[$this-regex-no + 1]"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:processing-instruction>
    </xsl:template>
    
    
    
</xsl:stylesheet>
