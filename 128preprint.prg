LOCAL lnOrgArea

#DEFINE CRLF CHR(13)+CHR(10)

lnOrgArea=SELECT()
*lcOrgAlias=ALIAS()
*lcOrgAlias = tcFinal

*- Send data to output
*set device to screen
*set device to file c:\temp\notrlzuc.txt


*SELECT * FROM (lcOrgAlias) INTO CURSOR curCartons
*USE IN curCartons

*GO TOP

SCAN

lcStringBlock3 =  '#!A1#IMS102/76#G#HV90#ER#R0/0#M1/1'   && 4"x3" sticker
lcStringBlock3 = lcStringBlock3 + '#T93.0#J10.0#YT108/2///'+division+'#G'
lcStringBlock3 = lcStringBlock3 + '#T93.0#J65.0#YB15/2M/5.5/6///'+alltrim(sfsupc2)+'#G'
lcStringBlock3 = lcStringBlock3 + '#Q1#G'
??? lcStringBlock3

ENDSCAN		&& End of SCAN lcOrgAlias

select (lnOrgArea)


*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

RETURN .T.


