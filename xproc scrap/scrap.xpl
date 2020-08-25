<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   name="xproc-scrap" xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   <p:input port="source" primary="true">
      <p:inline>
         <diagnostics/>
      </p:inline>
   </p:input>
   <p:input port="testdoc">
      <p:inline>
         <a>
            <b name="x">
               <c>more</c>
               <c>text</c>
            </b>
         </a>
      </p:inline>
   </p:input>

   <p:output port="result" serialization="map{ 'indent': true() }"/>


   <!-- MAIN STEPS BEGIN HERE -->
   <!-- ok -->
   <p:variable name="dir-a-path" select="'file:/u:/temp'" as="xs:string"/>
   <!-- ok -->
   <p:directory-list path="{$dir-a-path}" name="dir-a-list"/>
   
   <p:xslt name="dir-files">
      <p:with-input port="stylesheet" href="files.xsl"/>
   </p:xslt>
   
   <!-- mixed -->
   <!--<p:viewport match="c:directory" name="dir-list-test">
      <p:variable name="this-element" select="."/>
      <p:variable name="this-first-child" select="*[1]"/>
      <p:variable name="this-attr-name" select="@name"/>
      <p:insert position="first-child">
         <p:with-input port="insertion">
            <this-element>{$this-element}</this-element>
            <this-first-child>{$this-first-child}</this-first-child>
            <this-attr-name>{$this-attr-name}</this-attr-name>
         </p:with-input>
      </p:insert>
   </p:viewport>-->
   
   <!--<p:for-each match="a/b" name="testdoc-viewport">
      <p:with-input pipe="testdoc"/>
      <!-\-<p:with-input>
         <p:pipe port="testdoc" step="xproc-scrap"/>
      </p:with-input>-\->
      <p:variable name="this-element" select="."/>
      <p:variable name="this-parent" select="."/>
      <p:variable name="this-first-child" select="*[1]"/>
      <p:variable name="this-attr-name" select="@name"/>
      <p:insert position="first-child">
         <p:with-input port="insertion">
            <this-element>{$this-element}</this-element>
            <this-parent>{$this-parent}</this-parent>
            <this-first-child>{$this-first-child}</this-first-child>
            <this-attr-name>{$this-attr-name}</this-attr-name>
         </p:with-input>
      </p:insert>
      
   </p:for-each>-->

   <p:insert match="/*" position="first-child" name="diagnostics">
      <p:with-input port="source">
         <p:pipe port="source" step="xproc-scrap"/>
      </p:with-input>
      <p:with-input port="insertion">
         <p:pipe port="result" step="dir-a-list"/>
         <p:pipe port="result" step="dir-files"/>
         <!--<p:pipe port="result" step="dir-list-test"/>-->
         <!--<p:pipe port="result" step="testdoc-viewport"/>-->
      </p:with-input>
   </p:insert>

</p:declare-step>
