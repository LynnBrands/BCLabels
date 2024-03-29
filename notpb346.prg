*- ----------------------------------------------------------------------------------------------------------------------- -*
*- TR 1009452 - 03/15/05 - Bruno DIEPENDAELE
*- 3/28/05 - EasyPlug formatting added by Michael J. Sabal, Notations.
*- DESCRIPTION: This is a 3 part label designed without the Visual Foxpro label designer. The label is generated by
*- this Foxpro program NOTBLLUC.PRG (orig: NOTPCLUC.PRG)
*- Formatting codes are Avery Dennison EASYPLUG.
*- This label is a 3 part label:
*- PART 1: Carton Pick Slip Internal - this is a carton content list showing the buckets horizontaly
*- PART 2: Carton Pick Slip - this is a carton content list showing buckets and UPCs vertically
*- PART 3: UCC128 part of the label - STAGE / PEEBLES (revised 26 November 2012)
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
lnSKUCount = 0
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
		lnSKUCount = lnSKUCount + 1
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
??? "#!A1#IMS102.5/152.4#ERN1"   && 8" wide by 9" long "Page"
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
	lnOffset = (lnPageNum - 1) * 79
	isPrepack = .F.
	lnPrepack_qty=eval('curPart1.siz01_qty')
	if lnPrepack_qty > 0 then
		isPrepack = .T.
	endif

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
		lcStringBlock1=lcStringBlock1+'#T180.0#J'+str(lnOffset+15)+'#YT103/2///'+left(size_code,3)+'#G'
	ENDIF
	*=== TR 1012146 - BD - End of modification 6

	*- Header line 4 = detail band header
	*lcStringBlock1=lcStringBlock1+SPACE(5)
	lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+18)+'#YT102/2///'+'Style'+'#G'
	lcStringBlock1=lcStringBlock1+'#T182.0#J'+str(lnOffset+18)+'#YT102/2///'+'Color'+'#G'
	lcStringBlock1=lcStringBlock1+'#T170.0#J'+str(lnOffset+18)+'#YT102/2///'+'Price'+'#G'
	lcStringBlock1=lcStringBlock1+'#T160.0#J'+str(lnOffset+18)+'#YT102/2///'+'Label'+'#G'
	if isPrepack then
		lcStringBlock1=lcStringBlock1+'#T133.3#J'+str(lnOffset+18)+'#YT102/2///'+'Pack description'+'#G'
		*- Total
		lcStringBlock1=lcStringBlock1+'#T40.0#J'+str(lnOffset+18)+'#YT102/2///'+'Total ## of Prepacks'+'#G'
		lcStringBlock1=lcStringBlock1+'#T13.3#J'+STR(lnOffset+18)+'#YT102/2///'+'Retail'+'#G'
	else
		*- Maximum 9 size headers
		lnIndValidBucket=0
		for lnIndbucket=2 to 10
			lcIndbucket=TRANS(lnIndbucket,"@L 99")
			*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
				lcStringBlock1=lcStringBlock1+ ;
					'#T'+str(173.3-(lnIndbucket*13.3))+'#J'+str(lnOffset+18)+'#YT102/2///'+ ;
					padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
				lnIndValidBucket=lnIndValidBucket+1
			*endif
		endfor
		*- Total
		lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+18)+'#YT102/2///'+'Total'+'#G'
		lcStringBlock1=lcStringBlock1+'#T13.3#J'+STR(lnOffset+18)+'#YT102/2///'+'Retail'+'#G'
		*- Ship To
		*lcStringBlock1=lcStringBlock1+'Ship To:'+SPACE(3)+CRLF	
	endif


	lnIndLineBlock1=0
	DO WHILE !eof('curPart1') AND lnIndLineBlock1<=MaxNbLineBlock1
		if isPrepack then
			*- Get prepack header --*
			lcSQLPackQuery = "SELECT * FROM zzxppakh WHERE division='"+allt(Division)+"' AND size_code='"+ ;
				allt(size_code)+"' AND ppk_code='"+dimension+"'"
			= v_SQLPrep(lcSQLPackQuery,'prepack','')
			if used('prepack') and reccount('prepack')>0 then
				pack_qty = prepack.pack_qty
				pack_description = prepack.ppk_desc
			else
				pack_qty = 1
				pack_description = 'PREPACK'
			endif
			lnPrepack_qty=eval('curPart1.siz01_qty')
			lnNum_Packs = lnPrepack_qty / pack_qty
			lnTotal_qty = lnPrepack_qty
		endif

		*- Detail line
		*- -----------
		
		*--- TR 1012146 - 07/27/05 - BD - Modification 7 = print size_code when size_code is changing
		*--- Bruno DIEPENDAELE -> Mike Sabal = This is a new block of code. Please check the printer control characters
		IF curPart1.size_code<>lcCurSize_code and not isPrepack then
			
			IF lnIndLineBlock1<=MaxNbLineBlock1-2
				*- go to the next line
				lnIndLineBlock1=lnIndLineBlock1+1
			ELSE
				*- Exit from loop ==> go back to printing the main page header 
				exit	
			ENDIF
			lnIndLineBlock1=lnIndLineBlock1-1
			
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
			for lnIndbucket=2 to 10
				lcIndbucket=TRANS(lnIndbucket,"@L 99")
				*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
					lcStringBlock1=lcStringBlock1+ ;
						'#T'+str(173.3-(lnIndbucket*13.3))+'#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT102/2///'+ ;
						padl(eval('curPart1.siz'+lcIndbucket+'_head'),7)+'#G'
					lnIndValidBucket=lnIndValidBucket+1
				*endif
			endfor
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

		if isPrepack then
			*- Pack description
			lcStringBlock1=lcStringBlock1+'#T133.3#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
				allt(pack_description)+'#G'
				
			*- Total
			lcStringBlock1=lcStringBlock1+'#T40.0#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
				padl(allt(str(lnNum_Packs)),7)+'#G'
		else
			*- Bucket quantities
			lnTotal_qty=0
			lnIndValidBucket=0
			for lnIndbucket=2 to 10
				lcIndbucket=TRANS(lnIndbucket,"@L 99")
				*if eval('curPart1.siz'+lcIndbucket+'_qty')>0 and lnIndValidBucket<10
					lcStringBlock1=lcStringBlock1+ '#T'+str(173.3-(lnIndbucket*13.3))+'#J'+ ;
						str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
						padl(allt(str(eval('curPart1.siz'+lcIndbucket+'_qty'))),7)+"#G"
					lnTotal_qty=lnTotal_qty+eval('curPart1.siz'+lcIndbucket+'_qty')
					lnIndValidBucket=lnIndValidBucket+1
				*endif
			endfor
			
			*- Total
			lcStringBlock1=lcStringBlock1+'#T26.6#J'+str(lnOffset+21+(lnIndLineBlock1*4))+'#YT103/2///'+ ;
				padr(str(lnTotal_qty,6),6)+'#G'
		endif
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

