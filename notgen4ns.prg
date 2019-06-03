*- ----------------------------------------------------------------------------------------------------------------------- -*
*- TR 1009452 - 03/15/05 - Bruno DIEPENDAELE
*- 3/28/05 - EasyPlug formatting added by Michael J. Sabal, Notations.
*- DESCRIPTION: This is a 3 part label designed without the Visual Foxpro label designer. The label is generated by
*- this Foxpro program NOTFEDUC.PRG (orig: NOTPCLUC.PRG)
*- Formatting codes are Avery Dennison EASYPLUG.
*- This label is a 3 part label:
*- PART 1: Carton Pick Slip Internal - this is a carton content list showing the buckets horizontaly
*- PART 2: Carton Pick Slip - this is a carton content list showing buckets and UPCs vertically
*- PART 3: UCC128 part of the label - NEXCOM (07/13/2015)
*- *** Printing of parts 1 and 2 is suppressed ***
*- ----------------------------------------------------------------------------------------------------------------------- -*
LOCAL lnIndLineBlock1,lnIndLineBlock2,lnIndLineBlock3
LOCAL lnOrgArea
LOCAL lnPageNum, lnLineNum, lnOffset
LOCAL lcShipTo
LOCAL lcDivision,lcStyle,lcFieldName,lnIndbucket,lcIndbucket, lnAggVal
*--- TR 1012146 - 07/27/05 - BD - Modification 1 = Add variaable declaration
LOCAL lcCurSize_code
*=== TR 1012146 - BD - End of modification 1
*--- TR 1012882 - 08/30/05 - BD - Order by Style Modification 1 = Add variable declaration
LOCAL lcSortStyle
*=== TR 1012882 - 08/30/05 - BD - End of Order by Style Modification 1
LOCAL lcLocation
LOCAL lcDC

#DEFINE MaxNbLineBlock1 14
#DEFINE MaxNbLineBlock2 25
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
* SET PRINTER TO
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

*- Group by carton_num
*select * from (lcOrgAlias) into cursor curGroupByCarton group by carton_num
*SCAN
*==== TR 1012882 - 08/30/05 - BD - End of Order by Style Modification 2 

*- **************************
*- Build PART 1 of the label
*- **************************
*- --------------------------------------------------------------------------------------------------
*- Create cursor CurPart1 
*- --------------------------------------------------------------------------------------------------
*--- TR 1012146 - 07/27/05 - BD - Modification 2 = Add space(3) as size_code in the SQL
*--- Bruno DIEPENDAELE -> Mike Sabal = This is a block code change
lcCurPrintFinalTemp = GetUniqueFileName()
SELECT *, ;
 SPACE(3) as size_code,;
 space(1) as record_type,;
 space(7) as siz01_head,space(7) as siz02_head,space(7) as siz03_head,space(7) as siz04_head,;
 space(7) as siz05_head,space(7) as siz06_head,space(7) as siz07_head,space(7) as siz08_head,;
 space(7) as siz09_head,space(7) as siz10_head,space(7) as siz11_head,space(7) as siz12_head,;
 space(7) as siz13_head,space(7) as siz14_head,space(7) as siz15_head,space(7) as siz16_head,;
 space(7) as siz17_head,space(7) as siz18_head,space(7) as siz19_head,space(7) as siz20_head,;
 space(7) as siz21_head,space(7) as siz22_head,space(7) as siz23_head,space(7) as siz24_head,;
 9999999 as siz01_qty,9999999 as siz02_qty,9999999 as siz03_qty,9999999 as siz04_qty,;
 9999999 as siz05_qty,9999999 as siz06_qty,9999999 as siz07_qty,9999999 as siz08_qty,;
 9999999 as siz09_qty,9999999 as siz10_qty,9999999 as siz11_qty,9999999 as siz12_qty,;
 9999999 as siz13_qty,9999999 as siz14_qty,9999999 as siz15_qty,9999999 as siz16_qty,;
 9999999 as siz17_qty,9999999 as siz18_qty,9999999 as siz19_qty,9999999 as siz20_qty,;
 9999999 as siz21_qty,9999999 as siz22_qty,9999999 as siz23_qty,9999999 as siz24_qty;
