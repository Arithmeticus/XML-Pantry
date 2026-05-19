<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:fr="http://gpo.gov/franklin"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:ssh="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:uslm="http://schemas.gpo.gov/xml/uslm"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all"
    expand-text="yes" version="3.0">


    <!-- Stylesheet to show how a Word document has been changed by later XML versions of it. -->
    <!-- Primary (catalyzing) input: any XML document, including this one. -->
    <!-- Secondary (critical) input: (1) a Word document and (2) one or more XML files representing work done to the 
        text of that Word file. Parameters specify for each item in #2 the label to be used and the dateTime when
        changes were applied. -->
    <!-- Primary output: perhaps diagnostics, perhaps the components of the Word file itself -->
    <!-- Secondary output: the Word file, with changes documented through tracked changes, comments -->

    <xsl:variable name="HistDocx-version" as="xs:string" select="'0.9'"/>
    <xsl:variable name="HistDocx-version-last-update" visibility="public" as="xs:date" 
        select="xs:date('2026-04-30')"/>

    <!-- The following parameter squelches all the messages from save-archive -->
    <xsl:param name="comment-on-saved-archives" as="xs:boolean" select="false()"/>
    <xsl:param name="tan:xml-1-1-is-supported" static="yes" select="false()"/>
    <!--<xsl:import href="../../XPUB-Tools/XSLT/packages/TAN/functions/TAN-function-library.xsl"/>-->
    
    <xsl:import href="../../packages/TAN/functions/TAN-function-library.xsl"/>

    <!--<xsl:import href="../../packages/Franklin/src/Franklin.xsl"/>-->
    <!--<xsl:import href="../../XPUB-Tools/XSLT/TextNormalizer/core/TextNormalizer.main.xsl"/>-->

    <xsl:import href="../../packages/Franklin/Franklin.xsl"/>
    <xsl:import href="../../packages/TextNormalizer/TextNormalizer.main.xsl"/>


    <!-- USER CONFIGURATION -->
    
    <xsl:variable name="source-prefix" as="xs:string"
        select="resolve-uri('../../test%20suites/HistDocx/smoke-test-1-input/2023-07069', static-base-uri())"
    />

    <!-- Should only the docx components be returned? If true, then only the docx components will be returned,
        and no attempt will be made to save them as a new docx in a new location. Useful for when this stylesheet
        is being called via fn:transform(). -->
    <xsl:param name="return-only-docx-components" static="yes" as="xs:boolean" select="false()"/>


    <xsl:param name="source-docx-uri-resolved" as="xs:string"
        select="$source-prefix || '.docx'"/>

    <!-- Should intermediate edits that were eventually dropped be ignored or recorded? If the former, use true(), otherwise false(). -->
    <xsl:param name="ignore-insertions-dropped-by-final-author" as="xs:boolean" select="false()"/>

    <xsl:param name="target-docx-uri" as="xs:string"
        select="replace($source-docx-uri-resolved, '\.docx$', '.hist.docx')"/>

    <xsl:param name="changed-versions.uris-resolved" as="xs:string+" select="(
        $source-prefix || '.ixml.xml',
        $source-prefix || '.fedreg.conversion.ixml2fedreg.2024-07-26_22-30-45.xml',
        $source-prefix || '.fedreg.prepping.rtalino.2024-07-29_16-30-48.xml',
        $source-prefix || '.fedreg.markup.staff.xml',
        $source-prefix || '.fedreg.proofreading.staff.xml',
        $source-prefix || '.fedreg.refereeing.staff.xml',
        $source-prefix || '.fedreg.revising.staff.xml'
        )"/>
    
    <xsl:param name="changed-versions.labels" as="xs:string+" select="(
        'conversion_word2ixml',
        'conversion_ixml2fedreg',
        'prepping_rtalino',
        'markup_staff',
        'proofreading_staff',
        'refereeing_staff',
        'revising_staff'
        )"/>

    <xsl:param name="changed-versions.dateTimes" as="xs:dateTime+" select="(
        xs:dateTime('2024-07-26T10:29:00'),
        xs:dateTime('2024-07-26T10:32:00'),
        xs:dateTime('2024-07-29T12:30:00'),
        xs:dateTime('2024-07-31T09:13:00'),
        xs:dateTime('2024-08-07T15:13:00'),
        xs:dateTime('2024-08-08T15:00:00'),
        xs:dateTime('2024-08-13T09:50:00')
        )"/>


    <!-- END OF USER CONFIGURATION -->
    
    <!-- If you use a normal dateTime duration in Microsoft Word, it gets reset to UTC. An initial
        adjustment is necessary before imprinting in Word. -->
    <xsl:variable name="last-dateTime" as="xs:dateTime"
        select="$changed-versions.dateTimes[last()] => adjust-dateTime-to-timezone()"/>
    <xsl:variable name="last-dateTime-zone" as="xs:dayTimeDuration?"
        select="timezone-from-dateTime($last-dateTime)"/>
    <xsl:variable name="last-dateTime-adjusted-for-Word" as="xs:dateTime"
        select="$last-dateTime + $last-dateTime-zone"/>

    <xsl:variable name="source-docx" as="document-node()*">
        <xsl:try select="tan:open-archive($source-docx-uri-resolved)">
            <xsl:catch>
                <xsl:message>Unable to open DOCX at {$source-docx-uri-resolved}</xsl:message>
            </xsl:catch>
        </xsl:try>
    </xsl:variable>

    <xsl:variable name="source-docx-repaired" as="document-node()*"
        select="$source-docx ! fr:repair-docx-components(.)"/>


    <xsl:variable name="changed-versions.documents" as="document-node()*">
        <xsl:for-each select="$changed-versions.uris-resolved">
            <xsl:variable name="fallback-uri" as="xs:string" select="replace(., '\.docx', '')"/>
            <xsl:choose>
                <xsl:when test="doc-available(.)">
                    <xsl:sequence select="doc(.)"/>
                </xsl:when>
                <xsl:when test="doc-available($fallback-uri)">
                    <xsl:sequence select="doc($fallback-uri)"/>
                </xsl:when>
                <xsl:when test="unparsed-text-available(.)">
                    <xsl:document>
                        <unparsed-text uri="{.}">
                            <xsl:value-of select="unparsed-text(.)"/>
                        </unparsed-text>
                    </xsl:document>
                </xsl:when>
                <xsl:when test="unparsed-text-available($fallback-uri)">
                    <xsl:document>
                        <unparsed-text uri="{$fallback-uri}">
                            <xsl:value-of select="unparsed-text($fallback-uri)"/>
                        </unparsed-text>
                    </xsl:document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>Unable to open {.} or fallback {$fallback-uri}.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>
    
    
    <xsl:variable name="number-of-placeholder-codepoints-needed" as="xs:integer" select="8"/>
    <xsl:variable name="unused-codepoints" as="xs:integer*">
        <xsl:iterate select="512 to 1024">
            <xsl:param name="results-so-far" as="xs:integer*" select="()"/>
            <xsl:variable name="use-this-one" as="xs:boolean" select="
                    every $i in ($source-docx-repaired, $changed-versions.documents)
                        satisfies not(contains($i, codepoints-to-string(.)))"/>
            <xsl:choose>
                <xsl:when test="count($results-so-far) eq $number-of-placeholder-codepoints-needed">
                    <xsl:sequence select="$results-so-far"/>
                    <xsl:break/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:next-iteration>
                        <xsl:with-param name="results-so-far" select="
                                if ($use-this-one) then
                                    ($results-so-far, .)
                                else
                                    $results-so-far"/>
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:variable>
    <xsl:variable name="footnote-signal-replacement" as="xs:string" select="codepoints-to-string($unused-codepoints[1])"/>
    <xsl:variable name="serialized-space-replacement" as="xs:string" select="codepoints-to-string($unused-codepoints[2])"/>


    <!-- Main document -->

    <xsl:variable name="source-docx.main-document-norm" as="document-node()?">
        <xsl:apply-templates select="$source-docx-repaired[w:document[not(contains(@_archive-path, 'glossary'))]]"
            mode="normalize-docx-register">
            <xsl:with-param name="format-comparandum" tunnel="yes" select="'uslm'"/>
            <!-- Don't put footnotes into the stream. -->
            <!--<xsl:with-param name="docx-package" tunnel="yes" select="$source-docx-repaired"/>-->
        </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="opening-tags-already-in-word-document" as="xs:string*">
        <xsl:analyze-string select="$source-docx.main-document-norm => string()"
            regex="&lt;(\w+)(&gt;|\s+\w+=)">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    <xsl:variable name="closing-tags-already-in-word-document" as="xs:string*">
        <xsl:analyze-string select="$source-docx.main-document-norm => string()"
            regex="&lt;/(\w+)&gt;">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    <xsl:param name="closing-tags-to-put-in-word-document" as="xs:string*" select="'E', 'SU'"/>

    <xsl:variable name="changed-versions.main-documents-norm" as="document-node()*">
        <xsl:apply-templates select="$changed-versions.documents" mode="normalize-fr-general"/>
    </xsl:variable>



    <!-- exceptions to the normalization process -->

    <!-- Ignore footnote separators for the purpose of text comparison. -->
    <xsl:variable name="footnote-types-to-ignore" as="xs:string+" select="('separator', 'continuationSeparator', 'continuationNotice')"/>
    
    
    <!-- docx normalization overrides -->
    
    <xsl:template match="w:footnote[@w:type = $footnote-types-to-ignore] | w:endnote[@w:type = $footnote-types-to-ignore]"
        mode="normalize-docx-register"/>
    
    <!-- Sometimes text is hidden in the form of pictures, e.g., 2018-28101 -->
    <xsl:template match="w:pict" mode="normalize-docx-register"/>
    
    <xsl:template match="w:footnoteReference | w:footnoteRef | w:endnoteReference | w:endnoteRef" mode="normalize-docx-register">
        <xsl:value-of select="$footnote-signal-replacement"/>
    </xsl:template>
    
    <xsl:variable name="special-fr-docx-text-replacements" as="element()*">
        <!--<replace pattern="\*(\s+\*)+" replacement="replace(., ' ', '{$stars-space-replacement}')" replacement-type="function"/>-->
    </xsl:variable>
    <xsl:template match="text()" priority="1" mode="normalize-docx-register">
        <!-- Replace all batch replacements with our own. -->
        <!--<xsl:copy-of select="."/>-->
        <xsl:copy-of select="fr:batch-replace(., $special-fr-docx-text-replacements)"/>
    </xsl:template>
    
    
    <!-- FedReg normalization overrides -->
    
    <xsl:param name="fr-additional-final-text-replacements" as="element()*">
        <replace pattern="\s\s+" replacement=" "/>
    </xsl:param>
    
    <xsl:template match="unparsed-text" priority="3" mode="normalize-fr-general">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="unparsed-text/@*" priority="3" mode="normalize-fr-general"/>
    
    <xsl:template match="unparsed-text/text()" priority="3" mode="normalize-fr-general">
        <!-- Drop footnotes -->
        <xsl:analyze-string select="." regex="\s*&lt;FTNT&gt;.+?&lt;/FTNT&gt;\s*">
            <xsl:non-matching-substring>
                <!-- In SGML versions, we remove any extra newlines before an angle bracket
                    that begins an opening element tag. Those newlines are for the comfort of 
                    the person who has to work the SGML file. -->
                <xsl:value-of select="replace(., '[\r\n]+&lt;', '&lt;')"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- Normalize indentation to a single space -->
    <xsl:template match="*[text()[matches(., '\S')]]/text()[not(matches(., '\S'))]" priority="2"
        mode="normalize-fr-general">
        <xsl:text>{$serialized-space-replacement}</xsl:text>
    </xsl:template>

    <xsl:template match="uslm:span[@class = 'FootnoteReference'] | uslm:ref[@class = 'footnote']" priority="4" mode="normalize-fr-general">
        <xsl:value-of select="$footnote-signal-replacement"/>
    </xsl:template>
    
    <xsl:template match="uslm:span/text()" priority="2" mode="normalize-fr-general">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="text()[not(matches(., '\S'))]" priority="1" mode="normalize-fr-general"/>

    <xsl:template match="P | FP | FP-1 | FP-2 | FP1-2 | P1 | P2 | FP1 | FP2 | FP3 | HD1 | HD2 | HD3 | CHED | ENT | ROW | 
        uslm:p | xhtml:table | xhtml:tr | xhtml:td | row | entry"
        priority="5" mode="normalize-fr-general">
        <xsl:next-match/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <!-- Ignore superiors that represent footnote signals; they get handled differently. -->
    <xsl:template match="SU[following-sibling::*[1]/self::FTREF]" priority="4" mode="normalize-fr-general">
        <xsl:value-of select="$footnote-signal-replacement"/>
    </xsl:template>
    
    <!-- Ignore footnotes, at least when comparing the main document, and ignore comments. -->
    <xsl:template match="FTNT | uslm:footnote | comment()" priority="4"
        mode="normalize-fr-general"/>

    <xsl:template match="uslm:* | xhtml:*" priority="3" mode="normalize-fr-general">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="ENT | ROW | entry | row" priority="3" mode="normalize-fr-general">
        <!-- We aren't interested in the markup of select table components. -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Show parcel divisions -->
    
    <xsl:template match="processing-instruction('parcel')" priority="2" mode="normalize-fr-general">
        <xsl:text>&#xa;</xsl:text>
        <xsl:value-of select="serialize(.)"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
    
    <!-- Serialize select tags for select elements -->
    
    <xsl:template match="GPOTABLE | TTITLE | BOXHD | CHED | table | title 
        | tgroup | colspec | thead | tbody" priority="3" mode="normalize-fr-general">
        <!-- We do not put in opening or closing tags for the table or its header: too much information. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*" priority="2" mode="normalize-fr-general">
        <!-- The OFR docx has tags inside the file proper, and we embed them to show how we've marked things up. -->
        <xsl:text>&lt;{local-name(.)}</xsl:text>
        <xsl:apply-templates select="@*" mode="special-attr-rendering"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*" priority="1" mode="normalize-fr-general">
        <!-- Some elements' closing tags are in the word document -->
        <xsl:next-match/>
        <xsl:if
            test="local-name(.) = ($closing-tags-already-in-word-document, $closing-tags-to-put-in-word-document)">
            <xsl:text>&lt;/{local-name(.)}&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:mode name="special-attr-rendering" on-no-match="shallow-copy"/>
    <xsl:template match="@xsi:*" priority="1" mode="normalize-fr-general special-attr-rendering"/>
    <xsl:template match="*[local-name(.) = $opening-tags-already-in-word-document]/@*" priority="1" mode="special-attr-rendering">
        <xsl:text> {name(.)}="{.}"</xsl:text>
    </xsl:template>
    <xsl:template match="@*" mode="special-attr-rendering">
        <xsl:text>{$serialized-space-replacement}{name(.)}="{.}"</xsl:text>
    </xsl:template>



    <!-- Footnotes -->
    
    <!-- In FRDoc 2023-06435 the customer provided an endnote, and no footnotes. In such cases we switch
        to the endnotes. -->
    <!-- TODO: what to do in cases where the customer has mixed endnotes and footnotes? -->

    <xsl:variable name="source-docx.footnotes-norm" as="document-node()?">
        <xsl:apply-templates select="($source-docx-repaired[w:footnotes[not(contains(@_archive-path, 'glossary'))]][descendant::w:t],
            $source-docx-repaired[w:endnotes][descendant::w:t])[1]"
            mode="normalize-docx-register">
            <xsl:with-param name="format-comparandum" tunnel="yes" select="'uslm'"/>
        </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="changed-versions.foonotes-norm" as="document-node()*">
        <xsl:apply-templates select="$changed-versions.documents" mode="normalize-fr-notes-general"
        />
    </xsl:variable>


    <xsl:mode name="normalize-fr-notes-general" on-no-match="shallow-skip"/>

    <xsl:template match="document-node()" mode="normalize-fr-notes-general">
        <xsl:document>
            <xsl:apply-templates mode="#current"/>
        </xsl:document>
    </xsl:template>
    <xsl:template match="FTNT | uslm:footnote" mode="normalize-fr-notes-general">
        <xsl:apply-templates select="*" mode="normalize-fr-general"/>
    </xsl:template>

    <xsl:template match="FTNT//SU[1]" priority="3" mode="normalize-fr-general">
        <xsl:value-of select="$footnote-signal-replacement"/>
    </xsl:template>
    
    <xsl:template match="unparsed-text" mode="normalize-fr-notes-general">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:analyze-string select="." regex="&lt;FTNT&gt;.+?&lt;/FTNT&gt;\s*">
                <xsl:matching-substring>
                    <xsl:value-of select="."/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:copy>
    </xsl:template>




    <!-- COMPARE THE STRING VALUES OF THE DOCX AGAINST THE SUBSEQUENT VERSIONS -->

    <xsl:variable name="source-label" as="xs:string" select="'source'"/>
    <xsl:variable name="collation-labels" as="xs:string+" select="($source-label, $changed-versions.labels)"/>

    <xsl:param name="tan:snap-to-word" as="xs:boolean" select="true()"/>
    <!--<xsl:param name="tan:token-definition-default" as="element()?">
        <token-definition pattern="[\w&#xad;​&#x200b;&#x200d;]+|[\s\*]+|[^\w&#xad;​&#x200b;&#x200d;\s\*]" flags=""/>
    </xsl:param>-->
    
    <xsl:variable name="docx-main-text-collation" as="element()"
        select="tan:collate(($source-docx.main-document-norm, $changed-versions.main-documents-norm), $collation-labels)"/>
    <xsl:variable name="docx-main-text-collation-norm" as="element()">
        <xsl:apply-templates select="$docx-main-text-collation"
            mode="reorder-collation-output"/>
    </xsl:variable>
    <xsl:variable name="docx-footnotes-collation" as="element()"
        select="tan:collate(($source-docx.footnotes-norm, $changed-versions.foonotes-norm), $collation-labels)"/>
    <xsl:variable name="docx-footnotes-collation-norm" as="element()">
        <xsl:apply-templates select="$docx-footnotes-collation"
            mode="reorder-collation-output"/>
    </xsl:variable>
    <xsl:variable name="last-author-label" as="xs:string" select="$collation-labels[last()]"/>
    
    
    <xsl:mode name="reorder-collation-output" on-no-match="shallow-copy"/>
    
    <xsl:template match="tan:collation" mode="reorder-collation-output">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="*" group-adjacent="name(.)">
                <xsl:choose>
                    <xsl:when test="exists(current-group()[matches(tan:txt, '^&lt;')])">
                        <!-- If tags have been inserted somewhere, keep their location intact. -->
                        <xsl:copy-of select="current-group()"/>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() eq 'u'">
                        <xsl:for-each select="current-group()">
                            <!-- For most text changes, we prefer the source version before changes. -->
                            <xsl:sort select="tan:wit/@ref = $source-label"
                                order="descending"/>
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group> 
        </xsl:copy>
    </xsl:template>

    <xsl:variable name="docx-main-text-deletion-map" as="map(xs:integer, xs:string)">
        <xsl:map>
            <xsl:apply-templates select="$docx-main-text-collation-norm" mode="collation-to-delete-map"/>
        </xsl:map>
    </xsl:variable>
    <xsl:variable name="docx-main-text-deletion-positions" as="xs:integer*"
        select="map:keys($docx-main-text-deletion-map)"/>

    <xsl:variable name="docx-footnotes-deletion-map" as="map(xs:integer, xs:string)">
        <xsl:map>
            <xsl:apply-templates select="$docx-footnotes-collation-norm" mode="collation-to-delete-map"/>
        </xsl:map>
    </xsl:variable>
    <xsl:variable name="docx-footnotes-deletion-positions" as="xs:integer*"
        select="map:keys($docx-footnotes-deletion-map)"/>

    <xsl:mode name="collation-to-delete-map" on-no-match="shallow-skip"/>

    <xsl:template match="tan:u[tan:wit/@ref = $source-label]" mode="collation-to-delete-map">
        <xsl:variable name="wits" as="xs:string+" select="tan:wit/@ref"/>
        <xsl:variable name="resp" as="xs:string" select="$collation-labels[not(. = $wits)][1]"/>
        <xsl:variable name="deletion-was-overturned" as="xs:boolean" select="$wits = $last-author-label"/>
        <xsl:variable name="this-pos" as="xs:integer"
            select="xs:integer(tan:wit[@ref eq $source-label]/@pos)"/>
        <xsl:if test="not($deletion-was-overturned)">
            <xsl:for-each select="1 to string-length(tan:txt)">
                <xsl:map-entry key=". + $this-pos - 1" select="$resp"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:variable name="docx-main-text-insertion-map" as="map(*)">
        <xsl:map>
            <xsl:for-each-group select="$docx-main-text-collation-norm/*" group-adjacent="name(.)">
                <xsl:for-each-group select="current-group()/self::tan:u"
                    group-adjacent="tan:wit/@ref = $source-label">
                    <xsl:if test="current-grouping-key() = false()">
                        <xsl:variable name="prev-source-reading" as="element()?"
                            select="current-group()[1]/preceding-sibling::*[tan:wit/@ref = $source-label][1]"/>
                        <xsl:variable name="docx-pos" as="xs:integer"
                            select="(xs:integer($prev-source-reading/tan:wit[@ref = $source-label]/@pos), 0)[1] + string-length($prev-source-reading/tan:txt)"/>
                        <xsl:map-entry key="$docx-pos" select="current-group()"/>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:map>
    </xsl:variable>
    <xsl:variable name="docx-main-text-insertion-positions" as="xs:integer*"
        select="map:keys($docx-main-text-insertion-map)"/>

    <xsl:variable name="docx-footnotes-insertion-map" as="map(*)">
        <xsl:map>
            <xsl:for-each-group select="$docx-footnotes-collation-norm/*" group-adjacent="name(.)">
                <xsl:for-each-group select="current-group()/self::tan:u"
                    group-adjacent="tan:wit/@ref = $source-label">
                    <xsl:if test="current-grouping-key() = false()">
                        <xsl:variable name="prev-source-reading" as="element()?"
                            select="current-group()[1]/preceding-sibling::*[tan:wit/@ref = $source-label][1]"/>
                        <xsl:variable name="docx-pos" as="xs:integer"
                            select="(xs:integer($prev-source-reading/tan:wit[@ref = $source-label]/@pos), 0)[1] + string-length($prev-source-reading/tan:txt)"/>
                        <xsl:map-entry key="$docx-pos" select="current-group()"/>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:map>
    </xsl:variable>
    <xsl:variable name="docx-footnotes-insertion-positions" as="xs:integer*"
        select="map:keys($docx-footnotes-insertion-map)"/>



    <xsl:accumulator name="docx-string-pos" as="xs:integer" initial-value="1">
        <!-- Increment by one character for special characters represented by empty elements. -->
        <xsl:accumulator-rule
            match="w:r/w:tab[not(ancestor::mc:AlternateContent)] 
            | w:br[not(ancestor::mc:AlternateContent)] 
            | w:noBreakHyphen[not(ancestor::mc:AlternateContent)] 
            | w:softHyphen[not(ancestor::mc:AlternateContent)] 
            | ssh:c[not(@t)][not(ancestor::mc:AlternateContent)]" phase="end"
            select="$value + 1"/>
        <!-- Increment by one character for footnote references. -->
        <xsl:accumulator-rule
            match="w:footnoteRef | w:footnoteReference | w:endnoteRef | w:endnoteReference" phase="end"
            select="$value + 1"/>
        <!-- Increment by one character for the CRLF of the end of the paragraph. -->
        <xsl:accumulator-rule
            match="w:body/w:p | w:footnote[not(@w:type = $footnote-types-to-ignore)]/w:p | 
            w:endnote[not(@w:type = $footnote-types-to-ignore)]/w:p | 
            w:tc[not(ancestor::mc:AlternateContent) and not(ancestor::w:pict)]/w:p"
            phase="end" select="$value + 1"/>
        
        <!-- For the next rules, we have some duplication, only to avoid squelching messages from 
            Saxon about ambiguous rules. Those ambiguities should be resolved in Saxon release after
            version 12.5. At which point we can clean up / improve this code. -->
        
        <!-- For most text nodes, increment by the string length. -->
        <xsl:accumulator-rule match="text()[not(ancestor::w:del) 
            and not(ancestor::w:instrText) 
            and not(ancestor::mc:AlternateContent) 
            and not(ancestor::w:drawing)
            and not(ancestor::w:pict)
            and not(ancestor::w:fldData)
            and not(ancestor::w:*[@w:type = 'continuationNotice'])]" phase="end" select="$value + string-length(.)"/>
        <!-- Certain text nodes always need to be suppressed. -->
        <xsl:accumulator-rule match="w:del//text() | w:instrText//text() | w:drawing//text() | 
            w:pict//text() | w:fldData//text() |
            mc:AlternateContent//text() | w:footnote[@w:type eq 'continuationNotice']//text() | 
            w:endnote[@w:type eq 'continuationNotice']//text()" phase="end" select="$value"/>
        <!-- Certain elements always ignore the content -->
        <xsl:accumulator-rule match="w:del | w:instrText | w:drawing | w:pict | w:fldData |
            mc:AlternateContent | w:footnote[@w:type = 'continuationNotice'] | 
            w:endnote[@w:type = 'continuationNotice']" phase="end" select="$value"/>
    </xsl:accumulator>

    <xsl:variable name="source-docx.infused-with-history" as="document-node()*">
        <xsl:apply-templates select="$source-docx-repaired[w:document]"
            mode="infuse-docx-with-history"/>
        <xsl:apply-templates select="$source-docx-repaired[w:footnotes or w:endnotes]"
            mode="infuse-docx-with-history"/>
        <xsl:sequence select="$source-docx-repaired[not(w:document) and not(w:footnotes) and not(w:endnotes)]"/>
    </xsl:variable>

    <xsl:mode name="infuse-docx-with-history" use-accumulators="docx-string-pos"
        on-no-match="shallow-copy"/>

    <xsl:template match="/*" mode="infuse-docx-with-history">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current">
                <xsl:with-param name="root-element-name" tunnel="yes" select="local-name(.)"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="w:footnote[@w:type = $footnote-types-to-ignore] | w:endnote[@w:type = $footnote-types-to-ignore]"
        mode="infuse-docx-with-history">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="w:p[not(following-sibling::w:p)][not(ancestor::w:footnotes) and not(ancestor::w:endnotes)]" priority="1"
        mode="infuse-docx-with-history">
        <xsl:variable name="insertion-point" as="xs:integer"
            select="accumulator-after('docx-string-pos') - 1"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
            <xsl:if test="$insertion-point = $docx-main-text-insertion-positions">
                <xsl:apply-templates select="$docx-main-text-insertion-map($insertion-point)"
                    mode="collate-u-to-docx-ins"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="w:footnotes//w:p[not(following-sibling::w:p)] | 
        w:endnotes//w:p[not(following-sibling::w:p)]" priority="1"
        mode="infuse-docx-with-history">
        <xsl:variable name="insertion-point" as="xs:integer"
            select="accumulator-after('docx-string-pos') - 1"/>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current"/>
            <xsl:if test="$insertion-point = $docx-footnotes-insertion-positions">
                <xsl:apply-templates select="$docx-footnotes-insertion-map($insertion-point)"
                    mode="collate-u-to-docx-ins"/>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- Both this template and the following two deal with insertions at the point of paragraph breaks, and 
        deal with cases where the insertion should be placed after the new line. -->
    <xsl:template match="w:p[not(w:pPr)]" mode="infuse-docx-with-history">
        <xsl:param name="root-element-name" tunnel="yes" as="xs:string"/>
        
        <xsl:variable name="insertion-point" as="xs:integer"
            select="accumulator-before('docx-string-pos') - 1"/>
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when
                    test="$root-element-name eq 'document' and $insertion-point = $docx-main-text-insertion-positions">
                    <xsl:apply-templates select="$docx-main-text-insertion-map($insertion-point)"
                        mode="collate-u-to-docx-ins"/>
                </xsl:when>
                <xsl:when
                    test="$root-element-name eq 'footnotes' and $insertion-point = $docx-footnotes-insertion-positions">
                    <xsl:apply-templates select="$docx-footnotes-insertion-map($insertion-point)"
                        mode="collate-u-to-docx-ins"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <!-- This pair of templates is to be read closely with the previous one. -->
    <xsl:template match="w:footnote//w:pPr | w:endnote//w:pPr" priority="1" mode="infuse-docx-with-history">
        <xsl:variable name="insertion-already-happened" as="xs:boolean" 
            select="exists(ancestor::w:footnote/preceding-sibling::w:footnote[1]/w:p) or
            exists(ancestor::w:endnote/preceding-sibling::w:endnote[1]/w:p)"/>
        <xsl:if test="not($insertion-already-happened)">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="w:pPr" mode="infuse-docx-with-history">
        <xsl:param name="root-element-name" tunnel="yes" as="xs:string"/>

        <xsl:variable name="insertion-point" as="xs:integer"
            select="accumulator-before('docx-string-pos') - 1"/>
        
        <xsl:variable name="diagnostics-on" as="xs:boolean" select="false()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message>Insertion point {$insertion-point}</xsl:message>
            <xsl:if test="$insertion-point = $docx-main-text-insertion-positions">
                <xsl:message>Applying [{$docx-main-text-insertion-map($insertion-point)}]</xsl:message>
            </xsl:if>
            <xsl:if test="$insertion-point = $docx-footnotes-insertion-positions">
                <xsl:message>Applying [{$docx-footnotes-insertion-map($insertion-point)}]</xsl:message>
            </xsl:if>
        </xsl:if>

        <xsl:copy-of select="."/>
        <xsl:choose>
            <xsl:when
                test="$root-element-name eq 'document' and $insertion-point = $docx-main-text-insertion-positions">
                <xsl:apply-templates select="$docx-main-text-insertion-map($insertion-point)"
                    mode="collate-u-to-docx-ins"/>
            </xsl:when>
            <xsl:when
                test="$root-element-name eq 'footnotes' and $insertion-point = $docx-footnotes-insertion-positions">
                <xsl:apply-templates select="$docx-footnotes-insertion-map($insertion-point)"
                    mode="collate-u-to-docx-ins"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="w:r[w:footnoteReference] | w:r[w:endnoteReference] | w:r[w:drawing] | w:r[w:pict] | 
        w:r[w:instrText] | w:r[mc:AlternateContent] | w:r[w:fldChar]" priority="1" mode="infuse-docx-with-history">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="w:r[w:footnoteRef] | w:r[w:endnoteRef]" priority="1" mode="infuse-docx-with-history">
        <xsl:param name="root-element-name" tunnel="yes" as="xs:string"/>

        <xsl:variable name="insertion-point" as="xs:integer"
            select="accumulator-before('docx-string-pos')"/>

        <xsl:choose>
            <xsl:when
                test="$root-element-name eq 'document' and $insertion-point = $docx-main-text-insertion-positions">
                <xsl:apply-templates select="$docx-main-text-insertion-map($insertion-point)"
                    mode="collate-u-to-docx-ins"/>
            </xsl:when>
            <xsl:when
                test="$root-element-name eq 'footnotes' and $insertion-point = $docx-footnotes-insertion-positions">
                <xsl:apply-templates select="$docx-footnotes-insertion-map($insertion-point)"
                    mode="collate-u-to-docx-ins"/>
            </xsl:when>
        </xsl:choose>
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="w:r" mode="infuse-docx-with-history">
        <xsl:param name="root-element-name" tunnel="yes" as="xs:string"/>

        <!--<xsl:variable name="first-insertion-point-has-already-been-used" as="xs:boolean"
            select="exists(preceding-sibling::w:r[1]/w:footnoteRef)"/>
        <xsl:variable name="this-floor" as="xs:integer" select="
                if ($first-insertion-point-has-already-been-used) then
                    accumulator-before('docx-string-pos') + 1
                else
                    accumulator-before('docx-string-pos')
                "/>
        <xsl:variable name="this-ceiling" as="xs:integer"
            select="max((accumulator-after('docx-string-pos') - 1, $this-floor))"/>-->

        <xsl:variable name="this-floor" as="xs:integer" select="accumulator-before('docx-string-pos')"/>
        <xsl:variable name="this-ceiling" as="xs:integer"
            select="accumulator-after('docx-string-pos') - 1"/>
        <xsl:variable name="this-range" as="xs:integer*" select="$this-floor to $this-ceiling"/>

        <xsl:variable name="insertion-points" as="xs:integer*" select="
                if ($root-element-name = 'document') then
                    $this-range[. = $docx-main-text-insertion-positions]
                else
                    $this-range[. = $docx-footnotes-insertion-positions]
                "/>
        <xsl:variable name="deletion-points" as="xs:integer*" select="
                if ($root-element-name = 'document') then
                    $this-range[. = $docx-main-text-deletion-positions]
                else
                    $this-range[. = $docx-footnotes-deletion-positions]
                "/>

        <xsl:variable name="orig-r" as="element()" select="."/>
        <xsl:variable name="curr-text-norm" as="xs:string*">
            <xsl:apply-templates select="." mode="normalize-docx-register">
                <xsl:with-param name="format-comparandum" tunnel="yes" select="'uslm'"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="curr-text" as="xs:string" select="string-join($curr-text-norm)"/>
        
        <xsl:variable name="diagnostics-on" as="xs:boolean" select="false()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message>Diagnostics on {path(.)}</xsl:message>
            <!--<xsl:message>First insertion point already used? {$first-insertion-point-has-already-been-used}</xsl:message>-->
            <xsl:message>Floor: {$this-floor}; ceiling: {$this-ceiling}</xsl:message>
            <xsl:message>Insertion points: {$insertion-points}; deletion points: {$deletion-points}</xsl:message>
            <xsl:message>Text before: [{string(.)}]</xsl:message>
            <xsl:message>Text after : [{$curr-text}]</xsl:message>
        </xsl:if>


        <xsl:for-each-group select="$this-range" group-adjacent=". = $deletion-points">
            <xsl:variable name="this-group-has-deletion-points" as="xs:boolean" select="current-grouping-key() eq true()"/>
            <xsl:variable name="this-group-has-insertion-points" as="xs:boolean" select="current-group() = $insertion-points"/>
            <xsl:variable name="this-r-has-no-insertions-or-deletions" as="xs:boolean" select="
                    not($this-group-has-deletion-points) and
                    current-group()[1] eq $this-floor and
                    current-group()[last()] eq $this-ceiling and
                    not(exists($insertion-points))"/>
            <xsl:variable name="curr-substring" as="xs:string"
                select="substring($curr-text, (current-group()[1] - $this-floor + 1), count(current-group()))"/>
            
            <xsl:if test="$diagnostics-on">
                <xsl:message>Group {position()}, substring [{$curr-substring}]</xsl:message>
                <xsl:message>Slated for deletion? {$this-group-has-deletion-points}</xsl:message>
                <xsl:message>Insertion points: {current-group()[. = $insertion-points]}</xsl:message>
            </xsl:if>
            
            <xsl:choose>
                <!-- If no insertions or deletions happen anywhere in the w:r, then just copy the original. -->
                <xsl:when test="$this-r-has-no-insertions-or-deletions">
                    <xsl:copy-of select="$orig-r"/>
                </xsl:when>
                <!-- No deletion points, and no insertion points. Break up the w:r -->
                <xsl:when test="not($this-group-has-deletion-points) and not($this-group-has-insertion-points)">

                    <w:r>
                        <xsl:copy-of select="$orig-r/node()[not(self::w:t) and not(self::w:tab)]"/>
                        <!-- TODO: handle cases of w:softHyphen, etc. -->
                        <w:t>
                            <xsl:if test="matches($curr-substring, '^\s|\s\s|\s$')">
                                <xsl:attribute name="xml:space">preserve</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$curr-substring"/>
                        </w:t>
                    </w:r>
                </xsl:when>
                <!-- No deletion points, but there are insertion points. -->
                <xsl:when test="not($this-group-has-deletion-points) and $this-group-has-insertion-points">
                    <xsl:for-each-group select="current-group()" group-adjacent="
                            if (. = $insertion-points) then
                                .
                            else
                                -1">
                        <!-- Grouping technique: individuate insertion points, and group non-insertion points. -->

                        <xsl:variable name="is-insertion-point" as="xs:boolean" select="current-grouping-key() ge 0"/>
                        <xsl:variable name="curr-sub-substring" as="xs:string"
                            select="substring($curr-text, (current-group()[1] - $this-floor + 1), count(current-group()))"/>

                        <xsl:if test="$diagnostics-on">
                            <xsl:message>sub-substring [{$curr-sub-substring}] insertion point? {$is-insertion-point}</xsl:message>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when
                                test="$root-element-name eq 'document' and $is-insertion-point">
                                <xsl:apply-templates
                                    select="$insertion-points[. = current-group()] ! $docx-main-text-insertion-map(.)"
                                    mode="collate-u-to-docx-ins"/>

                            </xsl:when>
                            <xsl:when
                                test="$root-element-name eq 'footnotes' and $is-insertion-point">
                                <xsl:apply-templates
                                    select="$insertion-points[. = current-group()] ! $docx-footnotes-insertion-map(.)"
                                    mode="collate-u-to-docx-ins"/>

                            </xsl:when>
                        </xsl:choose>
                        <w:r>
                            <xsl:copy-of
                                select="$orig-r/node()[not(self::w:t) and not(self::w:tab)]"/>
                            <!-- TODO: handle cases of w:tab, w:softHyphen, etc. -->
                            <w:t>
                                <xsl:if test="matches($curr-sub-substring, '^\s|\s\s|\s$')">
                                    <xsl:attribute name="xml:space">preserve</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="$curr-sub-substring"/>
                            </w:t>
                        </w:r>

                    </xsl:for-each-group>
                </xsl:when>
                <!-- These are all deletion points. -->
                <xsl:otherwise>
                    <xsl:for-each-group select="current-group()" group-adjacent="
                            if ($root-element-name eq 'document') then
                                $docx-main-text-deletion-map(current())
                            else
                                $docx-footnotes-deletion-map(current())
                            ">
                        <xsl:variable name="this-author-label" as="xs:string" select="current-grouping-key()"/>
                        <xsl:variable name="this-dateTime" as="xs:dateTime"
                            select="$changed-versions.dateTimes[index-of($changed-versions.labels, $this-author-label)]
                            => adjust-dateTime-to-timezone()"
                        />
                        <xsl:variable name="this-dateTime-zone" as="xs:dayTimeDuration?"
                            select="timezone-from-dateTime($this-dateTime)"/>
                        <xsl:variable name="this-dateTime-adjusted-for-Word" as="xs:dateTime"
                            select="$this-dateTime + $this-dateTime-zone"/>
                        

                        <xsl:variable name="curr-substring" as="xs:string"
                            select="substring($curr-text, (current-group()[1] - $this-floor + 1), count(current-group()))"/>

                        <xsl:choose>
                            <xsl:when
                                test="$root-element-name = 'document' and current-group() = $insertion-points">
                                <xsl:apply-templates
                                    select="$insertion-points[. = current-group()] ! $docx-main-text-insertion-map(.)"
                                    mode="collate-u-to-docx-ins"/>
                            </xsl:when>
                            <xsl:when
                                test="$root-element-name = 'footnotes' and current-group() = $insertion-points">
                                <xsl:apply-templates
                                    select="$insertion-points[. = current-group()] ! $docx-footnotes-insertion-map(.)"
                                    mode="collate-u-to-docx-ins"/>
                            </xsl:when>
                        </xsl:choose>
                        <w:del w:id="" w:author="{$this-author-label}" w:date="{$this-dateTime-adjusted-for-Word}">
                            <w:r w:rsidDel="">
                                <w:delText>
                                    <xsl:if test="matches($curr-substring, '^\s|\s\s|\s$')">
                                        <xsl:attribute name="xml:space">preserve</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$curr-substring"/>
                                </w:delText>
                            </w:r>
                        </w:del>
                    </xsl:for-each-group>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>

    </xsl:template>


    <xsl:mode name="collate-u-to-docx-ins" on-no-match="shallow-skip"/>

    <xsl:template match="tan:u" mode="collate-u-to-docx-ins">
        <xsl:variable name="wits" as="xs:string+" select="tan:wit/@ref"/>
        <xsl:variable name="author" as="xs:string" select="$collation-labels[. = $wits][1]"/>
        <xsl:variable name="overruled-by-last-author" as="xs:boolean"
            select="not($wits = $last-author-label)"/>
        <xsl:variable name="this-dateTime" as="xs:dateTime"
            select="$changed-versions.dateTimes[index-of($changed-versions.labels, $author)] 
            => adjust-dateTime-to-timezone()"
        />
        <xsl:variable name="this-dateTime-zone" as="xs:dayTimeDuration?"
            select="timezone-from-dateTime($this-dateTime)"/>
        <xsl:variable name="this-dateTime-adjusted-for-Word" as="xs:dateTime"
            select="$this-dateTime + $this-dateTime-zone"/>
        <w:ins w:id="" w:author="{$author}" w:date="{$this-dateTime-adjusted-for-Word}">
            <xsl:choose>
                <xsl:when
                    test="$overruled-by-last-author and $ignore-insertions-dropped-by-final-author"/>
                <xsl:when test="$overruled-by-last-author">
                    <w:del w:id="" w:author="{$last-author-label}" 
                        w:date="{$last-dateTime-adjusted-for-Word}">
                        <w:r>
                            <w:delText>
                                <xsl:if test="matches(tan:txt, '^\s|\s\s|\s$')">
                                    <xsl:attribute name="xml:space">preserve</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="tan:txt"/>
                            </w:delText>
                        </w:r>
                    </w:del>
                </xsl:when>
                <xsl:otherwise>
                    <w:r>
                        <w:t>
                            <xsl:if test="matches(tan:txt, '^\s|\s\s|\s$')">
                                <xsl:attribute name="xml:space">preserve</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="tan:txt"/>
                        </w:t>
                    </w:r>
                </xsl:otherwise>
            </xsl:choose>
        </w:ins>
    </xsl:template>
    
    
    
    <xsl:variable name="source-docx.cleaned-and-parcel-bookmarked" as="document-node()*">
        <xsl:apply-templates select="$source-docx.infused-with-history[w:document or w:footnotes or w:endnotes]"
            mode="bookmark-parcels-and-clean"/>
        <xsl:sequence select="$source-docx.infused-with-history[not(w:document) and not(w:footnotes) and not(w:endnotes)]"/>
    </xsl:variable>
    <xsl:variable name="current-bookmarks" as="element()*"
        select="$source-docx.infused-with-history/w:document//w:bookmarkStart"/>
    
    <xsl:variable name="ps-with-parcel-marker" as="element()*"
        select="$source-docx.infused-with-history/w:document//w:p[contains(., '?parcel')]"/>
    
    <xsl:accumulator name="parcel-count" as="xs:integer" initial-value="0">
        <xsl:accumulator-rule match="w:p[contains(., '?parcel')]" select="$value + 1" phase="end"/>
    </xsl:accumulator>
    
    <xsl:mode name="bookmark-parcels-and-clean" on-no-match="shallow-copy" use-accumulators="parcel-count"/>
    
    <xsl:template match="w:p[contains(., '?parcel')]" mode="bookmark-parcels-and-clean">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(accumulator-before('parcel-count') = accumulator-after('parcel-count'))">
                <xsl:variable name="bookmark-id" as="xs:integer" select="count($current-bookmarks) + accumulator-after('parcel-count')"/>
                <w:bookmarkStart w:id="{$bookmark-id}" w:name="parcel_{format-integer(accumulator-after('parcel-count'), string(count($ps-with-parcel-marker)))}"/>
                <w:bookmarkEnd w:id="{$bookmark-id}"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()" mode="bookmark-parcels-and-clean">
        <xsl:text>{translate(., $serialized-space-replacement || $footnote-signal-replacement, ' ')}</xsl:text>
    </xsl:template>


    <xsl:output indent="no"/>

    <xsl:template match="/" use-when="$return-only-docx-components eq false()">
        <xsl:element name="HistDocx">
            <xsl:attribute name="version" select="$HistDocx-version"/>
            <source-docx-uri><xsl:copy-of select="$source-docx-uri-resolved"/></source-docx-uri>
            <target-docx-uri><xsl:copy-of select="$target-docx-uri"/></target-docx-uri>
            <author-labels>{string-join($collation-labels, ', ')}</author-labels>
            <!--<changed-versions-uris-resolved>
                <xsl:value-of select="$changed-versions.uris-resolved"/>
            </changed-versions-uris-resolved>-->
            <!--<xsl:copy-of select="$source-docx-repaired[w:document]"/>-->
            <!--<xsl:copy-of select="$changed-versions.documents"/>-->
            <!--<docx-norm><xsl:copy-of select="$source-docx.document-norm"/></docx-norm>-->
            <!--<xsl:for-each select="$changed-versions.main-documents-norm">
                <changed-version-main-document n="{position()}"><xsl:copy-of select="."/></changed-version-main-document>
            </xsl:for-each>-->
            <!--<xsl:for-each select="$changed-versions.foonotes-norm">
                <changed-version-footnotes n="{position()}">
                    <xsl:copy-of select="."/>
                </changed-version-footnotes>
            </xsl:for-each>-->
            <!--<xsl:apply-templates select="$docx-main-text-collation" mode="indent-collation"/>-->
            <!--<xsl:apply-templates select="$docx-footnotes-collation" mode="indent-collation"/>-->
            
            <!--<docx-main-text-deletions>
                <xsl:value-of select="$docx-main-text-deletion-positions => sort()"/>
            </docx-main-text-deletions>-->
            <!--<docx-main-text-insertions>
                <xsl:value-of select="$docx-main-text-insertion-positions => sort()"/>
            </docx-main-text-insertions>-->
            <!--<docx-footnotes-insertions>
                <xsl:value-of select="$docx-footnotes-insertion-positions"/>
            </docx-footnotes-insertions>-->
            <!--<xsl:copy-of select="$source-docx.cleaned-and-parcel-bookmarked[w:document]"/>-->
            <!--<xsl:copy-of select="$source-docx.parcel-bookmarked[w:footnotes]"/>-->
        </xsl:element>

        <xsl:if test="exists($source-docx.cleaned-and-parcel-bookmarked)">
            <xsl:message>Saving to {$target-docx-uri}</xsl:message>
            <xsl:call-template name="tan:save-docx">
                <xsl:with-param name="docx-components" select="$source-docx.cleaned-and-parcel-bookmarked"/>
                <xsl:with-param name="resolved-uri" select="$target-docx-uri"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:mode name="indent-collation" on-no-match="shallow-copy"/>

    <xsl:template match="*" mode="indent-collation">
        <xsl:text>&#xa;{ancestor::* ! '  '}</xsl:text>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="/" use-when="$return-only-docx-components eq true()">
        <xsl:sequence select="$source-docx.cleaned-and-parcel-bookmarked"/>
    </xsl:template>

</xsl:stylesheet>
