<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xl="http://www.w3.org/TR/xlink" xmlns:mv="http://www.wizardis.com.au/2005/12/MAVIS"
	xmlns="http://www.pbcore.org/PBCore/PBCoreNamespace.html"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">


	<xsl:output encoding="ISO-8859-1" indent="yes"/>

	<!-- MAVIS to PbCore stylesheet
	21/10/08 FLS REQ28747  Create PbCore mapping
	10/01/10 FLS REQ40366  Handle documents of stand-alone components.  Repeat subjects/genres rather than concatenating them in a single element.
	29/08/11 FLS REQ40858  PBCore export - possible confusion between AudienceLevel and Audience Rating. Include PDR producer as a creator.
	06/01/12 FLS BUG40859  PBCore export - names not exported if you tick Include full Name details?
	16/01/12 FLS REQ40708  Review pbCore 2.0 and change pbCore export in MAVIS if required
	13/02/12 FLS REQ40708  Changes after initial review by MM
	11/04/12 FLS BUG41032  Bcore 2.0 export - small issue with extra semi-colon in instantiationAlternativeModes tag
-->

	<xsl:variable name="subjectAuthority">MAVIS Subject Authority List</xsl:variable>
	<xsl:variable name="genreAuthority">MAVIS Genre Authority List</xsl:variable>
	<xsl:variable name="nameAuthority">MAVIS Name Authority List</xsl:variable>
	<xsl:variable name="relatedTitleType">Related Title</xsl:variable>
	<xsl:variable name="containedByType">Contained By Title</xsl:variable>
	<xsl:variable name="primaryIdType">MAVIS Title Number</xsl:variable>
	<xsl:variable name="preferredTitleType">Preferred Title</xsl:variable>
	<xsl:variable name="alternateTitleType">Alternate Title</xsl:variable>
	<xsl:variable name="itemDescription">Item Description</xsl:variable>
	<xsl:variable name="seriesTitleType">Series Title</xsl:variable>
	<xsl:variable name="uniformTitleType">Uniform Title</xsl:variable>
	<xsl:variable name="subjectTypeTopic">Topic</xsl:variable>
	<xsl:variable name="subjectTypeName">About</xsl:variable>
	<xsl:variable name="titleCompFormatIdType">MAVIS Component Number</xsl:variable>
	<xsl:variable name="titleCompCarrFormatIdType">MAVIS Carrier Number</xsl:variable>
	<xsl:variable name="itemFormatIdType">MAVIS Item ID</xsl:variable>
	<xsl:variable name="primaryLanguage">ORIG</xsl:variable>
	<xsl:variable name="responsibilityStatement">Statement of Responsibility</xsl:variable>

	<!-- used for essenceTrack -->
	<xsl:variable name="audioType">Audio</xsl:variable>
	<xsl:variable name="videoType">Video</xsl:variable>
	<xsl:variable name="imageType">Image</xsl:variable>
	<xsl:variable name="textType">Text</xsl:variable>

	<!-- used for FormatGenerations -->
	<xsl:variable name="digitalFileGeneration">Digital File</xsl:variable>
	<xsl:variable name="movingImageGeneration">MovingImage</xsl:variable>
	<xsl:variable name="audioGeneration">Audio</xsl:variable>
	<xsl:variable name="stillImageGeneration">Static Image</xsl:variable>
	<xsl:variable name="textGeneration">Text</xsl:variable>
	<xsl:variable name="artifactGeneration">Artifact</xsl:variable>
	<xsl:variable name="siteName">
		<xsl:text> </xsl:text>
		<xsl:value-of select="mv:mavis/@organisation"/>
	</xsl:variable>

	<!--  Main template - determines whether we have a document of titles, or components -->
	<xsl:template match="mv:mavis">
		<xsl:choose>
			<xsl:when test="mv:TitleWork or mv:SeriesWork or mv:UniformTitle">
				<xsl:call-template name="processWorks"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="processComponents"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Do not output anything except what's in the "mavis" template -->
	<xsl:template match="*"> </xsl:template>

	<!--  Called when we have a document of works with embedded components -->
	<xsl:template name="processWorks">
		<xsl:for-each select="mv:TitleWork | mv:UniformTitle | mv:SeriesWork">
			<xsl:call-template name="createWork"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Called when we have a document of standalone components -->
	<xsl:template name="processComponents">
		<xsl:for-each
			select="mv:NitrateFilmComponent | mv:AcetateFilmComponent | mv:VideoTapeComponent | mv:DigitalComponent | mv:PaperComponent | mv:ArtifactComponent | mv:PhotographicComponent | mv:AudioTapeComponent | mv:DiscComponent">
			<xsl:call-template name="createComponent"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="createWork">
		<PBCoreDescriptionDocument
			xsi:schemaLocation="http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/PBCore/PBCoreSchema.xsd">
			<!-- PBCoreIntellectualContent
		Asset Type - Mediums/Classes
		Asset Dates - Dates
		Titles
		Identifiers
		Subjects
		Summaries
		Genres
		Related Works, ContainedBy Works
		Coverage (Date type=COVERED, Place type=L)
		Audience Level
		Audience Rating -->
			<xsl:call-template name="assetTypes"/>
			<xsl:call-template name="assetDates"/>
			<xsl:call-template name="titleIdentifiers"/>
			<xsl:apply-templates select="mv:objectIdentifiers"/>
			<xsl:apply-templates select="mv:preferredTitle"/>
			<xsl:apply-templates select="mv:alternateTitles"/>
			<xsl:apply-templates select="mv:subjects"/>
			<xsl:apply-templates select="mv:nameAsSubjects"/>
			<xsl:apply-templates select="mv:objectSummaries"/>
			<xsl:apply-templates select="mv:genres"/>
			<xsl:apply-templates select="mv:relatedWorks"/>
			<xsl:apply-templates select="mv:containedBySummary"/>
			<xsl:call-template name="coverage"/>
			<xsl:call-template name="audienceLevel"/>
			<xsl:apply-templates select="mv:censorRating"/>

			<!-- PBCoreAnnotation - Title Notes -->
			<xsl:call-template name="titleAnnotation"/>

			<!-- PBCoreIntellectualProperty - Credits and Rights -->
			<xsl:apply-templates select="mv:responsibilityStatement"/>
			<xsl:apply-templates select="mv:roles"/>

			<!-- PBCoreInstantiation - Component Details -->
			<xsl:apply-templates select="mv:components"/>

			<!-- PBCoreExtensions - Segments -->
			<xsl:apply-templates select="mv:children"/>
		</PBCoreDescriptionDocument>
		<xsl:text>
</xsl:text>
	</xsl:template>


	<!-- this is the template that actually outputs the <PBCoreDescriptionDocument> tag for each component, when not enclosed in a work  -->
	<xsl:template name="createComponent">
		<PBCoreDescriptionDocument
			xsi:schemaLocation="http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/PBCore/PBCoreSchema.xsd">
			<!--abbreviated work detail - this is all we can get when processing a document of standalone components -->
			<xsl:choose>
				<xsl:when test="mv:work">
					<xsl:call-template name="createTitle">
						<xsl:with-param name="title" select="mv:work/@xl:title"/>
						<xsl:with-param name="titleType" select="$preferredTitleType"/>
					</xsl:call-template>
					<xsl:call-template name="titleIdentifierForComp"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="mv:roles"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="componentDetail"/>
		</PBCoreDescriptionDocument>
		<xsl:text>
</xsl:text>
	</xsl:template>

	<!-- Remove the trailing character from a string, if that character is a semi-colon -->
	<xsl:template name="stripLast">
		<xsl:param name="stringValue"/>
		<xsl:choose>
			<xsl:when test="substring($stringValue, string-length($stringValue), 1) = ';'">
				<xsl:value-of
					select="normalize-space(substring($stringValue, 1, (string-length($stringValue) - 1)))"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($stringValue)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Output a linebreak -->
	<xsl:template name="lineBreak">
		<xsl:text>
