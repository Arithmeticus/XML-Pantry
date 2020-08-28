<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ladder="tag:kalvesmaki.com,2020:ns"
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Input: an XML document -->
   <!-- Output: the same document, but with each attribute replaced by one or more elements under its parent. -->

   <!-- This stylesheet was written to support the XProc ladder <ladder:expand-attributes>. -->

   <!-- What attributes if any have space-delimited multiple values? Those attributes whose names match the regular expression will result in one element per value. -->
   <xsl:param name="attributes-with-multiple-values-regex" as="xs:string?"/>

   <xsl:variable name="try-expanding-attributes"
      select="string-length($attributes-with-multiple-values-regex) gt 0"/>
   <xsl:template match="/">
      <xsl:document>
         <xsl:choose>
            <xsl:when test="$try-expanding-attributes">
               <xsl:apply-templates mode="expand-attributes"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:document>
   </xsl:template>
   <xsl:template match="node()" mode="#all">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
   </xsl:template>
   <xsl:template match="@*">
      <xsl:element name="{name(.)}">
         <xsl:value-of select="."/>
      </xsl:element>
   </xsl:template>
   <xsl:template match="@*" mode="expand-attributes">
      <xsl:variable name="this-name" select="name(.)"/>
      <xsl:variable name="this-matches"
         select="matches($this-name, $attributes-with-multiple-values-regex)"/>
      <xsl:choose>
         <xsl:when test="$this-matches">
            <xsl:for-each select="tokenize(normalize-space(.), ' ')">
               <xsl:element name="{$this-name}">
                  <xsl:value-of select="."/>
               </xsl:element>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:element name="{$this-name}">
               <xsl:value-of select="."/>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>


</xsl:stylesheet>