FROM (lcOrgAlias) ;
where .F. ; 
INTO CURSOR CurPart1Temp
*=== TR 1012146 - BD - End of modification 2

MakeCursorWritable('CurPart1Temp','CurPart1')


*- Fill CurPart1 cursor
*- --------------------
*--- TR 1012146 - 07/27/05 - BD - Modification 3 = order cursor cur1GroupBySKU by size_code,style
*--- Bruno DIEPENDAELE -> Mike Sabal = This is a block code change
IF TYPE('&lcOrgAlias..size_code')='U'
	select *, vl_stylr(Division, 'size_code', '',Style) as size_code from (lcOrgAlias) ;
	where carton_num=curGroupByCarton.carton_num ;
	into cursor cur1GroupBySKUTemp
ELSE
	select * from (lcOrgAlias) ;
	where carton_num=curGroupByCarton.carton_num ;
	into cursor cur1GroupBySKUTemp
ENDIF

select * from cur1GroupBySKUTemp where carton_num=curGroupByCarton.carton_num ;
into cursor cur1GroupBySKU group by carton_num,style,color_code,lbl_code ;
ORDER BY carton_num,size_code,style

USE IN cur1GroupBySKUTemp
SELECT cur1GroupBySKU
*=== TR 1012146 - BD - End of modification 3
scan
	select * from (lcOrgAlias) where carton_num=cur1GroupBySKU.carton_num AND style=cur1GroupBySKU.style AND ;
	color_code=cur1GroupBySKU.color_code AND lbl_code=cur1GroupBySKU.lbl_code ;
	into cursor curOneSKU
	*- Add one new record per style
	SCATTER memvar MEMO
	insert into CurPart1 from MEMVAR	
	*- Fill size header fields siz01_head,..,siz09_head	
	*- ------------------------------------------------
	lcDivision=cur1GroupBySKU.division
	lcStyle=cur1GroupBySKU.style
	lcLocation=cur1GroupBySKU.location
	lcSize_Code = vl_stylr(lcDivision, 'size_code', '',lcStyle)

	*--- TR 1012146 - 07/27/05 - BD - Modification 4 = record size_code	in in CurPart1 cursor
	*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new code line
	replace size_code WITH lcSize_Code in CurPart1
	*=== TR 1012146 - BD - End of modification 4	

	vl_sizer(lcDivision,'','curSizeHeader',lcSize_Code)
	for lnIndbucket = 1 to 10
		lcIndbucket=TRANS(lnIndbucket , "@L 99") 
		*- Size header for this bucket = new fields size01_head,..,size22_head
		lcFieldName = "size" + lcIndbucket
		replace siz&lcIndbucket._head with padc(allt(eval('curSizeHeader.' + lcFieldName)), 7) in CurPart1
	endfor	&& End for 9
	
	*- Fill size quantities fields siz01_qty,..,siz09_qty	
	*- --------------------------------------------------
	select curOneSKU
	scan
		lnIndbucket=curOneSKU.sizebucket
		lcIndbucket=TRANS(lnIndbucket,"@L 99")
		*- Fill in siz01_head,..,siz24_head field
		*replace siz&lcIndbucket._head with padc(allt(eval('curOneSKU.size_desc')),7) in CurPart1
		*- Fill in siz01_qty,..,siz24_qty field
		lnAggVal = CurPart1.siz&lcIndbucket._qty + curOneSKU.total_qty
		replace siz&lcIndbucket._qty with lnAggVal in CurPart1
	endscan
endscan

*- Initialize AD Printer controls
??? "#!A1#IMS101.6/465.0#ERN1"	 && 4" wide by 18" long "Page"
*- ??? "#!A1#IMS101.6/156.0#PR7#G#HV90#ERN1"	 && 4" wide by 6" long "Page"
lnPageNum = 0                    && Each 3" page = 79mm, not 76.2mm
lnLinenum = 1

*- Build data string to be printed
*- -------------------------------
select curPart1
go top
*browse title alias()

lnTotalBlockQty=0

*--- TR 1012146 - 07/27/05 - BD - Modification 5 = initialize lcCurSize_code variable
*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new code line
lcCurSize_code=''
*=== TR 1012146 - BD - End of modification 5	

