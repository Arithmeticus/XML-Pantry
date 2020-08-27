<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" type="ladder:manage-files"
   name="manage-files" xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Prototype for short XProc ladders to assist in file management. -->
   
   <!-- Feature import-functions not available in current working edition of Morgana -->
   <!--<p:import-functions href="ladder-functions.xsl"/>-->
   
   <p:input port="source" primary="true">
      <p:inline>
         <diagnostics/>
      </p:inline>
   </p:input>

   <p:output port="result" serialization="map{ 'indent': true() }"/>
   
   <p:option name="file-operation" required="true" as="xs:string"
      values="('copy', 'delete', 'move')"/>
   <p:option name="source-directory-resolved" as="xs:string"/>
   <p:option name="target-directory-relative-to-source" as="xs:string"/>
   <p:option name="filenames-to-include" as="xs:string?"/>
   <p:option name="filenames-to-exclude" as="xs:string?"/>
   <p:option name="pattern-type" as="xs:string" values="('glob', 'regex')" select="'glob'"/>
   <p:option name="overwrite" as="xs:string" values="('all', 'none', 'older')" select="'none'"/>
   <p:option name="recurse" as="xs:boolean" select="false()"/>
   

   <!-- MAIN STEPS BEGIN HERE -->
   
   <!-- The following variables have been commented out, because ladder:glob-to-regex() cannot be imported by working edition of Morgana. -->
   <!--<p:variable name="include-pattern-norm"
      select="if ($pattern-type eq 'glob') then ladder:glob-to-regex($filenames-to-include) else $filenames-to-include"
   />
   <p:variable name="exclude-pattern-norm"
      select="if ($pattern-type eq 'glob') then ladder:glob-to-regex($filenames-to-exclude) else $filenames-to-exclude"
   />-->
   
   <p:variable name="get-file-details" as="xs:boolean" select="$overwrite eq 'older'"/>
   <p:variable name="max-depth" as="xs:string" select="if ($recurse) then 'unbounded' else '1'"/>
   
   <p:variable name="source-directory-resolved-norm" select="replace($source-directory-resolved, '[^/]$', '$0/')"/>
   <p:variable name="target-directory-resolved"
      select="replace(resolve-uri($target-directory-relative-to-source, $source-directory-resolved-norm), '[^/]$', '$0/')"/>
   
   <p:if test="not($overwrite eq 'all') and not($file-operation eq 'delete')" name="t-dir-list">
      <p:output port="result" primary="true"/>
      <!-- If we could convert glob to regex before this point, we could feed in the include and exclude parameters here -->
      <p:directory-list path="{$target-directory-resolved}" detailed="{$get-file-details}" max-depth="{$max-depth}"/>
   </p:if>
   <p:variable name="target-directory-list" select="."/>
   
   <!-- If we could convert glob to regex before this point, we could add parameters for including and excluding filenames here -->
   <p:directory-list path="{$source-directory-resolved}" name="s-dir-list" detailed="{$get-file-details}" max-depth="{$max-depth}"/>
   <p:variable name="source-directory-list" select="/"/>
   
   <p:variable name="xslt-map"
      select="map{
      'file-operation': $file-operation,
      'target-directory-relative-to-source': $target-directory-relative-to-source,
      'filenames-to-include': $filenames-to-include,
      'filenames-to-exclude': $filenames-to-exclude,
      'pattern-type': $pattern-type,
      'overwrite': $overwrite,
      'target-directory-list': $target-directory-list}"
   />
   
   <p:xslt name="dir-files" parameters="$xslt-map">
      <p:with-input port="stylesheet" href="prepare-file-operations.xsl"/>
   </p:xslt>
   
   <p:count name="dir-file-count">
      <p:with-input pipe="result@dir-files"/>
   </p:count>
   
   <p:for-each name="dir-file-move">
      <p:with-input select="move" pipe="result@dir-files"/>
      <p:output port="move-result">
         <p:pipe port="result" step="move-action"/>
      </p:output>
      <p:variable name="move-href" select="move/href"/>
      <p:variable name="move-target" select="move/target"/>
      <p:file-move href="{$move-href}" target="{$move-target}" name="move-action"/>
   </p:for-each>
   
   <p:for-each name="dir-file-copy">
      <p:with-input select="copy" pipe="result@dir-files"/>
      <p:output port="copy-result">
         <p:pipe port="result" step="copy-action"/>
      </p:output>
      <p:variable name="copy-href" select="copy/href"/>
      <p:variable name="copy-target" select="copy/target"/>
      <p:file-copy href="{$copy-href}" target="{$copy-target}" name="copy-action"/>
   </p:for-each>
   
   <p:for-each name="dir-file-delete">
      <p:with-input select="delete" pipe="result@dir-files"/>
      <p:output port="delete-result">
         <p:pipe port="result" step="delete-action"/>
      </p:output>
      <p:variable name="delete-href" select="delete/href"/>
      <p:file-delete href="{$delete-href}" name="delete-action"/>
   </p:for-each>
   
   
   <p:insert match="/*" position="first-child" name="diagnostics-pass-1">
      <p:with-input port="source">
         <p:pipe port="source" step="manage-files"/>
      </p:with-input>
      <p:with-input port="insertion">
         <p:inline exclude-inline-prefixes="#all">
            <input-options>
               <file-operation>{$file-operation}</file-operation>
               <source-directory-resolved>{$source-directory-resolved}</source-directory-resolved>
               <target-directory-relative-to-source>{$target-directory-relative-to-source}</target-directory-relative-to-source>
               <filenames-to-include>{$filenames-to-include}</filenames-to-include>
               <filenames-to-exclude>{$filenames-to-exclude}</filenames-to-exclude>
               <pattern-type>{$pattern-type}</pattern-type>
               <overwrite>{$overwrite}</overwrite>
               <recurse>{$recurse}</recurse>
            </input-options>
            <step-results>
               <source-directory-list>{$source-directory-list}</source-directory-list>
               <target-directory-resolved>{$target-directory-resolved}</target-directory-resolved>
               <target-directory-list>{$target-directory-list}</target-directory-list>
               <number-of-files-acted-on/>
               <actions-taken/>
            </step-results>
            
         </p:inline>
      </p:with-input>
   </p:insert>
   <p:insert match="/*/*/number-of-files-acted-on" position="first-child" name="diagnostics-pass-2">
      <p:with-input port="insertion">
         <p:pipe port="result" step="dir-file-count"/>
      </p:with-input>
   </p:insert>
   <p:insert match="/*/*/actions-taken" position="first-child" name="diagnostics-pass-3">
      <p:with-input port="insertion">
         <p:pipe port="move-result" step="dir-file-move"/>
         <p:pipe port="copy-result" step="dir-file-copy"/>
         <p:pipe port="delete-result" step="dir-file-delete"/>
      </p:with-input>
   </p:insert>

</p:declare-step>
