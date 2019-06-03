*- ----------------------------------------------------------------------------------------------------------------------- -*
*- TR 1009452 - 03/15/05 - Bruno DIEPENDAELE
*- 2/2/2006 - EasyPlug formatting added by Michael J. Sabal, Notations.
*- DESCRIPTION: This is a 3 part label designed without the Visual Foxpro label designer. The label is generated by
*- this Foxpro program NOTCAT4O.PRG (orig: NOTPCLUC.PRG)
*- Formatting codes are Avery Dennison EASYPLUG.
*- This label is a 3 part label:
*- PART 1: Carton Pick Slip Internal - this is a carton content list showing the buckets horizontaly
*- PART 2: Carton Pick Slip - CATHERINES specific carton label
*- PART 3: Carton Pick Slip - CATHERINES specific carton content label
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

#DEFINE MaxNbLineBlock1 8
#DEFINE MaxNbLineBlock2 10
#DEFINE MaxNbLineBlock3 17
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
lcCurPrintFinalTemp = GetUniqueFileName()
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
into cursor cur1GroupBySKU group by carton_num,style,color_code,lbl_code,line_seq ;
ORDER BY carton_num,size_code,style

USE IN cur1GroupBySKUTemp
SELECT cur1GroupBySKU
*=== TR 1012146 - BD - End of modification 3
scan
	select * from (lcOrgAlias) where carton_num=cur1GroupBySKU.carton_num AND style=cur1GroupBySKU.style AND ;
	color_code=cur1GroupBySKU.color_code AND lbl_code=cur1GroupBySKU.lbl_code AND line_seq=cur1GroupBySKU.line_seq;
	into cursor curOneSKU
	*- Add one new record per style
	SCATTER memvar MEMO
	insert into CurPart1 from MEMVAR	
	*- Fill size header fields siz01_head,..,siz09_head	
	*- ------------------------------------------------
	lcDivision=cur1GroupBySKU.division
	lcStyle=cur1GroupBySKU.style
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
	endfor	&& End for 10
	
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
??? "#!A1#IMS203.2/228.6#ERN1"   && 8" wide by 9" long "Page"
lnPageNum = 0                    && Each 3" page = 79mm, not 76.2mm
lnLinenum = 1

*- Build data string to be printed
*- -------------------------------
*browse title curPart1
select curPart1
go top

lnTotalBlockQty=0

*--- TR 1012146 - 07/27/05 - BD - Modification 5 = initialize lcCurSize_code variable
*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new code line
lcCurSize_code=''
*=== TR 1012146 - BD - End of modification 5	