DO WHILE NOT EOF('curPart1') 

	lnIndLineBlock1=0
	lcStringBlock1=''
	lnPageNum = lnPageNum + 1
	lnOffset = (lnPageNum - 1) * 156

	*- Header line 1
	lcStringBlock1=lcStringBlock1+'#T50.0#J05.0#YT107/2M///'+'Notations Carton Pick Slip (Internal)'+'#G'
	lcStringBlock1=lcStringBlock1+'#T50.0#J09.0#YT106/2M///'+left(carton_num,20)+'#G'
	lnIndLineBlock1=lnIndLineBlock1+1

	*- Header line 2
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+13)+'#YT102/2///'+'Customer:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T85.0#J'+str(lnOffset+13)+'#YT103/2///'+left(sfscust_name,12)+'#G'
	lcStringBlock1=lcStringBlock1+'#T57.0#J'+str(lnOffset+13)+'#YT102/2///'+'DC ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T48.0#J'+str(lnOffset+13)+'#YT103/2///'+allt(center_code)+'#G'
	lcStringBlock1=lcStringBlock1+'#T30.0#J'+str(lnOffset+13)+'#YT102/2///'+'Store ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T18.0#J'+str(lnOffset+13)+'#YT103/2///'+left(store,12)+'#G'
	&& lcStringBlock1=lcStringBlock1+'#T66.6#J'+str(lnOffset+13)+'#YT102/2///'+'Notations Order ##:'+'#G'
	&& lcStringBlock1=lcStringBlock1+'#T33.3#J'+str(lnOffset+13)+'#YT103/2///'+left(allt(str(ord_num)),15)+'#G'

	*- Header line 3
	lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+17)+'#YT102/2///'+'Dept:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T85.0#J'+str(lnOffset+17)+'#YT103/2///'+left(department,5)+'#G'
	lcStringBlock1=lcStringBlock1+'#T65.0#J'+str(lnOffset+17)+'#YT102/2///'+'Wave number:'+'#G'
        if wave_num > 0 then
  	  lcStringBlock1=lcStringBlock1+'#T50.0#J'+str(lnOffset+17)+'#YT103/2///'+str(wave_num)+'#G'
        else
  	  lcStringBlock1=lcStringBlock1+'#T50.0#J'+str(lnOffset+17)+'#YT103/2///'+allt(carton_udf2)+'#G'
        endif
	
	*- Header line 3b
	lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+21)+'#YT102/2///'+'PO ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T85.0#J'+str(lnOffset+21)+'#YT103/2///'+allt(po_num)+'#G'
	lcStringBlock1=lcStringBlock1+'#T65.0#J'+str(lnOffset+21)+'#YT102/2///'+'P/S##: '+allt(STR(pick_num))+'#G'
	&& lcStringBlock1=lcStringBlock1+'#T165.0#J'+STR(lnOffset+21)+'#YT102/2///'+'Start Date:'+'#G'
	&& lcStringBlock1=lcStringBlock1+'#T150.0#J'+STR(lnOffset+21)+'#YT103/2///'+ALLTRIM(DTOC(start_date))+'#G'
	lcStringBlock1=lcStringBlock1+'#T30.0#J'+STR(lnOffset+21)+'#YT102/2///'+'End Date:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T18.0#J'+STR(lnOffset+21)+'#YT103/2///'+ALLTRIM(DTOC(end_date))+'#G'
	
	*--- TR 1012146 - 07/27/05 - BD - Modification 6 = print size_code when size_code is changing
	*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new block of code. Please check the printer control characters
	*- Header line 3c = detail band header
	IF curPart1.size_code<>lcCurSize_code
		*- Print the Size Code
		lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+28)+'#YT103/2///'+'Size Code:'+'#G'
		lcStringBlock1=lcStringBlock1+'#T80.0#J'+str(lnOffset+28)+'#YT103/2///'+left(size_code,3)+'#G'
	ENDIF

	*- Header line 4 = detail band header
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+28)+'#YT102/2///'+'Style'+'#G'
	lcStringBlock1=lcStringBlock1+'#T80.0#J'+str(lnOffset+28)+'#YT102/2///'+'Color'+'#G'
	lcStringBlock1=lcStringBlock1+'#T70.0#J'+str(lnOffset+28)+'#YT102/2///'+'Label'+'#G'
	*- Maximum 9 size headers
	lnIndValidBucket=0
	for lnIndbucket=2 to 8
		lcIndbucket=TRANS(lnIndbucket,"@L 99")
		*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<8
			lcStringBlock1=lcStringBlock1+ ;
				'#T'+str(68-((lnIndbucket-1)*6))+'#J'+str(lnOffset+28)+'#YT102/2///'+ ;
				padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
			lnIndValidBucket=lnIndValidBucket+1
		*endif
	endfor
	*- Total
	lcStringBlock1=lcStringBlock1+'#T17.0#J'+str(lnOffset+28)+'#YT102/2///'+'Total'+'#G'
	lcStringBlock1=lcStringBlock1+'#T10.0#J'+STR(lnOffset+28)+'#YT102/2///'+'Retail'+'#G'


	lnIndLineBlock1=0
	DO WHILE !eof('curPart1') AND lnIndLineBlock1<=MaxNbLineBlock1
		*- Detail line
		*- -----------
		
		*--- TR 1012146 - 07/27/05 - BD - Modification 7 = print size_code when size_code is changing
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new block of code. Please check the printer control characters
		IF curPart1.size_code<>lcCurSize_code
			
			IF lnIndLineBlock1<=MaxNbLineBlock1-2
				*- go to the next line
				lnIndLineBlock1=lnIndLineBlock1+1
			ELSE
				*- Exit from loop ==> go back to printing the main page header 
				exit	
			ENDIF
			lnIndLineBlock1=lnIndLineBlock1-1
			
			*- Print the Size Code
			lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+'Size Code:'+'#G'
			lcStringBlock1=lcStringBlock1+'#T80.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+left(size_code,3)+'#G'
			*- go to the next line
			lnIndLineBlock1=lnIndLineBlock1+1
			
			*- Reprint the size header line
			lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+'Style'+'#G'
			lcStringBlock1=lcStringBlock1+'#T80.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+'Color'+'#G'
			lcStringBlock1=lcStringBlock1+'#T70.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+'Label'+'#G'
			*- Maximum 9 size headers
			lnIndValidBucket=0
			for lnIndbucket=2 to 8
				lcIndbucket=TRANS(lnIndbucket,"@L 99")
				*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<8
					lcStringBlock1=lcStringBlock1+ ;
						'#T'+str(68-((lnIndbucket-1)*6))+'#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+ ;
						padl(eval('curPart1.siz'+lcIndbucket+'_head'),4)+'#G'
					lnIndValidBucket=lnIndValidBucket+1
				*endif
			endfor
			*- Total
			lcStringBlock1=lcStringBlock1+'#T17.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+'Total'+'#G'
			lcStringBlock1=lcStringBlock1+'#T10.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT102/2///'+'Retail'+'#G'
			lnIndLineBlock1=lnIndLineBlock1+1

		ENDIF
		*=== TR 1012146 - BD - End of modification 7		
		
		*- Style
		lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT105/2///'+ ;
			padr(style,10)+'#G'
		
		*- Color
		lcStringBlock1=lcStringBlock1+'#T80.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT105/2///'+ ;
			padr(color_code,6)+'#G'

		*- Label
		lcStringBlock1=lcStringBlock1+'#T70.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT105/2///'+ ;
			padr(lbl_code,6)+'#G'

		*- Bucket quantities
		lnTotal_qty=0
		lnIndValidBucket=0
		for lnIndbucket=2 to 8
			lcIndbucket=TRANS(lnIndbucket,"@L 99")
			*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<8
				lcStringBlock1=lcStringBlock1+ '#T'+str(68-((lnIndbucket-1)*6))+'#J'+ ;
					str(lnOffset+31+(lnIndLineBlock1*4))+'#YT105/2///'+ ;
					padl(allt(str(eval('curPart1.siz'+lcIndbucket+'_qty'))),4)+"#G"
				lnTotal_qty=lnTotal_qty+eval('curPart1.siz'+lcIndbucket+'_qty')
				lnIndValidBucket=lnIndValidBucket+1
			*endif
		endfor
		
		*- Total
		lcStringBlock1=lcStringBlock1+'#T17.0#J'+str(lnOffset+31+(lnIndLineBlock1*4))+'#YT105/2///'+ ;
			padl(alltrim(str(lnTotal_qty)),4)+'#G'
		lcStringBlock1=lcStringBlock1+'#T10.0#J'+STR(lnOffset+31+(lnIndLineBlock1*4))+'#YT105/2///'+ ;
			TRANSFORM(retail1,"999.99")+'#G'
		lnTotalBlockQty = lnTotalBlockQty + lnTotal_qty
		lcDC = alltrim(center_code)
		lcShipTo = ALLTRIM(sfsship_name)
		lcShipToAddr = ALLTRIM(sfsship_city)+', '+ALLTRIM(sfsship_state)
	
		lnIndLineBlock1=lnIndLineBlock1+1

	 	*--- TR 1012146 - 07/27/05 - BD - Modification 8 = memorize the current size_code being printed
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new line of code.
		lcCurSize_code=curPart1.size_code
		*=== TR 1012146 - BD - End of modification 8				

	 	skip 1 in curPart1
	ENDDO 
