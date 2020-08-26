<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" type="ladder:file" name="manage-files"
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">

   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Tests for XProc Ladders -->

   <p:import href="../xproc%20ladders/xproc-ladders.xpl"/>

   <p:input port="source" primary="true">
      <p:inline>
         <diagnostics/>
      </p:inline>
   </p:input>

   <p:output port="result" serialization="map{ 'indent': true() }"/>
   
   <ladder:copy-files>
      <p:with-option name="source-directory-resolved" select="'file:/u:/temp'"/>
      <p:with-option name="target-directory-relative-to-source" select="'temp'"/>
      <p:with-option name="filenames-to-include" select="'*Copy*.txt'"/>
   </ladder:copy-files>
   
   <!--<ladder:move-files>
      <p:with-option name="source-directory-resolved" select="'file:/u:/temp'"/>
      <p:with-option name="target-directory-relative-to-source" select="'temp'"/>
      <p:with-option name="filenames-to-include" select="'*Copy*.txt'"/>
   </ladder:move-files>-->
   
   <ladder:delete-files>
      <p:with-option name="source-directory-resolved" select="'file:/u:/temp/temp'"/>
      <p:with-option name="filenames-to-include" select="'*Copy*.txt'"/>
   </ladder:delete-files>

   
</p:declare-step>
