<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" type="ladder:move-files"
   name="copy-files" xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- XProc 3.0 ladder for moving files. -->
   
   <p:import href="manage-files.xpl"/>
   
   <!-- Primary input can be anything. The real work is done by options. -->   
   <p:input port="source" primary="true"/>

   <!-- Primary output are diagnostic results of the operation. -->   
   <p:output port="result" serialization="map{ 'indent': true() }"/>
   
   <p:option name="source-directory-resolved" as="xs:string"/>
   <p:option name="target-directory-relative-to-source" as="xs:string"/>
   <p:option name="filenames-to-include" as="xs:string*"/>
   <p:option name="filenames-to-exclude" as="xs:string*"/>
   <p:option name="pattern-type" as="xs:string" values="('glob', 'regex')" select="'glob'"/>
   <p:option name="overwrite" as="xs:string" values="('all', 'none', 'older')" select="'none'"/>
   <p:option name="recurse" as="xs:boolean" select="false()"/>

   <ladder:manage-files>
      <p:with-option name="file-operation" select="'move'"/>
      <p:with-option name="source-directory-resolved" select="$source-directory-resolved"/>
      <p:with-option name="target-directory-relative-to-source" select="$target-directory-relative-to-source"/>
      <p:with-option name="filenames-to-include" select="$filenames-to-include"/>
      <p:with-option name="filenames-to-exclude" select="$filenames-to-exclude"/>
      <p:with-option name="pattern-type" select="$pattern-type"/>
      <p:with-option name="overwrite" select="$overwrite"/>
      <p:with-option name="recurse" select="$recurse"/>
   </ladder:manage-files>

</p:declare-step>
