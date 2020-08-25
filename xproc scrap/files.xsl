<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   <!-- Input: a document that is the result of XProc step p:directory-list -->
   <!-- Output: the document prepped for moving -->
   <!--<xsl:template match="node() | @*">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
   </xsl:template>-->

   <xsl:template match="c:file">
      <xsl:document>
         <xsl:copy>
            <xsl:value-of select="concat(../@xml:base, @xml:base)"/>
         </xsl:copy>
      </xsl:document>
   </xsl:template>
</xsl:stylesheet>
