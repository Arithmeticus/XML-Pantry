<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" type="ladder:delete-files"
   name="copy-files" xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- XProc 3.0 ladder for deleting files. -->
   
   <p:import href="manage-files.xpl"/>
   
   <!-- Primary input can be anything. The real work is done by options. -->   
   <p:input port="source" primary="true"/>

   <!-- Primary output are diagnostic results of the operation. -->   
   <p:output port="result" serialization="map{ 'indent': true() }"/>
   
   <p:option name="source-directory-resolved" as="xs:string"/>
   <p:option name="filenames-to-include" as="xs:string?"/>
   <p:option name="filenames-to-exclude" as="xs:string?"/>
   <p:option name="pattern-type" as="xs:string" values="('glob', 'regex')" select="'glob'"/>

   <ladder:manage-files>
      <p:with-option name="file-operation" select="'delete'"/>
      <p:with-option name="source-directory-resolved" select="$source-directory-resolved"/>
      <p:with-option name="target-directory-relative-to-source" select="'.'"/>
      <p:with-option name="filenames-to-include" select="$filenames-to-include"/>
      <p:with-option name="filenames-to-exclude" select="$filenames-to-exclude"/>
      <p:with-option name="pattern-type" select="$pattern-type"/>
   </ladder:manage-files>

</p:declare-step>
