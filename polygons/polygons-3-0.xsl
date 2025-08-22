<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:my="my-functions"
    expand-text="yes"
    exclude-result-prefixes="#all"
    version="3.0">
    <!-- Polygons modeled in XSLT 3.0 -->
    
    <xsl:variable name="polygon-1" as="array(*)" select="[(0,0), (8,8), (16,0)]"/>
    <xsl:variable name="polygon-2" as="array(*)" select="[(4,2), (8,4), (12,2)]"/>
    <xsl:variable name="polygon-3" as="array(*)" select="[(0,4), (0,12), (4,12), (4,4)]"/>
    <xsl:variable name="polygon-4" as="array(*)" select="[(8,6), (8,12), (12,12), (12,6), (10, 4)]"/>
    <xsl:variable name="polygon-5" as="array(*)" select="[(12,16), (16,16), (24,8)]"/>
    <xsl:variable name="polygon-6" as="array(*)" select="[(20,16), (24,16), (16,8)]"/>
    
    <xsl:variable name="all-polygons" as="array(*)*" select="$polygon-1, $polygon-2, $polygon-3, $polygon-4, $polygon-5, $polygon-6"/>
    
    <xsl:function name="my:compare-line-segments" as="map(*)">
        <!-- Input: Two line segments, in the form of four x-y coordinates -->
        <!-- Output: Various bits of information about the relationship of the two line segments. -->
        <!-- Segment 1, two coordinates -->
        <xsl:param name="x1" as="xs:double"/>
        <xsl:param name="y1" as="xs:double"/>
        <xsl:param name="x2" as="xs:double"/>
        <xsl:param name="y2" as="xs:double"/>
        <!-- Segment 2, two coordinates -->
        <xsl:param name="x3" as="xs:double"/>
        <xsl:param name="y3" as="xs:double"/>
        <xsl:param name="x4" as="xs:double"/>
        <xsl:param name="y4" as="xs:double"/>
        
        <xsl:variable name="common-coordinates" as="xs:double*">
            <xsl:choose>
                <xsl:when test="$x1 eq $x3 and $y1 eq $y3">
                    <xsl:sequence select="$x1, $y1"/>                    
                </xsl:when>
                <xsl:when test="$x1 eq $x4 and $y1 eq $y4">
                    <xsl:sequence select="$x1, $y1"/>                    
                </xsl:when>
                <xsl:when test="$x2 eq $x3 and $y2 eq $y3">
                    <xsl:sequence select="$x2, $y2"/>                    
                </xsl:when>
                <xsl:when test="$x2 eq $x4 and $y2 eq $y4">
                    <xsl:sequence select="$x2, $y2"/>                    
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="u-denominator" as="xs:double" select="($y4 - $y3) * ($x2 - $x1) - ($x4 - $x3) * ($y2 - $y1)"/>
        <xsl:variable name="ua-numerator" as="xs:double" select="($x4 - $x3) * ($y1 - $y3) - ($y4 - $y3) * ($x1 - $x3)"/>
        <xsl:variable name="ub-numerator" as="xs:double" select="($x2 - $x1) * ($y1 - $y3) - ($y2 - $y1) * ($x1 - $x3)"/>
        <xsl:variable name="segments-are-parallel" as="xs:boolean" select="$u-denominator eq 0"/>
        <xsl:variable name="segments-are-coincident" as="xs:boolean"
            select="$segments-are-parallel and $ua-numerator eq 0 and $ub-numerator eq 0"/>
        <xsl:variable name="coincident-segments-are-discrete" as="xs:boolean" select="
                $segments-are-coincident
                and
                ((every $i in ($x1, $x2),
                    $j in ($x3, $x4)
                    satisfies ($i lt $j)) or (every $i in ($x1, $x2),
                    $j in ($x3, $x4)
                    satisfies ($i gt $j)))"/>
        <!-- Values of 0 or 1 for $ua or $ub represent a segment that originates in the other, like an L or T. Values
            greater than 1 indicate non-intersecting segments, and the numeral represents the point at which the intersection
            would occur (e.g., 2 means that if the segment were twice as long, it would originate in the other segment).-->
        <xsl:variable name="ua" as="xs:double?" select="
                if ($segments-are-parallel) then
                    ()
                else
                    ($ua-numerator div $u-denominator)"/>
        <xsl:variable name="ub" as="xs:double?" select="
                if ($segments-are-parallel) then
                    ()
                else
                    ($ub-numerator div $u-denominator)"/>
        <xsl:variable name="segments-touch" as="xs:boolean" select="
                (($ua ge 0) and ($ua le 1) and ($ub ge 0) and ($ub le 1))
                or ($segments-are-coincident and not($coincident-segments-are-discrete))"/>
        <xsl:variable name="intersection-x" as="xs:double?" select="
                if ($segments-are-coincident and count($common-coordinates) eq 2) then
                    $common-coordinates[1]
                else
                    if ($segments-touch) then
                        ($x1 + $ua * ($x2 - $x1))
                    else
                        
                        ()"/>
        <xsl:variable name="intersection-y" as="xs:double?" select="
                if ($segments-are-coincident and count($common-coordinates) eq 2) then
                    $common-coordinates[2]
                else
                    if ($segments-touch) then
                        ($y1 + $ua * ($y2 - $y1))
                    else
                        
                        ()"/>
        <xsl:variable name="coordinate-distances" as="xs:double+" select="
                math:sqrt((($x3 - $x1) * ($x3 - $x1) + ($y3 - $y1) * ($y3 - $y1))),
                math:sqrt((($x4 - $x1) * ($x4 - $x1) + ($y4 - $y1) * ($y4 - $y1))),
                math:sqrt((($x3 - $x2) * ($x3 - $x2) + ($y3 - $y2) * ($y3 - $y2))),
                math:sqrt((($x4 - $x2) * ($x4 - $x2) + ($y4 - $y2) * ($y4 - $y2)))
                "/>
        <xsl:variable name="minimum-distance" as="xs:double" select="
                if (exists($intersection-x)) then
                    0
                else
                    min((
                        my:distance-point-to-segment($x1, $y1, $x3, $y3, $x4, $y4),
                        my:distance-point-to-segment($x2, $y2, $x3, $y3, $x4, $y4),
                        my:distance-point-to-segment($x3, $y3, $x1, $y1, $x2, $y2),
                        my:distance-point-to-segment($x4, $y4, $x1, $y1, $x2, $y2)
                    ))"/>
        <xsl:variable name="slope-segment-1-in-radians" as="xs:double" select="math:atan(($y2 - $y1) div ($x2 - $x1))"/>
        <xsl:variable name="slope-segment-2-in-radians" as="xs:double" select="math:atan(($y4 - $y3) div ($x4 - $x3))"/>
        <xsl:variable name="angle-difference-in-radians" as="xs:double" select="abs($slope-segment-1-in-radians - $slope-segment-2-in-radians)"/>
        
        <xsl:variable name="diagnostics-on" as="xs:boolean" select="false()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message>Diagnostics on, my:compare-line-segments(); segment 1: ({$x1}, {$y1}), ({$x2}, {$y2}); segment 2: ({$x3}, {$y3}), ({$x4}, {$y4})</xsl:message>
            <xsl:message>u-denominator: {$u-denominator}; ua-numerator: {$ua-numerator}; ub-numerator: {$ua-numerator}</xsl:message>
            <xsl:message>segments touch? {$segments-touch}; segments are parallel: {$segments-are-parallel}; segments are coincident: {$segments-are-coincident}; coincident segments are discrete: {$coincident-segments-are-discrete}</xsl:message>
            <xsl:message>ua: {$ua}; ub: {$ub}</xsl:message>
            <xsl:message>Segment intersection coordinates: {$intersection-x}, {$intersection-y}</xsl:message>
            <xsl:message>Coordinate distances: {$coordinate-distances}</xsl:message>
            <xsl:message>Minimum distance: {$minimum-distance}; max distance: {max($coordinate-distances)}</xsl:message>
            <xsl:message>Segment 1 slope: {$slope-segment-1-in-radians} radians ({$slope-segment-1-in-radians div math:pi() * 180} degrees)</xsl:message>
            <xsl:message>Segment 2 slope: {$slope-segment-2-in-radians} radians ({$slope-segment-2-in-radians div math:pi() * 180} degrees)</xsl:message>
            <xsl:message>Angle difference: {$angle-difference-in-radians} radians ({$angle-difference-in-radians div math:pi() * 180} degrees)</xsl:message>
        </xsl:if>
        
        <xsl:map>
            <xsl:map-entry key="'segments-touch'" select="$segments-touch"/>
            <xsl:map-entry key="'segment-1-bisection'" select="$ua"/>
            <xsl:map-entry key="'segment-2-bisection'" select="$ub"/>
            <xsl:map-entry key="'intersection-coordinates'" select="$intersection-x, $intersection-y"/>
            <xsl:map-entry key="'minimum-distance'" select="$minimum-distance"/>
            <xsl:map-entry key="'maximum-distance'" select="max($coordinate-distances)"/>
            <xsl:map-entry key="'angle-difference-in-radians'" select="$angle-difference-in-radians"/>
            <xsl:map-entry key="'angle-difference-in-degrees'" select="$angle-difference-in-radians div math:pi() * 180"/>
        </xsl:map>
    </xsl:function>
    
    <xsl:function name="my:distance-point-to-segment" as="xs:double?">
        <!-- Input: three sets of X-Y coordinates, one pair representing a point E, the other pair representing 
            the endpoints of a line segment AB. -->
        <!-- Output: the minimal distance from the point to the segment. -->
        
        <!-- Coordinates, point E -->
        <xsl:param name="x" as="xs:double"/>
        <xsl:param name="y" as="xs:double"/>
        <!-- Segment 1, endpoints A and B-->
        <xsl:param name="x1" as="xs:double"/>
        <xsl:param name="y1" as="xs:double"/>
        <xsl:param name="x2" as="xs:double"/>
        <xsl:param name="y2" as="xs:double"/>
        
        <!-- Vector AB (the original segment) -->
        <xsl:variable name="AB-x" as="xs:double" select="$x2 - $x1"/>
        <xsl:variable name="AB-y" as="xs:double" select="$y2 - $y1"/>
        <!-- Vector BE -->
        <xsl:variable name="BE-x" as="xs:double" select="$x - $x2"/>
        <xsl:variable name="BE-y" as="xs:double" select="$y - $y2"/>
        <!-- Vector AE -->
        <xsl:variable name="AE-x" as="xs:double" select="$x - $x1"/>
        <xsl:variable name="AE-y" as="xs:double" select="$y - $y1"/>
        
        <xsl:variable name="AB-dot-BE" as="xs:double" select="$AB-x * $BE-x + $AB-y * $BE-y"/>
        <xsl:variable name="AB-dot-AE" as="xs:double" select="$AB-x * $AE-x + $AB-y * $AE-y"/>
        
        <xsl:variable name="E-is-closest-to-A" as="xs:boolean" select="$AB-dot-AE lt 0"/>
        <xsl:variable name="E-is-closest-to-B" as="xs:boolean" select="$AB-dot-BE gt 0"/>
        
        
        <xsl:variable name="diagnostics-on" as="xs:boolean" select="false()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message>Diagnostics on, my:distance-point-to-segment(); point: ({$x}, {$y}); segment coordinates: ({$x1}, {$y1}), ({$x2}, {$y2})</xsl:message>
            <xsl:message>Vector AB: {$AB-x}, {$AB-y}; vector BE: {$BE-x}, {$BE-y}; vector AE: {$AE-x}, {$AE-y}</xsl:message>
            <xsl:message>AB dot BE: {$AB-dot-BE}; AB dot AE: {$AB-dot-AE}</xsl:message>
            <xsl:message>E is closest to A? {$E-is-closest-to-A}; ...to B? {$E-is-closest-to-B}</xsl:message>
        </xsl:if>
        
        <xsl:choose>
            <xsl:when test="$E-is-closest-to-B">
                <xsl:sequence select="math:sqrt(($x - $x2) * ($x - $x2) + ($y - $y2) * ($y - $y2))"
                />
            </xsl:when>
            <xsl:when test="$E-is-closest-to-A">
                <xsl:sequence select="math:sqrt(($x - $x1) * ($x - $x1) + ($y - $y1) * ($y - $y1))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="mod" as="xs:double" select="math:sqrt($AB-x * $AB-x + $AB-y * $AB-y)"/>
                <xsl:variable name="distance" as="xs:double" select="abs($AB-x * $AE-y - $AB-y * $AE-x) div $mod"/>
                <xsl:if test="$diagnostics-on">
                    <xsl:message>Mod: {$mod}; distance: {$distance}</xsl:message>
                </xsl:if>
                <xsl:sequence select="$distance"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="my:point-is-in-polygon" as="xs:boolean">
        <!-- Input: an X-Y coordinate, an array of X-Y coordinates -->
        <!-- Output: a boolean indicating whether the point is in the polygon or not. If the point is 
            on a line that makes the polygon, then the return value is true. -->
        <!-- Coordinates, point E -->
        <xsl:param name="x" as="xs:double"/>
        <xsl:param name="y" as="xs:double"/>
        <xsl:param name="polygon" as="array(*)"/>
        
        <xsl:variable name="p" as="array(*)" select="array:append($polygon, $polygon(1))"/>
        <xsl:variable name="largest-x-value" as="xs:double" select="
                max(
                for $i in (1 to array:size($polygon))
                return
                    $polygon($i)[1]
                )"/>
        <xsl:variable name="provisional-segment-end-point" as="xs:double+" select="$largest-x-value + 1, $y"/>
        <xsl:variable name="comparisons" as="map(*)*" select="
                for $i in (1 to array:size($polygon))
                return
                    my:compare-line-segments(
                    $x, $y, $provisional-segment-end-point[1], $provisional-segment-end-point[2],
                    $p($i)[1], $p($i)[2], $p($i + 1)[1], $p($i + 1)[2]
                    )"/>
        
        <xsl:variable name="diagnostics-on" as="xs:boolean" select="false()"/>
        <xsl:if test="$diagnostics-on">
            <xsl:message>Diagnostics on, my:point-is-in-polygon(); point {$x}, {$y}; polygon {serialize($polygon, map{ 'method' : 'adaptive' })}</xsl:message>
            <xsl:message>Provisional segment: ({$x}, {$y}) and ({$provisional-segment-end-point[1]}, {$provisional-segment-end-point[2]})</xsl:message>
            <xsl:for-each select="$comparisons">
                <xsl:message>comparison {position()}: {serialize(., map{'method' : 'adaptive'})}</xsl:message>
            </xsl:for-each>
        </xsl:if>
        
        <xsl:sequence select="
                (: If the point lies on a polygon's line, then yes the point is in the polygon :)
                (some $i in $comparisons
                    satisfies ($i('segment-1-bisection') = (0, 1) and ($i('minimum-distance') eq 0)))
                or
                (: If a ray from the point crosses an odd number of polygon sides, then yes 
                the point is in the polygon :)
                (count($comparisons[exists(map:get(., 'intersection-coordinates'))]) mod 2 eq 1)"
        />
    </xsl:function>
    
    <xsl:function name="my:polygons-overlap-or-touch" as="xs:boolean">
        <!-- Input: two arrays; each array's member consists of a pair of numerals, representing X-Y coordinates -->
        <!-- Output: true if the polygons touch; false otherwise -->
        <xsl:param name="polygon-1" as="array(*)"/>
        <xsl:param name="polygon-2" as="array(*)"/>
        <xsl:variable name="polygon-1-size" as="xs:integer" select="array:size($polygon-1)"/>
        <xsl:variable name="polygon-2-size" as="xs:integer" select="array:size($polygon-2)"/>
        <xsl:variable name="p1" as="array(*)" select="array:append($polygon-1, $polygon-1(1))"/>
        <xsl:variable name="p2" as="array(*)" select="array:append($polygon-2, $polygon-2(1))"/>
        
        <xsl:sequence select="
                (: If a point in one polygon is inside another, then yes the polygons overlap. This holds
                true even when the polygons do not intersect, such as a small square inside a large one. :)
                (some $i in (1 to $polygon-1-size)
                    satisfies my:point-is-in-polygon($polygon-1($i)[1], $polygon-1($i)[2], $polygon-2))
                or
                (some $i in (1 to $polygon-2-size)
                    satisfies my:point-is-in-polygon($polygon-2($i)[1], $polygon-2($i)[2], $polygon-1))
                or
                (: It may be that polygons overlap without points inside each other, like 
                two rectangles that form a + and in that case, we look for line intersection :)
                (some $i in (1 to $polygon-1-size),
                    $j in (1 to $polygon-2-size)
                    satisfies
                    my:compare-line-segments(
                    $p1($i)[1], $p1($i)[2], $p1($i + 1)[1], $p1($i + 1)[2],
                    $p2($j)[1], $p2($j)[2], $p2($j + 1)[1], $p2($j + 1)[2])?segments-touch)
                "/>
    </xsl:function>
    
    <xsl:variable name="comparison-1" as="map(*)" select="my:compare-line-segments(0, 0, 4, 4, 4, 4, 8, 0)"/>
    <xsl:variable name="comparison-2" as="map(*)" select="my:compare-line-segments(
        $polygon-1(1)[1],
        $polygon-1(1)[2],
        $polygon-1(2)[1],
        $polygon-1(2)[2],
        $polygon-2(1)[1],
        $polygon-2(1)[2],
        $polygon-2(2)[1],
        $polygon-2(2)[2])"/>
    
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <diagnostics>
            <segment-comparison><xsl:copy-of select="serialize($comparison-2, map{'method' : 'adaptive'})"/></segment-comparison>
            <polygons>
                <xsl:for-each select="1 to (count($all-polygons) - 1)">
                    <xsl:variable name="p1" as="xs:integer" select="."/>
                    <xsl:for-each select="($p1 + 1) to count($all-polygons)">
                        <xsl:variable name="p2" as="xs:integer" select="."/>
                        <do-polygons-touch p1="{$p1}" p2="{$p2}">{my:polygons-overlap-or-touch($all-polygons[$p1], $all-polygons[$p2])}</do-polygons-touch>
                    </xsl:for-each>
                </xsl:for-each>
            </polygons>
        </diagnostics>
    </xsl:template>
    
</xsl:stylesheet>