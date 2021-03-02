<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:k="tag:kalvesmaki.com,2020:ns"
   xmlns:math="http://www.w3.org/2005/xpath-functions/math"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   version="3.0">
   
   <!-- Function library for control characters -->
   
   <xsl:variable name="k:control-chars" as="xs:string">&#x1;&#x2;&#x3;&#x4;&#x5;&#x6;&#x7;&#x8;&#xb;&#xc;&#xe;&#xf;&#x10;&#x11;&#x12;&#x13;&#x14;&#x15;&#x16;&#x17;&#x18;&#x19;&#x1a;&#x1b;&#x1c;&#x1d;&#x1e;&#x1f;&#x7f;</xsl:variable>
   <xsl:variable name="k:control-pictures" as="xs:string">␁␂␃␄␅␆␇␈␋␌␎␏␐␑␒␓␔␕␖␗␘␙␚␛␜␝␞␟␡</xsl:variable>
   
   <xsl:function name="k:controls-to-pictures" as="item()*">
      <!-- Input: any items -->
      <!-- Output: the items, but with any control characters changed to control pictures (U+2400 onward) -->
      <!-- This function excludes &#x0; &#x9; &#xa; &#xd; -->
      <xsl:param name="items-to-change" as="item()*"/>
      <xsl:apply-templates select="$items-to-change" mode="k:controls-to-pictures"/>
   </xsl:function>
   
   <xsl:mode name="k:controls-to-pictures" on-no-match="shallow-copy"/>
   <xsl:template match="text()" mode="k:controls-to-pictures">
      <xsl:value-of select="translate(., $k:control-chars, $k:control-pictures)"/>
   </xsl:template>
   <xsl:template match="comment()" mode="k:controls-to-pictures">
      <xsl:comment><xsl:value-of select="translate(., $k:control-chars, $k:control-pictures)"/></xsl:comment>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="k:controls-to-pictures">
      <xsl:processing-instruction name="{name(.)}" select="translate(., $k:control-chars, $k:control-pictures)"/>
   </xsl:template>
   <xsl:template match="@*" mode="k:controls-to-pictures">
      <xsl:attribute name="{name(.)}" select="translate(., $k:control-chars, $k:control-pictures)"/>
   </xsl:template>
   <xsl:template match=".[. instance of xs:string]" mode="k:controls-to-pictures">
      <xsl:sequence select="translate(., $k:control-chars, $k:control-pictures)"/>
   </xsl:template>
   
   <xsl:function name="k:pictures-to-controls" as="item()*">
      <!-- Input: any items -->
      <!-- Output: the items, but with any control pictures (U+2400) changed to control characters -->
      <!-- This function excludes &#x0; &#x9; &#xa; &#xd; -->
      <xsl:param name="items-to-change" as="item()*"/>
      <xsl:apply-templates select="$items-to-change" mode="k:pictures-to-controls"/>
   </xsl:function>
   
   <xsl:mode name="k:pictures-to-controls" on-no-match="shallow-copy"/>
   <xsl:template match="text()" mode="k:pictures-to-controls">
      <xsl:value-of select="translate(., $k:control-pictures, $k:control-chars)"/>
   </xsl:template>
   <xsl:template match="comment()" mode="k:pictures-to-controls">
      <xsl:comment><xsl:value-of select="translate(., $k:control-pictures, $k:control-chars)"/></xsl:comment>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="k:pictures-to-controls">
      <xsl:processing-instruction name="{name(.)}" select="translate(., $k:control-pictures, $k:control-chars)"/>
   </xsl:template>
   <xsl:template match="@*" mode="k:pictures-to-controls">
      <xsl:attribute name="{name(.)}" select="translate(., $k:control-pictures, $k:control-chars)"/>
   </xsl:template>
   <xsl:template match=".[. instance of xs:string]" mode="k:pictures-to-controls">
      <xsl:sequence select="translate(., $k:control-pictures, $k:control-chars)"/>
   </xsl:template>
   
   <!-- For diagnostics, testing -->
   <xsl:param name="diagnostics-on" static="yes" select="false()"/>
   <!-- if you're going to return results as XML, do not forget to turn on version 1.1. -->
   <xsl:output indent="yes" version="1.1" use-when="$diagnostics-on"/>
   <xsl:template match="/" use-when="$diagnostics-on">
      <diagnostics>
         <control-chars-to-pix><xsl:sequence select="k:controls-to-pictures($k:control-chars)"></xsl:sequence></control-chars-to-pix>
         <control-pix-to-chars><xsl:sequence select="k:pictures-to-controls($k:control-pictures)"></xsl:sequence></control-pix-to-chars>
      </diagnostics>
   </xsl:template>
   
</xsl:stylesheet>