DO WHILE NOT EOF('curPart1') 

	lnIndLineBlock1=0
	lcStringBlock1=''
	lnPageNum = lnPageNum + 1
	lnOffset = (lnPageNum - 1) * 79

	*- Header line 1
	lcStringBlock1=lcStringBlock1+'#T138.0#J05.0#YT107/2///'+'Notations Carton Pick Slip (Internal)'+'#G'
	lcStringBlock1=lcStringBlock1+'#T50.0#J05.0#YT107/2///'+allt(carton_udf1)+'#G'
	lnIndLineBlock1=lnIndLineBlock1+1

	*- Header line 2
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+8)+'#YT103/2///'+'Customer:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T185.0#J'+str(lnOffset+8)+'#YT103/2///'+left(sfscust_name,12)+'#G'
	lcStringBlock1=lcStringBlock1+'#T157.0#J'+str(lnOffset+8)+'#YT103/2///'+'DC ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T150.0#J'+str(lnOffset+8)+'#YT103/2///'+allt(center_code)+'#G'
	lcStringBlock1=lcStringBlock1+'#T130.0#J'+str(lnOffset+8)+'#YT103/2///'+'Store ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T110.0#J'+str(lnOffset+8)+'#YT103/2///'+left(store,12)+'#G'
	lcStringBlock1=lcStringBlock1+'#T66.6#J'+str(lnOffset+8)+'#YT103/2///'+'Notations Order ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T33.3#J'+str(lnOffset+8)+'#YT103/2///'+left(allt(str(ord_num)),15)+'#G'

	*- Header line 3
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+12)+'#YT103/2///'+'Dept:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T185.0#J'+str(lnOffset+12)+'#YT103/2///'+left(department,5)+'#G'
	lcStringBlock1=lcStringBlock1+'#T165.0#J'+str(lnOffset+12)+'#YT103/2///'+'Wave number:'+'#G'
        if wave_num > 0 then
  	  lcStringBlock1=lcStringBlock1+'#T150.0#J'+str(lnOffset+12)+'#YT103/2///'+str(wave_num)+'#G'
        else
  	  lcStringBlock1=lcStringBlock1+'#T150.0#J'+str(lnOffset+12)+'#YT103/2///'+allt(carton_udf2)+'#G'
        endif
	lcStringBlock1=lcStringBlock1+'#T130.0#J'+str(lnOffset+12)+'#YT103/2///'+'Carton ID ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T110.0#J'+str(lnOffset+12)+'#YT103/2///'+left(carton_num,20)+'#G'
	lcStringBlock1=lcStringBlock1+'#T66.6#J'+str(lnOffset+12)+'#YT103/2///'+'PO ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T58.0#J'+str(lnOffset+12)+'#YT103/2///'+allt(po_num)+'#G'
	lcStringBlock1=lcStringBlock1+'#T28.0#J'+str(lnOffset+12)+'#YT103/2///'+'P/S##: '+allt(STR(pick_num))+'#G'

	*- Header line 3b
	lcStringBlock1=lcStringBlock1+'#T165.0#J'+STR(lnOffset+15)+'#YT103/2///'+'Start Date:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T150.0#J'+STR(lnOffset+15)+'#YT103/2///'+ALLTRIM(DTOC(start_date))+'#G'
	lcStringBlock1=lcStringBlock1+'#T90.0#J'+STR(lnOffset+15)+'#YT103/2///'+'End Date:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T75.0#J'+STR(lnOffset+15)+'#YT103/2///'+ALLTRIM(DTOC(end_date))+'#G'
	
	*--- TR 1012146 - 07/27/05 - BD - Modification 6 = print size_code when size_code is changing
	*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new block of code. Please check the printer control characters
	*- Header line 3c = detail band header
	IF curPart1.size_code<>lcCurSize_code
		*- Print the Size Code
		lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+15)+'#YT103/2///'+'Size Code:'+'#G'
		lcStringBlock1=lcStringBlock1+'#T180.0#J'+str(lnOffset+15)+'#YT103/2///'+left(CurPart1.size_code,3)+'#G'
	ENDIF
	*=== TR 1012146 - BD - End of modification 6
	
	*- Header line 4 = detail band header
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+18)+'#YT102/2///'+'Style'+'#G'
	lcStringBlock1=lcStringBlock1+'#T182.0#J'+str(lnOffset+18)+'#YT102/2///'+'Color'+'#G'
	lcStringBlock1=lcStringBlock1+'#T170.0#J'+str(lnOffset+18)+'#YT102/2///'+'Price'+'#G'
	lcStringBlock1=lcStringBlock1+'#T160.0#J'+str(lnOffset+18)+'#YT102/2///'+'Label'+'#G'
	*- Maximum 9 size headers
	lnIndValidBucket=0
	for lnIndbucket=2 to 9
		lcIndbucket=TRANS(lnIndbucket,"@L 99")
		*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
			lcStringBlock1=lcStringBlock1+ ;
				'#T'+str(160-((lnIndbucket-1)*13.3))+'#J'+str(lnOffset+18)+'#YT102/2///'+ ;
				padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
			lnIndValidBucket=lnIndValidBucket+1
		*endif
	endfor
	if (curPart1.siz10_qty>0) then
		lcStringBlock1=lcStringBlock1+ ;
			'#T40.3#J'+str(lnOffset+18)+'#YT102/2///'+padl(curPart1.siz10_head,7)+'#G'
		lnIndValidBucket=lnIndValidBucket+1
	endif
	*- Total
	lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+18)+'#YT102/2///'+'Total'+'#G'
	lcStringBlock1=lcStringBlock1+'#T13.3#J'+STR(lnOffset+18)+'#YT102/2///'+'Retail'+'#G'
	*- Ship To
	*lcStringBlock1=lcStringBlock1+'Ship To:'+SPACE(3)+CRLF


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
			
			lnIndLineBlock1=lnIndLineBlock1-1  && Compensate for overlap
			*- Print the Size Code
			lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+'Size Code:'+'#G'
			lcStringBlock1=lcStringBlock1+'#T180.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+left(size_code,3)+'#G'
			*- go to the next line
			lnIndLineBlock1=lnIndLineBlock1+1
			
			*- Reprint the size header line
			lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+'Style'+'#G'
			lcStringBlock1=lcStringBlock1+'#T186.6#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+'Color'+'#G'
			lcStringBlock1=lcStringBlock1+'#T173.3#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+'Price'+'#G'
			lcStringBlock1=lcStringBlock1+'#T160.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+'Label'+'#G'
			*- Maximum 9 size headers
			lnIndValidBucket=0
			for lnIndbucket=2 to 9
				lcIndbucket=TRANS(lnIndbucket,"@L 99")
				*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
					lcStringBlock1=lcStringBlock1+ ;
						'#T'+str(160-((lnIndbucket-1)*13.3))+'#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+ ;
						padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
					lnIndValidBucket=lnIndValidBucket+1
				*endif
			endfor
			if (curPart1.siz10_qty>0) then
				lcStringBlock1=lcStringBlock1+ ;
					'#T40.3#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+padl(curPart1.siz10_head,7)+'#G'
				lnIndValidBucket=lnIndValidBucket+1
			endif
			*- Total
			lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+'Total'+'#G'
			lcStringBlock1=lcStringBlock1+'#T13.3#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+'Retail'+'#G'
			lnIndLineBlock1=lnIndLineBlock1+1

		ENDIF
		*=== TR 1012146 - BD - End of modification 7		
		
		*- Style
		lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(style,10)+'#G'
		
		*- Color
		lcStringBlock1=lcStringBlock1+'#T182.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(color_code,6)+'#G'

		*- Price= do backend query to get price from zzoordrd
		lnPrice=vl_pickdtlsku(pick_num,'price','',style,color_code,lbl_code,dimension)
		lcStringBlock1=lcStringBlock1+'#T170.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(str(lnprice,6,2),6)+'#G'

		*- Label
		lcStringBlock1=lcStringBlock1+'#T160.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(lbl_code,6)+'#G'

		*- Bucket quantities
		lnTotal_qty=0
		lnIndValidBucket=0
		for lnIndbucket=2 to 9
			lcIndbucket=TRANS(lnIndbucket,"@L 99")
			*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
				lcStringBlock1=lcStringBlock1+ '#T'+str(160-((lnIndbucket-1)*13.3))+'#J'+ ;
					str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
					padl(allt(str(eval('curPart1.siz'+lcIndbucket+'_qty'))),7)+"#G"
				lnTotal_qty=lnTotal_qty+eval('curPart1.siz'+lcIndbucket+'_qty')
				lnIndValidBucket=lnIndValidBucket+1
			*endif
		endfor
		if (curPart1.siz10_qty>0) then
			lcStringBlock1=lcStringBlock1+ ;
				'#T40.3#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+padl(curPart1.siz10_qty,7)+'#G'
			lnTotal_qty = lnTotal_qty + curPart1.siz10_qty
			lnIndValidBucket=lnIndValidBucket+1
		endif
		
		*- Total
		lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(str(lnTotal_qty,6),6)+'#G'
		lcStringBlock1=lcStringBlock1+'#T13.3#J'+STR(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			TRANSFORM(retail1,"999.99")+'#G'
		lnTotalBlockQty = lnTotalBlockQty + lnTotal_qty
		lcShipTo = ALLTRIM(sfsship_name)+': '+ALLTRIM(sfsship_city)+', '+ALLTRIM(sfsship_state)
	
		lnIndLineBlock1=lnIndLineBlock1+1

	 	*--- TR 1012146 - 07/27/05 - BD - Modification 8 = memorize the current size_code being printed
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new line of code.
		lcCurSize_code=curPart1.size_code
		*=== TR 1012146 - BD - End of modification 8				

	 	skip 1 in curPart1
	ENDDO 

	*- Send block to printer
	*messagebox(lcStringBlock1)
	*lcStringBlock1=lcStringBlock1+CRLF
	if not eof('curPart1') then
	  ??? lcStringBlock1
	endif

ENDDO		&& End of DO WHILE NOT EOF('curPart1') 

*- Block 1 summary line
lcStringBlock1=lcStringBlock1+'#T33.3#J'+str(lnOffset+25+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
	'Total: '+str(lnTotalBlockQty)+'#G'
lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+25+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
	'Ship To: '+ alltrim(lcShipTo) + '#G'
if lnPageNum = 3 then
  lcStringBlock1 = lcStringBlock1 + '#Q1#G'
  ??? lcStringBlock1
  ??? "#!A1#IMS203.2/228.6#ERN1"   && 8" wide by 9" long "Page"
  lnPageNum = 0
else
  ??? lcStringBlock1
endif
  

*- **************************
*- Build PART 2 of the label
*- **************************
select curPart1
liBadSku = 0
go top
scan
	*- Get the Customer style = First lookup in Customer Style Reference - If not found lookup in UPC
	*- -----------------------------------------------------------------------------------------------
    lcSKU_UPC = vl_cstdr(curPart1.customer,'CUST_STYLE','',curPart1.division,curPart1.Style,curPart1.color_code,curPart1.lbl_code,curPart1.dimension,curPart1.sizebucket)
    lcSKU_descr = vl_cstyr(curPart1.customer,'CUST_DESC','',curPart1.division,curPart1.Style,curPart1.color_code,curPart1.lbl_code,curPart1.dimension)
    lcSKU_color = vl_cstyr(curPart1.customer,'CUST_COLOR','',curPart1.division,curPart1.Style,curPart1.color_code,curPart1.lbl_code,curPart1.dimension)
    lcSKU = lcSKU_UPC
    IF EMPTY(lcSKU_UPC) 
      lcSKU_UPC = vl_cstyr(curPart1.customer,'CUSTOMER_STYLE','',curPart1.division,curPart1.Style,curPart1.color_code,curPart1.lbl_code,curPart1.dimension)
    ENDIF	

	IF NOT EMPTY(lcSKU_UPC)
          replace Style with alltrim(lcSKU_UPC) in curPart1
        ELSE
          liBadSku = 1
          lcBadSku = curPart1.Style       
 	ENDIF
        IF NOT EMPTY(lcSKU_color)
          replace color_code with alltrim(lcSKU_color) in curPart1
        ENDIF
		
endscan

select curPart1
go top
*brow title alias()
lnTotalBlockQty = 0
llcount = 1

* DO WHILE NOT EOF('curPart1') 

	lnPageNum = lnPageNum + 1
	if lnPageNum > 3 then
	  ??? "#Q1#G"
	  ??? "#!A1#IMS203.2/228.6#ERN1"   && 8" wide by 9" long "Page"
	  lnPageNum = 1  
	endif
	lnOffset = (lnPageNum - 1) * 79
	lnOffset = lnOffset + 2

	lnIndLineBlock1=3
	lcStringBlock1=''

	lcStringBlock1 = lcStringBlock1 + '#T193.0#J'+str(lnOffset+70)+'#YB15/2O/1/6///'+alltrim(carton_num)+'#G'
	
	*- Header line 1
	lcStringBlock1=lcStringBlock1+'#T66.6#J'+str(lnOffset+5)+'#YT103/2///'+'Notations Order ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T33.3#J'+str(lnOffset+5)+'#YT103/2///'+left(allt(str(ord_num)),15)+'#G'

	lcStringBlock1=lcStringBlock1+'#M2/3'

	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+7)+'#YT105/2///'+'FROM: Notations, Inc.'+'#G'
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+14)+'#YT105/2///'+'539 Jacksonville Rd.'+'#G'
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+21)+'#YT105/2///'+'Warminster, PA  18974'+'#G'

	*- Header line 2
	lcStringBlock1=lcStringBlock1+'#T147.0#J'+str(lnOffset+7)+'#YT106/2///'+'TO: '+alltrim(sfsship_name)+'#G'
	lcStringBlock1=lcStringBlock1+'#T147.0#J'+str(lnOffset+15)+'#YT106/2///'+allt(sfsship_addr1)+'#G'
	lcStringBlock1=lcStringBlock1+'#T147.0#J'+str(lnOffset+23)+'#YT106/2///'+ ;
		alltrim(sfsship_city)+', '+alltrim(sfsship_state)+'  '+alltrim(sfsship_zip)+'#G'

	*- Header line 3
	lcStringBlock1=lcStringBlock1+'#T50.0#J'+str(lnOffset+15)+'#YT106/2///'+'PO ##:'+allt(po_num)+'#G'
	lcStringBlock1=lcStringBlock1+'#T50.0#J'+str(lnOffset+23)+'#YT106/2///'+'MODE 4'+'#G'

