REM ElScore - Scoreboard for Elite over Econet
REM By Mark Moxon
:
max%=99:cmdrs%=0:sort%=0:page%=0:star%=-1:cmrec%=-1:quit%=FALSE
DIM rowCmdr%(max%),rowUpdt%(max%),name$(max%),credits%(max%),kills%(max%),deaths%(max%)
DIM machine%(max%),condition%(max%),legal%(max%),network%(max%),station%(max%)
DIM M$(4):M$(0)="B+":M$(1)="Ma":M$(2)="Sp":M$(3)="Bb":M$(4)="Ar"
DIM C$(3):C$(0)=CHR$(151):C$(1)=CHR$(146):C$(2)=CHR$(147):C$(3)=CHR$(145)
DIM L$(2):L$(0)=CHR$(130)+"Cln":L$(1)=CHR$(131)+"Off":L$(2)=CHR$(129)+"Fug"
DIM cblock% 40,tblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA
port%=0:fstation%=0:fnetwork%=0:fport%=0:ostation%=0:onetwork%=0
PROCgetStationNumber
:
ON ERROR PROCerror
MODE 7
*FX4,1
*FX200,1
PROCstartMenu
VDU23;8202;0;0;0;
PROCprintHeader
REPEAT
  PROCreceive
  IF cmdrs%>0 THEN cmrec%=FNfindCmdr($rxbuffer%,cblock%?4,cblock%?3) ELSE cmrec%=-1
  IF cmrec%=-1 AND cmdrs%<max% THEN PROCaddCmdr
  IF cmrec%<>-1 THEN dosort%=FNupdateCmdr(cmrec%) ELSE dosort%=FALSE
  IF cmdrs%>1 AND dosort% THEN PROCsort
  IF star%<>-1 THEN PRINT TAB(0,star%);" ":star%=-1
  PROCupdateTable(0)
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
DEF PROCprocessKeys
  K%=INKEY(0)
  IF K%=ASC("S") THEN PROCswapSort
  IF K%=ASC("M") THEN PROCmenu:PROCprintHeader:IF cmdrs%>0 THEN PROCupdateTable(1)
  IF K%=ASC("P") THEN PROCnextPage
ENDPROC
:
DEF PROCaddCmdr
  cmrec%=cmdrs%
  rowCmdr%(cmrec%)=cmrec%
  rowUpdt%(cmrec%)=1
  cmdrs%=cmdrs%+1
  PROCprintHeader
ENDPROC
:
DEF PROCnextPage
  *FX15,1
  SOUND 3,241,188,1
  page%=page%+1
  IF page%>INT(cmdrs%/20) THEN page%=0
  CLS:PROCprintHeader:PROCupdateTable(1)
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
  FOR I%=0 TO cmdrs%-1
    IF match%=-1 AND station%(I%)=st% AND network%(I%)=nw% AND name$(I%)=nm$ THEN match%=I%
  NEXT
=match%
:
DEF PROCswapSort
  *FX15,1
  SOUND 3,241,188,1
  sort%=sort%EOR1
  PROChighlightSort
  IF cmdrs%>1 THEN PROCsort:PROCupdateTable(1)
ENDPROC
:
DEF PROCsort
  IF sort%=0 THEN PROCsortByKills ELSE PROCsortByCr
ENDPROC
:
DEF PROCsortByCr
  FOR I%=cmdrs%-1 TO 0 STEP -1
    FOR J%=0 TO I%-1
      IF credits%(rowCmdr%(J%))<credits%(rowCmdr%(J%+1)) THEN T%=rowCmdr%(J%):rowCmdr%(J%)=rowCmdr%(J%+1):rowCmdr%(J%+1)=T%:rowUpdt%(J%)=1:rowUpdt%(J%+1)=1
    NEXT
  NEXT
ENDPROC
:
DEF PROCsortByKills
  FOR I%=cmdrs%-1 TO 0 STEP -1
    FOR J%=0 TO I%-1
      IF kills%(rowCmdr%(J%))<kills%(rowCmdr%(J%+1)) THEN T%=rowCmdr%(J%):rowCmdr%(J%)=rowCmdr%(J%+1):rowCmdr%(J%+1)=T%:rowUpdt%(J%)=1:rowUpdt%(J%+1)=1
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
  PRINT SPC(6-FNdigits(snetwork%));"Stn ";snetwork%;".";FNpad0(sstation%);sstation%;
  PRINT TAB(0,1);CHR$(133);"<M>enu      ";
  PRINT CHR$(147);CHR$(247);CHR$(176);CHR$(234);CHR$(176);CHR$(234);" ";CHR$(234);" ";CHR$(234);CHR$(241);CHR$(130);
  PRINT SPC(9-FNdigits(port%));"Port ";port%
  PRINT TAB(0,2);CHR$(134);"<P>age      ";CHR$(131);"SCOREBOARD        Page ";page%+1;"/";INT(cmdrs%/20)+1
  PRINT TAB(0,3);CHR$(157);CHR$(132);"Mc Station C Lgl Player  Kills Credits"
  PROChighlightSort
