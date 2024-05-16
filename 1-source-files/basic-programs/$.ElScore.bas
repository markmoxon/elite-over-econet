REM ElScore - Scoreboard for Elite over Econet
REM By Mark Moxon
:
DIM order%(19),name$(19),credits%(19),kills%(19),deaths%(19),machine%(19)
DIM condition%(19),legal%(19),network%(19),station%(19)
DIM M$(3):M$(0)="B+":M$(1)="Ma":M$(2)="Sp":M$(3)="Bb"
DIM C$(3):C$(0)=CHR$(151):C$(1)=CHR$(146):C$(2)=CHR$(147):C$(3)=CHR$(145)
DIM L$(2):L$(0)=CHR$(130)+"Cln":L$(1)=CHR$(131)+"Off":L$(2)=CHR$(129)+"Fug"
DIM cblock% 40,tblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA
port%=0:fstation%=0:fnetwork%=0:fport%=0:next%=0:sort%=0:cmdr%=-1:quit%=FALSE
PROCgetStationNumber
:
ON ERROR PROCerror
MODE 7
*FX4,1
*FX200,1
PROCstartMenu
VDU23;8202;0;0;0;
PROCprintHeader
PROChighlightSort
REPEAT
  PROCreceive
  IF next%>0 THEN cmdr%=FNfindCmdr($rxbuffer%,cblock%?4,cblock%?3) ELSE cmdr%=-1
  IF cmdr%=-1 AND next%<20 THEN cmdr%=next%:order%(next%)=cmdr%:next%=next%+1
  IF cmdr%<>-1 THEN dosort%=FNupdateCmdr(cmdr%) ELSE dosort%=FALSE
  IF next%>1 AND dosort% THEN PROCsort:PROCprintTable ELSE PROCprintRow(cmdr%)
  IF fstation%>0 AND fport%>0 THEN PROCforward
UNTIL FALSE
END
:
DEF PROCerror
  REPORT
  PRINT " at line ";ERL
  PROCend
ENDPROC
:
DEF PROCend
  *FX200,1
  *FX4,0
  END
ENDPROC
:
DEF PROCreceive
  rxcb_number%=FNopenReceiveBlock(port%)
  :
  REM Wait for reception
  REPEAT
    A%=&33
    X%=rxcb_number%
    U%=USR OSBYTE
    IF INKEY(-82) THEN PROCswapSort
    IF INKEY(-102) THEN PROCmenu:PROCprintHeader:PROCprintTable
  UNTIL (U% AND &8000)<>0
  :
  REM Read control block back
  X%=cblock%:Y%=cblock% DIV 256
  A%=&11
  ?cblock%=rxcb_number%
  CALL OSWORD
  :
  PROCdeleteReceiveBlock
ENDPROC
:
DEF PROCforward
  ?cblock%=&80
  cblock%?1=fport%
  cblock%?2=fstation%
  cblock%?3=fnetwork%
  cblock%!4=rxbuffer%
  cblock%!8=rxbuffer%+20
  X%=cblock%:Y%=cblock% DIV 256
  A%=16
  CALL OSWORD
ENDPROC
:
DEF FNupdateCmdr(cm%)
  ch%=FALSE
  name$(cm%)=$rxbuffer%
  legal%(cm%)=rxbuffer%?8
  condition%(cm%)=rxbuffer%?9
  newkills%=rxbuffer%?10
  IF sort%=0 AND newkills%<>kills%(cm%) THEN ch%=TRUE
  kills%(cm%)=newkills%
  IF sort%=1 AND credits%(cm%)<>rxbuffer%!12 THEN ch%=TRUE
  deaths%(cm%)=rxbuffer%?11
  credits%(cm%)=rxbuffer%!12
  machine%(cm%)=rxbuffer%?16
  station%(cm%)=cblock%?3
  network%(cm%)=cblock%?4
=ch%
:
DEF FNfindCmdr(nm$,nw%,st%)
  match%=-1
  FOR I%=0 TO next%-1
    IF match%=-1 AND station%(I%)=st% AND network%(I%)=nw% AND name$(I%)=nm$ THEN match%=I%
  NEXT
=match%
:
DEF PROCswapSort
  REPEAT:UNTIL NOT(INKEY(-82))
  SOUND 3,241,188,1
  sort%=sort%EOR1
  PROChighlightSort
  IF next%>1 THEN PROCsort:PROCprintTable