if 1=0 then
	*- Header line 3b
	
	*--- TR 1012146 - 07/27/05 - BD - Modification 6 = print size_code when size_code is changing
	*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new block of code. Please check the printer control characters
	*- Header line 3c = detail band header
	IF curPart1.size_code<>lcCurSize_code
		*- Print the Size Code
		lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+15)+'#YT103/2///'+'Size Code:'+'#G'
		lcStringBlock1=lcStringBlock1+'#T180.0#J'+str(lnOffset+15)+'#YT103/2///'+left(size_code,3)+'#G'
	ENDIF
	*=== TR 1012146 - BD - End of modification 6
	
	*- Header line 4 = detail band header
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///'+'STYLE'+'#G'
	lcStringBlock1=lcStringBlock1+'#T170.0#J'+str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///'+'COLOR'+'#G'
	lcStringBlock1=lcStringBlock1+'#T145.0#J'+str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///'+'DEPT'+'#G'
	*- Maximum 9 size headers
	lcStringBlock1=lcStringBlock1+'#M1/3'
	lnIndValidBucket=0
	for lnIndbucket=2 to 9
		lcIndbucket=TRANS(lnIndbucket,"@L 99")
		*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
			lcStringBlock1=lcStringBlock1+ ;
				'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
				padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
			lcStringBlock1=lcStringBlock1+ ;
				'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
				'_____'+'#G'
			lnIndValidBucket=lnIndValidBucket+1
		*endif
	endfor
	if (curPart1.siz10_qty>0) then
		lcStringBlock1=lcStringBlock1+'#T40.0#J'+ ;
			str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padl(allt(str(curPart1.siz10_head)),7)+'#G'
		lcStringBlock1=lcStringBlock1+'#T40.0#J'+ ;
			str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///_____#G'
		lnIndValidBucket=lnIndValidBucket+1
	endif
	lcStringBlock1=lcStringBlock1+'#M2/3'
	*- Total
	lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+22+(lnIndLineBlock1*4))+'#YT103/2///'+'TOTAL'+'#G'
	lnIndLineBlock1 = lnIndLineBlock1 + 3

	DO WHILE !eof('curPart1') AND lnIndLineBlock1<=MaxNbLineBlock2
		*- Detail line
		*- -----------

		*--- TR 1012146 - 07/27/05 - BD - Modification 7 = print size_code when size_code is changing
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new block of code. Please check the printer control characters
		IF curPart1.size_code<>lcCurSize_code
			
			IF lnIndLineBlock1<=MaxNbLineBlock2-2
				*- go to the next line
				lnIndLineBlock1=lnIndLineBlock1+1
			ELSE
				*- Exit from loop ==> go back to printing the main page header 
				exit	
			ENDIF
			
			*- Maximum 9 size headers
			lcStringBlock1=lcStringBlock1+'#M1/3'
			lnIndValidBucket=0
			for lnIndbucket=2 to 9
				lcIndbucket=TRANS(lnIndbucket,"@L 99")
				*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
					lcStringBlock1=lcStringBlock1+ ;
						'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+ ;
						padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
					lcStringBlock1=lcStringBlock1+ ;
						'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
						'_______'+'#G'
					lnIndValidBucket=lnIndValidBucket+1
				*endif
			endfor
			if (curPart1.siz10_qty>0) then
				lcStringBlock1=lcStringBlock1+'#T40.0#J'+ ;
					str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+ ;
					padl(allt(str(curPart1.siz10_head)),7)+'#G'
				lcStringBlock1=lcStringBlock1+'#T40.0#J'+ ;
					str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///_____#G'
				lnIndValidBucket=lnIndValidBucket+1
			endif
			lcStringBlock1=lcStringBlock1+'#M2/3'
			lnIndLineBlock1=lnIndLineBlock1+2

		ENDIF
		*=== TR 1012146 - BD - End of modification 7		
		
		*- Style
		lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(style,10)+'#G'

		*- Color
		lcStringBlock1=lcStringBlock1+'#T170.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			color_code+'#G'

		*- Department
		lcStringBlock1=lcStringBlock1+'#T145.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(department,6)+'#G'

		*- Bucket quantities
		lnTotal_qty=0
		lnIndValidBucket=0
		for lnIndbucket=2 to 9
			lcIndbucket=TRANS(lnIndbucket,"@L 99")
			*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
				lcStringBlock1=lcStringBlock1+ '#T'+str(140-(lnIndbucket*10))+'#J'+ ;
					str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
					padl(allt(str(eval('curPart1.siz'+lcIndbucket+'_qty'))),3)+"#G"
				lnTotal_qty=lnTotal_qty+eval('curPart1.siz'+lcIndbucket+'_qty')
				lnIndValidBucket=lnIndValidBucket+1
			*endif
		endfor
		if (curPart1.siz10_qty>0) then
			lcStringBlock1=lcStringBlock1+'#T40.0#J'+ ;
				str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
				padl(allt(str(curPart1.siz10_qty)),3)+'#G'
			lnTotal_qty=lnTotal_qty+curPart1.siz10_qty
			lnIndValidBucket=lnIndValidBucket+1
		endif
		
		*- Total
		lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
			padr(str(lnTotal_qty,6),6)+'#G'
		lnTotalBlockQty = lnTotalBlockQty + lnTotal_qty
	
		lnIndLineBlock1=lnIndLineBlock1+2

	 	*--- TR 1012146 - 07/27/05 - BD - Modification 8 = memorize the current size_code being printed
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new line of code.
		lcCurSize_code=curPart1.size_code
		*=== TR 1012146 - BD - End of modification 8				

	 	skip 1 in curPart1
	ENDDO 
