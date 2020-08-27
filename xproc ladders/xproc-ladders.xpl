<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:ladder="tag:kalvesmaki.com,2020:ns"
   xmlns:c="http://www.w3.org/ns/xproc-step" version="3.0">
   
   <!-- Started August 2020, Joel Kalvesmaki -->
   <!-- Library of XProc 3.0 ladders for managing files. -->
   <!-- This is the primary point of entry to the XProc Ladder library. You may access any 
      component directly, if you prefer, but making this your one point of entry gives you
      complete access to the entire XProc Ladder library.
   -->
   
   <p:import href="ladders/copy-files.xpl"/>   
   <p:import href="ladders/delete-files.xpl"/>   
   <p:import href="ladders/move-files.xpl"/>
   <!-- Feature import-functions not available in current working edition of Morgana -->
   <!--<p:import-functions href="ladders/ladder-functions.xsl"/>-->
   

</p:library>
