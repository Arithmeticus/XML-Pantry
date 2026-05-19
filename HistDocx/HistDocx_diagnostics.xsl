<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tan="tag:textalign.net,2015:ns" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:fr="http://gpo.gov/franklin"
    xmlns:ssh="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:file="http://expath.org/ns/file"
    exclude-result-prefixes="#all"
    expand-text="yes" version="3.0">
    
    
    <!-- Used to run diagnostics on HistDocx -->
    
    <xsl:param name="frdoc-of-interest" as="xs:string" select="'2026-08480'"/>
    <xsl:variable name="frdoc-parts" as="xs:string+"
        select="reverse(tokenize($frdoc-of-interest, '-'))"/>
    <xsl:variable name="frdoc-year" as="xs:string" select="$frdoc-parts[2]"/>
    <xsl:variable name="frdoc-cluster" as="xs:string" select="$frdoc-parts[1] => replace('\d\d$', 'XX')"/>
    
    <!--<xsl:param name="base-dir" as="xs:string" select="'file:/C:/Users/jkalvesmaki/OneDrive%20-%20Government%20Printing%20Office%20(GPO)/Federal%20Register/workflow/master_data/frdocs'"/>-->
    <!--<xsl:param name="base-dir" as="xs:string" select="'file:/G:/FR/master_data/frdocs'"/>-->
    <xsl:param name="base-dir" as="xs:string" select="'file:/D:/xcs/fr_shadow/20260501/2026-08480/test'"/>
    
    <xsl:param name="changed-versions.max" as="xs:integer?" select="1"/>
    
    <xsl:param name="ignore-insertions-dropped-by-final-author" as="xs:boolean" select="true()"/>
    
    <!--<xsl:variable name="target-folder" as="xs:string"
        select="string-join(($base-dir, $frdoc-year, $frdoc-cluster, $frdoc-of-interest), '/')"/>-->
    <xsl:variable name="target-folder" as="xs:string" select="$base-dir"/>
    
    <xsl:variable name="fr-folder-uri-collection" as="xs:anyURI*" select="uri-collection($target-folder)"/>
    <xsl:param name="source-docx-uri-resolved" as="xs:string" select="$fr-folder-uri-collection[matches(., '\d\d\d\d-\d\d\d\d\d\.docx', 'i')]"/>
    
    <xsl:param name="changed-versions.uris-resolved" as="xs:string*"
        select="($fr-folder-uri-collection[matches(., '\d\d\d\d\d(\.fedreg_mw|\.fedreg\.[\w_-]+\.[\w_-]+\.|\.ixml\.xml|\.xcs\.sgm)', 'i') 
        or matches(., '\d+\.ixml\.xml', 'i')][not(matches(., '\.log|ixml2fedreg'))] 
        => sort((), file:last-modified#1))[position() le $changed-versions.max]"
    />
    
    <!--<xsl:param name="changed-versions.labels" as="xs:string*"
        select="$changed-versions.uris-resolved ! (replace(., '^.+fedreg\.(\w+)\.(\w+)\.\d\d\d\d-\d\d-\d\d.+', '$1_$2') 
        => replace('^.+\d+\.ixml.+$', 'Word2IXML'))"
    />-->
    <xsl:param name="changed-versions.labels" as="xs:string*">
        <xsl:for-each select="$changed-versions.uris-resolved">
            <xsl:choose>
                <xsl:when test="matches(., '\.ixml\.xml', 'i')">
                    <!-- example: 2020-16690.ixml.xml -->
                    <xsl:sequence select="'Word2IXML'"/>
                </xsl:when>
                <xsl:when test="matches(., 'mw', 'i')">
                    <!-- example: 2018-28059.fedreg_mw.2026-02-26_18-43-20.xml -->
                    <xsl:sequence select="'IXML2FR+MW'"/>
                </xsl:when>
                <xsl:when test="matches(., '\.staff\.xml', 'i')">
                    <!-- example: 2020-16690.fedreg.markup.staff.xml -->
                    <!-- Amalgamations of parcel work credit the staff as a whole, since there are many individuals 
                         to be credited or blamed. -->
                    <xsl:sequence
                        select="tokenize(., '\.')[position() = (3, 4)] => string-join('_')"/>
                </xsl:when>
                <xsl:when test="matches(., '\.(\w+)\.(\w+)\.\d\d\d\d-\d\d-\d\d', 'i')">
                    <!-- example: 2020-16690.fedreg.prepping.jkalvesmaki.2024-06-26_02-57-03.xml -->
                    <xsl:sequence
                        select="replace(., '^.+fedreg\.(\w+)\.(\w+)\.\d\d\d\d-\d\d-\d\d.+', '$1_$2')"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <!-- fallback: the filename -->
                    <xsl:sequence select="replace(., '^.+/([^/]+)$', '$1')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:param>
    
    <xsl:param name="changed-versions.dateTimes" as="xs:dateTime*"
        select="$changed-versions.uris-resolved ! file:last-modified(.)"/>
    
    <xsl:param name="target-docx-uri" as="xs:string"
        select="replace($source-docx-uri-resolved, '\.docx$', '.hist-diagnostics.docx')"/>
    
    <xsl:import href="HistDocx.xsl"/>
    
    <xsl:output indent="yes"/>
    <xsl:template match="/" priority="1">
        <diagnostics>
            <author-labels>{string-join($collation-labels, ', ')}</author-labels>
            <fr-folder-uri-collection>{$fr-folder-uri-collection}</fr-folder-uri-collection>
            <changed-versions-uris-resolved>
                <xsl:value-of select="$changed-versions.uris-resolved"/>
            </changed-versions-uris-resolved>
            <!--<source-docx>
                <xsl:copy-of select="$source-docx-repaired[w:document]"/>
                <!-\-<xsl:copy-of select="$source-docx-repaired[w:footnotes or w:endnotes]"/>-\->
            </source-docx>-->
            <!--<xsl:copy-of select="$source-docx.main-document-norm"/>-->
            <!--<xsl:copy-of select="$source-docx.footnotes-norm"/>-->
            <!--<xsl:for-each select="$changed-versions.documents">
                <changed-version n="{position()}">
                    <xsl:copy-of select="."/>
                </changed-version>
            </xsl:for-each>-->
            <xsl:for-each select="$changed-versions.main-documents-norm">
                <changed-ver-main n="{position()}"><xsl:copy-of select="."/></changed-ver-main>
            </xsl:for-each>
            <xsl:for-each select="$changed-versions.foonotes-norm">
                <changed-ver-notes n="{position()}"><xsl:copy-of select="."/></changed-ver-notes>
            </xsl:for-each>
            <!--<xsl:apply-templates select="$docx-main-text-collation" mode="indent-collation"/>-->
            <!--<xsl:apply-templates select="$docx-main-text-collation-norm" mode="indent-collation"/>-->
            <!--<xsl:apply-templates select="$docx-footnotes-collation" mode="indent-collation"/>-->
            <!--<xsl:apply-templates select="$docx-footnotes-collation-norm" mode="indent-collation"/>-->
            <!--<docx-main-text-deletion-points>
                <xsl:value-of select="$docx-main-text-deletion-positions => sort()"/>
            </docx-main-text-deletion-points>-->
            <!--<docx-main-text-insertion-points>
                <xsl:value-of select="$docx-main-text-insertion-positions => sort()"/>
            </docx-main-text-insertion-points>-->
            <!--<docx-footnote-deletion-points>
                <xsl:value-of select="$docx-footnotes-deletion-positions => sort()"/>
            </docx-footnote-deletion-points>-->
            <!--<docx-footnote-insertion-points>
                <xsl:value-of select="$docx-footnotes-insertion-positions => sort()"/>
            </docx-footnote-insertion-points>-->
            <!--<source-docx-infused-with-history>
                <xsl:copy-of select="$source-docx.infused-with-history[w:document]"/>
            </source-docx-infused-with-history>-->
            <!--<source-docx-cleaned-and-parcel-bookmarked>
                <xsl:copy-of select="$source-docx.cleaned-and-parcel-bookmarked[w:document]"/>
            </source-docx-cleaned-and-parcel-bookmarked>-->
            <!--<result-docx>
                <xsl:copy-of select="$source-docx.cleaned-and-parcel-bookmarked[w:document]"/>
                <!-\-<xsl:copy-of select="$source-docx.cleaned-and-parcel-bookmarked[w:footnotes]"/>-\->
            </result-docx>-->
            
        </diagnostics>
        <xsl:if test="exists($source-docx.cleaned-and-parcel-bookmarked)">
            <xsl:message>Saving to {$target-docx-uri}</xsl:message>
            <xsl:call-template name="tan:save-docx">
                <xsl:with-param name="docx-components" select="$source-docx.cleaned-and-parcel-bookmarked"/>
                <xsl:with-param name="resolved-uri" select="$target-docx-uri"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
