<?xml version="1.1" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gpo="http://www.gpo.gov"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
   xmlns:math="http://www.w3.org/2005/xpath-functions/math" version="3.0">

   <!-- Select functions upon which hash and check depends -->
   
   
   
   <xsl:variable name="gxt-namespace-uri" as="xs:string" select="'http://www.gpo.gov'"/>


   <!-- Strings -->
   
   <xsl:function name="gpo:ellipses" as="xs:string*">
      <!-- Input: any sequence of strings; an integer -->
      <!-- Output: the sequence of strings, but with any substring beyond the requested length replaced by ellipses -->
      <xsl:param name="strings-to-truncate" as="xs:string*"/>
      <xsl:param name="string-length-to-retain" as="xs:integer"/>
      <xsl:for-each select="$strings-to-truncate">
         <xsl:choose>
            <xsl:when test="string-length(.) lt $string-length-to-retain">
               <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="substring(., 1, $string-length-to-retain) || '...'"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:function>

   <xsl:function name="gpo:fill" as="xs:string?">
      <!-- Input: a string and an integer -->
      <!-- Output: a string that consists of the first parameter repeated as many times specified by the second parameter -->
      <xsl:param name="filler" as="xs:string?"/>
      <xsl:param name="count" as="xs:integer"/>
      <xsl:value-of
         select="
         string-join((for $i in (1 to $count)
         return
         $filler))"
      />
   </xsl:function>
   
   <xsl:function name="gpo:reverse-string" as="xs:string*">
      <!-- Input: zero or more strings -->
      <!-- Output: each string with its characters returned in reverse order -->
      <xsl:param name="in" as="xs:string*"/>
      <xsl:for-each select="$in">
         <xsl:value-of select="codepoints-to-string(reverse(string-to-codepoints(.)))"/>
      </xsl:for-each>
   </xsl:function>
   
   <xsl:function name="gpo:string-to-utf-8-octets" as="xs:integer*">
      <!-- Input: a string -->
      <!-- Output: integer values of the string, after conversion to UTF-8 bytes (0..255) -->
      <!-- This function was written to ensure that checksums of Unicode values do not cause repeating values. -->
      <!-- Anything below codepoint 128 will be simply the output of string-to-codepoints() -->
      <xsl:param name="str" as="xs:string"/>
      <xsl:for-each select="string-to-codepoints($str)">
         <xsl:choose>
            <xsl:when test=". lt 127">
               <xsl:sequence select="."/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:variable name="this-val" select="encode-for-uri(codepoints-to-string(.))"
                  as="xs:string"/>
               <xsl:analyze-string select="$this-val" regex="[^%]+">
                  <xsl:matching-substring>
                     <xsl:sequence select="gpo:hex-to-dec(.)"/>
                  </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:function>
   
   <xsl:function name="gpo:unicode-to-eight-bit-chars" as="xs:string?">
      <!-- Input: any Unicode string -->
      <!-- Output: the string, with upper characters (greater than dec 126, ~) converted to 8-bit-bytes -->
      <xsl:param name="unicode-string" as="xs:string?"/>
      <xsl:variable name="str-8bit-codepoints" select="gpo:string-to-utf-8-octets($unicode-string)"/>
      <xsl:sequence select="codepoints-to-string($str-8bit-codepoints)"/>
   </xsl:function>




   <!-- Numeric functions -->

   <xsl:variable name="gpo:numeric-error-key" as="map(*)">
      <xsl:map>
         <xsl:map-entry key="'g1'">Base system not recognized</xsl:map-entry>
         <xsl:map-entry key="'g2'">Lexical form of numeral not recognized</xsl:map-entry>
      </xsl:map>
   </xsl:variable>



   <xsl:function name="gpo:dec-to-bin" as="xs:string?">
      <!-- One-parameter version of the full one below -->
      <xsl:param name="in" as="xs:integer?"/>
      <xsl:sequence select="gpo:dec-to-n($in, 2)"/>
   </xsl:function>

   <xsl:function name="gpo:bin-to-dec" as="xs:integer?">
      <!-- Input: a binary -->
      <!-- Output: the number in decimal form, as an integer -->
      <!-- Input is assumed to be big-endian -->
      <xsl:param name="in" as="xs:string?"/>
      <xsl:sequence select="gpo:n-to-dec($in, 2)"/>
   </xsl:function>

   <xsl:function name="gpo:dec-to-hex" as="xs:string?">
      <!-- Input: xs:integer -->
      <!-- Output: the hexadecimal equivalent as a string, e.g., 31 - > '1F' -->
      <xsl:param name="in" as="xs:integer?"/>
      <xsl:sequence select="gpo:dec-to-n($in, 16)"/>
   </xsl:function>

   <xsl:function name="gpo:hex-to-dec" as="xs:integer?">
      <!-- Input: a string representing a hexadecimal number -->
      <!-- Output: the integer value, e.g., '1F' - > 31 -->
      <xsl:param name="in" as="xs:string?"/>
      <xsl:sequence select="gpo:n-to-dec($in, 16)"/>
   </xsl:function>

   <!-- Casting base-2 binary from/to data types -->

   <xsl:function name="gpo:bin-to-bits" as="xs:boolean*">
      <!-- Input: any string representing base-2 binary -->
      <!-- Output: a sequence of booleans representing the bits of the binary -->
      <xsl:param name="base-2-binary" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="string-length($base-2-binary) lt 1"/>
         <xsl:when test="not(matches($base-2-binary, '^-?[01]+$'))">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g2'), $gpo:numeric-error-key('g2'), $base-2-binary)"
            />
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="starts-with($base-2-binary, '-')">
               <xsl:message select="'Negative value being cast to absolute.'"/>
            </xsl:if>
            <xsl:analyze-string select="$base-2-binary" regex="[01]">
               <xsl:matching-substring>
                  <xsl:sequence select=". eq '1'"/>
               </xsl:matching-substring>
            </xsl:analyze-string>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="gpo:bits-to-bin" as="xs:string?">
      <!-- Input: a sequence of booleans -->
      <!-- Output: a base-2 binary representation of the sequence -->
      <!-- Example: false, true, true > '011' -->
      <xsl:param name="bits" as="xs:boolean*"/>
      <xsl:if test="exists($bits)">
         <xsl:sequence select="
               string-join(for $i in $bits
               return
                  (if ($i eq true()) then
                     '1'
                  else
                     '0'))"/>
      </xsl:if>
   </xsl:function>

   <xsl:variable name="gpo:hex-key" as="xs:string+"
      select="('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F')"/>
   <xsl:variable name="gpo:base26-key" as="xs:string+"
      select="('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')"/>
   <xsl:variable name="gpo:base64-key" as="xs:string+"
      select="($gpo:base26-key, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/')"/>

   <xsl:function name="gpo:n-to-dec" as="xs:integer?">
      <!-- Input: string representation of some number; an integer -->
      <!-- Output: an integer representing the first parameter in the base system of the 2nd parameter -->
      <xsl:param name="input" as="xs:string?"/>
      <xsl:param name="base" as="xs:integer"/>
      <xsl:variable name="this-key" as="xs:string*">
         <xsl:choose>
            <xsl:when test="$base le 16">
               <xsl:sequence select="subsequence($gpo:hex-key, 1, $base)"/>
            </xsl:when>
            <xsl:when test="$base eq 26">
               <xsl:sequence select="$gpo:base26-key"/>
            </xsl:when>
            <xsl:when test="$base eq 64">
               <xsl:sequence select="$gpo:base64-key"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="input-normalized" as="xs:string?" select="
            replace(if (($base le 16) or ($base eq 26)) then
               upper-case($input)
            else
               replace($input, '=+$', ''), '^-', '')"/>
      <xsl:variable name="digit-sequence" as="xs:integer*">
         <xsl:analyze-string select="$input-normalized" regex=".">
            <xsl:matching-substring>
               <xsl:copy-of select="index-of($this-key, .) - 1"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:variable>
      <xsl:variable name="split-rev" select="reverse($digit-sequence)" as="xs:integer*"/>
      <xsl:variable name="modifier" as="xs:integer" select="
            if (starts-with($input, '-')) then
               -1
            else
               1"/>

      <xsl:variable name="diagnostics-on" select="false()" as="xs:boolean"/>
      <xsl:if test="$diagnostics-on">
         <xsl:message select="'diagnostics on for gpo:n-to-dec()'"/>
         <xsl:message select="'input normalized: ', $input-normalized"/>
         <xsl:message select="'input is what base: ', $base"/>
         <xsl:message select="'this key: ', $this-key"/>
         <xsl:message select="'digit sequence: ', $digit-sequence"/>
      </xsl:if>

      <xsl:choose>
         <xsl:when test="not($base = (2 to 16, 26, 64))">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g1'), $gpo:numeric-error-key('g1'), $base)"
            />
         </xsl:when>
         <xsl:when test="count($digit-sequence) lt string-length($input-normalized)">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g2'), $gpo:numeric-error-key('g2'), $input)"
            />
         </xsl:when>
         <xsl:when test="(string-length($input) lt 1) or not(exists($input))"/>
         <xsl:otherwise>
            <xsl:sequence select="
                  $modifier *
                  sum(for $i in (1 to count($digit-sequence))
                  return
                     $split-rev[$i]
                     * (xs:integer(math:pow($base, $i - 1))))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="gpo:dec-to-n" as="xs:string?">
      <!-- Input: two integers -->
      <!-- Output: a string that represents the first numeral in base N, where N is the second numeral (must be 2-16, 26, or 64) -->
      <!-- No padding is performed on the output (e.g., = in base-64, or initial zeroes in hexadecimal) -->
      <xsl:param name="in" as="xs:integer?"/>
      <xsl:param name="base" as="xs:integer"/>
      <xsl:variable name="in-abs" select="abs($in)" as="xs:integer?"/>

      <xsl:variable name="this-key" as="xs:string+">
         <xsl:choose>
            <xsl:when test="$base eq 64">
               <xsl:sequence select="$gpo:base64-key"/>
            </xsl:when>
            <xsl:when test="$base eq 26">
               <xsl:sequence select="$gpo:base26-key"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence select="subsequence($gpo:hex-key, 1, $base)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="not($base = (2 to 16, 26, 64))">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g1'), $gpo:numeric-error-key('g1'), $base)"
            />
         </xsl:when>
         <xsl:when test="not(exists($in))"/>
         <xsl:otherwise>
            <xsl:sequence select="
                  (if ($in lt 0) then
                     '-'
                  else
                     '') ||
                  (if ($in-abs lt $base)
                  then
                     $this-key[$in-abs + 1]
                  else
                     (gpo:dec-to-n($in-abs idiv $base, $base) || $this-key[($in-abs mod $base) + 1]))"
            />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>


   <!-- BINARY FUNCTIONS -->

   <xsl:variable name="gpo:binary-error-key" as="map(*)">
      <xsl:map>
         <xsl:map-entry key="'g3'">Negative numbers of bits are not permitted.</xsl:map-entry>
         <xsl:map-entry key="'g4'">An octet must be in the range 0-255</xsl:map-entry>
         <xsl:map-entry key="'g5'">Only bytes (8 bit groups) may be cast to octets.</xsl:map-entry>
         <xsl:map-entry key="'g6'">8-bit characters must have codepoints in the range 1-255,
            9216</xsl:map-entry>
         <xsl:map-entry key="'g7'">Bitwise operations can be applied to bit sequences of identical
            length.</xsl:map-entry>
      </xsl:map>
   </xsl:variable>

   <xsl:function name="gpo:pad-bits" as="xs:boolean*">
      <xsl:param name="input-bits" as="xs:boolean*"/>
      <xsl:param name="big-endian" as="xs:boolean"/>
      <xsl:param name="item-size" as="xs:integer"/>
      <xsl:variable name="input-count" select="count($input-bits)" as="xs:integer"/>
      <xsl:variable name="this-remnant" select="$input-count mod $item-size" as="xs:integer"/>
      <xsl:variable name="bits-needed" as="xs:integer" select="
            if ($this-remnant eq 0) then
               0
            else
               $item-size - $this-remnant"/>

      <xsl:choose>
         <xsl:when test="$item-size lt 0">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g3'), $gpo:binary-error-key('g3'), $item-size)"
            />
         </xsl:when>
         <xsl:when test="$item-size lt 2">
            <xsl:sequence select="$input-bits"/>
         </xsl:when>
         <xsl:when test="$this-remnant eq 0">
            <xsl:sequence select="$input-bits"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$big-endian">
               <xsl:sequence select="
                     for $i in (1 to $bits-needed)
                     return
                        false()"/>
            </xsl:if>
            <xsl:sequence select="$input-bits"/>
            <xsl:if test="not($big-endian)">
               <xsl:sequence select="
                     for $i in (1 to $bits-needed)
                     return
                        false()"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:function>

   <xsl:function name="gpo:bits-to-byte" as="xs:boolean*">
      <!-- Input: a sequence of bits (booleans); a boolean -->
      <!-- Output: the same sequence, but extended to a multiple of 8 bits (a byte). If the 2nd param is true, it is
      big endian and the padding takes place at the beginning, otherwise, at the end. -->
      <xsl:param name="input-bits" as="xs:boolean*"/>
      <xsl:param name="big-endian" as="xs:boolean"/>
      <xsl:sequence select="gpo:pad-bits($input-bits, $big-endian, 8)"/>
   </xsl:function>

   <xsl:function name="gpo:bits-to-word" as="xs:boolean*">
      <!-- Input: a sequence of bits (booleans); a boolean -->
      <!-- Output: the same sequence, but extended to a multiple of 32 bits (a "word"). If the 2nd param is true, it is
      big endian and the padding takes place at the beginning, otherwise, at the end. -->
      <xsl:param name="input-bits" as="xs:boolean*"/>
      <xsl:param name="big-endian" as="xs:boolean"/>
      <xsl:sequence select="gpo:pad-bits($input-bits, $big-endian, 32)"/>
   </xsl:function>


   <xsl:function name="gpo:bitwise-not" as="xs:boolean*">
      <!-- Input: a boolean sequence -->
      <!-- Output: the bitwise complement of the sequence -->
      <!-- e.g., false, true > true, false -->
      <xsl:param name="boolean" as="xs:boolean*"/>
      <xsl:for-each select="$boolean">
         <xsl:sequence select="not(.)"/>
      </xsl:for-each>
   </xsl:function>

   <xsl:function name="gpo:bitwise-or" as="xs:boolean*">
      <!-- Input: two sequences of booleans -->
      <!-- Output: a single sequence as long as the longest input sequence, with pairwise OR computed. -->
      <xsl:param name="bit-sequence-a" as="xs:boolean*"/>
      <xsl:param name="bit-sequence-b" as="xs:boolean*"/>
      <xsl:variable name="a-count" select="count($bit-sequence-a)" as="xs:integer"/>
      <xsl:variable name="b-count" select="count($bit-sequence-b)" as="xs:integer"/>

      <xsl:choose>
         <xsl:when test="$a-count ne $b-count">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g7'), $gpo:binary-error-key('g7'), ($a-count, $b-count))"
            />
         </xsl:when>
         <xsl:when test="$a-count lt 1"/>
         <xsl:otherwise>
            <xsl:for-each select="1 to $a-count">
               <xsl:sequence select="$bit-sequence-a[current()] or $bit-sequence-b[current()]"/>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>


   <xsl:function name="gpo:bitwise-and" as="xs:boolean*">
      <!-- Input: two sequences of booleans -->
      <!-- Output: a single sequence as long as the longest input sequence, with pairwise AND computed. -->
      <xsl:param name="bit-sequence-a" as="xs:boolean*"/>
      <xsl:param name="bit-sequence-b" as="xs:boolean*"/>
      <xsl:variable name="a-count" select="count($bit-sequence-a)" as="xs:integer"/>
      <xsl:variable name="b-count" select="count($bit-sequence-b)" as="xs:integer"/>
      <xsl:choose>
         <xsl:when test="$a-count ne $b-count">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g7'), $gpo:binary-error-key('g7'), ($a-count, $b-count))"
            />
         </xsl:when>
         <xsl:when test="$a-count lt 1"/>
         <xsl:otherwise>
            <xsl:for-each select="1 to $a-count">
               <xsl:sequence select="$bit-sequence-a[current()] and $bit-sequence-b[current()]"/>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>


   <xsl:function name="gpo:bitwise-xor" as="xs:boolean*">
      <!-- Input: two sequences of booleans -->
      <!-- Output: a single sequence as long as the longest input sequence, with pairwise XOR computed. -->
      <xsl:param name="bit-sequence-a" as="xs:boolean*"/>
      <xsl:param name="bit-sequence-b" as="xs:boolean*"/>
      <!--<xsl:param name="big-endian" as="xs:boolean"/>-->
      <xsl:variable name="a-count" select="count($bit-sequence-a)" as="xs:integer"/>
      <xsl:variable name="b-count" select="count($bit-sequence-b)" as="xs:integer"/>

      <xsl:choose>
         <xsl:when test="$a-count ne $b-count">
            <xsl:sequence
               select="error(QName($gxt-namespace-uri, 'g7'), $gpo:binary-error-key('g7'), ($a-count, $b-count))"
            />
         </xsl:when>
         <xsl:when test="$a-count lt 1"/>
         <xsl:otherwise>
            <xsl:for-each select="1 to $a-count">
               <xsl:sequence select="$bit-sequence-a[current()] ne $bit-sequence-b[current()]"/>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>


   <xsl:function name="gpo:bitwise-plus" as="xs:boolean*">
      <!-- Input: two sequences of booleans, and a boolean -->
      <!-- Output: a sequence of booleans representing the sum of the input, as if base-2 binary. -->
      <!-- Unlike most bitwise operations, where the length of input and output are expected to be the same,
      that is definitely not the case here, which means that a declaration must be made whether the operation
      is big-endian (most significant byte first) or little-endian (most significant byte last) -->
      <!-- If one input is longer than the other, each unpaired boolean at the most significant part 
         of the longest series will be assessed against an assumed counterpart of false.
      -->
      <xsl:param name="bit-sequence-a" as="xs:boolean*"/>
      <xsl:param name="bit-sequence-b" as="xs:boolean*"/>
      <xsl:param name="big-endian" as="xs:boolean"/>
      <xsl:variable name="a-count" select="count($bit-sequence-a)" as="xs:integer"/>
      <xsl:variable name="b-count" select="count($bit-sequence-b)" as="xs:integer"/>
      <xsl:variable name="max-length" select="max(($a-count, $b-count))" as="xs:integer"/>
      <!-- Convert input to little-endian, which is easier to iterate over, going from
      units to twos to fours, etc. Also, make them an even length.-->
      <xsl:variable name="bit-seq-a-le" as="xs:boolean*" select="
            (if ($big-endian) then
               reverse($bit-sequence-a)
            else
               $bit-sequence-a),
            (for $i in (1 to ($max-length - $a-count))
            return
               false())"/>
      <xsl:variable name="bit-seq-b-le" as="xs:boolean*" select="
            (if ($big-endian) then
               reverse($bit-sequence-b)
            else
               $bit-sequence-b),
            (for $i in (1 to ($max-length - $b-count))
            return
               false())"/>
      <xsl:variable name="results-little-endian" as="xs:boolean*">
         <!-- Don't forget, little-endian means the littlest digit is at the FIRST/LOWEST end ("end" in 
            "endian" does not mean "last") -->
         <xsl:iterate select="1 to $max-length">
            <xsl:param name="carryover" as="xs:boolean" select="false()"/>
            <xsl:on-completion>
               <xsl:if test="$carryover eq true()">
                  <xsl:sequence select="$carryover"/>
               </xsl:if>
            </xsl:on-completion>
            <xsl:variable name="this-pos" select="." as="xs:integer"/>
            <xsl:variable name="this-a" select="$bit-seq-a-le[$this-pos]" as="xs:boolean"/>
            <xsl:variable name="this-b" select="$bit-seq-b-le[$this-pos]" as="xs:boolean"/>
            <!-- The truth table for summing bits is a bit complicated, so here it is for reference: -->
            <!--
        a:         0          1