ENDPROC
:
DEF PROCsort
  IF sort%=0 THEN PROCsortByKills ELSE PROCsortByCr
ENDPROC
:
DEF PROCsortByCr
  FOR I%=next%-1 TO 0 STEP -1
    FOR J%=0 TO I%-1
      IF credits%(order%(J%))<credits%(order%(J%+1)) THEN T%=order%(J%):order%(J%)=order%(J%+1):order%(J%+1)=T%
    NEXT
  NEXT
ENDPROC
:
DEF PROCsortByKills
  FOR I%=next%-1 TO 0 STEP -1
    FOR J%=0 TO I%-1
      IF kills%(order%(J%))<kills%(order%(J%+1)) THEN T%=order%(J%):order%(J%)=order%(J%+1):order%(J%+1)=T%
    NEXT
  NEXT
ENDPROC
:
DEF PROChighlightSort
  IF sort%=0 THEN PRINT TAB(26,3);CHR$(129);TAB(32,3);CHR$(132); ELSE PRINT TAB(26,3);CHR$(132);TAB(32,3);CHR$(129);
ENDPROC
:
DEF PROCprintHeader
  PRINT TAB(0,0);CHR$(132);"<S>ort      ";
  PRINT CHR$(147);CHR$(188);CHR$(164);CHR$(232);" ";CHR$(232);" ";CHR$(236);CHR$(164);CHR$(232);CHR$(172);CHR$(129);
  PRINT SPC(7-FNdigits(snetwork%)-FNdigits(sstation%));"Stn: ";snetwork%;".";sstation%;
  PRINT TAB(0,1);CHR$(133);"<M>enu      ";
  PRINT CHR$(147);CHR$(247);CHR$(176);CHR$(234);CHR$(176);CHR$(234);" ";CHR$(234);" ";CHR$(234);CHR$(241);CHR$(130);
  PRINT SPC(8-FNdigits(port%));"Port: ";port%
  PRINT TAB(13,2);CHR$(131);"SCOREBOARD"
  PRINT TAB(0,3);CHR$(157);CHR$(132);"Mc Net Stn C Lgl Player  Kills Credits"
ENDPROC
:
DEF PROCstartMenu
  PRINT TAB(10,0);CHR$(141);"Elite Scoreboard"
  PRINT TAB(10,1);CHR$(141);"Elite Scoreboard"
  PRINT '"Please enter the port number for this"
  INPUT "scoreboard: " port%
  CLS
ENDPROC
:
DEF PROCmenu
  REPEAT:UNTIL NOT(INKEY(-102))
  REPEAT
    CLS:*FX15,1
    PRINT TAB(15,0);CHR$(141);"Menu"
    PRINT TAB(15,1);CHR$(141);"Menu"
    PRINT ''"<C>hange this scoreboard's port (";port%;")"
    PRINT ''"Forward all scores to this machine:"
    PRINT '"  <N>etwork number (";fnetwork%;")"
    PRINT "  <S>tation number (";fstation%;")"
    PRINT "  <P>ort number    (";fport%;")"
    IF fstation%>0 AND fport%>0 THEN PRINT '"To disable forwarding, set the port":PRINT"or station to zero" ELSE PRINT '"To enable forwarding, set the port":PRINT"and station to non-zero values"
    PRINT ''"<R>eturn to scoreboard"
    PRINT ''"<Q>uit"
    q$=GET$
    IF q$="C" OR q$="c" THEN INPUT TAB(0,23);"Enter the new port number: " port%:PROCdeleteReceiveBlock:rxcb_number%=FNopenReceiveBlock(port%)
    IF q$="N" OR q$="n" THEN INPUT TAB(0,23);"Enter the network number to forward to: " fnetwork%
    IF q$="S" OR q$="s" THEN INPUT TAB(0,23);"Enter the station number to forward to: " fstation%
    IF q$="P" OR q$="p" THEN INPUT TAB(0,23);"Enter the port number to forward to: " fport%
    IF q$="Q" OR q$="q" THEN PROCend
  UNTIL q$="R" OR q$="r"
  CLS
