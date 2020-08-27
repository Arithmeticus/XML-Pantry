<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" 
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Input: a document that is the result of XProc step <p:directory-list> -->
   <!-- Output: one document per matching file with elements describing the action to take (copy, move, or delete), the filename, and the location -->
   
   <xsl:import href="ladder-functions.xsl"/>
   
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
   <xsl:param name="filenames-to-include" as="xs:string*"/>
   <!-- What pattern must the local filename (base name plus extension) NOT match? If empty, no files will be filtered out. -->
   <xsl:param name="filenames-to-exclude" as="xs:string*"/>
   <!-- Are pattern types glob-like or regular expressions? -->
   <xsl:param name="pattern-type" as="xs:string" select="'glob'"/>
   <!-- Which target files may be overwritten?Expected string values: all, none, older -->
   <xsl:param name="overwrite" as="xs:string" select="'none'"/>
   <!-- What is the directory for the target directory? Required if $overwrite is not 'all' -->
   <xsl:param name="target-directory-list" as="document-node()*"/>
   
   
   <!-- NORMALIZE INPUT PARAMETERS, ASSESS CONDITIONS -->
   <xsl:variable name="operation-picked" as="xs:string?">
      <xsl:choose>
         <xsl:when test="lower-case($file-operation) eq 'copy'">copy</xsl:when>
         <xsl:when test="lower-case($file-operation) eq 'move'">move</xsl:when>
         <xsl:when test="lower-case($file-operation) eq 'delete'">delete</xsl:when>
      </xsl:choose>
   </xsl:variable>
   
   <xsl:variable name="source-directory-resolved" select="/*/@xml:base"/>
   <xsl:variable name="target-dir-path-norm"
      select="replace(resolve-uri($target-directory-relative-to-source, $source-directory-resolved), '[^/]$', '$0/')"
   />
   
   <xsl:variable name="filename-must-match-regex" as="xs:string?"
      select="
         if ($pattern-type = 'glob') then
            ladder:glob-to-regex($filenames-to-include)
         else
            string-join($filenames-to-include, '|')"
   />
   <xsl:variable name="filename-must-not-match-regex" as="xs:string?"
      select="
         if ($pattern-type = 'glob') then
            ladder:glob-to-regex($filenames-to-exclude)
         else
            string-join($filenames-to-exclude, '|')"
   />
   
   <xsl:variable name="filenames-should-be-changed"
      select="string-length($filename-change-pattern) gt 0 and string-length($filename-change-replacement) gt 0"
   />
   
   <xsl:variable name="overwrite-norm" as="xs:string?">
      <xsl:choose>
         <xsl:when test="lower-case($overwrite) eq 'all'">all</xsl:when>
         <xsl:when test="lower-case($overwrite) eq 'none'">none</xsl:when>
         <xsl:when test="lower-case($overwrite) eq 'older'">older</xsl:when>
      </xsl:choose>
   </xsl:variable>
   
   <xsl:variable name="target-directory-list-prepped" as="document-node()*">
      <xsl:if test="not($overwrite-norm eq 'all')">
         <xsl:apply-templates select="$target-directory-list" mode="prep-target-dir-list"/>
      </xsl:if>
   </xsl:variable>
   <xsl:key name="target-entries" use="@resolved-uri" match="*"/>
   <xsl:template match="/" mode="prep-target-dir-list">
      <xsl:document>
         <xsl:apply-templates mode="#current"/>
      </xsl:document>
   </xsl:template>
   <xsl:template match="*" mode="prep-target-dir-list">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:attribute name="resolved-uri"
            select="string-join(ancestor-or-self::*[@xml:base]/@xml:base)"/>
         <xsl:apply-templates mode="#current"/>
      </xsl:copy>
   </xsl:template>
   
   
   
   
   <!-- RETURN RESULTS -->
   <xsl:template match="/*" priority="1">
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

   <xsl:template match="c:file | c:directory">
      <xsl:param name="relative-path-so-far" as="xs:string?"/>
      <xsl:variable name="this-filename" select="@name"/>
      <xsl:variable name="target-resolved-uri" select="$target-dir-path-norm || $relative-path-so-far || @xml:base"/>

      <!-- matches should not be case-sensitive -->
      <xsl:variable name="filename-is-ok" as="xs:boolean"
         select="
            (if (string-length($filename-must-match-regex) gt 0) then
               (matches($this-filename, $filename-must-match-regex, 'i'))
            else
               true()) and (if (string-length($filename-must-not-match-regex) gt 0) then
               (not(matches($this-filename, $filename-must-not-match-regex, 'i')))
            else
               true())"
      />
      <xsl:variable name="corresponding-target-dir-list-entries"
         select="
            for $i in $target-directory-list-prepped
            return
               key('target-entries', $target-resolved-uri, $i)"
      />
      <xsl:variable name="this-dateTime" select="xs:dateTime(@last-modified)"/>
      <xsl:variable name="target-dateTime"
         select="xs:dateTime($corresponding-target-dir-list-entries[@last-modified][1]/@last-modified)"
      />
      <xsl:variable name="preserve-target" as="xs:boolean">
         <xsl:choose>
            <xsl:when test="not($filename-is-ok) or not(exists($corresponding-target-dir-list-entries)) or ($overwrite-norm eq 'all')">
               <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="($overwrite-norm eq 'none')">
               <xsl:sequence select="exists($corresponding-target-dir-list-entries)"/>
            </xsl:when>
            <!-- overwrite = 'older' -->
            <xsl:when test="exists($corresponding-target-dir-list-entries) and (not(exists($this-dateTime)) or not(exists($target-dateTime)))">
               <xsl:message select="'A request to overwrite only older files requires that both the source and target directory lists be populated with @last-modified information.'"/>
               <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="not($this-dateTime gt $target-dateTime)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="act-on-this-file" as="xs:boolean"
         select="$filename-is-ok and not($preserve-target)"/>
      <xsl:variable name="new-name"
         select="
            if ($filenames-should-be-changed) then
               replace(@xml:base, $filename-change-pattern, $filename-change-replacement)
            else
               @xml:base"
      />
      <xsl:variable name="this-source-href" select="string-join(ancestor-or-self::*[@xml:base]/@xml:base)"/>
      
      <!-- For development and testing -->
      <xsl:variable name="inline-diagnostics-on" select="true()"/>
      
      <xsl:choose>
         <xsl:when test="$act-on-this-file and ($this-source-href eq $target-dir-path-norm)">
            <xsl:message
               select="'Cannot ' || $operation-picked || ' ' || $this-source-href || ' into itself. Other operations will be attempted.'"
            />
         </xsl:when>
         <xsl:when test="$act-on-this-file">
            <xsl:document>
               <xsl:element name="{$operation-picked}">
                  <href><xsl:value-of select="$this-source-href"/></href>
                  <xsl:if test="$operation-picked = ('move', 'copy')">
                     <target><xsl:value-of select="$target-dir-path-norm || $relative-path-so-far || @xml:base"/></target>
                  </xsl:if>
                  <xsl:if test="$inline-diagnostics-on">
                     <diagnostics>
                        <target-resolved-urui><xsl:value-of select="$target-resolved-uri"/></target-resolved-urui>
                        <file-must-match-regex><xsl:value-of select="$filename-must-match-regex"/></file-must-match-regex>
                        <file-must-not-match-regex><xsl:value-of select="$filename-must-not-match-regex"/></file-must-not-match-regex>
                        <filename-ok><xsl:value-of select="$filename-is-ok"/></filename-ok>
                        <corresponding-target-dir-list-entrise><xsl:copy-of select="$corresponding-target-dir-list-entries"/></corresponding-target-dir-list-entrise>
                        <this-dateTime><xsl:copy-of select="$this-dateTime"/></this-dateTime>
                        <target-dateTime><xsl:copy-of select="$target-dateTime"/></target-dateTime>
                        <preserve-target><xsl:value-of select="$preserve-target"/></preserve-target>
                        <act-on-this-file><xsl:value-of select="$act-on-this-file"/></act-on-this-file>
                     </diagnostics>
                  </xsl:if>
               </xsl:element>
            </xsl:document>
         </xsl:when>
         <xsl:otherwise>
            <!-- If this is a directory, we keep going to the contents. -->
            <xsl:apply-templates>
               <xsl:with-param name="relative-path-so-far" select="@xml:base"/>
            </xsl:apply-templates>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