IF AT('#',lcShipTo)>0 AND AT('##',lcShipTo)=0 THEN
  lipos = AT('#',lcShipTo)
  lcShipTo = SUBSTR(lcShipTo,1,lipos-1)+'#'+SUBSTR(lcShipTo,lipos,(LEN(lcShipTo)-lipos)+1)
ENDIF
*- Block 1 summary line
if not isPrepack then
	lcStringBlock1=lcStringBlock1+'#T33.3#J'+str(lnOffset+25+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
		'Total: '+str(lnTotalBlockQty)+'#G'
endif
if isPrepack then
	lcStringBlock1 = lcStringBlock1+'#M2/2#T100.0#J'+str(lnOffset+65)+'#YT109/2M///PREPACK#G#M1/1'
endif 
lcStringBlock1=lcStringBlock1+'#T200.0#J'+str(lnOffset+25+(lnIndLineBlock1*4))+'#YT106/2///'+ ;
	'Ship To: '+ alltrim(lcShipTo) + '#G'
if lnPageNum = 3 then
  lcStringBlock1 = lcStringBlock1 + '#Q1#G'
  *-internal packing list commented out lcStringBlock1
  *-??? lcStringBlock1
  *-??? "#!A1#IMS203.2/159.0#ERN1"   && 8" wide by 9" long "Page"
  lnPageNum = 0
else
  *-??? lcStringBlock1
endif
  

*- ***************************************
*- Build PART 3 of the label
*- ***************************************
*- Make all customer specific changes here
*- ***************************************

go top

*- STAGE & PEEBLES (revised 26 November 2012)
*- There are three different versions of this label: Bulk pack, pre-pack bulk, and pack-by store.
*- Prepack bulk will not be supported at this time.

*-lnPageNum = lnPageNum + 1
lnPageNum = 1
lnOffset = (lnPageNum - 1) * 79
lcStringBlock3 = ''
if alltrim(location)=='WMELKO' then
 *- lnOffset = lnOffset - 2
endif

*- Draw lines


*-lcStringBlock3 = lcStringBlock3 + '#T101.6#J'+str(lnOffset+0)+'#YL0/1/1/75#G'
*-lcStringBlock3 = lcStringBlock3 + '#T101.6#J'+str(lnOffset+36)+'#YL0/2/1/101.6#G'
lcStringBlock3 = lcStringBlock3 + '#T101.6#J'+str(lnOffset+26)+'#YL0/2/1/101.6#G'
lcStringBlock3 = lcStringBlock3 + '#T101.6#J'+str(lnOffset+52)+'#YL0/2/1/101.6#G'
lcStringBlock3 = lcStringBlock3 + '#T68.3#J'+str(lnOffset+0)+'#YL0/1/1/26#G'
lcStringBlock3 = lcStringBlock3 + '#T39.7#J'+str(lnOffset+26)+'#YL0/1/1/26#G'
lcStringBlock3 = lcStringBlock3 + '#T51.5#J'+str(lnOffset+0)+'#YL0/1/1/36#G'
lcStringBlock3 = lcStringBlock3 + '#T101.6#J'+str(lnOffset+78)+'#YL0/2/1/101.6#G'
lcStringBlock3 = lcStringBlock3 + '#T101.6#J'+str(lnOffset+114)+'#YL0/2/1/101.6#G'

*- Zone A (Ship from) 25.4mm H x 31.75mm W  Text size 8-10pt
*- Normally, PA address always appears.  PLG address must appear for CA shipments.

lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+3)+'#YT106/2///'+'FROM:'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+7)+'#YT103/2///'+'LYNN BRANDS, LLC'+'#G'
IF alltrim(location)=='WPAFG' THEN
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+10)+'#YT103/2///'+'539 JACKSONVILLE RD.'+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+13)+'#YT103/2///'+'WARMINSTER, PA'+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+16)+'#YT103/2///'+'              18974'+'#G'
ENDIF
IF alltrim(location)=='WMELKO' THEN
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+10)+'#YT103/2///'+'140 N. ORANGE AVENUE'+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+13)+'#YT103/2///'+'CITY OF INDUSTRY, CA'+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+16)+'#YT103/2///'+'              91744'+'#G'
ENDIF