else
  lcStringBlock1 = lcStringBlock1 + '#T200.0#J'+str(lnOffset+40)+'#YT103/2///SEE SEPARATE LABEL FOR DETAILED CONTENTS#G'
  lcStringBlock1 = lcStringBlock1 + '#T200.0#J'+str(lnOffset+48)+'#YT103/2///(TOO MANY SKUS TO FIT ON THIS LABEL)#G'
endif

* ENDDO		&& End of DO WHILE NOT EOF('curPart1') 

*- Block 1 summary line
* lcStringBlock1=lcStringBlock1+'#T80.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
* 	'TOTAL QTY: '+str(lnTotalBlockQty)+'#G'

lcStringBlock1=lcStringBlock1+'#M1/1#G'

*- Check for end of page

??? lcStringBlock1
lcStringBlock1 = ''

*- ***************************************
*- Build PART 3 of the label
*- ***************************************
*- Make all customer specific changes here
*- ***************************************

select curPart1
go top
*brow title alias()
lnTotalBlockQty = 0

DO WHILE NOT EOF('curPart1') 

	lnPageNum = lnPageNum + 1
	if lnPageNum > 3 then
          ??? lcStringBlock1
	  ??? "#Q1#G"
	  ??? "#!A1#IMS203.2/228.6#ERN1"   && 8" wide by 9" long "Page"
	  lnPageNum = 1  
  	  lcStringBlock1=''
	endif
	lnOffset = (lnPageNum - 1) * 79
	lnOffset = lnOffset + 1

	lnIndLineBlock1=1

