*- ----------------------------------------------------------------------------------------------------------------------- -*
*- TR 1009452 - 03/15/05 - Bruno DIEPENDAELE
*- 3/28/05 - EasyPlug formatting added by Michael J. Sabal, Notations.
*- DESCRIPTION: This is a 3 part label designed without the Visual Foxpro label designer. The label is generated by
*- this Foxpro program NOTSEAUC1FC.PRG (orig: NOTPCLUC.PRG)
*- Formatting codes are Avery Dennison EASYPLUG.
*- This label is a 3 part label:
*- PART 1: Carton Pick Slip Internal - this is a carton content list showing the buckets horizontaly
*- PART 2: Carton Pick Slip - this is a carton content list showing buckets and UPCs vertically
*- PART 3: UCC128 part of the label - SEARS FASHION CENTER (04/01/05)
*- ----------------------------------------------------------------------------------------------------------------------- -*
LOCAL lnIndLineBlock1,lnIndLineBlock2,lnIndLineBlock3
LOCAL lnOrgArea
LOCAL lnPageNum, lnLineNum, lnOffset
LOCAL lcShipTo
*--- TR 1012882 - 08/30/05 - BD - Order by Style Modification 1 = Add variable declaration
LOCAL lcSortStyle
*=== TR 1012882 - 08/30/05 - BD - End of Order by Style Modification 1

#DEFINE MaxNbLineBlock1 8
#DEFINE MaxNbLineBlock2 8
#DEFINE MaxNbLineBlock3 20
#DEFINE CRLF CHR(13)+CHR(10)

lnOrgArea=SELECT()
lcOrgAlias=ALIAS()

*- Send data to output
*set device to screen
*set device to file c:\temp\notrlzuc.txt


*!*	************ TEST
*!*	set device to print
*!*	set printer to
*!*	set printer font 'Arial',6 STYLE 'BI'
*!*	??? " "
*!*	for lnInd=1 to 500
*!*		@lnInd,1 say 'Bruno test printing line'+str(lnInd)
*!*	endfor
*!*	set device to screen
*!*	set printer to
*!*	***************

*- -------------------
*- TURN ON the printer
*- -------------------
*SET DEVICE TO PRINT
*SET PRINTER TO
*set printer font 'Courier',6 STYLE 'BI'

*--- ------------------------------------------------------------------------------------------------------------------
*--- TR 1012882 - 08/30/05 - BD - Order by Style Modification 2  
*--- Bruno DIEPENDAELE -> Mike Sabal = This is a block code change

*- First create field SortStyle = this field is used to sort the cursor by style; when there are more than 
*- one style in one carton, SortStyle contains the first style for all records of this carton.
select *, style as SortStyle from (lcOrgAlias) into cursor curSortStyleTemp
MakeCursorWritable('curSortStyleTemp','curSortStyle')
select carton_num from (lcOrgAlias) into cursor curCartonList group by carton_num
SCAN
	SELECT style,carton_num from (lcOrgAlias) WHERE carton_num=curCartonList.carton_num INTO CURSOR curOneCarton ORDER BY style
	*- Take first style in alpha order as the SortStyle
	lcSortStyle=curOneCarton.style
	replace SortStyle WITH lcSortStyle FOR carton_num=curCartonList.carton_num IN curSortStyle
ENDSCAN
IF USED('curOneCarton')
	USE IN curOneCarton
ENDIF
USE IN curCartonList

*- Create cursor curGroupByCarton = list of carton ordered by customer,SortStyle,carton_num
*- This cursor is defining the label sequencing
select Customer,SortStyle,Carton_num from curSortStyle into cursor curGroupByCarton ;
 	   group by customer,SortStyle,carton_num ORDER BY customer,SortStyle,carton_num
SCAN

lcStringBlock3 =  '#!A1#IMS203.2/76.2#ERN1'   && 8" wide by 9" long "Page"
lnPageNum = 0                    && Each 3" page = 79mm, not 76.2mm
lnLinenum = 1
lcStringBlock3 = lcStringBlock3 + '#M3/5#T100.0#J60.0#YT109/2M///A STORE#G'
*lcStringBlock3 = lcStringBlock3 + '#T100.0#J40.0#YT109/2M///PLEASE RUSH#G#M1/1'

*- End

lcStringBlock3 = lcStringBlock3 + '#Q1#G'
??? lcStringBlock3

ENDSCAN		&& End of SCAN curGroupByCarton

select (lnOrgArea)


*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

use in curGroupByCarton

RETURN .T.


