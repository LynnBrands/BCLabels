*- --------------------------------------------------------------------
*- 4/29/05 - Michael J. Sabal, Notations
*- DESCRIPTION: Easyplug hangtag to be printed from within Blue
*- Cherry's Label Launcher facility.
*-
*- NOTHTSTD.PRG
*- Must be used from within the "Preticket Production Detail Label" shell
*- 
*- --------------------------------------------------------------------

LOCAL lnOrgArea, sout
LOCAL szBucket, szName, szQty

lnOrgArea = SELECT()
lcOrgAlias = ALIAS()

*- ------------------------------
*- TURN ON the printer
*- ------------------------------
*SET DEVICE TO PRINT
*SET PRINTER TO NAME GetPrinter()

*- Group by PRODUCTION ORDER #
select * from (lcOrgAlias) into cursor curPtix group by prod_num, style, color_code, size_name ORDER BY sizebucket

SCAN

  sout = ""
  
  && Print hangtag separator
  
  = MESSAGEBOX("Starting separator",0,"1")

  sout = "#!A1#IMS89/102#PR10#G#HV90#ER#R0/0#M1/1" + ;
	   "#T29.0#J66.0#YT107/2///"+ALLTRIM(STR(CEILING(sizeqty*1.1)))+"#G"
  sout = sout + "#Q1/#G"
*	   "#T0001#J0006#YL0/0/5/12#M1/1#T38.0#J22.0#YT101/2///STYLE#G" + ;
*	   "#M1/1#T29.0#J22.0#YT107/2///"+ALLTRIM(style)+"#G" + ;
*	   "#M1/1#T38.0#J33.0#YT101/2///COL#G#M1/1" + ;
*	   "#T29.0#J33.0#YT107/2///"+ALLTRIM(color_code)+"#G" + ;
*	   "#M1/1#T38.0#J44.0#YT101/2///SIZE#G#M1/1" + ;
*	   "#T29.0#J44.0#YT107/2///"+ALLTRIM(size_name)+"#G" + ;
*	   "#M1/1#T38.0#J55.0#YT101/2///CUT###G#M1/1" + ;
*	   "#T29.0#J55.0#YT107/2///"+ALLTRIM(prod_num)+"#G" + ;
*	   "#M1/1#T38.0#J66.0#YT101/2///QNTY#G#M1/1" + ;

  = MESSAGEBOX("Starting separator",0,"2")

*	   "#T38.0#J22.0#YT101/2///STYLE#G" + ;
*	   "#M1/1#T29.0#J22.0#YT107/2///"+ALLTRIM(style)+"#G" + ;
*	   "#M1/1#T38.0#J33.0#YT101/2///COL#G#M1/1" + ;
*	   "#T29.0#J33.0#YT107/2///"+ALLTRIM(color_code)+"#G" + ;
*	   "#M1/1#T38.0#J44.0#YT101/2///SIZE#G#M1/1" + ;
*	   "#T29.0#J44.0#YT107/2///"+ALLTRIM(size_name)+"#G" + ;
*	   "#M1/1#T38.0#J55.0#YT101/2///CUT###G#M1/1" + ;
*	   "#T29.0#J55.0#YT107/2///"+ALLTRIM(prod_num)+"#G" + ;
*	   "#M1/1#T38.0#J66.0#YT101/2///QNTY#G#M1/1" + ;
  
  sout = sout + "#!A1#IMS89/102#PR10#G#HV90#ER#R0/0" + ;
	   "#T29.0#J66.0#YT107/2///"+ALLTRIM(STR(CEILING(sizeqty*1.1)))+"#G"
  sout = sout + "#Q1/#G"

  && Begin AD control header

  sout = sout + "#!A1#IMS89/102#PR9#G#HV90#ER#R0/0#M1/1"

  && Header information

  sout = sout + "#T82.0#J10.0.#YT101/2///FOR NOTATIONS #G#T83.0#J12.5" + ;
	   "#YT101/2///INTERNAL USE ONLY#G"

  && Style

  sout = sout + "#T37.0#J18.5#YT100/2///STYLE#G#T37.0#J15.5#YT106/2///" + ;
	   ALLTRIM(style) + "#G"
  sout = sout + "#T81.0#J20.0#YT101/2///STYLE#G#T73.0#J20.0#YT106/2///" + ;
	   ALLTRIM(style) + "#G"

  && Color

  sout = sout + "#T12.0#J18.5#YT100/2///COLOR#G#T12.0#J15.5#YT106/2///" + ;
	   ALLTRIM(color_code) + "#G"
  sout = sout + "#T81.0#J27.0#YT101/2///COL#G#T73.0#J27.0#YT106/2///" + ;
	   ALLTRIM(color_code) + "#G"

  && UPC number

  sout = sout + "#T35.0#J43.0#YB2/2M/17/3 ///"+sfsupc_chkdigit+"#G" + ;
  	"#T80.0#J90.0#YB2/2M/10/3 ///"+sfsupc_chkdigit+"#G"

  && Size

  sout = sout + "#T30.0#J52.0#YT106/2///SIZE " + ALLTRIM(size_name)+"#G"
  sout = sout + "#T81.0#J34.0#YT101/2///SIZE#G#T73.0#J34.0#YT106/2///" + ;
	   ALLTRIM(size_name) + "#G"

  && Label code

  sout = sout + "#T81.0#J41.0#YT101/2///LABEL#G#T73.0#J41.0#YT106/2///" + ;
	   ALLTRIM(lbl_code) + "#G"

  && Department / class / mic / message

  if ALLTRIM(customer)<>"BCMOO" then
    if not empty(adgrp_name) then
      sout = sout + "#T21.0#J55.0#YT101/2M///"+ALLTRIM(adgrp_name)+"#G"
      sout = sout + "#T65.0#J58.0#YT101/2M///"+ALLTRIM(adgrp_name)+"#G"
    else
      if not empty(department) then
        sout = sout + "#T37.0#J58.0#YT101/2///DEPT  "+alltrim(department)+"#G"
        if alltrim(customer)="KOHLS" and not empty(class) then
          sout = sout + "#T21.0#J58.0#YT101/2///MC "+substr(class,1,2)+"#G"
          sout = sout + "#T05.0#J58.0#YT101/2R///SC "+substr(class,3,2)+"#G"
          sout = sout + "#T72.0#J68.0#YT101/2///"+alltrim(department)+"D"+ ;
		alltrim(class)+"C#G"
        else
          sout = sout + "#T72.0#J68.0#YT101/2///"+alltrim(department)+"D#G"
        endif && Kohls
      endif && department
    endif && adgrp_name
  endif && customer

  && Production number

  sout = sout + "#T81.0#J48.0#YT101/2///CUT###G#T73.0#J48.0#YT106/2///" + ; 
	   STR(prod_num) + "#G"

  && Retail price

  sout = sout + "#T31.5#J68.0#YT107/2///$" + transform(ret_price,"999.99") + "#G"
  sout = sout + "#T73.0#J64.0#YT107/2///" + transform(ret_price,"999.99") + "R#G"

  && End the label

  sout = sout + "#Q" + ALLTRIM(STR(CEILING(sizeqty*1.1)))+"#G"

*  ??? sout
*  SET PRINTER TO	 && Flush Printer
= MESSAGEBOX(sout,0,"99")

ENDSCAN

*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

use in curPtix

RETURN .T.
