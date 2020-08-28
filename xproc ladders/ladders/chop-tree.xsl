<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" 
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Input: an XML document -->
   <!-- Output: one document per descendant element, per parameters specified -->
   <!-- This stylesheet was written to support the XProc ladder <ladder:chop-tree>. -->
   <!-- The name of this application alludes to the notion of chopping a tree right below
      its main branches, thereby making each branch a new tree in its own right. The default
      settings of the parameters are set up so that there is one result document per root-element
      child.
   -->
   <!-- Whenever an element is chopped and made into a new document, the descendants of that
   new tree will not be processed further. -->
   
   <!-- Very important to set build-tree to false, so that there is really a sequence of output documents. -->
   <xsl:output build-tree="false"/>
   
   <!-- PARAMETERS -->
   <!-- At what level should the tree be chopped? Must be 2 (default) or greater to have any effect. The number refers to the level of element hierarchy. -->
   <xsl:param name="chop-at-level" as="xs:integer?" select="2"/>
   
   <!-- What elements should become new documents? Expected: a regular expression to match against the local name. If empty, this value will be ignored. -->
   <xsl:param name="chop-elements-named-regex" as="xs:string?"/>
   
   <xsl:variable name="chop-level-is-in-effect" select="$chop-at-level gt 1"/>
   <xsl:variable name="chop-name-is-in-effect" select="string-length($chop-elements-named-regex) gt 0"/>
   
   <!-- We're skipping everything except elements (comments and pi's get skipped by default). -->
   <xsl:template match="text()"/>
   <xsl:template match="document-node()">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="/*" priority="1">
      <xsl:apply-templates>
         <xsl:with-param name="level-so-far" select="1"/>
      </xsl:apply-templates>
   </xsl:template>
   <xsl:template match="*">
      <xsl:param name="level-so-far" as="xs:integer"/>
      <xsl:variable name="this-name" select="name(.)"/>
      <xsl:variable name="this-level" select="$level-so-far + 1"/>
      <xsl:variable name="chop-here" select="($chop-level-is-in-effect and $this-level eq $chop-at-level)
         or ($chop-name-is-in-effect and matches($this-name, $chop-elements-named-regex))"/>
      <xsl:choose>
         <xsl:when test="$chop-here">
            <xsl:document>
               <xsl:copy-of select="."/>
            </xsl:document>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates>
               <xsl:with-param name="level-so-far" select="$this-level"/>
            </xsl:apply-templates>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   
</xsl:stylesheet>