ENDDO		&& End of DO WHILE NOT EOF('curPart1') 

IF AT('#',lcShipTo)>0 AND AT('##',lcShipTo)=0 THEN
  lipos = AT('#',lcShipTo)
  lcShipTo = SUBSTR(lcShipTo,1,lipos-1)+'#'+SUBSTR(lcShipTo,lipos,(LEN(lcShipTo)-lipos)+1)
ENDIF
*- Block 1 summary line
if curPart1.terms=='N01' then
	lcStringBlock1 = lcStringBlock1 + '#M2/2#T98.0#J'+str(lnOffset+150)+'#YT109/2///CREDIT CARD#G#M1/1'
endif
lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+33+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
	'Total: '+alltrim(str(lnTotalBlockQty))+'#G'
lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+37+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
	'Ship To: '+ alltrim(lcShipTo) + '#G'
lcStringBlock1=lcStringBlock1+'#T98.0#J'+str(lnOffset+41+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
	'         '+ alltrim(lcShipToAddr) + '#G'


if lnPageNum = 3 then
  lcStringBlock1 = lcStringBlock1 + '#Q1#G'
  ??? lcStringBlock1 && Temporary stop
  ??? "#!A1#IMS101.6/465.0#ERN1"   && 8" wide by 9" long "Page"
  lnPageNum = 0
else
  ??? lcStringBlock1
endif
  

*- **************************
*- Build PART 2 of the label
*- **************************
*- --------------------------------------------------------------------------------------------------
*- Create cursor CurPart2 
*- --------------------------------------------------------------------------------------------------
lcCurPrintFinalTemp = GetUniqueFileName()
SELECT *, ;
 space(12) as SKU_UPC ;
FROM (lcOrgAlias) ;
where .F. ; 
INTO CURSOR CurPart2Temp
MakeCursorWritable('CurPart2Temp','CurPart2')

select * from (lcOrgAlias) where carton_num=curGroupByCarton.carton_num into cursor cur2Temp
scan
	*- Get the Customer style = First lookup in Customer Style Reference - If not found lookup in UPC
	*- -----------------------------------------------------------------------------------------------
    lcSKU_UPC = vl_cstdr(cur2Temp.customer,'CUST_STYLE','',cur2Temp.division,cur2Temp.Style,cur2Temp.color_code,cur2Temp.lbl_code,cur2Temp.dimension,cur2Temp.sizebucket)
	
	IF EMPTY(lcSKU_UPC)
		*- zveupcnr.upc_num = char(11)
		lcUPC=vl_upcsr(cur2Temp.Division,'upc_num','',cur2Temp.Style,cur2Temp.Color_code,cur2Temp.lbl_code,cur2Temp.Dimension,cur2Temp.Sizebucket)
		lcUPC_chk=vl_upcsr(cur2Temp.Division,'chk_digit','',cur2Temp.Style,cur2Temp.Color_code,cur2Temp.lbl_code,cur2Temp.Dimension,cur2Temp.Sizebucket)		
		lcSKU_UPC=allt(lcUPC)+allt(lcUPC_chk)
	ENDIF
		
	*- Add one new record in CurPart2
	select cur2Temp
	SCATTER memvar MEMO
	insert into CurPart2 from MEMVAR	
	replace SKU_UPC with lcSKU_UPC in CurPart2
endscan

select CurPart2
go top

DO WHILE NOT EOF('CurPart2') 

	lnPageNum = lnPageNum + 1
	if lnPageNum > 3 then
	  ??? "#Q1#G"
	  ??? "#!A1#IMS101.6/465.0#ERN1"   && 8" wide by 9" long "Page"
	  lnPageNum = 1  
	endif
	lnOffset = (lnPageNum - 1) * 156
	lnOffset = lnOffset + 5

	lcStringBlock2=''
	*- Header line 1
	*lcStringBlock2=lcStringBlock2+SPACE(5)
	lcStringBlock2=lcStringBlock2+'#T98.0#J'+str(lnOffset+8)+'#YT102/2///'+ ;
		'Customer: '+left(sfscust_name,12)+'#G'
	lcStringBlock2=lcStringBlock2+'#T50.0#J'+str(lnOffset+4)+'#YT107/2M///'+ ;
		'Carton Packing Slip'+'#G'
	lcStringBlock2=lcStringBlock2+'#T25.0#J'+str(lnOffset+8)+'#YT102/2///'+ ;
		'SO ##: '+left(allt(str(ord_num)),10)+'#G'

	*- Header line 2
	lcStringBlock2=lcStringBlock2+'#T98.0#J'+str(lnOffset+12)+'#YT102/2///'+ ;
		+'Store:'+SPACE(1)+left(store,12)+'#G'
	lcStringBlock2=lcStringBlock2+'#T50.0#J'+str(lnOffset+12)+'#YT102/2M///'+ ;
		'Carton ##: '+left(carton_num,20)+'#G'
	lcStringBlock2=lcStringBlock2+'#T25.0#J'+str(lnOffset+12)+'#YT102/2///'+ ;
		'PO ##:'+SPACE(1)+padr(allt(po_num),14)+'#G'

	*- Header line 3 = detail band header
	*lcStringBlock2=lcStringBlock2+SPACE(5)
	lcStringBlock2=lcStringBlock2+'#T98.0#J'+str(lnOffset+18)+'#YT102/2///'+ ;
		'Style'+'#G'
	lcStringBlock2=lcStringBlock2+'#T70.0#J'+str(lnOffset+18)+'#YT102/2///'+ ;
		'Color'+'#G'
	lcStringBlock2=lcStringBlock2+'#T57.3#J'+str(lnOffset+18)+'#YT102/2///'+ ;
		'Size'+'#G'
	lcStringBlock2=lcStringBlock2+'#T44.0#J'+str(lnOffset+18)+'#YT102/2///'+ ;
		'SKU/UPC'+'#G'
	lcStringBlock2=lcStringBlock2+'#T16.6#J'+str(lnOffset+18)+'#YT102/2///'+ ;
		'Qty'+'#G'

	lnIndLineBlock2=0
	lnLineNum = 0
	lnItemCount = 0
	DO WHILE !eof('curPart2') AND lnIndLineBlock2<=MaxNbLineBlock2
		
		*- Detail line
		*- -----------
		
		*- Style
		lcStringBlock2=lcStringBlock2+'#T98.0#J'+str(lnOffset+21+(lnIndLineBlock2*3))+'#YT102/2///'+ ;
			padr(style,10)+'#G'
		
		*- Color
		lcStringBlock2=lcStringBlock2+'#T70.0#J'+str(lnOffset+21+(lnIndLineBlock2*3))+'#YT102/2///'+ ;
			padr(color_code,6)+'#G'

		*- Size
		lcStringBlock2=lcStringBlock2+'#T57.3#J'+str(lnOffset+21+(lnIndLineBlock2*3))+'#YT102/2///'+ ;
			padr(size_desc,6)+'#G'

		*- SKU/UPC
		lcStringBlock2=lcStringBlock2+'#T44.0#J'+str(lnOffset+21+(lnIndLineBlock2*3))+'#YT102/2///'+ ;
			padr(SKU_UPC,12)+'#G'
		
		*- Qty
		lcStringBlock2=lcStringBlock2+'#T16.6#J'+str(lnOffset+21+(lnIndLineBlock2*3))+'#YT102/2///'+ ;
			padr(str(Total_qty,6),6)+'#G'
		IF Total_qty > 0 THEN
			lnItemCount = lnItemCount + 1
		ENDIF
		lnIndLineBlock2=lnIndLineBlock2+1
	 	skip 1 in curPart2
	
	ENDDO
	
	*- Send one Packing Slip block to the printer
	lcStringBlock2=lcStringBlock2+CRLF
	*messagebox(lcStringBlock2)
	if not eof('curPart2') then
	  && ??? lcStringBlock2 && Temporary stop
	endif	

ENDDO		&& End of DO WHILE NOT EOF('CurPart2Final') 

*- Block 2 summary line
lcStringBlock2=lcStringBlock2+'#T25.0#J'+str(lnOffset+25+(lnIndLineBlock2*3))+'#YT106/2///'+ ;
	'Total: '+alltrim(str(lnTotalBlockQty))+'#G'

*- Check for end of page

if lnPageNum = 3 then
  lcStringBlock2 = lcStringBlock2 + '#Q1#G'
  ??? lcStringBlock2
  ??? '#!A1#IMS101.6/465.0#ERN1'
  lnPageNum = 0
else
  ??? lcStringBlock2 
endif

*- ***************************************
*- Build PART 3 of the label
*- ***************************************
*- Make all customer specific changes here
*- ***************************************

select CurPart2
go top

*- Generic 4x6

lnPageNum = lnPageNum + 1
lnOffset = (lnPageNum - 1) * 156
lcStringBlock3 = ''
lnOffset = lnOffset + 3

*- Draw lines
*- Horizontal
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+20.3)+'#YL4/2/1/95#G'
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+45.7)+'#YL4/2/1/95#G'
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+71.3)+'#YL4/2/1/95#G'
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+96.7)+'#YL4/2/1/95#G'