ENDPROC
:
DEF PROCstartMenu
  PRINT TAB(10,0);CHR$(141);"Elite Scoreboard"
  PRINT TAB(10,1);CHR$(141);"Elite Scoreboard"
  PRINT '"Please enter the port number for this"
  INPUT "scoreboard (1-255): " port%
  CLS
ENDPROC
:
DEF PROCmenu
  REPEAT
    CLS:*FX15,1
    PRINT TAB(15,0);CHR$(141);"Menu"
    PRINT TAB(15,1);CHR$(141);"Menu"
    PRINT ''"<C>hange this scoreboard's port (";port%;")"
    PRINT '"Forward all scores to:"
    PRINT '"  <N>etwork number (";fnetwork%;")"
    PRINT "  <S>tation number (";fstation%;")"
    PRINT "  <P>ort number    (";fport%;")"
    IF fstation%>0 AND fport%>0 THEN PRINT '"To disable forwarding, set the port":PRINT"or station to zero" ELSE PRINT '"To enable forwarding, set the port":PRINT"and station to non-zero values"
    PRINT '"<D>elete a score"
    PRINT '"<R>eturn to scoreboard"
    PRINT '"<Q>uit"
    q$=GET$
    IF q$="C" OR q$="c" THEN INPUT TAB(0,22);"Enter the new port number (1-255): " port%:PROCdeleteReceiveBlock:rxcb_number%=FNopenReceiveBlock(port%)
    IF q$="N" OR q$="n" THEN INPUT TAB(0,22);"Enter the network number to forward to: " fnetwork%
    IF q$="S" OR q$="s" THEN INPUT TAB(0,22);"Enter the station number to forward to: " fstation%
    IF q$="P" OR q$="p" THEN INPUT TAB(0,22);"Enter the port number to forward to: " fport%
    IF q$="D" OR q$="d" THEN INPUT TAB(0,22);"Enter the network number to delete: " dn%:INPUT TAB(0,23);"Enter the station number to delete: " ds%:PROCdelete(dn%,ds%)
    IF q$="Q" OR q$="q" THEN PROCend
  UNTIL q$="R" OR q$="r"
  CLS
ENDPROC
:
DEF PROCdelete(dn%,ds%)
  PRINT TAB(0,22);SPC(40);TAB(0,23);SPC(40);
  nomatch%=TRUE
  FOR I%=cmdrs%-1 TO 0 STEP -1
    IF network%(I%)=dn% AND station%(I%)=ds% THEN PROCdeleteCmdr(I%):nomatch%=FALSE
  NEXT
  IF nomatch% THEN PRINT TAB(0,22);"No players found on ";dn%;".";FNpad0(ds%);ds%:PROCbeep(0)
ENDPROC
:
DEF PROCdeleteCmdr(cm%)
  S%=station%(cm%)
  PRINT TAB(0,22);"Delete player ";name$(cm%);" on ";network%(cm%);".";FNpad0(S%);S%;" (Y/N)?"
  d$=GET$
  IF d$<>"Y" AND d$<>"y" THEN PRINT TAB(0,23);"Player not deleted":PROCbeep(0):ENDPROC
  IF cmdrs%>1 THEN PROCmoveCmdr(cm%)
  IF cmdrs%>0 THEN cmdrs%=cmdrs%-1
  PRINT TAB(0,23);"Player deleted"
  PROCbeep(1)
ENDPROC
:
DEF PROCbeep(high%)
  IF high%=1 THEN SOUND 3,241,188,1 ELSE SOUND 3,244,12,8
  PROCpause:PROCpause:PROCpause
ENDPROC
:
DEF PROCmoveCmdr(cm%)
  oldrow%=rowCmdr%(cm%)
  name$(cm%)=name$(cmdrs%-1)
  legal%(cm%)=legal%(cmdrs%-1)
  condition%(cm%)=condition%(cmdrs%-1)
  kills%(cm%)=kills%(cmdrs%-1)
  deaths%(cm%)=deaths%(cmdrs%-1)
  credits%(cm%)=credits%(cmdrs%-1)
  machine%(cm%)=machine%(cmdrs%-1)
  station%(cm%)=station%(cmdrs%-1)
  network%(cm%)=network%(cmdrs%-1)
  rowCmdr%(cm%)=rowCmdr%(cmdrs%-1)
  FOR I%=0 TO cmdrs%-2
    IF rowCmdr%(I%) > oldrow% THEN rowCmdr%(I%)=rowCmdr%(I%)-1
  NEXT
ENDPROC
:
DEF PROCupdateTable(all%)
  start%=page%*20
  IF start%+19>cmdrs%-1 THEN end%=cmdrs%-1 ELSE end%=start%+19
  FOR R%=start% TO end%
    C%=rowCmdr%(R%)
    IF (rowUpdt%(R%)=1 OR all%=1) AND R%>=start% AND R%<=end% THEN PROCprintCmdr(C%,R%+4-start%)
    rowUpdt%(R%)=0
  NEXT
