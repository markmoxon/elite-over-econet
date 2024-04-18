REM ElScore - Scoreboard for Elite over Econet
REM By Mark Moxon
:
DIM order%(19),name$(19),credits%(19),score%(19),machine%(19)
DIM condition%(19),legal%(19),network%(19),station%(19)
DIM M$(2):M$(0)="B":M$(1)="M":M$(2)="S"
DIM C$(3):C$(0)=CHR$(151):C$(1)=CHR$(146):C$(2)=CHR$(147):C$(3)=CHR$(145)
DIM L$(2):L$(0)="Cln":L$(1)="Off":L$(2)="Fug"
DIM cblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:next%=0:sort%=0:@%=10
X%=cblock%:Y%=cblock% DIV 256:A%=&13:!cblock%=8:CALL OSWORD
snw%=cblock%?2:sst%=cblock%?1
:
MODE 7:VDU23;8202;0;0;0;
INPUT "Port",port%
CLS
PRINT "  [S]ort by Cr   EELLIITTEE   Stn: ";snw%;".";sst%
PRINT "  [Esc] to quit  EELLIITTEE    Port: ";port%
PRINT CHR$(157);CHR$(132);"Station Status Name    Score   Credits"
REPEAT
  PROCreceive
  IF next%>0 THEN cmdr%=FNfindCmdr($rxbuffer%,cblock%?4,cblock%?3) ELSE cmdr%=-1
  IF cmdr%=-1 AND next%<20 THEN cmdr%=next%:order%(next%)=cmdr%:next%=next%+1
  IF cmdr%<>-1 THEN dosort%=FNupdateCmdr(cmdr%) ELSE dosort%=FALSE
  IF next%>1 AND dosort% THEN PROCsort:PROCprintTable ELSE PROCprintRow(cmdr%)
UNTIL FALSE
END
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
  UNTIL (U% AND &8000)<>0
  REM Read control block back
  X%=cblock%:Y%=cblock% DIV 256:A%=&11
  ?cblock%=rxcb_number%:CALL OSWORD
ENDPROC
:
DEF PROCreceiveTest
  PRINTTAB(0,23);:INPUT"Name",n$
  $rxbuffer%=n$
  rxbuffer%?8=RND(3)-1
  rxbuffer%?9=RND(4)-1
  rxbuffer%?10=RND(256)-1
  rxbuffer%?11=RND(256)-1
  rxbuffer%!12=RND(65536)-1
  rxbuffer%?16=RND(3)-1
  cblock%?3=RND(256)-1
  cblock%?4=RND(10)-1
ENDPROC
:
DEF FNupdateCmdr(I%)
  ch%=FALSE
  name$(I%)=$rxbuffer%
  legal%(I%)=rxbuffer%?8
  condition%(I%)=rxbuffer%?9
  newscore%=rxbuffer%?10+256*rxbuffer%?11
  IF sort%=0 AND newscore%<>score%(I%) THEN ch%=TRUE
  score%(I%)=newscore%
  IF sort%=1 AND credits%(I%)<>rxbuffer%!12 THEN ch%=TRUE
  credits%(I%)=rxbuffer%!12
  machine%(I%)=rxbuffer%?16
  station%(I%)=cblock%?3
  network%(I%)=cblock%?4
=ch%
:
DEF FNfindCmdr(nm$,nw%,st%)
  FOR I%=0 TO next%-1
    IF station%(I%)=st% AND network%(I%)=nw% AND name$(I%)=nm$ THEN =I%
  NEXT
=-1
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
      IF score%(order%(J%))<score%(order%(J%+1)) THEN T%=order%(J%):order%(J%)=order%(J%+1):order%(J%+1)=T%
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
    PRINT SPC(39)
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
  @%=10
  IF cmdr%=I% THEN style$="* " ELSE style$="  "
  PRINT TAB(0,row%);style$;M$(machine%(I%));" ";network%(I%);".";station%(I%);
  PRINT TAB(9,row%);C$(condition%(I%));CHR$(255);CHR$(135);L$(legal%(I%));"  ";name$(I%);
  S%=score%(I%)
  IF S%=0 THEN J%=0 ELSE J%=INT(LOG(S%))
  PRINT TAB(29-J%,row%);S%;
  C%=credits%(I%)
  IF C%>999999 THEN K$="k":C%=C%/1000:K%=1 ELSE K$="":K%=0
  IF C%=0 THEN J%=0 ELSE J%=INT(LOG(C%))
  @%=&2010A:PRINT TAB(38-J%-K%,row%);C%/10;K$;
ENDPROC