*- Vertical
lcStringBlock3 = lcStringBlock3 + '#T63.5#J'+str(lnOffset+0)+'#YL4/1/1/20#G'
lcStringBlock3 = lcStringBlock3 + '#T38.1#J'+str(lnOffset+20.3)+'#YL4/1/1/25.4#G'
lcStringBlock3 = lcStringBlock3 + '#T40.0#J'+str(lnOffset+71.3)+'#YL4/1/1/25.4#G'

*- Zone A (Ship from)

lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+4)+'#YT100/2///'+'FROM:'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+7)+'#YT101/2///'+'NOTATIONS, INC.'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+10)+'#YT101/2///'+'539 JACKSONVILLE RD.'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+13)+'#YT101/2///'+'WARMINSTER, PA 18974 US'+'#G'

*- Zone B (Ship to [DC])

IF alltrim(center_code)<>'D2S' THEN
  B_NAME = alltrim(sfsship_name)
  B_ADDR1 = alltrim(sfsship_addr1)
  B_ADDR2 = alltrim(sfsship_addr2)
  B_CSZ = alltrim(sfsship_city)+', '+alltrim(sfsship_state)+'  '+SUBSTR(alltrim(sfsship_zip),1,5)+'  '+SUBSTR(alltrim(sfsship_country),1,2)