ENDPROC
:
DEF PROCprintCmdr(cm%,row%)
  PRINT TAB(0,row%);SPC(40);
  IF cmrec%=cm% THEN flag$="*":star%=row% ELSE flag$=" "
  N%=network%(cm%):L%=legal%(cm%):S%=station%(cm%)
  PRINT TAB(0,row%);flag$;CHR$(134);M$(machine%(cm%));SPC(3-FNdigits(N%));N%;".";FNpad0(S%);S%;
  PRINT TAB(12,row%);C$(condition%(cm%));CHR$(172);L$(legal%(cm%));CHR$(134);name$(cm%);CHR$(130);
  K%=kills%(cm%):D%=deaths%(cm%)
  PRINT TAB(29-FNdigits(K%)-FNdigits(D%),row%);K%;"/";D%;
  K$=" ":M%=credits%(cm%)
  IF M%>99999 AND M%<=99999999 THEN K$="k":M%=M%/1000
  IF M%>99999999 THEN K$="m":M%=M%/1000000
  @%=&2010A:PRINT TAB(37-FNdigits(M%),row%);M%/10;K$;:@%=10
ENDPROC
:
: REM Econet library
:
DEF PROCreceive
  rxcb_number%=FNopenReceiveBlock(port%)
  :
  REM Wait for reception
  REPEAT
    A%=&33
    X%=rxcb_number%
    U%=USR OSBYTE
    PROCprocessKeys
  UNTIL (U% AND &8000)<>0
  :
  REM Read control block back
  X%=cblock%:Y%=cblock% DIV 256
  A%=&11
  ?cblock%=rxcb_number%
  CALL OSWORD
  :
  PROCdeleteReceiveBlock
  :
  REM Update originating network address when it is set to zero
  IF cblock%?4=0 THEN cblock%?4=snetwork%
  :
  REM If this is a forwarded packet, set the player address
  onetwork%=cblock%?4:ostation%=cblock%?3
  IF rxbuffer%?17>0 THEN cblock%?3=rxbuffer%?17:cblock%?4=rxbuffer%?18
ENDPROC
:
DEF FNdigits(dg%)
=LEN(STR$(dg%))-1
:
DEF FNpad0(st%)
=STRING$(2-FNdigits(st%),"0")
:
DEF PROCforward
  REM Set bytes 17 and 18 of forwarded data to player address
  rxbuffer%?17=cblock%?3
  rxbuffer%?18=cblock%?4
  :
  REM Send forwarded data
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
  REM Open RECEIVE block on port &57, read control block number
  rxcb_number%=FNopenReceiveBlock(&57)
  :
  REM Broadcast bridge query with control byte &82 to port &9C
  REM and receive response on port &57
  attempts%=10
  tblock%?1=&9C
  tblock%!2=&FFFF
  $(tblock%+4)="BRIDGE"
  tblock%?10=&57
  tblock%?11=0
  REPEAT
    REM Broadcast bridge query
    REPEAT
      tblock%?0=&82
      A%=&10
      X%=tblock%:Y%=tblock% DIV 256
      CALL OSWORD
    UNTIL tblock%?0
    :
    REM Wait for broadcast to be sent
    A%=&32:X%=0:Y%=0
    R%=FNpollTransmission
    :
    attempts%=attempts%-1
    IF attempts%<>0 AND NOT(R%<>&41 AND R%<>&42) THEN PROCpause
  UNTIL attempts%=0 OR (R%<>&41 AND R%<>&42)
  REM IF attempts%=0 OR R%<>0 THEN PRINT '"Bridge query broadcast failed"''"Press a key to continue":A=GET
  IF attempts%=0 OR R%<>0 THEN PROCdeleteReceiveBlock:=0
  :
  REM Fetch network number from response
  attempts%=50
  REPEAT
    A%=&33:X%=rxcb_number%:Y%=0
    R%=FNpollTransmission
    attempts%=attempts%-1
    IF attempts%<>0 AND R% AND &80=0 THEN PROCpause
  UNTIL attempts%=0 OR R% AND &80<>0
  REM IF R% AND &80=0 THEN PRINT '"No response to bridge query"''"Press a key to continue":A=GET
  IF R% AND &80=0 THEN =0
  :
  REM Read control block back
  X%=cblock%:Y%=cblock% DIV 256
  A%=&11
  ?cblock%=rxcb_number%
  CALL OSWORD
  R%=?rxbuffer%
  PROCdeleteReceiveBlock
=R%
:
DEF FNpollTransmission
  REPEAT
    U%=USR OSBYTE
  UNTIL NOT (U% AND &8000)
=((U% AND &FF00) DIV &100)
:
DEF PROCpause
  T%=TIME+50
  REPEAT
  UNTIL TIME>T%
ENDPROC
