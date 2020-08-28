<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" type="ladder:chop-tree"
   name="chop-tree" xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- XProc 3.0 ladder for copying files. -->
   
   <!-- Primary input is any XML document. -->   
   <p:input port="source" primary="true"/>

   <!-- Primary output are diagnostic results of the operation. -->   
   <p:output port="result" sequence="true" primary="true"/>
   
   <p:option name="chop-at-level" as="xs:integer?" select="2"/>
   <p:option name="chop-elements-named-regex" as="xs:string?"/>
   
   <p:variable name="xslt-map" select="map{
      'chop-at-level': $chop-at-level,
      'chop-elements-named-regex' : $chop-elements-named-regex
      }"/>
   <p:xslt parameters="$xslt-map">
      <p:with-input port="stylesheet" href="chop-tree.xsl"/>
   </p:xslt>

</p:declare-step>