ELSE
  B_NAME = alltrim(sfsstore_name)
  B_ADDR1 = alltrim(sfsmark_addr1)
  B_ADDR2 = alltrim(sfsmark_addr2)
  B_CSZ = alltrim(sfsmark_city)+', '+alltrim(sfsmark_state)+'  '+SUBSTR(alltrim(sfsmark_zip),1,5)+'  '+SUBSTR(alltrim(sfsmark_country),1,2)
ENDIF
IF AT('#',B_NAME)>0 AND AT('##',B_NAME)=0 THEN
  lipos = AT('#',B_NAME)
  B_NAME = SUBSTR(B_NAME,1,lipos-1)+'#'+SUBSTR(B_NAME,lipos,(LEN(B_NAME)-lipos)+1)
ENDIF

lcStringBlock3 = lcStringBlock3 + '#T58.0#J'+str(lnOffset+4)+'#YT100/2///'+'TO:'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T55.0#J'+str(lnOffset+9)+'#YT105/2///'+B_NAME+'#G'
lcStringBlock3 = lcStringBlock3 + '#T55.0#J'+str(lnOffset+12)+'#YT105/2///'+B_ADDR1+'#G'
lcStringBlock3 = lcStringBlock3 + '#T55.0#J'+str(lnOffset+15)+'#YT105/2///'+B_ADDR2+'#G'
lcStringBlock3 = lcStringBlock3 + '#T55.0#J'+str(lnOffset+18)+'#YT105/2///'+B_CSZ+'#G'

