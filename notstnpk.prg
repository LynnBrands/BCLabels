*- ----------------------------------------------------------------------------------------------------------------------- -*
*- TR 1009452 - 03/15/05 - Bruno DIEPENDAELE
*- 3/28/05 - EasyPlug formatting added by Michael J. Sabal, Notations.
*- DESCRIPTION: This is a 3 part label designed without the Visual Foxpro label designer. The label is generated by
*- this Foxpro program NOTSTNUC.PRG (orig: NOTPCLUC.PRG)
*- Formatting codes are Avery Dennison EASYPLUG.
*- This label is a 3 part label:
*- PART 1: Carton Pick Slip Internal - this is a carton content list showing the buckets horizontaly
*- PART 2: Carton Pick Slip - this is a carton content list showing buckets and UPCs vertically
*- PART 3: GS1-128 part of the label - Steinmart CORP. (04/03/2009 modified 16 Oct 2014 based on new guidelines)
*- ----------------------------------------------------------------------------------------------------------------------- -*
LOCAL lnIndLineBlock1,lnIndLineBlock2,lnIndLineBlock3
LOCAL lnOrgArea
LOCAL lnPageNum, lnLineNum, lnOffset
LOCAL lcShipTo, lcStore
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
??? "#!A1#IMS203.2/159.0#ERN1"   && 8" wide by 9" long "Page"
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
if lnPageNum = 2 then
  lcStringBlock1 = lcStringBlock1 + '#Q1#G'
  ??? lcStringBlock1
  ??? "#!A1#IMS203.2/159.0#ERN1"   && 8" wide by 9" long "Page"
  lnPageNum = 0
else
  ??? lcStringBlock1
endif
  

*- ***************************************
*- Build PART 3 of the label
*- ***************************************
*- Make all customer specific changes here
*- ***************************************

go top

*- Steinmart

lnPageNum = lnPageNum + 1
lnOffset = (lnPageNum - 1) * 79
lnOffset = lnOffset - 2
lcStringBlock3 = ''

*- Draw lines

lcStringBlock3 = lcStringBlock3 + '#T203.2#J'+str(lnOffset+36)+'#YL0/2/1/203.2#G'
lcStringBlock3 = lcStringBlock3 + '#T166.0#J'+str(lnOffset+0)+'#YL0/1/1/36#G'
lcStringBlock3 = lcStringBlock3 + '#T121.0#J'+str(lnOffset+0)+'#YL0/1/1/36#G'
lcStringBlock3 = lcStringBlock3 + '#T46.6#J'+str(lnOffset+0)+'#YL0/1/1/36#G'
lcStringBlock3 = lcStringBlock3 + '#T139.6#J'+str(lnOffset+36)+'#YL0/1/1/40#G'
lcStringBlock3 = lcStringBlock3 + '#T100.0#J'+str(lnOffset+36)+'#YL0/1/1/40#G'


*- Zone A (Ship from)

lcStringBlock3 = lcStringBlock3 + '#T200.0#J'+str(lnOffset+2)+'#YT106/2///'+'FROM:'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T200.0#J'+str(lnOffset+6)+'#YT103/2///'+'LYNN BRANDS, LLC'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T200.0#J'+str(lnOffset+9)+'#YT103/2///'+'539 JACKSONVILLE RD.'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T200.0#J'+str(lnOffset+12)+'#YT103/2///'+'WARMINSTER, PA'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T180.0#J'+str(lnOffset+15)+'#YT103/2///'+'18974'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T200.0#J'+str(lnOffset+21)+'#YT102/2///'+'SO##:'+alltrim(str(ord_num))+'#G'

*- Zone B (Ship to [DC])

IF AT('#',sfsship_name)>0 AND AT('##',sfsship_name)=0 THEN
  lipos = AT('#',sfsship_name)
  sfsship_name = SUBSTR(sfsship_name,1,lipos-1)+'#'+SUBSTR(sfsship_name,lipos,(LEN(sfsship_name)-lipos)+1)
ENDIF
IF AT('#',sfsship_addr2)>0 AND AT('##',sfsship_addr2)=0 THEN
  lipos = AT('#',sfsship_addr2)
  sfsship_name = SUBSTR(sfsship_addr2,1,lipos-1)+'#'+SUBSTR(sfsship_addr2,lipos,(LEN(sfsship_addr2)-lipos)+1)
ENDIF
lcStringBlock3 = lcStringBlock3 + '#T165.0#J'+str(lnOffset+2)+'#YT106/2///'+'TO:'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T162.0#J'+str(lnOffset+9)+'#YT103/2///'+alltrim(sfsship_name)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T162.0#J'+str(lnOffset+13)+'#YT103/2///'+alltrim(sfsship_addr1)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T162.0#J'+str(lnOffset+17)+'#YT103/2///'+alltrim(sfsship_addr2)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T162.0#J'+str(lnOffset+21)+'#YT103/2///'+ ;
	alltrim(sfsship_city)+', '+alltrim(sfsship_state)+'  '+alltrim(sfsship_zip)+'#G'

*- Zone D (PO / Dept)

lcStringBlock3 = lcStringBlock3 + '#T112.0#J'+str(lnOffset+31)+'#YB15/2O/4.5/6///400'+alltrim(po_num)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T112.0#J'+str(lnOffset+35)+'#YT107/2///'+'(400) '+alltrim(po_num)+'#G'

*- Zone E (Carrier, etc.)

lcStringBlock3 = lcStringBlock3 + '#T10.0#J'+str(lnOffset+6)+'#YT104/2R///VENDOR## 13723#G'
lcStringBlock3 = lcStringBlock3 + '#T10.0#J'+str(lnOffset+12)+'#YT108/2R///'+'DEPT: '+alltrim(department)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T10.0#J'+str(lnOffset+18)+'#YT108/2R///'+'CARTON __1_'+'#G'
lcStringBlock3 = lcStringBlock3 + '#T10.0#J'+str(lnOffset+24)+'#YT108/2R///'+'OF __1_'+'#G'

*- Zone G (Mark for store # [UCC128])

lcStore = ALLTRIM(store)
IF LEN(lcStore)<4 then
  lcStore = '0'+lcStore
ENDIF
IF LEN(lcStore)>4 then
  lcStore = SUBSTR(lcStore,2,4)
ENDIF
lcStringBlock3 = lcStringBlock3 + '#T190.0#J'+STR(lnOffset+71)+'#YB15/2O/4.5/6///91'+ALLTRIM(lcStore)+'#G'
lcStringBlock3 = lcStringBlock3 + '#T180.0#J'+STR(lnOffset+75)+'#YT107/2///(91)'+ALLTRIM(lcStore)+'#G'

*- Zone H (Mark for store # [text])

lcStore = SUBSTR(lcStore,LEN(lcStore)-2,3)
lcStringBlock3 = lcStringBlock3 + '#M3/3#T136.0#J'+str(lnOffset+66)+'#YT109/2///'+alltrim(lcStore)+'#G#M1/1'

*- Zone I (Carton # [UCC128])

lcStringBlock3 = lcStringBlock3 + '#T89.0#J'+str(lnOffset+75)+'#YB15/2M/5.5/6///'+alltrim(carton_num)+'#G'

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