*- Zone B (Ship to [DC]) 25.4mm H x 69.85mm W Text size 12-14pt

IF AT('#',sfsship_name)>0 AND AT('##',sfsship_name)=0 THEN
  lipos = AT('#',sfsship_name)
  sfsship_name = SUBSTR(sfsship_name,1,lipos-1)+'#'+SUBSTR(sfsship_name,lipos,(LEN(sfsship_name)-lipos)+1)
ENDIF
lcStringBlock3 = lcStringBlock3 + '#T65.0#J'+str(lnOffset+3)+'#YT107/2///'+'TO:'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T63.0#J'+str(lnOffset+9)+'#YT107/2///'+alltrim(sfsship_name)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T63.0#J'+str(lnOffset+13)+'#YT107/2///'+alltrim(sfsship_addr1)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T63.0#J'+str(lnOffset+17)+'#YT107/2///'+alltrim(sfsship_addr2)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T63.0#J'+str(lnOffset+21)+'#YT107/2///'+ ;
	alltrim(sfsship_city)+', '+alltrim(sfsship_state)+'  '+alltrim(sfsship_zip)+'#G'

*- Zone C (Ship to Post [UCC128]) 25.4mm H x 63.5mm W

IF len(ALLTRIM(sfsship_zip))>5
  lcStringBlock3 = lcStringBlock3 + '#T86.0#J'+str(lnOffset+46)+'#YB15/2O/2.5/5///420'+substr(sfsship_zip,1,5)+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T76.0#J'+str(lnOffset+50)+'#YT107/2///(420)'+substr(sfsship_zip,1,5)+'#G'
ELSE
  lcStringBlock3 = lcStringBlock3 + '#T86.0#J'+str(lnOffset+46)+'#YB15/2O/2.5/5///420'+alltrim(sfsship_zip)+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T76.0#J'+str(lnOffset+50)+'#YT107/2///(420)'+alltrim(sfsship_zip)+'#G'
ENDIF

*- Zone D (Carrier, etc.) 