*- Zone C (Ship to Post [UCC128])

lcStringBlock3 = lcStringBlock3 + '#T88.0#J'+str(lnOffset+40)+'#YB15/2O/15/5///420'+SUBSTR(alltrim(sfsship_zip),1,5)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T79.0#J'+str(lnOffset+44)+'#YT105/2///(420)'+SUBSTR(alltrim(sfsship_zip),1,5)+'#G'

*- Zone D (Carrier, etc.)
&& lcStringBlock3 = lcStringBlock3 + '#T36.0#J'+str(lnOffset+27)+'#YT102/2///Carrier:#G'
&& lcStringBlock3 = lcStringBlock3 + '#T36.0#J'+str(lnOffset+37)+'#YT102/2///BOL:#G'

*- Zone E (PO / Dept)
lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+57)+'#YT109/2///'+'PO: '+alltrim(po_num)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+67)+'#YT109/2///'+'Dept: '+alltrim(department)+'#G'
&& lcStringBlock3 = lcStringBlock3 + '#T40.0#J'+str(lnOffset+67)+'#YT105/2///'+'Carton ____ of ____#G'

*- Zone F (if not combined with Zone E)

*- Zone G (Mark for store # [UCC128])



*- Zone H (Mark for store # [text])


*- Zone I (Carton # [UCC128])

lcStringBlock3 = lcStringBlock3 + '#T92.0#J'+str(lnOffset+142)+'#YB15/2O/35.0/6///'+alltrim(carton_num)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T82.0#J'+str(lnOffset+147)+'#YT105/2///'+alltrim(carton_num)+'#G'

*- End

lcStringBlock3 = lcStringBlock3 + '#Q1#G'
??? lcStringBlock3

ENDSCAN		&& End of SCAN curGroupByCarton

select (lnOrgArea)


*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

use in CurPart1
use in CurPart2
use in curGroupByCarton

RETURN .T.

*-----------------------------------------------------------------------------
*- FUNCTION vl_msnnum(pick_num,line_seq)
*- Returns assortment from zzeipohd
*- Michael J. Sabal, Notations, Inc. 28 June 2010
*-----------------------------------------------------------------------------
FUNCTION vl_msnnum
PARAMETERS parm_picknum, parm_lineseq

  LOCAL lcSQLQuery, llCount, lcSQLReturn

  lcSQLQuery = "SELECT d.assortment FROM zzoordrd d "+;
				"WHERE d.pick_num="+alltrim(str(parm_picknum))+ ;
               " AND d.line_seq="+alltrim(str(parm_lineseq))
  = v_SQLPrep(lcSQLQuery,'poline','')
  if used('poline') and reccount('poline')>0
    *- We have a valid range style
    lcSQLReturn = poline.assortment
  else
  lcSQLQuery = "SELECT d.assortment FROM zzoshprd d "+;
				"WHERE d.pick_num="+alltrim(str(parm_picknum))+ ;
               " AND d.line_seq="+alltrim(str(parm_lineseq))
  = v_SQLPrep(lcSQLQuery,'poline','')
  if used('poline') and reccount('poline')>0
    *- We have a valid range style
    lcSQLReturn = poline.assortment
  else
    lcSQLReturn = ""
	endif
	endif

RETURN lcSQLReturn

*-----------------------------------------------------------------------------
*- FUNCTION vl_pidmode(ord_num,line_seq)
*- Returns PID/64 from zzedatawhse
*- Michael J. Sabal, Notations, Inc. 28 June 2010
*-----------------------------------------------------------------------------
FUNCTION vl_pidmode
PARAMETERS parm_ordnum, parm_lineseq

  LOCAL lcSQLQuery, llCount, lcSQLReturn

  lcSQLQuery = "select top 1 value from zzedatawhse "+;
	"where ORD_NUM="+alltrim(str(parm_ordnum))+;
	" and line_seq="+alltrim(str(parm_lineseq))+;
	" and SEGMENT='PID' and QUALIFIER='64'"
  = v_SQLPrep(lcSQLQuery,'poline','')
    lcSQLReturn = poline.value

RETURN lcSQLReturn
