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
port%=0:fstn%=0:fnet%=0:next%=0:sort%=0:cmdr%=-1:quit%=FALSE
X%=cblock%:Y%=cblock% DIV 256:A%=&13:!cblock%=8:CALL OSWORD
snw%=cblock%?2:sst%=cblock%?1
:
ON ERROR PROCerror
MODE 7:VDU23;8202;0;0;0;
*FX4,1
*FX200,1
PROCmenu
PROCprintHeader
REPEAT
  PROCreceive
  IF next%>0 THEN cmdr%=FNfindCmdr($rxbuffer%,cblock%?4,cblock%?3) ELSE cmdr%=-1
  IF cmdr%=-1 AND next%<20 THEN cmdr%=next%:order%(next%)=cmdr%:next%=next%+1
  IF cmdr%<>-1 THEN dosort%=FNupdateCmdr(cmdr%) ELSE dosort%=FALSE
  IF next%>1 AND dosort% THEN PROCsort:PROCprintTable ELSE PROCprintRow(cmdr%)
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
    PRINTTAB(0,23);:INPUT"Name",n$
    IF n$="M" THEN PROCmenu:PROCprintHeader:PROCprintTable
    IF n$="S" THEN PROCswapSort
  UNTIL LEN(n$)>3 OR n$="R" OR n$="U"
  IF n$="R" OR n$="U" THEN U%=RND(next%)-1:$rxbuffer%=name$(U%):cblock%?3=station%(U%):cblock%?4=network%(U%) ELSE $rxbuffer%=n$:cblock%?3=RND(256)-1:cblock%?4=RND(129)-1
  IF n$="R" THEN rxbuffer%?8=legal%(U%):rxbuffer%?9=condition%(U%):rxbuffer%!10=kills%(U%):rxbuffer%!12=credits%(U%):rxbuffer%?16=machine%(U%)
  IF n$<>"R" THEN rxbuffer%?8=RND(3)-1:rxbuffer%?9=RND(4)-1:rxbuffer%!10=RND(65536)-1:rxbuffer%!12=RND(&00CA9A3B):rxbuffer%?16=RND(3)-1
ENDPROC
:
DEF PROCswapSort
  SOUND 3,241,188,1
  sort%=sort%EOR1
  IF next%>1 THEN PROCsort:PROCprintTable
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
DEF PROCmenu
  CLS:*FX15,1
  IF quit% THEN PRINT "Set Port <";port%;">? (Y/N) ";:q$=GET$ ELSE PRINT "Enter Port ";:q$="Y"
  IF q$="Y" OR q$="y" THEN INPUT port%
  PRINT '"Set Forwarding station <";fstn%;">? (Y/N) ";
  q$=GET$:IF q$="Y" OR q$="y" THEN INPUT fstn%
  PRINT '"Set Forwarding network <";fnet%;">? (Y/N) ";
  q$=GET$:IF q$="Y" OR q$="y" THEN INPUT fnet%
  IF quit% THEN PRINT '"Quit? (Y/N)":q$ = GET$ ELSE q$ = ""
  IF q$="Y" OR q$="y" THEN PROCend
  quit%=TRUE
  CLS
ENDPROC
:
DEF FNupdateCmdr(I%)
  ch%=FALSE
  name$(I%)=$rxbuffer%
  legal%(I%)=rxbuffer%?8
  condition%(I%)=rxbuffer%?9
  newkills%=rxbuffer%?10+256*rxbuffer%?11
  IF sort%=0 AND newkills%<>kills%(I%) THEN ch%=TRUE
  kills%(I%)=newkills%
  IF sort%=1 AND credits%(I%)<>rxbuffer%!12 THEN ch%=TRUE
  credits%(I%)=rxbuffer%!12
  machine%(I%)=rxbuffer%?16
  station%(I%)=cblock%?3
  network%(I%)=cblock%?4
=ch%
:
DEF FNfindCmdr(nm$,nw%,st%)
  match%=-1
  FOR I%=0 TO next%-1
    IF match%=-1 AND station%(I%)=st% AND network%(I%)=nw% AND name$(I%)=nm$ THEN match%=I%
  NEXT
=match%
:
DEF PROCsort
  IF sort%=0 THEN PROCsortByScore ELSE PROCsortByCr
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
DEF PROCsortByScore
  FOR I%=next%-1 TO 0 STEP -1
    FOR J%=0 TO I%-1
      IF kills%(order%(J%))<kills%(order%(J%+1)) THEN T%=order%(J%):order%(J%)=order%(J%+1):order%(J%+1)=T%
    NEXT
  NEXT
ENDPROC
:
DEF PROCprintTable
  PRINT TAB(0,4);
  FOR I%=0 TO next%-1
    PROCprintCmdr(order%(I%),4+I%)
  NEXT
  FOR I%=next% TO 19
    PRINT SPC(40);
  NEXT
ENDPROC
:
DEF PROCprintRow(C%)
  FOR I%=0 TO next%-1
    IF C%=order%(I%) THEN PROCprintCmdr(I%,4+I%)
  NEXT
ENDPROC
:
DEF PROCprintCmdr(I%,row%)
  PRINT TAB(0,row%);SPC(40);
  IF cmdr%=I% THEN flag$="*" ELSE flag$=" "
  N%=network%(I%):L%=legal%(I%)
  PRINT TAB(0,row%);flag$;CHR$(134);M$(machine%(I%));SPC(3-FNdigits(N%));N%;".";station%(I%);
  PRINT TAB(12,row%);C$(condition%(I%));CHR$(172);L$(legal%(I%));CHR$(134);name$(I%);CHR$(130);
  S%=kills%(I%)
  PRINT TAB(31-FNdigits(S%),row%);S%;
  K$=" ":C%=credits%(I%)
  IF C%>99999 AND C%<=99999999 THEN K$="k":C%=C%/1000
  IF C%>99999999 THEN K$="m":C%=C%/1000000
  @%=&2010A:PRINT TAB(37-FNdigits(C%),row%);C%/10;K$;:@%=10
ENDPROC
:
DEF FNdigits(D%)
IF D%=0 THEN =0 ELSE =INT(LOG(D%))