*- Zone E (Trading Partner Information) 25.4mm H x 101.6mm W Text size 8-10pt
*- For Bulk: PO, Dept, Size, Color, Style, Quantity, X of Y
*- For Prepack Bulk: PO, Dept, Color, Style, Prepack Breakdown, X of Y, Quantity
*- For Pack by store: PO, Dept, SO#, X of Y, Total Qty, Weight

lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+56)+'#YT103/2///'+'PO: '+alltrim(po_num)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T68.0#J'+str(lnOffset+56)+'#YT103/2///'+'DEPT: '+alltrim(department)+'#G'
*- lcStringBlock3 = lcStringBlock3 + '#T48.0#J'+str(lnOffset+72)+'#YT104/2///'+'CARTON ____ OF ____#G'
if lnSKUCount = 1 and not isPrepack then    && Bulk pack
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+64)+'#YT103/2///'+'STYLE: '+alltrim(style)+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T68.0#J'+str(lnOffset+64)+'#YT103/2///'+'COLOR: '+alltrim(sfscolor_name)+'#G'
  *- lcStringBlock3 = lcStringBlock3 + '#T38.0#J'+str(lnOffset+64)+'#YT103/2///'+'SIZE: '+alltrim(size_desc)+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+70)+'#YT103/2///'+'SIZE: '+alltrim(size_desc)+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T38.0#J'+str(lnOffset+56)+'#YT103/2///'+'QTY: '+alltrim(str(lnTotalBlockQty))+'#G'
ELSE 
if alltrim(store)<>'00601' and alltrim(store)<>'05099' and alltrim(store)<>'05899' then    && Pack by store
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+64)+'#YT103/2///'+'SO##:'+alltrim(str(ord_num))+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T68.0#J'+str(lnOffset+64)+'#YT103/2///'+'WEIGHT:'+alltrim(str(carton_wgt))+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T38.0#J'+str(lnOffset+56)+'#YT103/2///'+'QTY: '+alltrim(str(lnTotalBlockQty))+'#G'
else  && Pre-pack bulk
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+60)+'#YT103/2///'+'STYLE: '+alltrim(style)+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T68.0#J'+str(lnOffset+60)+'#YT103/2///'+'COLOR: '+alltrim(sfscolor_name)+'#G'
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+64)+'#YT103/2///SIZE#G'
  lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+68)+'#YT103/2///QTY#G'
  select curPart1
  go top
	for lnIndbucket=2 to 9
		lcIndbucket=TRANS(lnIndbucket,"@L 99")
		lcStringBlock3=lcStringBlock3+ ;
			'#T'+str(78-((lnIndbucket-2)*10))+'#J'+str(lnOffset+64)+'#YT103/2///'+ ;
			padl(eval('curPart1.siz'+lcIndbucket+'_head'),5)+'#G'
	endfor
	if isPrepack then
		getPPKExplosion(division,size_code,dimension)
	else
		getSizeExplosion(pick_num,line_seq)
	endif
	if explarr[1]>-1 then
		for lnIndbucket=2 to 9
			if explarr[lnIndbucket] > 0 then
				lcIndbucket=TRANS(lnIndbucket,"@L 99")
				lcStringBlock3=lcStringBlock3+ ;
					'#T'+str(78-((lnIndbucket-2)*10))+'#J'+str(lnOffset+68)+'#YT103/2///'+ ;
					alltrim(str(explarr[lnIndbucket]))+'#G'
			endif
		endfor
		lcStringBlock3 = lcStringBlock3 + '#T98.0#J'+str(lnOffset+72)+'#YT103/2///PACK QTY: '+str(explarr[1])+'#G'
		lcStringBlock3 = lcStringBlock3 + '#T38.0#J'+str(lnOffset+56)+'#YT103/2///'+'QTY: '+alltrim(str(lnTotalBlockQty/explarr[1]))+'#G'
	endif
endif
endif
*- Zone F (if not combined with Zone E)

