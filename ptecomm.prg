*- ----------------------------------------------------------------------
*- Plain Text label for Catherine's "E-Commerce Goods" stickers
*- 2/8/2006 - Michael J. Sabal
*- Using Avery Dennison EasyPlug
*- Intended for use on 4 1/8"x2 1/8" label stock
*- ----------------------------------------------------------------------
lnOrgArea = SELECT()
lcOrgAlias = ALIAS()

select * from (lcOrgAlias) into cursor curLabel

SCAN

  lcStringBlock = ''
  lcStringBlock = lcStringBlock + '#!A1#IMS105/54#PR9#G#HV90#ER#R0/0#M1/1'
  lcStringBlock = lcStringBlock + '#T95.0#J30.0#YT109/2///'+'E-COMMERCE GOODS'+'#G'
  lcStringBlock = lcStringBlock + '#Q'+STR(lbl_qty)+'/#G'
  ??? lcStringBlock
  EXIT

ENDSCAN

select (lnOrgArea)

*- Turn off the printer
SET DEVICE TO SCREEN
SET PRINTER TO

USE IN curLabel

RETURN .T.
