*- ----------------------------------------------------------------------
*- Preprinted pallet label
*- 1/30/2006 - Michael J. Sabal
*- Using Avery Dennison EasyPlug
*- Intended for use on 4"x3" label stock
*- ----------------------------------------------------------------------

lnOrgArea = SELECT()
lcOrgAlias = ALIAS()

select * from (lcOrgAlias) into cursor curPallet

SCAN
  lcStringBlock = ''
  lcStringBlock = lcStringBlock + '#!A1#IMS102/76#PR9#G#HV90#ER#R0/0#M1/1'
  lcStringBlock = lcStringBlock + '#T64.0#J15.0#YT109/2///'+ALLTRIM(location)+'#G'
  if len(ALLTRIM(pall_num))>7 then
    lcpall_num=substr(ALLTRIM(pall_num),len(ALLTRIM(pall_num))-6)
  else
    lcpall_num=alltrim(pall_num)
  ENDIF
  DO WHILE (LEN(lcpall_num)<7)
    lcpall_num = '0'+lcpall_num
  ENDDO     
  
* #YB13 = I2of5 (2.5:1)
* #YB7 = I3of9 (2.0:1)
* #YB16 = I3of9 (3.0:1)
  lcStringBlock = lcStringBlock + '#T65.0#J25.0#YT109/2///'+ALLTRIM(lcpall_num)+'#G'
  lcStringBlock = lcStringBlock + '#T90.0#J60.0#YB7/2O/5/8///'+ALLTRIM(lcpall_num)+'#G'
  lcStringBlock = lcStringBlock + '#T90.0#J55.0#YB7/2O/5/8///'+ALLTRIM(lcpall_num)+'#G'
  lcStringBlock = lcStringBlock + '#T90.0#J50.0#YB7/2O/5/8///'+ALLTRIM(lcpall_num)+'#G'
  lcStringBlock = lcStringBlock + '#T90.0#J45.0#YB7/2O/5/8///'+ALLTRIM(lcpall_num)+'#G'
  lcStringBlock = lcStringBlock + '#T90.0#J40.0#YB7/2O/5/8///'+ALLTRIM(lcpall_num)+'#G'
  lcStringBlock = lcStringBlock + '#Q1#G'
  ??? lcStringBlock
ENDSCAN

select (lnOrgArea)

*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

use in curPallet

RETURN .T.
