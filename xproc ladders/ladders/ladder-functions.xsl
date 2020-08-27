<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" 
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Function library to support XProc Ladders -->
   
   <xsl:function name="ladder:glob-to-regex" as="xs:string*">
      <!-- Input: any strings that follow a glob-like syntax -->
      <!-- Output: the strings converted to regular expressions -->
      <!-- This function assumes that instances of the comma (optionally followed by space) separate multiple globs -->
      <xsl:param name="globs" as="xs:string*"/>
      <xsl:for-each select="$globs">
         <!-- 1st escape any special regex characters that are not glob special characters -->
         <xsl:variable name="pass1" select="replace(., '([\\\+\|\^\$\{\}\(\)\.])', '\\$0')"/>
         <!-- Next replace the * with regex 0 or more characters -->
         <xsl:variable name="pass2" select="replace($pass1, '\*', '.*')"/>
         <!-- Next replace the ? with regex 1 character -->
         <xsl:variable name="pass3" select="replace($pass2, '\?', '.')"/>
         <!-- The glob character class, marked by [ ], need not be tampered with -->
         <!-- We bind the ending to the end of the string ($) since a glob user assumes nothing beyond the last string -->
         <!-- We bind the opening either to a slash or to the beginning of a string, since the pattern could be a relative or resolved filename -->
         <xsl:variable name="pass4" select="for $i in tokenize($pass3, ',\s*') return ('^' || $i || '$|/' || $i || '$')"/>
         <xsl:value-of select="string-join($pass4, '|')"/>
      </xsl:for-each>
   </xsl:function>
   
</xsl:stylesheet>
