<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns" type="ladder:expand-attributes"
   name="expand-attributes" xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- XProc 3.0 ladder for expanding attributes into elements. -->
   
   <!-- Primary input is any XML document. -->   
   <p:input port="source" primary="true" sequence="true"/>

   <!-- Primary output are diagnostic results of the operation. -->   
   <p:output port="result" sequence="true" primary="true"/>
   
   <p:option name="attributes-with-multiple-values-regex" as="xs:string?"/>
   
   <p:variable name="xslt-map" select="map{
      'attributes-with-multiple-values-regex' : $attributes-with-multiple-values-regex
      }"/>
   
   <p:for-each name="xslt-expand-attributes">
      <p:xslt parameters="$xslt-map">
         <p:with-input port="stylesheet" href="expand-attributes.xsl"/>
      </p:xslt>
   </p:for-each>

</p:declare-step>
