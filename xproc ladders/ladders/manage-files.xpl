<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" type="ladder:manage-files"
   name="manage-files" xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Prototype for short XProc ladders to assist in file management. -->
   
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
   

   <!-- MAIN STEPS BEGIN HERE -->
   <p:variable name="xslt-map"
      select="map{
      'file-operation': $file-operation,
      'target-directory-relative-to-source': $target-directory-relative-to-source,
      'filenames-to-include': $filenames-to-include,
      'filenames-to-exclude': $filenames-to-exclude,
      'pattern-type': $pattern-type}"
   />
   
   <p:directory-list path="{$source-directory-resolved}" name="dir-list"/>

   <p:xslt name="dir-files" parameters="map{
      'file-operation': $file-operation,
      'target-directory-relative-to-source': $target-directory-relative-to-source,
      'filenames-to-include': $filenames-to-include,
      'filenames-to-exclude': $filenames-to-exclude,
      'pattern-type': $pattern-type}">
      <p:with-input port="stylesheet" href="prepare-file-operations.xsl"/>
   </p:xslt>
   
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

   <p:count name="dir-file-count">
      <p:with-input pipe="result@dir-files"/>
   </p:count>

   <p:insert match="/*" position="first-child" name="diagnostics">
      <p:with-input port="source">
         <p:pipe port="source" step="manage-files"/>
      </p:with-input>
      <p:with-input port="insertion">
         <p:pipe port="result" step="dir-list"/>
         <p:pipe port="result" step="dir-files"/>
         <p:pipe port="move-result" step="dir-file-move"/>
         <p:pipe port="copy-result" step="dir-file-copy"/>
         <p:pipe port="delete-result" step="dir-file-delete"/>
         <p:pipe port="result" step="dir-file-count"/>
      </p:with-input>
   </p:insert>

</p:declare-step>