</xsl:text>
	</xsl:template>

	<!-- ==================================== -->
	<!--  Named Templates for Intellectual Content -->
	<!-- ==================================== -->
	<!-- Annotations - all forms of title notes -->
	<xsl:template name="titleAnnotation">
		<xsl:call-template name="createNote">
			<xsl:with-param name="noteNode" select="mv:note"/>
			<xsl:with-param name="noteType">Note</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="createNote">
			<xsl:with-param name="noteNode" select="mv:preservationSummary"/>
			<xsl:with-param name="noteType">Preservation Summary</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="createNote">
			<xsl:with-param name="noteNode" select="mv:restrictedNote"/>
			<xsl:with-param name="noteType">Restrictions</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="createNote">
			<xsl:with-param name="noteNode" select="mv:nominationAward"/>
			<xsl:with-param name="noteType">Nomination / Award Notes</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Asset Types - use mediums and classes -->
	<xsl:template name="assetTypes">
		<xsl:for-each select="mv:mediums/mv:WorkMedium/mv:medium">
			<pbcoreAssetType>
				<xsl:value-of select="@xl:title"/>
			</pbcoreAssetType>
		</xsl:for-each>
		<xsl:for-each select="mv:classes/mv:WorkClass/mv:workClass">
			<pbcoreAssetType>
				<xsl:value-of select="@xl:title"/>
			</pbcoreAssetType>
		</xsl:for-each>
	</xsl:template>

	<!-- Work Dates - use dateType as the attribute. May be a range -->
	<xsl:template name="assetDates">
		<xsl:for-each select="mv:objectDates/mv:Date-Year">
			<xsl:if test="mv:dateType != 'COVERED'">
				<pbcoreAssetDate>
					<xsl:attribute name="dateType">
						<xsl:value-of select="mv:dateType"/>
					</xsl:attribute>
					<xsl:call-template name="createDateElement">
						<xsl:with-param name="dateNode" select="."/>
					</xsl:call-template>
				</pbcoreAssetDate>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Audience Level - a subset of Genre -->
	<xsl:template name="audienceLevel">
		<xsl:for-each select="mv:genres/mv:WorkGenre">
			<xsl:if test="mv:genre = 'CH' or mv:genre = 'CHILD' or mv:genre = 'COL'">
				<pbcoreAudienceLevel>
					<xsl:value-of select="mv:genre/@xl:title"/>
				</pbcoreAudienceLevel>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Coverage - Dates (may be a range) and Places -->
	<xsl:template name="coverage">
		<xsl:for-each select="mv:objectDates/mv:Date-Year[mv:dateType = 'COVERED']">
			<pbcoreCoverage>
				<xsl:attribute name="coverageType">Temporal</xsl:attribute>
				<xsl:call-template name="createDateElement">
					<xsl:with-param name="dateNode" select="."/>
				</xsl:call-template>
			</pbcoreCoverage>
		</xsl:for-each>
		<xsl:for-each select="mv:objectPlaces/mv:ObjectPlace[mv:placeType = 'L']">
			<pbcoreCoverage>
				<xsl:attribute name="coverageType">Spatial</xsl:attribute>
				<xsl:value-of select="mv:place"/>
			</pbcoreCoverage>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="componentRoles">
		<xsl:apply-templates select="mv:roles"/>
	</xsl:template>

	<!-- =============== -->
	<!-- General templates -->
	<!-- =============== -->
	<xsl:template name="titleIdentifierForComp">
		<xsl:param name="titleCompNo">
			<xsl:call-template name="getObjectKey">
				<xsl:with-param name="href">
					<xsl:value-of select="@xl:href"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:call-template name="createIdentifier">
			<xsl:with-param name="identifier">
				<xsl:value-of select="substring-before($titleCompNo, '-')"/>
			</xsl:with-param>
			<xsl:with-param name="identifierSource">
				<xsl:value-of select="$primaryIdType"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="titleIdentifiers">
		<xsl:call-template name="createIdentifier">
			<xsl:with-param name="identifier">
				<xsl:call-template name="getObjectKey">
					<xsl:with-param name="href">
						<xsl:value-of select="@xl:href"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="identifierSource">
				<xsl:value-of select="$primaryIdType"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="createNote">
		<xsl:param name="noteNode"/>
		<xsl:param name="noteType"/>

		<xsl:if test="$noteNode">
			<pbcoreAnnotation>
				<xsl:attribute name="annotationType">
					<xsl:value-of select="$noteType"/>
				</xsl:attribute>
				<xsl:value-of select="$noteNode"/>
			</pbcoreAnnotation>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createTitle">
		<xsl:param name="title"/>
		<xsl:param name="titleType"/>
		<pbcoreTitle>
			<xsl:attribute name="titleType">
				<xsl:value-of select="$titleType"/>
			</xsl:attribute>
			<xsl:value-of select="$title"/>
		</pbcoreTitle>
	</xsl:template>

	<xsl:template name="createIdentifier">
		<xsl:param name="identifier"/>
		<xsl:param name="identifierSource"/>
		<pbcoreIdentifier>
			<xsl:attribute name="source">
				<xsl:value-of select="$identifierSource"/>
			</xsl:attribute>
			<xsl:value-of select="$identifier"/>
		</pbcoreIdentifier>
	</xsl:template>

	<xsl:template name="createCreator">
		<xsl:param name="creator"/>
		<xsl:param name="creatorRole"/>
		<pbcoreCreator>
			<creator>
				<xsl:value-of select="$creator"/>
			</creator>
			<creatorRole>
				<xsl:value-of select="$creatorRole"/>
			</creatorRole>
		</pbcoreCreator>
	</xsl:template>

	<xsl:template name="createContributor">
		<xsl:param name="contributor"/>
		<xsl:param name="contributorRole"/>
		<pbcoreContributor>
			<contributor>
				<xsl:value-of select="$contributor"/>
			</contributor>
			<contributorRole>
				<xsl:value-of select="$contributorRole"/>
			</contributorRole>
		</pbcoreContributor>
	</xsl:template>

	<xsl:template name="createPublisher">
		<xsl:param name="publisher"/>
		<xsl:param name="publisherRole"/>
		<pbcorePublisher>
			<publisher>
				<xsl:value-of select="$publisher"/>
			</publisher>
			<publisherRole>
				<xsl:value-of select="$publisherRole"/>
			</publisherRole>
		</pbcorePublisher>
	</xsl:template>

	<xsl:template name="createRightsHolder">
		<xsl:param name="holder"/>
		<xsl:param name="holderRole"/>
		<pbcoreRightsSummary>
			<rightsSummary><xsl:value-of select="$holderRole"/>: <xsl:value-of select="$holder"
					/><xsl:call-template name="lineBreak"/>
				<xsl:if test="mv:copyrightDate">Date of Copyright: <xsl:value-of
						select="mv:copyrightDate"/><xsl:call-template name="lineBreak"/></xsl:if>
				<xsl:if test="mv:copyrightRegNo">Copyright Registration Number: <xsl:value-of
						select="mv:copyrightRegNo"/><xsl:call-template name="lineBreak"/></xsl:if>
				<xsl:if test="mv:summary">Notes: <xsl:value-of select="mv:summary"/></xsl:if>
			</rightsSummary>
		</pbcoreRightsSummary>
	</xsl:template>

	<xsl:template name="getObjectKey">
		<xsl:param name="href">
			<xsl:value-of select="@xl:href"/>
		</xsl:param>
		<xsl:value-of
			select="substring-after(substring-after(substring-after($href, '/'), '/'), '/')"/>
	</xsl:template>

	<xsl:template name="getObjectDesc">
		<xsl:param name="href"/>
		<xsl:value-of select="substring-before(substring-after($href, '/'), '/')"/>
	</xsl:template>

	<xsl:template name="createDateElement">
		<xsl:param name="dateNode"/>
		<xsl:value-of select="$dateNode/mv:yearFrom"/>
		<xsl:if test="$dateNode/mv:monthFrom > 0">-<xsl:value-of select="$dateNode/mv:monthFrom"
			/></xsl:if>
		<xsl:if test="$dateNode/mv:dayFrom > 0">-<xsl:value-of select="$dateNode/mv:dayFrom"
			/></xsl:if>
		<xsl:if test="$dateNode/mv:yearTo > 0">
			<xsl:text> to </xsl:text>
			<xsl:value-of select="$dateNode/mv:yearTo"/>
			<xsl:if test="$dateNode/mv:monthTo > 0">-<xsl:value-of select="$dateNode/mv:monthTo"
				/></xsl:if>
			<xsl:if test="$dateNode/mv:dayTo > 0">-<xsl:value-of select="$dateNode/mv:dayTo"
				/></xsl:if>
		</xsl:if>
	</xsl:template>


	<!-- =================================== -->
	<!-- Match templates for Intellectual Content -->
	<!-- =================================== -->
	<xsl:template match="mv:preferredTitle">
		<xsl:for-each select="child::*">
			<xsl:call-template name="createTitle">
				<xsl:with-param name="title">
					<xsl:value-of select="mv:descr"/>
				</xsl:with-param>
				<xsl:with-param name="titleType">
					<xsl:if test="ancestor::mv:TitleWork">
						<xsl:value-of select="$preferredTitleType"/>
						<xsl:if test="mv:titlePurpose">
							<xsl:text>: </xsl:text>
							<xsl:value-of select="mv:titlePurpose/@xl:title"/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="ancestor::mv:SeriesWork">
						<xsl:value-of select="$seriesTitleType"/>
					</xsl:if>
					<xsl:if test="ancestor::mv:UniformTitle">
						<xsl:value-of select="$uniformTitleType"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:alternateTitles">
		<xsl:for-each select="child::*">
			<xsl:call-template name="createTitle">
				<xsl:with-param name="title">
					<xsl:value-of select="mv:descr"/>
				</xsl:with-param>
				<xsl:with-param name="titleType">
					<xsl:value-of select="$alternateTitleType"/>
					<xsl:if test="mv:titlePurpose">
						<xsl:text>: </xsl:text>
						<xsl:value-of select="mv:titlePurpose/@xl:title"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:objectIdentifiers">
		<xsl:for-each select="child::*">
			<xsl:call-template name="createIdentifier">
				<xsl:with-param name="identifier">
					<xsl:value-of select="mv:identifier"/>
				</xsl:with-param>
				<xsl:with-param name="identifierSource">
					<xsl:value-of select="mv:identifierType/@xl:title"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:subjects">
		<xsl:for-each select="mv:WorkSubject">
			<pbcoreSubject>
				<xsl:attribute name="source">
					<xsl:value-of select="$subjectAuthority"/>
					<xsl:value-of select="$siteName"/>
				</xsl:attribute>
				<xsl:attribute name="subjectType">
					<xsl:value-of select="$subjectTypeTopic"/>
				</xsl:attribute>
				<xsl:value-of select="mv:subject/@xl:title"/>
			</pbcoreSubject>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:nameAsSubjects">
		<xsl:for-each select="mv:NameAsSubject">
			<pbcoreSubject>
				<xsl:attribute name="source">
					<xsl:value-of select="$nameAuthority"/>
					<xsl:value-of select="$siteName"/>
				</xsl:attribute>
				<xsl:attribute name="subjectType">
					<xsl:value-of select="$subjectTypeName"/>
				</xsl:attribute>
				<xsl:value-of select="mv:party/@xl:title"/>
			</pbcoreSubject>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:objectSummaries">
		<xsl:for-each select="child::*">
			<pbcoreDescription>
				<xsl:attribute name="descriptionType">
					<xsl:value-of select="mv:summaryType/@xl:title"/>
				</xsl:attribute>
				<xsl:value-of select="mv:summary"/>
			</pbcoreDescription>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:genres">
		<xsl:for-each select="mv:WorkGenre">
			<pbcoreGenre>
				<xsl:attribute name="source">
					<xsl:value-of select="$genreAuthority"/>
					<xsl:value-of select="$siteName"/>
				</xsl:attribute>
				<xsl:value-of select="mv:genre/@xl:title"/>
			</pbcoreGenre>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:relatedWorks">
		<xsl:for-each select="child::*">
			<pbcoreRelation>
				<relationType>
					<xsl:value-of select="$relatedTitleType"/>
				</relationType>
				<relationIdentifier>
					<xsl:attribute name="source">
						<xsl:value-of select="$primaryIdType"/>
					</xsl:attribute>
					<xsl:attribute name="annotation">
						<xsl:value-of select="@xl:title"/>
					</xsl:attribute>
					<xsl:call-template name="getObjectKey">
						<xsl:with-param name="href" select="@xl:href"/>
					</xsl:call-template>
				</relationIdentifier>
			</pbcoreRelation>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mv:containedBySummary">
		<xsl:for-each select="child::*">
			<pbcoreRelation>
				<relationType>
					<xsl:value-of select="$containedByType"/>
				</relationType>
				<relationIdentifier>
					<xsl:attribute name="source">
						<xsl:value-of select="$primaryIdType"/>
					</xsl:attribute>
					<xsl:attribute name="annotation">
						<xsl:value-of select="@xl:title"/>
					</xsl:attribute>
					<xsl:call-template name="getObjectKey">
						<xsl:with-param name="href">
							<xsl:value-of select="@xl:href"/>
						</xsl:with-param>
					</xsl:call-template>
				</relationIdentifier>
			</pbcoreRelation>
		</xsl:for-each>
	</xsl:template>

	<!-- pbcorePart -->
	<xsl:template match="mv:children">
		<xsl:for-each select="mv:WorkStructure">
			<pbcorePart>
				<pbcoreIdentifier>
					<xsl:attribute name="source">
						<xsl:value-of select="$primaryIdType"/>
					</xsl:attribute>
					<xsl:attribute name="annotation">
						<xsl:value-of select="mv:segment/@xl:title"/>
					</xsl:attribute>
					<xsl:call-template name="getObjectKey">
						<xsl:with-param name="href">
							<xsl:value-of select="mv:segment/@xl:href"/>
						</xsl:with-param>
					</xsl:call-template>
				</pbcoreIdentifier>
				<pbcoreTitle>
					<xsl:value-of select="mv:segment/@xl:title"/>
				</pbcoreTitle>
				<pbcoreDescription>
					<xsl:choose>
						<xsl:when test="mv:workStructureType = 'SE'">Episode</xsl:when>
						<xsl:when test="mv:workStructureType = 'U'">Expression</xsl:when>
						<xsl:otherwise>Content</xsl:otherwise>
					</xsl:choose>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mv:segmentSeqNo"/>
					<xsl:if test="mv:episode"><xsl:text> (</xsl:text><xsl:value-of
							select="mv:episode"/>)</xsl:if>
				</pbcoreDescription>
			</pbcorePart>
		</xsl:for-each>
	</xsl:template>

	<!-- pbcoreAudienceRating -->
	<xsl:template match="mv:censorRating">
		<pbcoreAudienceRating>
			<xsl:value-of select="@xl:title"/>
		</pbcoreAudienceRating>
	</xsl:template>

	<!-- COP roles are Rights Holders, principal roles or specific roles are Creators,  everyone else is a Contributor -->
	<xsl:template match="mv:roles">
		<xsl:for-each select="mv:Name-Role[mv:role != 'COP']">
			<xsl:choose>
				<xsl:when
					test="
						(mv:principalRole = 'Y') or (
						mv:role = 'AUT' or mv:role = 'CMP' or mv:role = 'CRE' or
						mv:role = 'DIR' or mv:role = 'DRT' or mv:role = 'EXP' or
						mv:role = 'FIL' or mv:role = 'FLM' or mv:role = 'FOR' or
						mv:role = 'KOM' or mv:role = 'PCO' or mv:role = 'PDB' or
						mv:role = 'PDC' or mv:role = 'PDD' or mv:role = 'PDE' or
						mv:role = 'PDR' or mv:role = 'PRC' or mv:role = 'PRO' or
						mv:role = 'REC' or mv:role = 'REG' or mv:role = 'REGS' or
						mv:role = 'SCR' or mv:role = 'SCW' or mv:role = 'SP' or
						mv:role = 'SSP' or mv:role = 'STO' or mv:role = 'TEL' or
						mv:role = 'WRI' or mv:role = 'WRT')">
					<xsl:call-template name="createCreator">
						<xsl:with-param name="creator">
							<xsl:choose>
								<xsl:when test="mv:party/@xl:title">
									<xsl:value-of select="mv:party/@xl:title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="mv:party//@xl:title"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="creatorRole">
							<xsl:value-of select="mv:role/@xl:title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="createContributor">
						<xsl:with-param name="contributor">
							<xsl:choose>
								<xsl:when test="mv:party/@xl:title">
									<xsl:value-of select="mv:party/@xl:title"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="mv:party//@xl:title"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="contributorRole">
							<xsl:value-of select="mv:role/@xl:title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>

		<xsl:for-each select="mv:Name-Role[mv:role = 'COP']">
			<xsl:call-template name="createRightsHolder">
				<xsl:with-param name="holder">
					<xsl:choose>
						<xsl:when test="mv:party/@xl:title">
							<xsl:value-of select="mv:party/@xl:title"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="mv:party//@xl:title"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="holderRole">
					<xsl:value-of select="mv:role/@xl:title"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="mv:responsibilityStatement">
		<xsl:call-template name="createCreator">
			<xsl:with-param name="creator">
				<xsl:value-of select="."/>
			</xsl:with-param>
			<xsl:with-param name="creatorRole">
				<xsl:value-of select="$responsibilityStatement"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- ============================================== -->
	<!--  Main template for Instantiation is a match template called from the main work template -->
	<!-- ============================================== -->
	<xsl:template match="mv:components">
		<xsl:for-each select="child::*">
			<xsl:call-template name="componentDetail"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Main component template - produces the instantiation details -->
	<xsl:template name="componentDetail">
		<pbcoreInstantiation>
			<xsl:call-template name="identifiers"/>
			<xsl:call-template name="componentLocation"/>
			<xsl:call-template name="instantiationDates"/>
			<xsl:call-template name="dimensions"/>
			<xsl:call-template name="digitalPhysical"/>
			<xsl:call-template name="standard"/>
			<xsl:call-template name="mediaType"/>
			<xsl:call-template name="generations"/>
			<xsl:call-template name="componentFileSize"/>
			<xsl:call-template name="duration"/>
			<xsl:call-template name="colors"/>
			<xsl:call-template name="tracks"/>
			<xsl:call-template name="channelConfiguration"/>
			<xsl:apply-templates select="mv:itemLanguages"/>
			<xsl:call-template name="essenceTrack"/>
			<xsl:call-template name="relation"/>
			<xsl:call-template name="itemAnnotation"/>
			<xsl:call-template name="itemParts"/>
		</pbcoreInstantiation>
	</xsl:template>

	<!-- =================================== -->
	<!--  Named Templates for Instantiation  data -->
	<!-- =================================== -->
	<!-- Parts - MAVIS Component-Carrier relationship. Technical details for digital carriers appear here, rather than in the main instantiation section -->
	<xsl:template name="createPart">
		<xsl:param name="noCarriers"/>

		<instantiationPart>
			<xsl:call-template name="carrierIdentifiers">
				<xsl:with-param name="noCarriers" select="$noCarriers"/>
			</xsl:call-template>
			<xsl:call-template name="carrierLocation"/>

			<xsl:choose>
				<xsl:when test="name() = 'DigitalCarrier'">
					<xsl:call-template name="carrierFileSize"/>
					<xsl:call-template name="dimensions"/>
					<xsl:call-template name="colors"/>
					<xsl:call-template name="essenceTrack"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="duration"/>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:call-template name="relation"/>
			<xsl:call-template name="itemAnnotation"/>
		</instantiationPart>
	</xsl:template>

	<xsl:template name="itemParts">
		<xsl:variable name="noCarriers">
			<xsl:value-of select="count(mv:carriers/child::*)"/>
		</xsl:variable>
		<xsl:for-each select="mv:carriers/child::*">
			<xsl:call-template name="createPart">
				<xsl:with-param name="noCarriers">
					<xsl:value-of select="$noCarriers"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="createLocation">
		<xsl:param name="location"/>
		<instantiationLocation>
			<xsl:call-template name="stripLast">
				<xsl:with-param name="stringValue">
					<xsl:choose>
						<xsl:when test="normalize-space($location) != ''">
							<xsl:value-of select="normalize-space($location)"/>
						</xsl:when>
						<xsl:otherwise>Unknown</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</instantiationLocation>
	</xsl:template>


	<xsl:template name="createItemIdentifier">
		<xsl:param name="identifier"/>
		<xsl:param name="identifierSource"/>
		<xsl:param name="annotation"/>
		<instantiationIdentifier>
			<xsl:attribute name="source">
				<xsl:value-of select="$identifierSource"/>
			</xsl:attribute>
			<xsl:if test="$annotation">
				<xsl:attribute name="annotation">
					<xsl:value-of select="$annotation"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$identifier"/>
		</instantiationIdentifier>
	</xsl:template>

	<!--Component Identifiers  -->
	<xsl:template name="identifiers">
		<xsl:variable name="itemId"
			select="substring-after(substring-after(substring-after(@xl:href, '/'), '/'), '/')"/>
		<xsl:if test="mv:isUnattached = 'N'">
			<xsl:call-template name="createItemIdentifier">
				<xsl:with-param name="identifier">
					<xsl:call-template name="getObjectKey">
						<xsl:with-param name="href">
							<xsl:value-of select="@xl:href"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="identifierSource">
					<xsl:value-of select="$titleCompFormatIdType"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="createItemIdentifier">
			<xsl:with-param name="identifier" select="$itemId"/>
			<xsl:with-param name="identifierSource">
				<xsl:value-of select="$itemFormatIdType"/>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:for-each select="mv:objectIdentifiers/mv:ObjectIdentifier">
			<xsl:call-template name="createItemIdentifier">
				<xsl:with-param name="identifier">
					<xsl:value-of select="mv:identifier"/>
				</xsl:with-param>
				<xsl:with-param name="identifierSource">
					<xsl:value-of select="mv:identifierType/@xl:title"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!--Component dates  -->
	<xsl:template name="instantiationDates">
		<xsl:for-each select="mv:objectDates/mv:Date-Year">
			<xsl:if test="mv:dateType != 'COVERED'">
				<instantiationDate>
					<xsl:attribute name="dateType">
						<xsl:value-of select="mv:dateType"/>
					</xsl:attribute>
					<xsl:call-template name="createDateElement">
						<xsl:with-param name="dateNode" select="."/>
					</xsl:call-template>
				</instantiationDate>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>




	<xsl:template name="createDimensions">
		<xsl:param name="dimension"/>
		<xsl:if test="normalize-space($dimension) != ''">
			<instantiationDimensions>
				<xsl:value-of select="normalize-space($dimension)"/>
			</instantiationDimensions>
		</xsl:if>
	</xsl:template>

	<!--Component/Carrier dimensions  -->
	<xsl:template name="dimensions">
		<xsl:choose>
			<xsl:when test="name() = 'DigitalCarrier'">
				<xsl:if
					test="mv:imageLength or mv:imageWidth or mv:resolutionUnit or mv:xResolution or mv:yResolution">
					<xsl:call-template name="createDimensions">
						<xsl:with-param name="dimension">
							<xsl:if test="mv:imageLength"><xsl:text>Length: </xsl:text><xsl:value-of
									select="mv:imageLength"/>;</xsl:if>
							<xsl:if test="mv:imageWidth"><xsl:text> Width: </xsl:text><xsl:value-of
									select="mv:imageWidth"/>;</xsl:if>
							<xsl:if test="mv:resolutionUnit"
									><xsl:text> Unit: </xsl:text><xsl:value-of
									select="mv:resolutionUnit/@xl:title"/>;</xsl:if>
							<xsl:if test="mv:xResolution"><xsl:text> X: </xsl:text><xsl:value-of
									select="mv:xResolution"/>;</xsl:if>
							<xsl:if test="mv:yResolution">
								<xsl:text> Y: </xsl:text>
								<xsl:value-of select="mv:yResolution"/>
							</xsl:if>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="name() = 'PaperComponent' or name() = 'ArtifactComponent'">
				<xsl:call-template name="createDimensions">
					<xsl:with-param name="dimension">
						<xsl:if test="mv:carrierSize">Size: <xsl:value-of
								select="mv:carrierSize/@xl:title"/>;</xsl:if>
						<xsl:if test="mv:dimensions"> Dimensions: <xsl:value-of
								select="mv:dimensions"/></xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="name() = 'PhotographicComponent'">
				<xsl:call-template name="createDimensions">
					<xsl:with-param name="dimension">
						<xsl:if test="mv:carrierSize">Size: <xsl:value-of
								select="mv:carrierSize/@xl:title"/>;</xsl:if>
						<xsl:if test="mv:photoDimensions"> Dimensions: <xsl:value-of
								select="mv:photoDimensions"/></xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when
				test="name() = 'VideoTapeComponent' or name() = 'AcetateFilmComponent' or name() = 'NitrateFilmComponent'">
				<xsl:call-template name="createDimensions">
					<xsl:with-param name="dimension">
						<xsl:value-of select="mv:imageFormatCode/@xl:title"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="digitalPhysical">
		<xsl:choose>
			<xsl:when test="name() = 'DigitalComponent'">
				<xsl:call-template name="digital"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="physical"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="digital">
		<xsl:if test="mv:fileFormat">
			<instantiationDigital>
				<xsl:value-of select="mv:fileFormat/@xl:title"/>
			</instantiationDigital>
		</xsl:if>
	</xsl:template>


	<xsl:template name="createPhysical">
		<xsl:param name="physical"/>
		<xsl:if test="normalize-space($physical) != ''">
			<instantiationPhysical>
				<xsl:call-template name="stripLast">
					<xsl:with-param name="stringValue" select="$physical"/>
				</xsl:call-template>
			</instantiationPhysical>
		</xsl:if>
	</xsl:template>

	<xsl:template name="physical">
		<xsl:call-template name="createPhysical">
			<xsl:with-param name="physical">
				<xsl:if test="mv:format"><xsl:text>Format: </xsl:text><xsl:value-of
						select="mv:format/@xl:title"/>;</xsl:if>
				<xsl:if test="mv:typeMaterial"><xsl:text> TypeMaterial: </xsl:text><xsl:value-of
						select="mv:typeMaterial/@xl:title"/>;</xsl:if>
				<xsl:if test="mv:techCode"><xsl:text> TechCode: </xsl:text><xsl:value-of
						select="mv:techCode/@xl:title"/>;</xsl:if>
				<xsl:if test="mv:gauge">
					<xsl:text> Gauge: </xsl:text>
					<xsl:value-of select="mv:gauge/@xl:title"/>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="createTime">
		<xsl:param name="timeHr"/>
		<xsl:param name="timeMin"/>
		<xsl:param name="timeSec"/>
		<xsl:param name="timeTics"/>
		<xsl:choose><xsl:when test="normalize-space($timeHr) != ''"><xsl:value-of select="$timeHr"
				/></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose>:<xsl:choose><xsl:when
				test="normalize-space($timeMin) != ''"><xsl:value-of select="$timeMin"
				/></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose>:<xsl:choose><xsl:when
				test="normalize-space($timeSec) != ''"><xsl:value-of select="$timeSec"
				/></xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose><xsl:choose><xsl:when
				test="normalize-space($timeTics) != ''">:<xsl:value-of select="$timeTics"
				/></xsl:when></xsl:choose>
	</xsl:template>

	<xsl:template name="createDigitalDuration">
		<xsl:param name="audioDur"/>
		<xsl:param name="videoDur"/>
		<xsl:if test="$audioDur or $videoDur">
			<instantiationDuration>
				<xsl:if test="$audioDur">Audio: <xsl:value-of select="$audioDur"/><xsl:if
						test="$videoDur">; </xsl:if></xsl:if>
				<xsl:if test="$videoDur">Video: <xsl:value-of select="$videoDur"/></xsl:if>
			</instantiationDuration>
		</xsl:if>
	</xsl:template>


	<xsl:template name="createDuration">
		<xsl:param name="durationHr"/>
		<xsl:param name="durationMin"/>
		<xsl:param name="durationSec"/>
		<xsl:param name="durationTics"/>
		<instantiationDuration>
			<xsl:call-template name="createTime">
				<xsl:with-param name="timeHr">
					<xsl:value-of select="$durationHr"/>
				</xsl:with-param>
				<xsl:with-param name="timeMin">
					<xsl:value-of select="$durationMin"/>
				</xsl:with-param>
				<xsl:with-param name="timeSec">
					<xsl:value-of select="$durationSec"/>
				</xsl:with-param>
				<xsl:with-param name="timeTics">
					<xsl:value-of select="$durationTics"/>
				</xsl:with-param>
			</xsl:call-template>
		</instantiationDuration>
	</xsl:template>

	<!-- Component / Carrier duration -->
	<xsl:template name="duration">
		<xsl:choose>
			<xsl:when test="name() = 'DigitalComponent'">
				<xsl:call-template name="createDigitalDuration">
					<xsl:with-param name="audioDur" select="mv:audioDuration"/>
					<xsl:with-param name="videoDur" select="mv:videoDuration"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="mv:durationHr or mv:durationMin or mv:durationSec">
					<xsl:call-template name="createDuration">
						<xsl:with-param name="durationHr">
							<xsl:value-of select="mv:durationHr"/>
						</xsl:with-param>
						<xsl:with-param name="durationMin">
							<xsl:value-of select="mv:durationMin"/>
						</xsl:with-param>
						<xsl:with-param name="durationSec">
							<xsl:value-of select="mv:durationSec"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="componentLocation">
		<xsl:call-template name="createLocation">
			<xsl:with-param name="location">
				<xsl:choose>
					<xsl:when test="name() = 'DigitalComponent'">
						<xsl:for-each select="mv:carriers//mv:ResourceIdentifier">
							<xsl:value-of select="mv:resourceIdentifierType"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="mv:resourceIdentifier"/>
							<xsl:if test="not(position() = last())">; </xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="mv:site">Vault Site: <xsl:value-of select="mv:site/@xl:title"
								/><xsl:if test="mv:carriers//mv:rackNo">; </xsl:if></xsl:if>
						<xsl:for-each select="mv:carriers/child::*">
							<xsl:if test="mv:rackNo">RackNo: <xsl:value-of select="mv:rackNo"
								/></xsl:if>
							<xsl:if test="mv:rackNo and mv:permanentLocation">
								<xsl:text>; </xsl:text>
							</xsl:if>
							<xsl:if test="mv:permanentLocation"
									><xsl:text>Permanent Location: </xsl:text><xsl:value-of
									select="mv:permanentLocation"/>;</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- There is no test for Uniform Titles, as they do not have a medium. Or for Series Titles, as they dont have components and formatMediaType is reported at the Instantiation level in PbCore-->
	<xsl:template name="mediaType">
		<xsl:if test="ancestor::mv:TitleWork/mv:mediums/mv:WorkMedium[mv:isPrincipal = 'Y']">
			<instantiationMediaType>
				<xsl:value-of
					select="ancestor::mv:TitleWork/mv:mediums/mv:WorkMedium[mv:isPrincipal = 'Y']/mv:medium/@xl:title"
				/>
			</instantiationMediaType>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createFileSize">
		<xsl:param name="totalSize"/>
		<instantiationFileSize>
			<xsl:attribute name="unitsOfMeasure">bytes</xsl:attribute>
			<xsl:value-of select="format-number($totalSize, '##############################')"/>
		</instantiationFileSize>
	</xsl:template>


	<xsl:template name="componentFileSize">
		<xsl:if test="mv:carriers/*/mv:fileSize">
			<xsl:call-template name="createFileSize">
				<xsl:with-param name="totalSize" select="sum(mv:carriers/*/mv:fileSize)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="carrierFileSize">
		<xsl:if test="mv:fileSize">
			<xsl:call-template name="createFileSize">
				<xsl:with-param name="totalSize" select="mv:fileSize"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="createStandard">
		<xsl:param name="standardString"/>
		<xsl:if test="normalize-space($standardString) != ''">
			<instantiationStandard>
				<xsl:call-template name="stripLast">
					<xsl:with-param name="stringValue" select="$standardString"/>
				</xsl:call-template>
			</instantiationStandard>
		</xsl:if>
	</xsl:template>

	<!-- any other fields suitable for Photo, Paper and ArtifactComponents? Dimensions? -->
	<xsl:template name="standard">
		<xsl:if test="name() = 'DigitalCarrier'">
			<xsl:call-template name="createStandard">
				<xsl:with-param name="standardString">
					<xsl:if test="mv:audioCompression">
						<xsl:text>Audio: </xsl:text>
						<xsl:value-of select="mv:audioCompression/@xl:title"/>
					</xsl:if>
					<xsl:if test="mv:videoCompression">
						<xsl:text> Video: </xsl:text><xsl:value-of
							select="mv:videoCompression/@xl:title"/>;
							<xsl:text> Audio: </xsl:text><xsl:value-of
							select="mv:videoAudioCompression/@xl:title"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="name() = 'AcetateFilmComponent' or name() = 'NitrateFilmComponent'">
			<xsl:call-template name="createStandard">
				<xsl:with-param name="standardString">Film</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="name() = 'VideoTapeComponent'">
			<xsl:call-template name="createStandard">
				<xsl:with-param name="standardString">
					<xsl:value-of select="mv:videoMode/@xl:title"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="name() = 'DiscComponent'">
			<xsl:call-template name="createStandard">
				<xsl:with-param name="standardString">
					<xsl:if test="mv:grooveGeometry">Groove geometry: <xsl:value-of
							select="mv:grooveGeometry/@xl:title"/>;</xsl:if>
					<xsl:if test="mv:equalisation"> Equalization: <xsl:value-of
							select="mv:equalisation/@xl:title"/></xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="name() = 'AudioTapeComponent'">
			<xsl:call-template name="createStandard">
				<xsl:with-param name="standardString">
					<xsl:if test="mv:noiseReduction">Noise Reduction: <xsl:value-of
							select="mv:noiseReduction/@xl:title"/>;</xsl:if>
					<xsl:if test="mv:equalisation"> Equalization: <xsl:value-of
							select="mv:equalisation/@xl:title"/></xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template name="createGeneration">
		<xsl:param name="generation"/>
		<xsl:if test="normalize-space($generation) != ''">
			<instantiationGenerations>
				<xsl:call-template name="stripLast">
					<xsl:with-param name="stringValue" select="$generation"/>
				</xsl:call-template>
			</instantiationGenerations>
		</xsl:if>
	</xsl:template>

	<!-- supplied pick list looks like this element does not apply to digital components-->
	<xsl:template name="generations">
		<xsl:call-template name="createGeneration">
			<xsl:with-param name="generation">
				<xsl:if test="mv:categoryMaterial">Category: <xsl:value-of
						select="mv:categoryMaterial/@xl:title"/>;</xsl:if>
				<xsl:if test="mv:copyingFunctions/mv:ComponentPreferredCopying"> Access Category: </xsl:if>
				<xsl:for-each select="mv:copyingFunctions/mv:ComponentPreferredCopying">
					<xsl:value-of select="mv:copyingFunction/@xl:title"/>
					<xsl:if test="not(position() = last())">, </xsl:if>
					<xsl:if test="(position() = last())">;</xsl:if>
				</xsl:for-each>
				<xsl:if test="mv:productionStatus"> ProductionStatus: <xsl:value-of
						select="mv:productionStatus/@xl:title"/></xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- using videoAvgBitrateUnit or averageBitRate-->
	<xsl:template name="dataRate">
		<xsl:choose>
			<xsl:when test="mv:videoAvgBitrate">
				<instantiationDataRate>
					<xsl:if test="mv:videoAvgBitrateUnit">
						<xsl:attribute name="unitsOfMeasure">
							<xsl:value-of select="mv:videoAvgBitrateUnit/@xl:title"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="mv:videoAvgBitrate"/>
				</instantiationDataRate>
			</xsl:when>
			<xsl:when test="mv:averageBitRate">
				<instantiationDataRate>
					<xsl:value-of select="mv:averageBitRate"/>
				</instantiationDataRate>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="createColors">
		<xsl:param name="colorString"/>
		<xsl:if test="normalize-space($colorString) != ''">
			<instantiationColors>
				<xsl:call-template name="stripLast">
					<xsl:with-param name="stringValue" select="$colorString"/>
				</xsl:call-template>
			</instantiationColors>
		</xsl:if>
	</xsl:template>

	<xsl:template name="colors">
		<xsl:choose>
			<xsl:when test="name() = 'VideoTapeComponent'">
				<xsl:if test="mv:videoImage">
					<xsl:call-template name="createColors">
						<xsl:with-param name="colorString" select="mv:videoImage/@xl:title"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when
				test="name() = 'NitrateFilmComponent' or name() = 'AcetateFilmComponent' or name() = 'PhotographicComponent'">
				<xsl:if test="mv:typeMaterial">
					<xsl:call-template name="createColors">
						<xsl:with-param name="colorString">
							<xsl:value-of select="mv:typeMaterial/@xl:title"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="mv:tintTone/@xl:title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="name() = 'DigitalCarrier'">
				<xsl:call-template name="createColors">
					<xsl:with-param name="colorString">
						<xsl:if test="mv:videoColourType">Video Colour Type: <xsl:value-of
								select="mv:videoColourType/@xl:title"/>;</xsl:if>
						<xsl:if test="mv:videoColourSpace"> Video Colour Space: <xsl:value-of
								select="mv:videoColourSpace/@xl:title"/>;</xsl:if>
						<xsl:if test="mv:colourSpace"> Image/Text Colour Space: <xsl:value-of
								select="mv:colourSpace/@xl:title"/>;</xsl:if>
						<xsl:if test="mv:colourMap"> Image Colour Map: <xsl:value-of
								select="mv:colourMap"/></xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="createTracks">
		<xsl:param name="formatTracks"/>
		<instantiationTracks>
			<xsl:value-of select="$formatTracks"/>
		</instantiationTracks>
	</xsl:template>


	<!-- we don't seem to have track information for Digital -->
	<xsl:template name="tracks">
		<xsl:choose>
			<xsl:when test="mv:videoTracks and name() = 'VideoTapeComponent'">
				<xsl:call-template name="createTracks">
					<xsl:with-param name="formatTracks"
						select="concat('Video: ', mv:videoTracks/@xl:title)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="mv:signalFormat and name() = 'AudioTapeComponent'">
				<xsl:call-template name="createTracks">
					<xsl:with-param name="formatTracks"
						select="concat('Audio: ', mv:signalFormat/@xl:title)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when
				test="mv:signalFormat and (name() = 'NitrateFilmComponent' or name() = 'AcetateFilmComponent')">
				<xsl:call-template name="createTracks">
					<xsl:with-param name="formatTracks"
						select="concat('Film Sound: ', mv:signalFormat/@xl:title)"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="createChannelConfiguration">
		<xsl:param name="channel"/>
		<xsl:if test="normalize-space($channel) != ''">
			<instantiationChannelConfiguration>
				<xsl:call-template name="stripLast">
					<xsl:with-param name="stringValue" select="$channel"/>
				</xsl:call-template>
			</instantiationChannelConfiguration>
		</xsl:if>
	</xsl:template>

	<xsl:template name="channelConfiguration">
		<xsl:choose>
			<xsl:when test="name() = 'VideoTapeComponent'">
				<xsl:call-template name="createChannelConfiguration">
					<xsl:with-param name="channel">
						<xsl:if test="mv:soundField">Video Sound Field: <xsl:value-of
								select="mv:soundField/@xl:title"/><xsl:text>;</xsl:text></xsl:if>
						<xsl:if test="mv:videoTracks"> Video Tracks: <xsl:value-of
								select="mv:videoTracks/@xl:title"/></xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>

			<xsl:when test="name() = 'AudioTapeComponent'">
				<xsl:if test="mv:signalFormat">
					<xsl:call-template name="createChannelConfiguration">
						<xsl:with-param name="channel" select="mv:signalFormat/@xl:title"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>

			<xsl:when test="name() = 'DiscComponent'">
				<xsl:if test="mv:soundField">
					<xsl:call-template name="createChannelConfiguration">
						<xsl:with-param name="channel" select="mv:soundField/@xl:title"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="carrierLocation">
		<xsl:call-template name="createLocation">
			<xsl:with-param name="location">
				<xsl:choose>
					<xsl:when test="name() = 'DigitalCarrier'">
						<xsl:if test="mv:objectResourceIdentifiers/mv:ResourceIdentifier[1]">
							<xsl:value-of
								select="mv:objectResourceIdentifiers/mv:ResourceIdentifier[1]/mv:resourceIdentifierType"/>
							<xsl:text>: </xsl:text>
							<xsl:value-of
								select="mv:objectResourceIdentifiers/mv:ResourceIdentifier[1]/mv:resourceIdentifier"
							/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="mv:rackNo">RackNo: <xsl:value-of select="mv:rackNo"
							/>;</xsl:if>
						<xsl:if test="mv:permanentLocation">
							<xsl:text> Permanent Location: </xsl:text>
							<xsl:value-of select="mv:permanentLocation"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="carrierIdentifiers">
		<xsl:param name="noCarriers"/>

		<xsl:variable name="objectKey">
			<xsl:call-template name="getObjectKey">
				<xsl:with-param name="href">
					<xsl:value-of select="@xl:href"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="objectDesc">
			<xsl:call-template name="getObjectDesc">
				<xsl:with-param name="href">
					<xsl:value-of select="@xl:href"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<!-- title-comp no identifier - only if component is attached  -->
		<xsl:if test="mv:isUnattached = 'N'">
			<xsl:call-template name="createItemIdentifier">
				<xsl:with-param name="identifier">
					<xsl:value-of select="$objectKey"/>
				</xsl:with-param>
				<xsl:with-param name="identifierSource">
					<xsl:value-of select="$titleCompCarrFormatIdType"/>
				</xsl:with-param>
				<xsl:with-param name="annotation">
					<xsl:value-of select="$objectDesc"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="mv:carrierNo"/>
					<xsl:text> of </xsl:text>
					<xsl:value-of select="$noCarriers"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<!-- Item Id -->
		<xsl:call-template name="createItemIdentifier">
			<xsl:with-param name="identifier">
				<xsl:value-of select="mv:itemId"/>
			</xsl:with-param>
			<xsl:with-param name="identifierSource">
				<xsl:value-of select="$itemFormatIdType"/>
			</xsl:with-param>
			<xsl:with-param name="annotation">
				<xsl:value-of select="$objectDesc"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="mv:carrierNo"/>
				<xsl:text> of </xsl:text>
				<xsl:value-of select="$noCarriers"/>
			</xsl:with-param>
		</xsl:call-template>

		<!-- Other Identifiers for carriers -->
		<xsl:for-each select="mv:objectIdentifiers/mv:ObjectIdentifier">
			<xsl:call-template name="createItemIdentifier">
				<xsl:with-param name="identifier">
					<xsl:value-of select="mv:identifier"/>
				</xsl:with-param>
				<xsl:with-param name="identifierSource">
					<xsl:value-of select="mv:identifierType/@xl:title"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>

	</xsl:template>

	<!-- Component / Carrier essence track stuff - mainly for digital but some stuff thrown in for analogue -->
	<xsl:template name="essenceTrack">
		<xsl:choose>
			<xsl:when test="name() = 'DigitalCarrier'">
				<xsl:call-template name="createAudioEssenceTrack"/>
				<xsl:call-template name="createVideoEssenceTrack"/>
				<xsl:call-template name="createImageEssenceTrack"/>
				<xsl:call-template name="createTextEssenceTrack"/>
			</xsl:when>
			<xsl:when
				test="name() = 'VideoTapeComponent' or name() = 'AudioTapeComponent' or name() = 'DiscComponent' or name() = 'NitrateFilmComponent' or name() = 'AcetateFilmComponent'">
				<instantiationEssenceTrack>
					<xsl:call-template name="essenceTrackType"/>
					<!-- <xsl:call-template name="essenceTrackFrameRate"/> Not needed - a duplication of essenceTrackPlaybackSpeed -->
					<xsl:call-template name="essenceTrackAspectRatio"/>
					<xsl:call-template name="essenceTrackPlaybackSpeed"/>
				</instantiationEssenceTrack>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="createAudioEssenceTrack">
		<xsl:variable name="type" select="$audioType"/>
		<xsl:if
			test="
				mv:audioCompression or mv:audioSampleRate or mv:audioDurationHr or mv:audioDurationMin or mv:audioDurationSec or mv:audioDurationTics
				or averageBitRate or mv:audioStartHr or mv:audioStartMin or mv:audioStartSec or mv:audioStartTics">
			<instantiationEssenceTrack>
				<xsl:call-template name="createTrackType">
					<xsl:with-param name="trackType">Digital/<xsl:value-of select="$type"
						/></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackStandard">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackEncoding">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackDataRate">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackSamplingRate">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackTimeStart">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackDuration">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
			</instantiationEssenceTrack>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createVideoEssenceTrack">
		<xsl:variable name="type" select="$videoType"/>
		<xsl:if
			test="
				mv:videoAudioCompression or mv:videoCompression or mv:videoWidth or mv:videoHeight or mv:videoAudioSampleRate or mv:videoFrameRate
				or mv:videoAspectRatio or mv:videoDurationHr or mv:videoDurationMin or mv:videoDurationSec or mv:videoDurationTics or mv:videoAvgBitrate
				or mv:videoStartHr or mv:videoStartMin or mv:videoStartSec or mv:videoStartTics">
			<instantiationEssenceTrack>
				<xsl:call-template name="createTrackType">
					<xsl:with-param name="trackType">Digital/<xsl:value-of select="$type"
						/></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackStandard">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackEncoding">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackDataRate">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackFrameSize">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackSamplingRate">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackTimeStart">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackDuration">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackFrameRate"/>
				<xsl:call-template name="essenceTrackAspectRatio"/>
			</instantiationEssenceTrack>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createImageEssenceTrack">
		<xsl:variable name="type" select="$imageType"/>
		<xsl:if test="mv:imageCompression or mv:imageBitDepth or mv:imageWidth or mv:imageLength">
			<instantiationEssenceTrack>
				<xsl:call-template name="createTrackType">
					<xsl:with-param name="trackType">Digital/<xsl:value-of select="$type"
						/></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackEncoding">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackBitDepth">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackFrameSize">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
			</instantiationEssenceTrack>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createTextEssenceTrack">
		<xsl:variable name="type" select="$textType"/>
		<xsl:if test="mv:imageBitDepth">
			<instantiationEssenceTrack>
				<xsl:call-template name="createTrackType">
					<xsl:with-param name="trackType">Digital/<xsl:value-of select="$type"
						/></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="essenceTrackBitDepth">
					<xsl:with-param name="trackType">
						<xsl:value-of select="$type"/>
					</xsl:with-param>
				</xsl:call-template>
			</instantiationEssenceTrack>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createTrackType">
		<xsl:param name="trackType"/>
		<essenceTrackType>
			<xsl:value-of select="$trackType"/>
		</essenceTrackType>
	</xsl:template>

	<xsl:template name="essenceTrackType">
		<xsl:call-template name="createTrackType">
			<xsl:with-param name="trackType">
				<xsl:choose>
					<xsl:when test="name() = 'VideoTapeComponent'">Video</xsl:when>
					<xsl:when test="name() = 'AudioTapeComponent' or name() = 'DiscComponent'"
						>Audio</xsl:when>
					<xsl:when
						test="name() = 'NitrateFilmComponent' or name() = 'AcetateFilmComponent'"
						>Film</xsl:when>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="createTrackEncoding">
		<xsl:param name="encoding"/>
		<essenceTrackEncoding>
			<xsl:value-of select="normalize-space($encoding)"/>
		</essenceTrackEncoding>
	</xsl:template>

	<!-- We use the compression values - this seems to be what pbCore wants here -->
	<xsl:template name="essenceTrackEncoding">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="$trackType = $videoType">
				<xsl:if test="mv:videoAudioCompression or mv:videoCompression">
					<xsl:call-template name="createTrackEncoding">
						<xsl:with-param name="encoding">
							<xsl:text>Video: </xsl:text>
							<xsl:value-of select="mv:videoCompression/@xl:title"/>
							<xsl:text> Audio: </xsl:text>
							<xsl:value-of select="mv:videoAudioCompression/@xl:title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$trackType = $audioType">
				<xsl:if test="mv:audioCompression">
					<xsl:call-template name="createTrackEncoding">
						<xsl:with-param name="encoding" select="mv:audioCompression/@xl:title"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$trackType = $imageType">
				<xsl:if test="mv:imageCompression">
					<xsl:call-template name="createTrackEncoding">
						<xsl:with-param name="encoding" select="mv:imageCompression/@xl:title"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="essenceTrackDataRate">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="$trackType = $videoType and mv:videoAvgBitrate">
				<essenceTrackDataRate>
					<xsl:if test="mv:videoAvgBitrateUnit">
						<xsl:attribute name="unitsOfMeasure">
							<xsl:value-of select="mv:videoAvgBitrateUnit/@xl:title"/>
						</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="mv:videoAvgBitrate"/>
				</essenceTrackDataRate>
			</xsl:when>

			<xsl:when test="$trackType = $audioType and mv:averageBitRate">
				<essenceTrackDataRate>
					<xsl:value-of select="mv:averageBitRate"/>
				</essenceTrackDataRate>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="essenceTrackBitDepth">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="mv:imageBitDepth">
				<essenceTrackBitDepth>
					<xsl:value-of select="mv:imageBitDepth"/>
					<xsl:text> bit</xsl:text>
				</essenceTrackBitDepth>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="createTrackStandard">
		<xsl:param name="standard"/>
		<essenceTrackStandard>
			<xsl:value-of select="normalize-space($standard)"/>
		</essenceTrackStandard>
	</xsl:template>

	<xsl:template name="essenceTrackStandard">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="$trackType = $videoType">
				<xsl:if test="mv:videoCompression or mv:videoAudioCompression">
					<xsl:call-template name="createTrackStandard">
						<xsl:with-param name="standard">
							<xsl:text>Video: </xsl:text>
							<xsl:value-of select="mv:videoCompression/@xl:title"/>
							<xsl:text> Audio: </xsl:text>
							<xsl:value-of select="mv:videoAudioCompression/@xl:title"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$trackType = $audioType">
				<xsl:if test="mv:audioCompression">
					<xsl:call-template name="createTrackStandard">
						<xsl:with-param name="standard" select="mv:audioCompression/@xl:title"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="essenceTrackSamplingRate">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="$trackType = $audioType">
				<xsl:if test="mv:audioSampleRate">
					<essenceTrackSamplingRate>
						<xsl:value-of select="mv:audioSampleRate/@xl:title"/>
					</essenceTrackSamplingRate>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$trackType = $videoType">
				<xsl:if test="mv:videoAudioSampleRate">
					<essenceTrackSamplingRate>
						<xsl:value-of select="mv:videoAudioSampleRate/@xl:title"/>
					</essenceTrackSamplingRate>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="createEssenceDuration">
		<xsl:param name="durationHr"/>
		<xsl:param name="durationMin"/>
		<xsl:param name="durationSec"/>
		<xsl:param name="durationTics"/>
		<essenceTrackDuration>
			<xsl:call-template name="createTime">
				<xsl:with-param name="timeHr">
					<xsl:value-of select="$durationHr"/>
				</xsl:with-param>
				<xsl:with-param name="timeMin">
					<xsl:value-of select="$durationMin"/>
				</xsl:with-param>
				<xsl:with-param name="timeSec">
					<xsl:value-of select="$durationSec"/>
				</xsl:with-param>
				<xsl:with-param name="timeTics">
					<xsl:choose>
						<xsl:when test="$durationTics">
							<xsl:value-of select="$durationTics"/>
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
		</essenceTrackDuration>
	</xsl:template>

	<xsl:template name="essenceTrackDuration">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="$trackType = $audioType">
				<xsl:if
					test="mv:audioDurationHr or mv:audioDurationMin or mv:audioDurationSec or mv:audioDurationTics">
					<xsl:call-template name="createEssenceDuration">
						<xsl:with-param name="durationHr">
							<xsl:value-of select="mv:audioDurationHr"/>
						</xsl:with-param>
						<xsl:with-param name="durationMin">
							<xsl:value-of select="mv:audioDurationMin"/>
						</xsl:with-param>
						<xsl:with-param name="durationSec">
							<xsl:value-of select="mv:audioDurationSec"/>
						</xsl:with-param>
						<xsl:with-param name="durationTics">
							<xsl:value-of select="mv:audioDurationTics"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$trackType = $videoType">
				<xsl:if
					test="mv:videoDurationHr or mv:videoDurationMin or mv:videoDurationSec or mv:videoDurationTics">
					<xsl:call-template name="createEssenceDuration">
						<xsl:with-param name="durationHr">
							<xsl:value-of select="mv:videoDurationHr"/>
						</xsl:with-param>
						<xsl:with-param name="durationMin">
							<xsl:value-of select="mv:videoDurationMin"/>
						</xsl:with-param>
						<xsl:with-param name="durationSec">
							<xsl:value-of select="mv:videoDurationSec"/>
						</xsl:with-param>
						<xsl:with-param name="durationTics">
							<xsl:value-of select="mv:videoDurationTics"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>


	<xsl:template name="createTimeStart">
		<xsl:param name="startHr"/>
		<xsl:param name="startMin"/>
		<xsl:param name="startSec"/>
		<xsl:param name="startTics"/>
		<essenceTrackTimeStart>
			<xsl:call-template name="createTime">
				<xsl:with-param name="timeHr">
					<xsl:value-of select="$startHr"/>
				</xsl:with-param>
				<xsl:with-param name="timeMin">
					<xsl:value-of select="$startMin"/>
				</xsl:with-param>
				<xsl:with-param name="timeSec">
					<xsl:value-of select="$startSec"/>
				</xsl:with-param>
				<xsl:with-param name="timeTics">
					<xsl:value-of select="$startTics"/>
				</xsl:with-param>
			</xsl:call-template>
		</essenceTrackTimeStart>
	</xsl:template>

	<xsl:template name="essenceTrackTimeStart">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="$trackType = $audioType">
				<xsl:if
					test="mv:audioStartHr or mv:audioStartMin or mv:audioStartSec or mv:audioStartTics">
					<xsl:call-template name="createTimeStart">
						<xsl:with-param name="startHr">
							<xsl:value-of select="mv:audioStartHr"/>
						</xsl:with-param>
						<xsl:with-param name="startMin">
							<xsl:value-of select="mv:audioStartMin"/>
						</xsl:with-param>
						<xsl:with-param name="startSec">
							<xsl:value-of select="mv:audioStartSec"/>
						</xsl:with-param>
						<xsl:with-param name="startTics">
							<xsl:value-of select="mv:audioStartTics"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$trackType = $videoType">
				<xsl:if
					test="mv:videoStartHr or mv:videoStartMin or mv:videoStartSec or mv:videoStartTics">
					<xsl:call-template name="createTimeStart">
						<xsl:with-param name="startHr">
							<xsl:value-of select="mv:videoStartHr"/>
						</xsl:with-param>
						<xsl:with-param name="startMin">
							<xsl:value-of select="mv:videoStartMin"/>
						</xsl:with-param>
						<xsl:with-param name="startSec">
							<xsl:value-of select="mv:videoStartSec"/>
						</xsl:with-param>
						<xsl:with-param name="startTics">
							<xsl:value-of select="mv:videoStartTics"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="essenceTrackFrameSize">
		<xsl:param name="trackType"/>
		<xsl:choose>
			<xsl:when test="$trackType = $imageType">
				<xsl:if test="mv:imageWidth or mv:imageLength">
					<essenceTrackFrameSize>
						<xsl:value-of select="mv:imageWidth"/>x<xsl:value-of select="mv:imageLength"/>
						<xsl:if test="mv:resolutionUnit">
							<xsl:text> </xsl:text><xsl:value-of select="mv:resolutionUnit/@xl:title"
							/>
						</xsl:if>
					</essenceTrackFrameSize>
				</xsl:if>
			</xsl:when>

			<xsl:when test="$trackType = $videoType">
				<xsl:if test="mv:videoWidth or mv:videoHeight">
					<essenceTrackFrameSize>
						<xsl:value-of select="mv:videoWidth"/>x<xsl:value-of select="mv:videoHeight"/>
						<xsl:if test="mv:videoFrameLayout">
							<xsl:text> </xsl:text><xsl:value-of
								select="mv:videoFrameLayout/@xl:title"/>
						</xsl:if>
					</essenceTrackFrameSize>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="essenceTrackAspectRatio">
		<xsl:if test="mv:aspectRatio">
			<essenceTrackAspectRatio>
				<xsl:value-of select="mv:aspectRatio"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="mv:aspectRatio/@xl:title"/>
			</essenceTrackAspectRatio>
		</xsl:if>
		<xsl:if test="mv:videoAspectRatio">
			<essenceTrackAspectRatio>
				<xsl:value-of select="mv:videoAspectRatio"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="mv:videoAspectRatio/@xl:title"/>
			</essenceTrackAspectRatio>
		</xsl:if>
	</xsl:template>

	<xsl:template name="createFrameRate">
		<xsl:param name="formatFrameRate"/>
		<essenceTrackFrameRate>
			<xsl:value-of select="$formatFrameRate"/>
		</essenceTrackFrameRate>
	</xsl:template>

	<!-- this is 'frames/feet per second' - it is stored in sampleRate for analog, and videoFrameRate for Digital Video -->
	<xsl:template name="essenceTrackFrameRate">
		<xsl:choose>
			<xsl:when test="mv:sampleRate">
				<xsl:call-template name="createFrameRate">
					<xsl:with-param name="formatFrameRate" select="mv:sampleRate/@xl:title"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="mv:videoFrameRate">
				<xsl:call-template name="createFrameRate">
					<xsl:with-param name="formatFrameRate"
						select="concat(mv:videoFrameRate, ' fps')"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="createPlaybackSpeed">
		<xsl:param name="speed"/>
		<essenceTrackPlaybackSpeed>
			<xsl:value-of select="$speed"/>
		</essenceTrackPlaybackSpeed>
	</xsl:template>

	<xsl:template name="essenceTrackPlaybackSpeed">
		<xsl:choose>
			<xsl:when
				test="name() = 'DiscComponent' or name() = 'NitrateFilmComponent' or name() = 'AcetateFilmComponent' or name() = 'VideoTapeComponent' or name() = 'AudioTapeComponent'">
				<xsl:if test="mv:sampleRate">
					<xsl:call-template name="createPlaybackSpeed">
						<xsl:with-param name="speed" select="mv:sampleRate/@xl:title"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Relations - MAVIS copy history -->
	<xsl:template name="createRelation">
		<xsl:param name="object"/>
		<xsl:param name="relationType"/>

		<xsl:variable name="objectKey">
			<xsl:call-template name="getObjectKey">
				<xsl:with-param name="href">
					<xsl:value-of select="$object/@xl:href"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="objectDesc">
			<xsl:call-template name="getObjectDesc">
				<xsl:with-param name="href">
					<xsl:value-of select="$object/@xl:href"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>

		<instantiationRelation>
			<instantiationRelationType>
				<xsl:value-of select="$relationType"/>
			</instantiationRelationType>
			<instantiationRelationIdentifier>
				<xsl:attribute name="source">
					<xsl:choose>
						<xsl:when test="not(contains($objectKey, '-'))">
							<xsl:value-of select="$itemFormatIdType"/>
						</xsl:when>
						<xsl:when test="contains($objectDesc, 'Component')">
							<xsl:value-of select="$titleCompFormatIdType"/>
						</xsl:when>
						<xsl:when test="contains($objectDesc, 'Carrier')">
							<xsl:value-of select="$titleCompCarrFormatIdType"/>
						</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="annotation">
					<xsl:value-of
						select="substring-before(substring-after($object/@xl:href, '/'), '/')"/>
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="not(contains($objectKey, '-'))">
							<xsl:value-of select="substring-after($object/@xl:title, ' - ')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="substring-after($object/@xl:title, ' ')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="$objectKey"/>
			</instantiationRelationIdentifier>
		</instantiationRelation>
	</xsl:template>

	<xsl:template name="relation">
		<xsl:for-each select="mv:copiedFromItems/mv:ItemCopy">
			<xsl:call-template name="createRelation">
				<xsl:with-param name="object" select="mv:item"/>
				<xsl:with-param name="relationType">Copied From</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="mv:copiedToItems/mv:ItemCopy">
			<xsl:call-template name="createRelation">
				<xsl:with-param name="object" select="mv:copyItem"/>
				<xsl:with-param name="relationType">Copied To</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Annotations - MAVIS item notes -->
	<xsl:template name="createItemNote">
		<xsl:param name="noteNode"/>
		<xsl:param name="noteType"/>

		<xsl:if test="$noteNode">
			<instantiationAnnotation>
				<xsl:attribute name="annotationType">
					<xsl:value-of select="$noteType"/>
				</xsl:attribute>
				<xsl:value-of select="$noteNode"/>
			</instantiationAnnotation>
		</xsl:if>
	</xsl:template>

	<xsl:template name="itemAnnotation">
		<xsl:call-template name="createItemNote">
			<xsl:with-param name="noteNode" select="mv:itemDescr"/>
			<xsl:with-param name="noteType">Description</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="createItemNote">
			<xsl:with-param name="noteNode" select="mv:notes"/>
			<xsl:with-param name="noteType">General Notes</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="createItemNote">
			<xsl:with-param name="noteNode" select="mv:obligations"/>
			<xsl:with-param name="noteType">Obligations</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="createItemNote">
			<xsl:with-param name="noteNode" select="mv:restrictions"/>
			<xsl:with-param name="noteType">Restrictions</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="createItemNote">
			<xsl:with-param name="noteNode" select="mv:stockNote"/>
			<xsl:with-param name="noteType">Stock Notes</xsl:with-param>
		</xsl:call-template>

		<xsl:call-template name="createItemNote">
			<xsl:with-param name="noteNode" select="mv:labelNote"/>
			<xsl:with-param name="noteType">Label Notes</xsl:with-param>
		</xsl:call-template>

	</xsl:template>

	<!-- =================================== -->
	<!--  Match Templates for Instantiation  data-->
	<!-- =================================== -->
	<xsl:template match="mv:itemLanguages">
		<xsl:if test="mv:ItemLanguage/mv:languageRole = 'ORIG'">
			<instantiationLanguage>
				<xsl:for-each select="mv:ItemLanguage[mv:languageRole = 'ORIG']">
					<xsl:value-of select="mv:language/@xl:title"/>
					<xsl:if test="not(position() = last())">; </xsl:if>
				</xsl:for-each>
			</instantiationLanguage>
		</xsl:if>

		<xsl:if test="mv:ItemLanguage/mv:languageRole != 'ORIG'">
			<instantiationAlternativeModes>
				<xsl:for-each select="mv:ItemLanguage[mv:languageRole != 'ORIG']">
					<xsl:value-of select="mv:language/@xl:title"/>
					<xsl:text> (</xsl:text>
					<xsl:value-of select="mv:languageRole/@xl:title"/>
					<xsl:text>)</xsl:text>
					<xsl:if test="not(position() = last())">; </xsl:if>
				</xsl:for-each>
			</instantiationAlternativeModes>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>