if 1=0 then
	lcStringBlock1 = lcStringBlock1 + '#T193.0#J'+str(lnOffset+70)+'#YB15/2O/1/6///'+alltrim(carton_num)+'#G'
	
	*- Header line 1
	lcStringBlock1=lcStringBlock1+'#T66.6#J'+str(lnOffset+5)+'#YT103/2///'+'Notations Order ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T33.3#J'+str(lnOffset+5)+'#YT103/2///'+left(allt(str(ord_num)),15)+'#G'

	lcStringBlock1=lcStringBlock1+'#M2/3'

	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+7)+'#YT105/2///'+'FROM: Notations, Inc.'+'#G'
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+14)+'#YT105/2///'+'539 Jacksonville Rd.'+'#G'
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+21)+'#YT105/2///'+'Warminster, PA  18974'+'#G'

	*- Header line 2
	lcStringBlock1=lcStringBlock1+'#T147.0#J'+str(lnOffset+7)+'#YT106/2///'+'TO: '+alltrim(sfsship_name)+'#G'
	lcStringBlock1=lcStringBlock1+'#T147.0#J'+str(lnOffset+15)+'#YT106/2///'+allt(sfsship_addr1)+'#G'
	lcStringBlock1=lcStringBlock1+'#T147.0#J'+str(lnOffset+23)+'#YT106/2///'+ ;
		alltrim(sfsship_city)+', '+alltrim(sfsship_state)+'  '+alltrim(sfsship_zip)+'#G'

	*- Header line 3
	lcStringBlock1=lcStringBlock1+'#T50.0#J'+str(lnOffset+15)+'#YT106/2///'+'PO ##:'+allt(po_num)+'#G'
	lcStringBlock1=lcStringBlock1+'#T50.0#J'+str(lnOffset+23)+'#YT106/2///'+'MODE 4'+'#G'