*- Zone G (Mark for store # [UCC128])
*- 4 March 2009: SSI Routing guide has changed the format to 5 digits
*- but they don't have any clue about the GS1 requirement of an even number
*- of digits for app code 91 in the barcode.  We'll leave it at 4.
lcBCStore = ALLTRIM(store)
lcStore = alltrim(store)
DO WHILE LEN(lcStore) < 5 
  lcStore = '0'+lcStore
ENDDO 
&& lcStringBlock3 = lcStringBlock3 + '#T93.0#J'+STR(lnOffset+102)+'#YB15/2O/3/5///91'+substr(alltrim(lcStore),2)+'#G'
&& lcStringBlock3 = lcStringBlock3 + '#T85.0#J'+STR(lnOffset+106)+'#YT107/2///(91)'+alltrim(lcStore)+'#G'

*- Zone H (Mark for store # [text])

lcStringBlock3 = lcStringBlock3 + '#T50.0#J'+str(lnOffset+82)+'#YT105/2///'+'STORE:'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T47.0#J'+str(lnOffset+100)+'#M2/3#YT109/2///'+alltrim(store)+'#G#M1/1'
if alltrim(store)<>'00601' and alltrim(store)<>'05099' and alltrim(store)<>'05899' then    && Pack by store
	lcStringBlock3 = lcStringBlock3 + '#T50.0#J'+str(lnOffset+106)+'#YT106/2///'+alltrim(sfsmark_city)+', '+alltrim(sfsmark_state)+'  '+alltrim(sfsmark_zip)+'#G'
else && Pre-pack bulk
	lcStringBlock3 = lcStringBlock3 + '#T50.0#J'+str(lnOffset+106)+'#YT106/2///'+alltrim(sfsship_city)+', '+alltrim(sfsship_state)+'  '+alltrim(sfsship_zip)+'#G'
endif
*- Zone I (Carton # [UCC128])

lcStringBlock3 = lcStringBlock3 + '#T93.0#J'+str(lnOffset+151)+'#YB15/2M/5.25/6///'+alltrim(carton_num)+'#G'

*- End

lcStringBlock3 = lcStringBlock3 + '#Q1#G'
??? lcStringBlock3

ENDSCAN		&& End of SCAN curGroupByCarton

select (lnOrgArea)


*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

use in CurPart1

RETURN .T.

*-----------------------------------------------------------------------------
*- FUNCTION getPPKExplosion(division, size_code, dimension)
*-----------------------------------------------------------------------------
PROCEDURE getPPKExplosion
PARAMETERS Division, size_code, dimension

LOCAL lcSQL
PUBLIC ARRAY explarr(10)

	explarr[1] = -1

	lcSQL = "SELECT * FROM zzxppakd WHERE division='"+allt(Division)+"' AND size_code='"+ ;
		allt(size_code)+"' AND ppk_code='"+dimension+"'"
	
	= v_SQLPrep(lcSQL,'explrec','')
  if used('explrec') and reccount('explrec')>0
    *- We have a valid size explosion
	explarr[1] = explrec.pack_total
	explarr[2] = explrec.pack02_qty
	explarr[3] = explrec.pack03_qty
	explarr[4] = explrec.pack04_qty
	explarr[5] = explrec.pack05_qty
	explarr[6] = explrec.pack06_qty
	explarr[7] = explrec.pack07_qty
	explarr[8] = explrec.pack08_qty
	explarr[9] = explrec.pack09_qty
	explarr[10] = explrec.pack10_qty
  endif

RETURN 

*-----------------------------------------------------------------------------
*- FUNCTION getSizeExplosion(pick_num,line_seq)
*-----------------------------------------------------------------------------
PROCEDURE getSizeExplosion
PARAMETERS pick_num, line_seq

LOCAL lcSQL
PUBLIC ARRAY explarr(10)

	explarr[1] = -1

	lcSQL = "select x.* from zzoordrd pd " + ;
	"join zzoordrd bd on pd.MAN_BULK=bd.ord_num and pd.color_code=bd.color_code and pd.style=bd.style " + ;
	"join zzxszexr x on bd.size_expl=x.size_expl " + ;
	"where pd.pick_num = "+str(pick_num)+" AND pd.line_seq="+str(line_seq)
	
	= v_SQLPrep(lcSQL,'explrec','')
  if used('explrec') and reccount('explrec')>0
    *- We have a valid size explosion
	explarr[1] = explrec.expl_qty
	explarr[2] = explrec.size02_qty
	explarr[3] = explrec.size03_qty
	explarr[4] = explrec.size04_qty
	explarr[5] = explrec.size05_qty
	explarr[6] = explrec.size06_qty
	explarr[7] = explrec.size07_qty
	explarr[8] = explrec.size08_qty
	explarr[9] = explrec.size09_qty
	explarr[10] = explrec.size10_qty
  endif

RETURN 
