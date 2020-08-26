<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" 
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Input: a document that is the result of XProc step <p:directory-list> -->
   <!-- Output: one document per matching file with elements describing the action to take (copy, move, or delete), the filename, and the location -->
   <!-- Very important to set build-tree to false, so that there is really a sequence of output documents. -->
   <xsl:output build-tree="false"/>

   <!-- PARAMETERS -->
   <!-- What is the destination directory (for copying and moving)? -->
   <xsl:param name="target-directory-relative-to-source" as="xs:string?"/>
   <!-- If the local name (base name plus extension) is to be changed, what pattern should be searched (regular expression)? An empty string means no name change. -->
   <xsl:param name="filename-change-pattern" as="xs:string?"/>
   <!-- If the local name (base name plus extension) is to be changed, what should replace the pattern (regular expression)? An empty string means no name change. -->
   <xsl:param name="filename-change-replacement" as="xs:string?"/>
   
   <!-- What is the desired operation: copy, delete, or move? -->
   <xsl:param name="file-operation" required="yes" as="xs:string"/>
   <!-- What pattern must the local filename (base name plus extension) match? If empty, no files will be filtered out. -->
   <xsl:param name="filenames-to-include" as="xs:string?"/>
   <!-- What pattern must the local filename (base name plus extension) NOT match? If empty, no files will be filtered out. -->
   <xsl:param name="filenames-to-exclude" as="xs:string?"/>
   <!-- Are pattern types glob-like or regular expressions? -->
   <xsl:param name="pattern-type" as="xs:string" select="'glob'"/>
   
   
   <!-- NORMALIZE INPUT PARAMETERS, ASSESS CONDITIONS -->
   <xsl:variable name="operation-picked" as="xs:string?">
      <xsl:choose>
         <xsl:when test="lower-case($file-operation) eq 'copy'">copy</xsl:when>
         <xsl:when test="lower-case($file-operation) eq 'move'">move</xsl:when>
         <xsl:when test="lower-case($file-operation) eq 'delete'">delete</xsl:when>
      </xsl:choose>
   </xsl:variable>
   
   <xsl:variable name="source-directory-resolved" select="/*/@xml:base"/>
   <xsl:variable name="target-dir-norm"
      select="replace(resolve-uri($target-directory-relative-to-source, $source-directory-resolved), '[^/]$', '$0/')"
   />
   
   <xsl:function name="ladder:glob-to-regex" as="xs:string*">
      <!-- Input: any strings that follow a glob-like syntax -->
      <!-- Output: the strings converted to regular expressions -->
      <!-- This function assumes that instances of the comma (optionally followed by space) separate multiple globs -->
      <xsl:param name="globs" as="xs:string*"/>
      <xsl:for-each select="$globs">
         <!-- 1st escape any special regex characters that are not glob special characters -->
         <xsl:variable name="pass1" select="replace(., '([\\\+\|\^\$\{\}\(\)])', '\\$0')"/>
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
   
   <xsl:variable name="filename-must-match-regex" as="xs:string?"
      select="
         if ($pattern-type = 'glob') then
            ladder:glob-to-regex($filenames-to-include)
         else
            $filenames-to-include"
   />
   <xsl:variable name="filename-must-not-match-regex" as="xs:string?"
      select="
         if ($pattern-type = 'glob') then
            ladder:glob-to-regex($filenames-to-exclude)
         else
            $filenames-to-exclude"
   />
   
   <xsl:variable name="filenames-should-be-changed"
      select="string-length($filename-change-pattern) gt 0 and string-length($filename-change-replacement) gt 0"
   />
   
   
   <!-- RETURN RESULTS -->
   <xsl:template match="/*">
      <xsl:choose>
         <xsl:when test="$operation-picked = ('move', 'copy') 
            and string-length($target-directory-relative-to-source) lt 1">
            <xsl:message terminate="yes"
               select="'A ' || $operation-picked || ' operation must include a target location'"/>
         </xsl:when>
         <xsl:when test="not(exists($operation-picked))">
            <xsl:message terminate="yes"
               select="'The parameter $file-operation must be copy, move, or delete.'"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates mode="#current"/>
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>

   <xsl:template match="c:file">
      <xsl:variable name="this-filename" select="@name"/>
      <!-- matches should not be cases-sensitive -->
      <xsl:variable name="act-on-this-file" as="xs:boolean"
         select="
            (if (string-length($filename-must-match-regex) gt 0) then
               (matches($this-filename, $filename-must-match-regex, 'i'))
            else
               true()) and (if (string-length($filename-must-not-match-regex) gt 0) then
               (not(matches($this-filename, $filename-must-not-match-regex, 'i')))
            else
               true())"
      />
      <xsl:variable name="new-name"
         select="
            if ($filenames-should-be-changed) then
               replace(@xml:base, $filename-change-pattern, $filename-change-replacement)
            else
               @xml:base"
      />
      <xsl:if test="$act-on-this-file">
         <xsl:document>
            <xsl:element name="{$operation-picked}">
               <href><xsl:value-of select="../@xml:base || @xml:base"/></href>
               <xsl:if test="$operation-picked = ('move', 'copy')">
                  <target><xsl:value-of select="$target-dir-norm || @xml:base"/></target>
               </xsl:if>
            </xsl:element>
         </xsl:document>
      </xsl:if>
   </xsl:template>
</xsl:stylesheet>