ENDPROC
:
DEF PROCprintTable
  PROChighlightSort
  IF next%>0 THEN FOR I%=0 TO next%-1:PROCprintCmdr(order%(I%),4+I%):NEXT
  IF next%<20 THEN FOR I%=next% TO 19:PRINT TAB(0,4+I%);SPC(40);:NEXT
ENDPROC
:
DEF PROCprintRow(cm%)
  FOR I%=0 TO next%-1
    PRINT TAB(0,4+I%);" ";
    IF cm%=order%(I%) THEN PROCprintCmdr(cm%,4+I%)
  NEXT
ENDPROC
:
DEF PROCprintCmdr(cm%,row%)
  PRINT TAB(0,row%);SPC(40);
  IF cmdr%=cm% THEN flag$="*" ELSE flag$=" "
  N%=network%(cm%):L%=legal%(cm%)
  PRINT TAB(0,row%);flag$;CHR$(134);M$(machine%(cm%));SPC(3-FNdigits(N%));N%;".";station%(cm%);
  PRINT TAB(12,row%);C$(condition%(cm%));CHR$(172);L$(legal%(cm%));CHR$(134);name$(cm%);CHR$(130);
  K%=kills%(cm%):D%=deaths%(cm%)
  PRINT TAB(29-FNdigits(K%)-FNdigits(D%),row%);K%;"/";D%;
  K$=" ":R%=credits%(cm%)
  IF R%>99999 AND R%<=99999999 THEN K$="k":R%=R%/1000
  IF R%>99999999 THEN K$="m":R%=R%/1000000
  @%=&2010A:PRINT TAB(37-FNdigits(R%),row%);R%/10;K$;:@%=10
ENDPROC
:
DEF FNdigits(dg%)
=LEN(STR$(dg%))-1
:
DEF PROCgetStationNumber
  X%=cblock%:Y%=cblock% DIV 256
  !cblock%=8
  A%=&13
  CALL OSWORD
  sstation%=cblock%?1
  A%=0:X%=1:os%=((USR OSBYTE) AND &FF00) DIV 256
  IF os%>2 THEN snetwork%=FNgetNetworkNumber ELSE snetwork%=FNdoBridgeQuery
ENDPROC
:
DEF FNgetNetworkNumber
  X%=cblock%:Y%=cblock% DIV 256
  ?cblock%=17
  cblock%!1=0
  A%=&13
  CALL OSWORD
=cblock%?1
:
DEF FNdoBridgeQuery
  REM Open RECEIVE block on port &8A, read control block number
  rxcb_number%=FNopenReceiveBlock(&8A)
  :
  REM Broadcast bridge query with control byte &82 to port &9C
  REM and receive response on port &8A
  attempts%=5
  REPEAT
    tblock%?0=&82
    tblock%?1=&9C
    tblock%!2=&FFFF
    $(tblock%+4)="BRIDGE"
    tblock%?10=&8A
    tblock%?11=0
    X%=tblock%:Y%=tblock% DIV 256
    A%=&10
    CALL OSWORD
    :
    REM Wait for broadcast to be sent
    A%=&32
    X%=FNpollTransmission
    attempts%=attempts%-1
  UNTIL attempts%=0 OR X%=&40 OR X%=&43 OR X%=&44 OR X%=0
  IF X%>0 THEN R%=0 ELSE R%=FNgetResponse
  PROCdeleteReceiveBlock
=R%
:
DEF FNgetResponse
  REM Fetch network number from response
  attempts%=20
  REPEAT
    X%=FNpollTransmission
    attempts%=attempts%-1
  UNTIL attempts%=0 OR X%>0
  IF X%>0 THEN result%=?rxbuffer% ELSE result%=0
=result%
:
DEF FNopenReceiveBlock(pt%)
  ?cblock%=0
  cblock%?1=&7F
  cblock%?2=pt%
  cblock%!3=0
  cblock%!5=rxbuffer%
  cblock%!9=rxbuffer%+20
  X%=cblock%:Y%=cblock% DIV 256
  A%=&11
  CALL OSWORD
=?cblock%
:
DEF PROCdeleteReceiveBlock
  A%=&34
  X%=cblock%?0
  CALL OSBYTE
ENDPROC
:
DEF FNpollTransmission
  REPEAT
  UNTIL NOT ((USR OSBYTE) AND &8000)
=(((USR OSBYTE) AND &FF00) DIV &100)
