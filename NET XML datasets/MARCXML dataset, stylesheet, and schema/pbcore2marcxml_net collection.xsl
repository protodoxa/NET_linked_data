<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns="http://www.loc.gov/MARC21/slim" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="marc">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <marc:collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
            xmlns:pb="http://www.pbcore.org/PBCore/PBCoreNamespace.html">
            <xsl:for-each select="/pb:pbcoreCollection/pb:PBCoreDescriptionDocument">
                <marc:record>
                    <!-- leader -->
                    <marc:leader>      am         3u     </marc:leader>             
                    <!-- distribution and date fields -->                   
                        <marc:datafield tag="264" ind1=" " ind2="2">
                            <marc:subfield code="a">United States : </marc:subfield>
                            <marc:subfield code="b">National Educational Television,</marc:subfield>
                            <xsl:for-each select="pb:pbcoreAssetDate[@dateType='BROADCAST']">
                                <xsl:analyze-string select="." regex="(19)..">
                                    <xsl:matching-substring>
                                        <marc:subfield code="c">
                                            <xsl:value-of select="."/>
                                        </marc:subfield>
                                    </xsl:matching-substring>
                                </xsl:analyze-string>                             
                            </xsl:for-each>                        
                        </marc:datafield> 
                    <xsl:for-each select="pb:pbcoreAssetDate">
                        <xsl:if test="@dateType='BROADCAST'">                            
                            <marc:datafield tag="033" ind1="0" ind2="1">
                                <marc:subfield code="a">
                                    <xsl:variable name="year">
                                        <xsl:analyze-string select="." regex="(19)..">
                                            <xsl:matching-substring>
                                                <xsl:value-of select="."/>
                                            </xsl:matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:variable>
                                    <xsl:variable name="monthAndDay" select="substring-after(., '-')"/>
                                    <xsl:variable name="month" select="substring-before($monthAndDay, '-')"/>
                                    <xsl:variable name="day" select="substring-after($monthAndDay, '-')"/>
                                    <xsl:value-of select="$year"/>
                                    <xsl:value-of select="format-number($month, '00')"/>
                                    <xsl:value-of select="format-number($day, '00')"/>
                                </marc:subfield>
                            </marc:datafield>                
                        </xsl:if>
                        <xsl:if test="@dateType='RECORDED'">                            
                            <marc:datafield tag="033" ind1="0" ind2="0">
                                <marc:subfield code="a">
                                    <xsl:variable name="year">
                                        <xsl:analyze-string select="." regex="(19)..">
                                            <xsl:matching-substring>
                                                <xsl:value-of select="."/>
                                            </xsl:matching-substring>
                                        </xsl:analyze-string>
                                    </xsl:variable>
                                    <xsl:variable name="monthAndDay" select="substring-after(., '-')"/>
                                    <xsl:variable name="month" select="substring-before($monthAndDay, '-')"/>
                                    <xsl:variable name="day" select="substring-after($monthAndDay, '-')"/>
                                    <xsl:value-of select="$year"/>
                                    <xsl:value-of select="format-number($month, '00')"/>
                                    <xsl:value-of select="format-number($day, '00')"/>
                                </marc:subfield>
                            </marc:datafield>                             
                        </xsl:if>
                    </xsl:for-each>         
                    <!-- identifiers -->
                    <xsl:for-each select="pb:pbcoreIdentifier">
                        <xsl:choose>
                            <xsl:when test="@source = 'Library of Congress Control Number'">
                                <marc:datafield tag="010" ind1=" " ind2=" ">
                                    <marc:subfield code="a">
                                        <xsl:value-of select="."/>
                                    </marc:subfield>
                                </marc:datafield>
                            </xsl:when>
                            <xsl:otherwise>
                                <marc:datafield tag="024" ind1="7" ind2=" ">
                                    <marc:subfield code="a">
                                        <xsl:value-of select="."/>
                                    </marc:subfield>
                                    <marc:subfield code="2">
                                        <xsl:value-of select="@source"/>
                                    </marc:subfield>
                                </marc:datafield>
                            </xsl:otherwise>
                        </xsl:choose>                        
                    </xsl:for-each>  
                   <!--classification number-->
                    <xsl:for-each select="pb:pbcoreInstantiation/pb:instantiationPhysical">
                        <marc:datafield tag="050" ind1="0" ind2="0">
                            <marc:subfield code="a">
                              <xsl:choose>  
                                  <xsl:when test="count(../pb:instantiationPart) > 1">
                                    <xsl:for-each select="../pb:instantiationPart[1]/pb:instantiationLocation">
                                        <xsl:value-of select="substring-after(., 'RackNo: ')"/>
                                    </xsl:for-each><xsl:text>-</xsl:text>
                                    <xsl:for-each select="../pb:instantiationPart[last()]/pb:instantiationLocation">
                                        <xsl:value-of select="substring-after(., 'RackNo: ')"/>
                                    </xsl:for-each><xsl:text>(</xsl:text>                                
                                    <xsl:value-of select="substring-after(../pb:instantiationGenerations, ': ')"/><xsl:text>)</xsl:text>
                                </xsl:when>
                                  <xsl:otherwise>
                                      <xsl:value-of select="substring-after(../pb:instantiationLocation, 'RackNo: ')"/><xsl:text>(</xsl:text>
                                      <xsl:value-of select="substring-after(../pb:instantiationGenerations, ': ')"/><xsl:text>)</xsl:text>
                                  </xsl:otherwise>
                              </xsl:choose>
                                </marc:subfield>                           
                        </marc:datafield>    
                    </xsl:for-each>                    
                    <!-- titles -->
                    <xsl:for-each select="pb:pbcoreTitle[1]">
                        <marc:datafield tag="245" ind1="0" ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="."/>
                            </marc:subfield>                          
                            <xsl:for-each select="../pb:pbcoreCreator">
                                <xsl:if test="pb:creatorRole='Statement of Responsibility'">
                                    <marc:subfield code="c">
                                        <xsl:value-of select="pb:creator"/>
                                    </marc:subfield>
                                </xsl:if>
                            </xsl:for-each>
                        </marc:datafield>
                    </xsl:for-each>
                    <xsl:for-each select="pb:pbcoreTitle[position() > 1]">
                        <marc:datafield tag="246" ind1="3" ind2="3">
                            <marc:subfield code="a">
                                <xsl:value-of select="."/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- summaries -->
                    <xsl:for-each select="pb:pbcoreDescription">
                        <marc:datafield tag="520" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="."/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- genres -->
                    <xsl:for-each select="pb:pbcoreGenre">
                        <marc:datafield tag="655" ind1=" " ind2="0">
                            <marc:subfield code="a">
                                <xsl:value-of select="."/>
                            </marc:subfield>
                            <marc:subfield code="0">
                                <xsl:value-of select="@ref"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- general notes -->
                    <xsl:for-each select="pb:pbcoreAnnotation">
                        <marc:datafield tag="500" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="."/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- credits (authorized headings) -->
                    <xsl:for-each select="pb:pbcoreContributor">
                        <marc:datafield tag="720" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="pb:contributor"/>
                            </marc:subfield>
                            <marc:subfield code="e">
                                <xsl:value-of select="pb:contributorRole"/>
                            </marc:subfield>
                            <marc:subfield code="0">
                                <xsl:value-of select="pb:contributor/@ref"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <xsl:for-each select="pb:pbcoreCreator">
                        <xsl:if test="pb:creatorRole!='Statement of Responsibility'">
                            <marc:datafield tag="720" ind1=" " ind2=" ">
                                <marc:subfield code="a">
                                    <xsl:value-of select="pb:creator"/>
                                </marc:subfield>
                                <marc:subfield code="e">
                                    <xsl:value-of select="pb:creatorRole"/>
                                </marc:subfield>
                                <marc:subfield code="0">
                                    <xsl:value-of select="pb:creator/@ref"/>
                                </marc:subfield>
                            </marc:datafield>
                        </xsl:if>
                    </xsl:for-each>
                    <!-- subjects -->
                    <xsl:for-each select="pb:pbcoreSubject">
                        <xsl:if test="contains(@ref, 'subjects')">
                            <marc:datafield tag="650" ind1=" " ind2="0">
                                <marc:subfield code="a">
                                    <xsl:value-of select="."/>
                                </marc:subfield>
                                <marc:subfield code="0">
                                    <xsl:value-of select="@ref"/>
                                </marc:subfield>
                            </marc:datafield>                        
                        </xsl:if>
                        <xsl:if test="contains(@ref, 'names')">
                            <marc:datafield tag="651" ind1=" " ind2="0">
                                <marc:subfield code="a">
                                    <xsl:value-of select="."/>
                                </marc:subfield>
                                <marc:subfield code="0">
                                    <xsl:value-of select="@ref"/>
                                </marc:subfield>
                            </marc:datafield>                        
                        </xsl:if>
                    </xsl:for-each>
                    <!-- associated place (from pbcoreCoverage, a bad map in the mavis2pbcore stylesheet) -->
                    <xsl:for-each select="pb:pbcoreCoverage">
                        <marc:datafield tag="370" ind1=" " ind2=" ">
                            <marc:subfield code="g">
                                <xsl:value-of select="."/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- copyright note -->
                    <xsl:for-each select="pb:pbcoreRightsSummary">
                        <marc:datafield tag="542" ind1=" " ind2=" ">
                            <marc:subfield code="f">
                                <xsl:value-of select="pb:rightsSummary"/>
                            </marc:subfield>
                            <xsl:if test="../pb:pbcoreAssetDate/@dateType='COPYRIGHT'">
                                <marc:subfield code="g">
                                    <xsl:value-of select="../pb:pbcoreAssetDate"/>
                                </marc:subfield>
                            </xsl:if>
                        </marc:datafield>                        
                    </xsl:for-each>
                    <!-- title relationships -->
                    <xsl:for-each select="pb:pbcoreRelation">
                        <marc:datafield tag="787" ind1="0" ind2=" ">
                            <marc:subfield code="w">
                                <xsl:value-of select="pb:relationIdentifier"/>
                            </marc:subfield>
                            <marc:subfield code="n">
                                <xsl:value-of select="pb:relationIdentifier/@source"/>
                            </marc:subfield>
                            <marc:subfield code="a">
                                <xsl:value-of select="pb:relationIdentifier/@annotation"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <xsl:for-each select="pb:pbcorePart">
                        <marc:datafield tag="774" ind1="0" ind2=" ">
                            <marc:subfield code="w">
                                <xsl:value-of select="pb:pbcoreIdentifier"/>
                            </marc:subfield>
                            <marc:subfield code="n">
                                <xsl:value-of select="pb:pbcoreIdentifier/@source"/>
                            </marc:subfield>
                            <marc:subfield code="a">
                                <xsl:value-of select="pb:pbcoreTitle"/>
                            </marc:subfield>
                            <marc:subfield code="m">
                                <xsl:value-of select="pb:pbcoreDescription"/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- 300 -->
                    <xsl:for-each select="pb:pbcoreInstantiation">                        
                        <xsl:if test="pb:instantiationPhysical">
                            <marc:datafield tag="300" ind1=" " ind2=" ">
                                <marc:subfield code="a">
                                    <xsl:variable name="count" select="count(pb:instantiationPart)"/>
                                    <xsl:value-of select="$count"/><xsl:text> </xsl:text>
                                    <xsl:if test="pb:instantiationEssenceTrack/pb:essenceTrackType='Film'">
                                        <xsl:text>film reels </xsl:text>
                                    </xsl:if>
                                    <xsl:if test="pb:instantiationEssenceTrack/pb:essenceTrackType='Video'">
                                        <xsl:text>video reels </xsl:text>
                                    <xsl:if test="pb:instantiationDuration"></xsl:if><xsl:text>(</xsl:text>
                                    <xsl:value-of select="pb:instantiationDuration"/><xsl:text>) : </xsl:text></xsl:if>
                                </marc:subfield>
                                <marc:subfield code="b">
                                    <xsl:text>sd., </xsl:text>
                                    <xsl:for-each select="pb:instantiationColors">
                                        <xsl:choose>
                                            <xsl:when test=".='Black &amp; White'">
                                                <xsl:text>b&amp;w ;</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>col. ;</xsl:text>
                                            </xsl:otherwise>                                                                                          
                                        </xsl:choose>
                                    </xsl:for-each>
                                </marc:subfield>
                                <marc:subfield code="c">
                                    <xsl:for-each select="pb:instantiationPhysical">
                                        <xsl:choose>
                                            <xsl:when test="contains(., '2 inch')">
                                                <xsl:text>2 in.</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="contains(., '1 inch')">
                                                <xsl:text>1 in.</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="contains(., '3/4 inch')">
                                                <xsl:text>3/4 in.</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="contains(., 'Composite Positive')">
                                                <xsl:text>16mm.</xsl:text>
                                            </xsl:when>                                          
                                        </xsl:choose>
                                    </xsl:for-each>
                                </marc:subfield>
                                <marc:subfield code="3">
                                    <xsl:value-of select="substring-after(pb:instantiationGenerations, ': ')"/>
                                </marc:subfield>
                            </marc:datafield>
                        </xsl:if>
                        <xsl:if test="pb:instantiationDigital='Video/MPEG4'">
                            <marc:datafield tag="300" ind1=" " ind2=" ">
                                <marc:subfield code="a">
                                    <xsl:variable name="count" select="count(pb:instantiationPart)"/>                                   
                                    <xsl:choose>
                                        <xsl:when test="count(pb:instantiationPart)>1">
                                            <xsl:value-of select="$count"/><xsl:text> video files (digital, MPEG 4) : </xsl:text>
                                        </xsl:when>  
                                        <xsl:otherwise>
                                            <xsl:value-of select="$count"/><xsl:text> video file (digital, MPEG 4) : </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>                                    
                                </marc:subfield>
                                <marc:subfield code="b">
                                    <xsl:text>sd., </xsl:text>
                                    <xsl:for-each select="pb:instantiationColors">
                                        <xsl:choose>
                                            <xsl:when test=".='Black &amp; White'">
                                                <xsl:text>b&amp;w ;</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>col. ;</xsl:text>
                                            </xsl:otherwise>                                                                                          
                                        </xsl:choose>
                                    </xsl:for-each>
                                </marc:subfield>
                                <marc:subfield code="3">Access file</marc:subfield>
                            </marc:datafield>
                        </xsl:if>
                    </xsl:for-each>
                    <!-- playing time -->
                    <xsl:for-each select="pb:pbcoreInstantiation[1]/pb:instantiationDuration">
                        <marc:datafield tag="306" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="."/>
                            </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- content type, RDA list (previously matched as media type) -->
                    <marc:datafield tag="336" ind1=" " ind2=" ">
                        <marc:subfield code="a">two-dimensional moving image</marc:subfield>
                        <marc:subfield code="b">tbi</marc:subfield>
                        <marc:subfield code="2">rdacontent</marc:subfield>
                    </marc:datafield>
                    <!-- media type (used to be same value as 336, since fixed) -->
                    <xsl:for-each select="pb:pbcoreInstantiation[1]">
                        <xsl:choose>                            
                            <xsl:when test="pb:instantiationEssenceTrack/pb:essenceTrackType='Film'">
                                <marc:datafield tag="337" ind1=" " ind2=" ">
                                    <marc:subfield code="a">projected</marc:subfield>
                                    <marc:subfield code="b">g</marc:subfield>
                                    <marc:subfield code="2">rdamedia</marc:subfield>
                                    <marc:subfield code="3">
                                        <xsl:value-of select="pb:instantiationEssenceTrack/pb:essenceTrackType"/>
                                    </marc:subfield>
                                </marc:datafield>                               
                            </xsl:when>
                            <xsl:when test="pb:instantiationEssenceTrack/pb:essenceTrackType='Video' or 'Digital/Video'">
                                <marc:datafield tag="337" ind1=" " ind2=" ">
                                    <marc:subfield code="a">video</marc:subfield>
                                    <marc:subfield code="b">v</marc:subfield>
                                    <marc:subfield code="2">rdamedia</marc:subfield>                                 
                                </marc:datafield>   
                            </xsl:when>
                            <xsl:otherwise>
                                <marc:datafield tag="337" ind1=" " ind2=" ">
                                    <marc:subfield code="a">unspecified</marc:subfield>
                                    <marc:subfield code="b">x</marc:subfield>
                                    <marc:subfield code="2">rdamedia</marc:subfield>                                    
                                </marc:datafield>   
                            </xsl:otherwise>                           
                        </xsl:choose>
                        <!-- 338 carrier type, RDA list (context of NET collection very important here, broader use might want to re-map) -->
                        <xsl:for-each select="pb:instantiationEssenceTrack/pb:essenceTrackType">                       
                            <xsl:choose>
                                <xsl:when test=".='Film'">
                                    <marc:datafield tag="338" ind1=" " ind2=" ">
                                        <marc:subfield code="a">film reel</marc:subfield>
                                        <marc:subfield code="b">mr</marc:subfield>
                                        <marc:subfield code="2">rdaccarrier</marc:subfield>                                   
                                    </marc:datafield>   
                                </xsl:when>
                                <xsl:when test=".='Video'">
                                    <marc:datafield tag="338" ind1=" " ind2=" ">
                                        <marc:subfield code="a">videotape reel</marc:subfield>
                                        <marc:subfield code="b">vr</marc:subfield>
                                        <marc:subfield code="2">rdacarrier</marc:subfield>                                    
                                    </marc:datafield>   
                                </xsl:when>
                                <xsl:otherwise>
                                    <marc:datafield tag="338" ind1=" " ind2=" ">
                                        <marc:subfield code="a">unspecified</marc:subfield>
                                        <marc:subfield code="b">zu</marc:subfield>
                                        <marc:subfield code="2">rdacarrier</marc:subfield>                                    
                                    </marc:datafield>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>                       
                        <!-- $344, channel configuration -->
                        <xsl:for-each select="pb:instantiationChannelConfiguration">
                            <marc:datafield tag="344" ind1=" " ind2=" ">
                                <marc:subfield code="g">
                                    <xsl:value-of select="."/>
                                </marc:subfield>
                            </marc:datafield>
                        </xsl:for-each>                  
                        <!-- language note -->
                        <xsl:for-each select="pb:instantiationLanguage">
                            <marc:datafield tag="546" ind1=" " ind2=" ">
                                <marc:subfield code="a">
                                    <xsl:value-of select="."/>
                                </marc:subfield>
                            </marc:datafield>
                        </xsl:for-each>
                        <xsl:for-each select="pb:instantiationAlternativeModes">
                            <marc:datafield tag="546" ind1=" " ind2=" ">
                                <marc:subfield code="a">
                                    <xsl:value-of select="."/>
                                </marc:subfield>
                            </marc:datafield>
                        </xsl:for-each>
                        <!-- frameSize resolution note, holding spot for extension to ebucore -->
                        <xsl:for-each select="pb:instantiationPart/pb:instantiationEssenceTrack/pb:essenceTrackFrameSize">
                            <marc:datafield tag="500" ind1=" " ind2=" ">
                                <marc:subfield code="a">Resoultion framesize: <xsl:value-of select="."/>
                                </marc:subfield>
                            </marc:datafield>
                        </xsl:for-each>
                    </xsl:for-each>
                    <!--345, projected image-->
                   <xsl:for-each select="pb:pbcoreInstantiation"> 
                       <xsl:if test="pb:instantiationEssenceTrack/pb:essenceTrackType='Film'">
                        <marc:datafield tag="345" ind1=" " ind2=" ">
                            <marc:subfield code="a">standard sound aperture</marc:subfield>
                            <marc:subfield code="2">rdapf</marc:subfield>
                            <marc:subfield code="3">
                                <xsl:value-of select="substring-after(pb:instantiationGenerations, ': ')"/>
                            </marc:subfield>                          
                        </marc:datafield>
                        <marc:datafield tag="345" ind1=" " ind2=" ">
                            <marc:subfield code="b">
                                <xsl:value-of select="pb:instantiationEssenceTrack/pb:essenceTrackPlaybackSpeed"/>
                            </marc:subfield>
                            <marc:subfield code="3">
                                <xsl:value-of select="substring-after(pb:instantiationGenerations, ': ')"/>
                            </marc:subfield>
                        </marc:datafield>                                                                                                             
                    </xsl:if>
                    <!-- 346, video characteristics -->
                        <xsl:if test="pb:instantiationEssenceTrack/pb:essenceTrackType='Video'">
                            <marc:datafield tag="346" ind1=" " ind2=" ">
                                <marc:subfield code="a">                                 
                                    <xsl:if test="contains(pb:instantiationPhysical, '2 in')">Quadruplex</xsl:if>
                                    <xsl:if test="contains(pb:instantiationPhysical, '3/4')">U-matic</xsl:if>
                                    <xsl:if test="contains(pb:instantiationPhysical, '1 in')">Type C</xsl:if>
                                </marc:subfield>
                                <marc:subfield code="2">rdavf</marc:subfield>
                                <marc:subfield code="3">
                                    <xsl:value-of select="substring-after(pb:instantiationGenerations, ': ')"/>
                                </marc:subfield>
                            </marc:datafield>
                            <marc:datafield tag="346" ind1=" " ind2=" ">
                                <marc:subfield code="b">
                                    <xsl:value-of select="pb:instantiationStandard"/>
                                </marc:subfield>
                                <marc:subfield code="2">rdabs</marc:subfield>
                                <marc:subfield code="3">
                                    <xsl:value-of select="substring-after(pb:instantiationGenerations, ': ')"/>
                                </marc:subfield>
                            </marc:datafield>                                                                                                                                                                         
                        </xsl:if>
                   </xsl:for-each>
                    <!-- 347, digital characteristics -->
                    <xsl:for-each select="pb:pbcoreInstantiation/pb:instantiationDigital">
                        <xsl:variable name="identifier" select="../pb:instantiationIdentifier"/>
                        <xsl:if test=".='Video/MPEG4'">                            
                            <marc:datafield tag="347" ind1=" " ind2=" ">
                                <marc:subfield code="a">video file</marc:subfield>
                                <marc:subfield code="2">rdaft</marc:subfield>
                                <marc:subfield code="3">Access file (MPEG 4)</marc:subfield>
                            </marc:datafield>
                            <marc:datafield tag="347" ind1=" " ind2=" ">
                                <marc:subfield code="b">
                                    <xsl:value-of select="../pb:instantiationPart/pb:instantiationEssenceTrack/pb:essenceTrackStandard"/>
                                </marc:subfield>
                                <marc:subfield code="3">Access file (MPEG 4)</marc:subfield>
                            </marc:datafield>
                            <marc:datafield tag="347" ind1=" " ind2=" ">
                                <marc:subfield code="c">
                                    <xsl:value-of select="../pb:instantiationPart/pb:instantiationFileSize"/><xsl:text> </xsl:text>
                                    <xsl:value-of select="../pb:instantiationPart/pb:instantiationFileSize/@unitsOfMeasure"/>
                                </marc:subfield>
                                <marc:subfield code="3">Access file (MPEG 4)</marc:subfield>
                            </marc:datafield>
                            <marc:datafield tag="347" ind1=" " ind2=" ">
                                <marc:subfield code="d">
                                    <xsl:value-of select="../pb:instantiationPart/pb:instantiationEssenceTrack/pb:essenceTrackAspectRatio"/>
                                </marc:subfield>
                                <marc:subfield code="3">Access file (MPEG 4)</marc:subfield>
                            </marc:datafield>  
                            <marc:datafield tag="347" ind1=" " ind2=" ">
                                <marc:subfield code="f">
                                    <xsl:value-of select="../pb:instantiationPart/pb:instantiationEssenceTrack/pb:essenceTrackSamplingRate"/>;<xsl:text> </xsl:text>
                                    <xsl:value-of select="../pb:instantiationPart/pb:instantiationEssenceTrack/pb:essenceTrackDataRate"/><xsl:text> </xsl:text>
                                    <xsl:value-of select="../pb:instantiationPart/pb:instantiationEssenceTrack/pb:essenceTrackDataRate/@unitsOfMeasure"/>
                                </marc:subfield>  
                                <marc:subfield code="3">Access file (MPEG 4)</marc:subfield>
                            </marc:datafield>                                                                                             
                        </xsl:if>
                        <!-- holdings, digital -->
                        <xsl:analyze-string select="normalize-space(../pb:instantiationLocation)" regex="(https:)\W\W(navccwebp1.loc.gov:8080)\W(navcc)\W(content)\W(view.seam)\W(id=)\d+">
                            <xsl:matching-substring>
                                <marc:datafield tag="856" ind1="4" ind2="1">
                                    <marc:subfield code="a">Library of Congress</marc:subfield>
                                    <marc:subfield code="u">
                                        <xsl:value-of select="normalize-space(.)"/>  
                                    </marc:subfield>
                                    <marc:subfield code="w">
                                        <xsl:text>MAVIS identifier: </xsl:text><xsl:value-of select="$identifier"/>
                                    </marc:subfield>                                  
                                </marc:datafield>                                                                                       
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:for-each>
                    <!-- holdings, physical -->                  
                    <xsl:for-each select="pb:pbcoreInstantiation/pb:instantiationPhysical">                        
                        <marc:datafield tag="852" ind1="0" ind2=" ">
                            <marc:subfield code="a">Library of Congress</marc:subfield>
                            <marc:subfield code="b">Vault site: Culpeper</marc:subfield>                   
                            <xsl:for-each select="../pb:instantiationPart/pb:instantiationLocation">
                                        <marc:subfield code="c">
                                            <xsl:value-of select="substring-after(., 'RackNo: ')"/>      
                                        </marc:subfield>                                                                                         
                                    </xsl:for-each>                                                                     
                                <marc:subfield code="z">
                                    <xsl:if test="contains(../pb:instantiationLocation, '-')">
                                        <xsl:text>NET/PBS rack numbers (###-##-##) are unprocessed and may be shelved out of sequence or unavailable.</xsl:text>
                                    </xsl:if>
                                </marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                    <!-- MAVIS item numbers, 776 (additional physical form) -->
                    <xsl:for-each select="pb:pbcoreInstantiation/pb:instantiationIdentifier">
                        <xsl:if test="@source='MAVIS Item ID'">
                            <marc:datafield tag="776" ind1="0" ind2=" ">
                                <marc:subfield code="w">
                                    <xsl:value-of select="."/>
                                </marc:subfield>
                                <marc:subfield code="n">
                                    <xsl:value-of select="@source"/>
                                </marc:subfield>
                            </marc:datafield>
                        </xsl:if>
                    </xsl:for-each>                                        
                    <!-- tracing copy history? -->
                    <xsl:for-each select="pb:pbcoreInstantiation/pb:instantiationRelation">
                        <marc:datafield tag="887" ind1=" " ind2=" ">
                            <marc:subfield code="a">
                                <xsl:value-of select="../pb:instantiationIdentifier"/><xsl:text> </xsl:text>
                                <xsl:if test="contains(., 'To')">copied to</xsl:if>
                                <xsl:if test="contains(., 'From')">copied from</xsl:if><xsl:text>: </xsl:text>
                                <xsl:value-of select="pb:instantiationRelationIdentifier"/>
                            </marc:subfield>
                            <marc:subfield code="2">MAVIS copy history</marc:subfield>
                        </marc:datafield>
                    </xsl:for-each>
                </marc:record>
            </xsl:for-each>
        </marc:collection>
    </xsl:template>

</xsl:stylesheet>