else
	lcStringBlock1=lcStringBlock1+'#M1/1#T66.6#J'+str(lnOffset+5)+'#YT103/2///'+'Notations Order ##:'+'#G'
	lcStringBlock1=lcStringBlock1+'#T33.3#J'+str(lnOffset+5)+'#YT103/2///'+left(allt(str(ord_num)),15)+'#G'

	lcStringBlock1=lcStringBlock1+'#M2/3'
	lcStringBlock1=lcStringBlock1+'#T150.0#J'+str(lnOffset+7)+'#YT106/2///'+'PO ##:'+allt(po_num)+'#G'
endif
	
	*- Header line 4 = detail band header
if liBadSku = 0 then
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+'LN'+'#G'
lcStringBlock1=lcStringBlock1+'#T190.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+'STYLE'+'#G'
	lcStringBlock1=lcStringBlock1+'#T160.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+'COLOR'+'#G'
	lcStringBlock1=lcStringBlock1+'#T135.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+'DEPT'+'#G'
else
        lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT105/2///'+ ;
          'CUSTOMER SKU MISSING - MUST REPRINT BEFORE USING ('+lcBadSku+')#G'
endif
	*- Maximum 9 size headers
	lcStringBlock1=lcStringBlock1+'#M1/3'
	lnIndValidBucket=0
	for lnIndbucket=2 to 9
		lcIndbucket=TRANS(lnIndbucket,"@L 99")
		*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
			lcStringBlock1=lcStringBlock1+ ;
				'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
				padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
			lcStringBlock1=lcStringBlock1+ ;
				'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
				'_____'+'#G'
			lnIndValidBucket=lnIndValidBucket+1
		*endif
	        lcCurSize_code = curPart1.size_code
			lcCurLineSeq = curPart1.line_seq
	endfor
	if (curPart1.siz10_qty>10) then
		lcStringBlock1=lcStringBlock1+ ; 
			'#T40.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
			padl(curPart1.siz10_head,7)+'#G'
		lcStringBlock1=lcStringBlock1+ ; 
			'#T40.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///_____#G'
	endif
	lcStringBlock1=lcStringBlock1+'#M2/3'
	*- Total
	lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+'TOTAL'+'#G'
	lnIndLineBlock1 = lnIndLineBlock1 + 3

	DO WHILE !eof('curPart1') AND lnIndLineBlock1<=MaxNbLineBlock3
		*- Detail line
		*- -----------

		*--- TR 1012146 - 07/27/05 - BD - Modification 7 = print size_code when size_code is changing
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new block of code. Please check the printer control characters
		IF curPart1.size_code<>lcCurSize_code
			
			IF lnIndLineBlock1<=MaxNbLineBlock3-2
				*- go to the next line
				*lnIndLineBlock1=lnIndLineBlock1+1
			ELSE
				*- Exit from loop ==> go back to printing the main page header 
				exit	
			ENDIF
			
			*- Maximum 9 size headers
			lcStringBlock1=lcStringBlock1+'#M1/3'
			lnIndValidBucket=0
			for lnIndbucket=2 to 9
				lcIndbucket=TRANS(lnIndbucket,"@L 99")
				*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
					lcStringBlock1=lcStringBlock1+ ;
						'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
						padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
					lcStringBlock1=lcStringBlock1+ ;
						'#T'+str(140-(lnIndbucket*10))+'#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
						'_____'+'#G'
					lnIndValidBucket=lnIndValidBucket+1
				*endif
			endfor
			if (curPart1.siz10_qty>10) then
				lcStringBlock1=lcStringBlock1+ ; 
					'#T40.0#J'+str(lnOffset+10+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
					padl(curPart1.siz10_head,7)+'#G'
				lcStringBlock1=lcStringBlock1+ ; 
					'#T40.0#J'+str(lnOffset+10+(lnIndLineBlock1*3))+'#YT103/2///_____#G'
			endif
			lcStringBlock1=lcStringBlock1+'#M2/3'
			lnIndLineBlock1=lnIndLineBlock1+3

		ENDIF
		*=== TR 1012146 - BD - End of modification 7		
                lcpoline = vl_poline(pick_num,line_seq)
                lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
                        alltrim(lcpoline)+'#G'		
		
		
		*- Style
		lcStringBlock1=lcStringBlock1+'#T190.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
			padr(style,10)+'#G'
		
		*- Color
		lcStringBlock1=lcStringBlock1+'#T160.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
			color_code+'#G'

		*- Department
		lcStringBlock1=lcStringBlock1+'#T135.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
			padr(department,6)+'#G'

		*- Bucket quantities
		lnTotal_qty=0
		lnIndValidBucket=0
		for lnIndbucket=2 to 9
			lcIndbucket=TRANS(lnIndbucket,"@L 99")
			*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
				lcStringBlock1=lcStringBlock1+ '#T'+str(140-(lnIndbucket*10))+'#J'+ ;
					str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
					padl(allt(str(eval('curPart1.siz'+lcIndbucket+'_qty'))),3)+"#G"
				lnTotal_qty=lnTotal_qty+eval('curPart1.siz'+lcIndbucket+'_qty')
				lnIndValidBucket=lnIndValidBucket+1
			*endif
		endfor
		if (curPart1.siz10_qty > 0) then
			lcStringBlock1 = lcStringBlock1 + '#T40.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///' + ;
				padl(allt(str(curPart1.siz10_qty)),3)+'#G'
			lnTotal_qty = lnTotal_qty+curPart1.siz10_qty
			lnIndValidBucket = lnIndValidBucket + 1
		endif
		
		*- Total
		lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT103/2///'+ ;
			padr(str(lnTotal_qty,6),6)+'#G'
		lnTotalBlockQty = lnTotalBlockQty + lnTotal_qty
	
		lnIndLineBlock1=lnIndLineBlock1+3

	 	*--- TR 1012146 - 07/27/05 - BD - Modification 8 = memorize the current size_code being printed
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new line of code.
		lcCurSize_code=curPart1.size_code
		lcCurLineSeq = curPart1.line_seq
		*=== TR 1012146 - BD - End of modification 8				
	 	skip 1 in curPart1
	ENDDO 

ENDDO		&& End of DO WHILE NOT EOF('curPart1') 

*- Block 1 summary line
lcStringBlock1=lcStringBlock1+'#T60.0#J'+str(lnOffset+11+(lnIndLineBlock1*3))+'#YT105/2///'+ ;
	'TOTAL QTY: '+str(lnTotalBlockQty)+'#G'

lcStringBlock1=lcStringBlock1+'#M1/1#G'

*- Check for end of page

if NOT EOF('curPart1') then
  lcStringBlock1 = lcStringBlock1 + '#Q1#G'
  ??? lcStringBlock1
  ??? '#!A1#IMS203.2/228.6#ERN1'
  lnPageNum = 0
else
  lcStringBlock1 = lcStringBlock1 + '#Q1#G'
  ??? lcStringBlock1
endif

ENDSCAN		&& End of SCAN curGroupByCarton

select (lnOrgArea)


*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

use in CurPart1
use in curGroupByCarton

RETURN .T.


*-----------------------------------------------------------------------------
*- FUNCTION vl_poline(pick_num,line_seq)
*- Returns the region code from zzxcslsr
*- Michael J. Sabal, Notations, Inc. 14 Aug 2007
*-----------------------------------------------------------------------------
FUNCTION vl_poline
PARAMETERS parm_picknum, parm_lineseq

  LOCAL lcSQLQuery, llCount, lcSQLReturn

  lcSQLQuery = "SELECT udfoordd1c FROM zzoordrd WHERE pick_num="+alltrim(str(parm_picknum))+ ;
               " AND line_seq="+alltrim(str(parm_lineseq))
  = v_SQLPrep(lcSQLQuery,'poline','')
  if used('poline') and reccount('poline')>0
    *- We have a valid range style
    lcSQLReturn = poline.udfoordd1c
  else
    lcSQLReturn = ""
  endif

RETURN lcSQLReturn

