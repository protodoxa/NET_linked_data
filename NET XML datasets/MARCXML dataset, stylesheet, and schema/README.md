# MARC XML READ ME:

## FILES IN THIS FOLDER:

MARC21slim.xsd - the MARCXML schema definitions for MARC serlializations

net collection_marcxml.xml - the MARCXML serialization of the NET collection dataset

pbcore2macxml_net collection.xsl - the stylesheet that transforms the PBCORE dataset to MARC

## ABOUT THIS DATASET:

The stylesheet was written by Chris Pierce at the Library of Congress to transform a PBCore-standardized serialization of records describing the Library's collection of materials distributed by the National Educational Television public broadcasting company during the period between the late 1950s and the early 1970s. The mappings between PBCore and MARC are formalized, documented, and discussed in the crosswalk found in the CROSSWALK folder and in the report discussing this project.


## DATA CLEANSING RECOMMENDATIONS:

There are a number of irregularities that have been ironed out post-transformation rather than editing the stylesheet, some of which was due to the effects of conversion downstream, idiosyncracies with the original PBCORE dataset, and general glitches in the stylesheet's code itself. For best results, the following data cleaning process is recommended post-transformation:

1. The MARC to BIBFRAME conversion tools did not appear to import URIs for subjects that have been entered as 653 (Uncontrolled terms) in MARC. The reason for entering subjects as 653 is because there's not a lot of structure in the PBCore dataset for what kinds of topics are represented by these subjects. Chris Pierce decided to differentiate by URI, where a name (even geographic names) comes from the LCNAF file and thus contains the characters 'names' (http://id.loc.gov/authorities/names/n79035339) and where a subject comes from the LCSH list and thus contains the characters 'subjects' (http://id.loc.gov/authorities/subjects/sh85113502). Names were thus mapped (mostly incorrectly) to 651 (geographci names) and subjects to 650 (topics), and thus it is necessary to ctr-F on tag="651" and adjust the subjects for inclusion as 600 (Personal name), 610 (Corporate name), or 651. This process takes about an hour on the current dataset from the NET collection; names as subjects are frequent but not ubiquitous in the NET collection.

2.Records for paper files were inadvertently included in the dataset and can be removed by ctr-F searching and delete for FILE (capital sensitive speeds up this search).Also deaccessioned components were removed from the description (they remain in the holdings).

3.Empty 345 b (projection speed for projected moving image content) fields were removed; they should have been coded conditionally in the stylesheet.

4.A BIG issue with this particular transformation is the original assumption of the infrequency of components that were not part of an NET-related acquisition or were the result of obsolete migrations that were outside the norm. Most NET/PBS materials consist of the following technical formats (there are also a number of pre-print formats not processed at the time the dataset was curated):

	A. Film
		1. 16 mm
	B. Video
		1. 2 inch Quadruplex
		2. 3/4 inch U-matic
		3. 1 inch C-type
	C. Digital video
		1. MPEG 4
		2. MFX
		3. MPEG 2

However, there are also components for DVD (although only 1 component in this dataset), VHS, and Betacam. It is recommended to ctrl-F on tag="050" to examine rack numbers for the LC NET collection after transformation and update the folling types of rack number patterns:

		DV - DVDs - update 300 $c (dimensions) with "3/4 		inches (Blu-ray, DVD, etc.)" and the following 347 		(digital video characteristics) should be added: 			347 $A video file $2 rdaft [and] 347 $b DVD video; 		corresponding $3 fields defining the type 				of material specified would be useful as well to 		add to 347 and are used to find the right 300 $c 			to edit if there are multiple. Original 346 (Video 		characteristics) fields should be removed.You also 		have the option of not including DVD components at 		all, which is what Chris Pierce did, rather than 		adding new 347 fields.

		VA - VHS - 300 $c (dimensions) should be updated 		to 1/2 inches, usually updated to the 300 field 			with $3 Access; 346 $a (video format) should be 			updated to VHS (the right 346 will likely be 		Access).

		VX - Betacam SP - 300 $c (dimensions) should be 		updated to 1/2 inches, usually updated to the 300 			field with $3 Preservation material; 346 $a (Video 		format) should be updated to to Betacam SP.

As an explanation for this more lengthy issue with components, the PBCORE dataset's instantiationPhysical element could not be relied upon for consistent reporting of technical format, mostly because a high number of these were entered originally as "unknown." This particualrly prevents making a conditional query for each format type. The stylesheet sticks to a rough approximation of guages of videotape carriers, but there's also overlap here too. Thus, performing the updates above are necessary for straightening out inconsistencies as a result of this transformation.