carryover:      +0  +1     +0  +1
               ========   ========
        b:  0 | 0+0 1+0    1+0 0+1
            1 | 1+0 0+1    0+1 1+1
            -->

            <xsl:sequence select="
                  if ($this-a eq $this-b) then
                     $carryover eq true()
                  else
                     $carryover eq false()"/>
            <xsl:next-iteration>
               <xsl:with-param name="carryover" as="xs:boolean" select="
                     ($this-a eq true() and $this-b eq true())
                     or ($this-a ne $this-b and $carryover eq true())"/>
            </xsl:next-iteration>
         </xsl:iterate>
      </xsl:variable>

      <!-- Output: don't forget, the results might be one digit larger than the longest input string -->
      <xsl:sequence select="
            if ($big-endian) then
               reverse($results-little-endian)
            else
               $results-little-endian"/>
   </xsl:function>

   <xsl:function name="gpo:bitwise-rotate" as="xs:boolean*">
      <!-- Input: a boolean sequence; an integer -->
      <!-- Output: the sequence, circularly shifted left the number of places specified by the integer; if the integer is
      negative, it will be shifted right. -->
      <!-- It is up to the user to consider whether the bits are big- or little-endian as to the meaning of "left". -->
      <xsl:param name="bit-sequence" as="xs:boolean*"/>
      <xsl:param name="rotate-left" as="xs:integer"/>
      <xsl:variable name="bit-sequence-count" select="count($bit-sequence)" as="xs:integer"/>
      <xsl:variable name="places-to-shift" as="xs:integer" select="
            if ($bit-sequence-count ne 0) then
               $rotate-left mod $bit-sequence-count
            else
               0"/>
      <xsl:variable name="places-to-shift-adjusted" as="xs:integer" select="
            if ($places-to-shift lt 0) then
               $places-to-shift + $bit-sequence-count
            else
               $places-to-shift"/>

      <xsl:variable name="diagnostics-on" select="false()" as="xs:boolean"/>
      <xsl:if test="$diagnostics-on">
         <xsl:message select="'Diagnostics on, gpo:bitwise-rotate()'"/>
         <xsl:message select="'Bit sequence: ' || gpo:bits-to-bin($bit-sequence)"/>
         <xsl:message select="'Amount to left-rotate: ', $rotate-left"/>
         <xsl:message select="'Bit count:', $bit-sequence-count"/>
         <xsl:message select="'Places to shift:', $places-to-shift"/>
         <xsl:message select="'Places to shift adjusted:', $places-to-shift-adjusted"/>
      </xsl:if>

      <xsl:choose>
         <xsl:when test="$places-to-shift eq 0">
            <xsl:sequence select="$bit-sequence"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence
               select="subsequence($bit-sequence, $places-to-shift-adjusted + 1), subsequence($bit-sequence, 1, $places-to-shift-adjusted)"
            />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>


</xsl:stylesheet>
