REM ElScore - Scoreboard for Elite over Econet
REM By Mark Moxon
:
DIM order%(19),name$(19),credits%(19),kills%(19),machine%(19)
DIM condition%(19),legal%(19),network%(19),station%(19)
DIM M$(2):M$(0)="Bb":M$(1)="Ma":M$(2)="Sp"
DIM C$(3):C$(0)=CHR$(151):C$(1)=CHR$(146):C$(2)=CHR$(147):C$(3)=CHR$(145)
DIM L$(2):L$(0)=CHR$(130)+"Cln":L$(1)=CHR$(131)+"Off":L$(2)=CHR$(129)+"Fug"
DIM cblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4
port%=0:fstation%=0:fnetwork%=0:fport%=0:next%=0:sort%=0:cmdr%=-1:quit%=FALSE
X%=cblock%:Y%=cblock% DIV 256:A%=&13:!cblock%=8:CALL OSWORD
snw%=cblock%?2:sst%=cblock%?1
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
  REM Open RECEIVE block, read control block number
  ?cblock%=0
  cblock%?1=&7F
  cblock%?2=port%
  cblock%!3=0
  cblock%!5=rxbuffer%
  cblock%!9=rxbuffer%+20
  X%=cblock%:Y%=cblock% DIV 256:A%=&11:CALL OSWORD
  rxcb_number%=?cblock%
  REM Wait for reception
  A%=&33:X%=rxcb_number%
  REPEAT:U%=USR OSBYTE
  IF INKEY(-82) THEN PROCswapSort
  IF INKEY(-102) THEN PROCmenu:PROCprintHeader:PROCprintTable
  UNTIL (U% AND &8000)<>0
  REM Read control block back
  X%=cblock%:Y%=cblock% DIV 256:A%=&11
  ?cblock%=rxcb_number%:CALL OSWORD
ENDPROC
:
DEF PROCreceiveTest
  REM <M>enu <S>ort <U>pdate <R>eceive
  REPEAT
    INPUT TAB(0,23)"Name",n$
    IF n$="M" THEN PROCmenu:PROCprintHeader:PROCprintTable
    IF n$="S" THEN PROCswapSort
  UNTIL LEN(n$)>3 OR n$="R" OR n$="U"
  IF n$="R" OR n$="U" THEN U%=RND(next%)-1:$rxbuffer%=name$(U%):cblock%?3=station%(U%):cblock%?4=network%(U%) ELSE $rxbuffer%=n$:cblock%?3=RND(256)-1:cblock%?4=RND(129)-1
  IF n$="R" THEN rxbuffer%?8=legal%(U%):rxbuffer%?9=condition%(U%):rxbuffer%!10=kills%(U%):rxbuffer%!12=credits%(U%):rxbuffer%?16=machine%(U%)
  IF n$<>"R" THEN rxbuffer%?8=RND(3)-1:rxbuffer%?9=RND(4)-1:rxbuffer%!10=RND(65536)-1:rxbuffer%!12=RND(&00CA9A3B):rxbuffer%?16=RND(3)-1
ENDPROC
:
DEF PROCforward
  ?cblock%=&80:cblock%?1=fport%:cblock%?2=fstation%:cblock%?3=fnetwork%
  cblock%!4=rxbuffer%:cblock%!8=rxbuffer%+20
  X%=cblock%:Y%=cblock% DIV 256:A%=16:CALL OSWORD
ENDPROC
:
DEF FNupdateCmdr(cm%)
  ch%=FALSE
  name$(cm%)=$rxbuffer%
  legal%(cm%)=rxbuffer%?8
  condition%(cm%)=rxbuffer%?9
  newkills%=rxbuffer%?10+256*rxbuffer%?11
  IF sort%=0 AND newkills%<>kills%(cm%) THEN ch%=TRUE
  kills%(cm%)=newkills%
  IF sort%=1 AND credits%(cm%)<>rxbuffer%!12 THEN ch%=TRUE
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
  REPEAT:UNTIL INKEY(1)=-1
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
  PRINT SPC(7-FNdigits(snw%)-FNdigits(sst%));"Stn: ";snw%;".";sst%;
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
  REPEAT:UNTIL INKEY(1)=-1
  REPEAT
    CLS:*FX15,1
    PRINT TAB(15,0);CHR$(141);"Menu"
    PRINT TAB(15,1);CHR$(141);"Menu"
    PRINT ''"<C>hange this scoreboard's port (";port%;")"
    PRINT ''"Forward on all scores to this machine:"
    PRINT '"  <S>tation number (";fstation%;")"
    PRINT "  <N>etwork number (";fnetwork%;")"
    PRINT "  <P>ort number    (";fport%;")"
    IF fstation%>0 AND fport%>0 THEN PRINT '"To disable forwarding, set the port":PRINT"or station to zero" ELSE PRINT '"To enable forwarding, set the port":PRINT"and station to non-zero values"
    PRINT ''"<R>eturn to scoreboard"
    PRINT ''"<Q>uit"
    q$=GET$
    IF q$="C" OR q$="c" THEN INPUT TAB(0,23);"Enter the new port number: " port%
    IF q$="S" OR q$="s" THEN INPUT TAB(0,23);"Enter the station number to forward to: " fstation%
    IF q$="N" OR q$="n" THEN INPUT TAB(0,23);"Enter the network number to forward to: " fnetwork%
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
  K%=kills%(cm%)
  PRINT TAB(31-FNdigits(K%),row%);K%;
  K$=" ":R%=credits%(cm%)
  IF R%>99999 AND R%<=99999999 THEN K$="k":R%=R%/1000
  IF R%>99999999 THEN K$="m":R%=R%/1000000
  @%=&2010A:PRINT TAB(37-FNdigits(R%),row%);R%/10;K$;:@%=10
ENDPROC
:
DEF FNdigits(dg%)
  IF dg%=0 THEN =0 ELSE =INT(LOG(dg%))