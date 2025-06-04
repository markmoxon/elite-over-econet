REM ElScore - Scoreboard for Elite over Econet
REM By Mark Moxon
:
max%=99:cmdrs%=0:sort%=0:page%=0:star%=-1:cmrec%=-1:thisRow%=0
auto%=0:autoTime%=0:auto$="":autoSaved%=FALSE:quit%=FALSE
DIM rowCmdr%(max%,1),rowUpdt%(max%)
DIM name$(max%),kills%(max%),deaths%(max%)
DIM credits%(max%),condition%(max%),legal%(max%)
DIM machine%(max%),network%(max%),station%(max%)
DIM M$(5):M$(0)="B+":M$(1)="M ":M$(2)="SP":M$(3)="B ":M$(4)="A ":M$(5)="E "
DIM C$(3):C$(0)=CHR$(151):C$(1)=CHR$(146):C$(2)=CHR$(147):C$(3)=CHR$(145)
DIM L$(2):L$(0)=CHR$(130)+"Cln":L$(1)=CHR$(131)+"Off":L$(2)=CHR$(129)+"Fug"
DIM cblock% 40,tblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA
port%=0:fstation%=0:fnetwork%=0:fport%=0:ostation%=0:onetwork%=0:saving%=0
PROCgetStationNumber
:
MODE 7
PROCstartMenu
ON ERROR PROCerror
*FX4,1
*FX200,1
VDU23;8202;0;0;0;
PROCprintHeader
PROCmainLoop
END
:
DEF PROCmainLoop
 REPEAT
  PROCreceive
  IF $rxbuffer%<>"" THEN PROCprocess
 UNTIL FALSE
ENDPROC
:
DEF PROCprocess
  PRINT TAB(18,0);CHR$(226);
  IF cmdrs%>0 THEN cmrec%=FNfindCmdr($rxbuffer%,cblock%?4,cblock%?3) ELSE cmrec%=-1
  IF cmrec%=-1 AND cmdrs%<=max% THEN PROCaddCmdr
  IF cmrec%<>-1 THEN dosort%=FNupdateCmdr(cmrec%) ELSE dosort%=FALSE
  PRINT TAB(18,0);CHR$(232);
  IF cmrec%<>-1 AND dosort% AND cmdrs%>1 THEN PROCsortCmdr(cmrec%,0):PROCsortCmdr(cmrec%,1)
  IF star%<>-1 THEN PRINT TAB(0,star%);" ":star%=-1
  PROCupdateTable(0)
  IF fstation%>0 AND fport%>0 THEN PROCforward(fstation%,fnetwork%,fport%)
ENDPROC
:
DEF PROCerror
 REPORT
 PRINT " at line ";ERL
ENDPROC
:
DEF PROCend
 *FX200,0
 *FX4,0
 END
ENDPROC
:
DEF PROCbeep(high%)
 IF high%=1 THEN SOUND 3,241,188,1 ELSE SOUND 3,244,12,8
 PROCpause:PROCpause:PROCpause
ENDPROC
:
DEF PROCprocessKeys
 K%=INKEY(0)
 IF K%=ASC("S") THEN PROCchangeSort(0):ENDPROC
 IF K%=ASC("M") THEN PROCmainMenu:ENDPROC
 IF K%=ASC("R") THEN PROCupdateScreen:ENDPROC
 IF K%=136 THEN PROCprevPage:ENDPROC
 IF K%=137 THEN PROCnextPage(0):ENDPROC
 IF auto%>0 THEN PROCcheckAuto
ENDPROC
:
DEF PROCcheckAuto
 T%=autoTime%-TIME
 IF T%<0 THEN PROCautoNextPage ELSE PRINT TAB(8,2);STR$(INT(T%/100)+1)+"  "
ENDPROC
:
DEF PROCautoNextPage
 PROCnextPage(1)
 autoTime%=TIME+auto%*100
 IF auto$<>"" THEN PROCsave_screen
ENDPROC
:
DEF PROCsave_screen
 ON ERROR PROCfileError(""):PRINT TAB(0,24);SPC(39);:PROCmainLoop
 IF autoSaved% THEN OSCLI("ACCESS "+auto$+" WR")
 OSCLI("SAVE "+auto$+" 7C00 7FBF")
 OSCLI("ACCESS "+auto$+" WR/R")
 autoSaved%=TRUE
 ON ERROR PROCend
ENDPROC
:
DEF PROCmainMenu
 PROCmenu
 PROCprintHeader
 IF cmdrs%>0 THEN PROCupdateTable(1)
ENDPROC
:
DEF PROCaddCmdr
 cmrec%=cmdrs%
 rowCmdr%(cmrec%,0)=cmrec%
 rowCmdr%(cmrec%,1)=cmrec%
 cmdrs%=cmdrs%+1
 PROCprintHeader
ENDPROC
:
DEF PROCprevPage
 *FX15,1
 PROCbeep(1)
 page%=page%-1
 IF page%<0 THEN page%=INT((cmdrs%-1)/20)
 PROCupdateScreen
ENDPROC
:
DEF PROCnextPage(toggleSort%)
 *FX15,1
 IF K%=137 THEN PROCbeep(1)
 page%=page%+1
 IF page%>INT((cmdrs%-1)/20) THEN page%=0
 IF page%=0 AND toggleSort%=1 THEN PROCchangeSort(1) ELSE PROCupdateScreen
ENDPROC
:
DEF PROCupdateScreen
 CLS:PROCprintHeader:PROCupdateTable(1)
ENDPROC
:
DEF FNupdateCmdr(cm%)
 ch%=FALSE
 rxbuffer%?7=13:name$(cm%)=$rxbuffer%
 legal%(cm%)=FNlimit(rxbuffer%?8,2)
 condition%(cm%)=FNlimit(rxbuffer%?9,3)
 newkills%=rxbuffer%?10+256*rxbuffer%?19
 IF newkills%<>kills%(cm%) THEN ch%=TRUE
 kills%(cm%)=newkills%
 IF credits%(cm%)<>rxbuffer%!12 THEN ch%=TRUE
 newdeaths%=rxbuffer%?11
 IF newdeaths%<>deaths%(cm%) THEN ch%=TRUE
 deaths%(cm%)=newdeaths%
 credits%(cm%)=rxbuffer%!12
 IF credits%(cm%)<0 THEN credits%(cm%)=0
 machine%(cm%)=FNlimit(rxbuffer%?16,5)
 station%(cm%)=cblock%?3
 network%(cm%)=cblock%?4
 rowUpdt%(rowCmdr%(cm%,sort%))=1
=ch%
:
DEF FNlimit(vl%,lm%)
 IF vl%<0 THEN =0
 IF vl%>lm% THEN =lm%
=vl%
:
DEF FNfindCmdr(nm$,nw%,st%)
 match%=-1
 FOR I%=0 TO cmdrs%-1
  IF station%(I%)=st% AND network%(I%)=nw% AND name$(I%)=nm$ THEN match%=I%:I%=cmdrs%-1
 NEXT
=match%
:
DEF FNfindCmdrRow(cm%,st%)
 match%=-1
 FOR I%=0 TO cmdrs%-1
  IF rowCmdr%(I%,st%)=cm% THEN match%=I%:I%=cmdrs%-1
 NEXT
=match%
:
DEF PROCchangeSort(header%)
 *FX15,1
 SOUND 3,241,188,1
 IF sort%=0 THEN sort%=1 ELSE sort%=0
 IF header%=1 THEN PROCprintHeader ELSE PROChighlightSort
 IF cmdrs%>1 THEN PROCupdateTable(1)
ENDPROC
:
DEF PROCsortCmdr(cm%,st%)
 thisRow%=FNfindCmdrRow(cm%,st%)
 REPEAT
  sorted%=TRUE
  IF thisRow%=0 THEN prevCm%=-1 ELSE prevCm%=rowCmdr%(thisRow%-1,st%)
  IF thisRow%=cmdrs%-1 THEN nextCm%=-1 ELSE nextCm%=rowCmdr%(thisRow%+1,st%)
  IF st%=0 AND prevCm%>=0 THEN sorted%=FNswapIfNeeded(FNkillScore(cm%),FNkillScore(prevCm%),-1,st%)
  IF st%=0 AND sorted% AND nextCm%>=0 THEN sorted%=FNswapIfNeeded(FNkillScore(nextCm%),FNkillScore(cm%),1,st%)
  IF st%=1 AND prevCm%>=0 THEN sorted%=FNswapIfNeeded(credits%(cm%),credits%(prevCm%),-1,st%)
  IF st%=1 AND sorted% AND nextCm%>=0 THEN sorted%=FNswapIfNeeded(credits%(nextCm%),credits%(cm%),1,st%)
 UNTIL sorted%
ENDPROC
:
DEF FNswapIfNeeded(v1%,v2%,dir%,st%)
 IF v1%>v2% THEN PROCswapRow(thisRow%,thisRow%+dir%,st%):thisRow%=thisRow%+dir%:=FALSE
=TRUE
:
DEF PROCswapRow(A%,B%,st%)
 T%=rowCmdr%(A%,st%):rowCmdr%(A%,st%)=rowCmdr%(B%,st%):rowCmdr%(B%,st%)=T%
 IF st%=sort% THEN rowUpdt%(A%)=1:rowUpdt%(B%)=1
ENDPROC
:
DEF FNkillScore(cm%)
=100000*kills%(cm%)-deaths%(cm%)
:
DEF PROCprintHeader
 PRINT TAB(0,0);CHR$(133);"<M>enu      ";
 PRINT CHR$(147);CHR$(188);CHR$(164);CHR$(232);" ";CHR$(232);" ";CHR$(236);CHR$(164);CHR$(232);CHR$(172);CHR$(129);
 PRINT SPC(6-FNdigits(snetwork%));"Stn ";snetwork%;".";FNpad0(sstation%);sstation%;
 PRINT TAB(0,1);CHR$(132);"<S>ort      ";
 PRINT CHR$(147);CHR$(247);CHR$(176);CHR$(234);CHR$(176);CHR$(234);" ";CHR$(234);" ";CHR$(234);CHR$(241);CHR$(130);
 PRINT SPC(9-FNdigits(port%));"Port ";port%
 PRINT TAB(0,2);CHR$(134);"[]";
 IF auto%=0 THEN PRINT "Page"; ELSE PRINT "Auto";
 PRINT TAB(13,2);CHR$(131);"SCOREBOARD        Page ";page%+1;"/";
 IF cmdrs%=0 THEN PRINT "1"; ELSE PRINT STR$(INT((cmdrs%-1)/20)+1);
 PRINT TAB(0,3);CHR$(157);CHR$(132);"Mc Station C Lgl Player  Kills Credits"
 PROChighlightSort
ENDPROC
:
DEF PROChighlightSort
 IF sort%=0 THEN PRINT TAB(26,3);CHR$(129);TAB(32,3);CHR$(132); ELSE PRINT TAB(26,3);CHR$(132);TAB(32,3);CHR$(129);
ENDPROC
:
DEF PROCstartMenu
 PRINT TAB(5,0);CHR$(141);"Elite over Econet Scoreboard"
 PRINT TAB(5,1);CHR$(141);"Elite over Econet Scoreboard"
 REPEAT
  PRINT TAB(0,4);SPC(40);
  INPUT TAB(0,3);"Please enter the port number for this"'"scoreboard (1-255): " port%
 UNTIL port%>=1 AND port%<=255
 CLS
ENDPROC
:
DEF PROCmenu
 REPEAT
  CLS:*FX15,1
  PRINT TAB(16,0);CHR$(141);"Menu"
  PRINT TAB(16,1);CHR$(141);"Menu"
  PRINT '" Change this scoreboard's";CHR$(130);"<P>ort";CHR$(135);"(";port%;")"
  IF fstation%>0 AND fport%>0 THEN PRINT '" Change";CHR$(130);"<F>orwarding";CHR$(135); ELSE PRINT '" Set up";CHR$(130);"<F>orwarding";CHR$(135);"to another machine"
  IF fstation%>0 AND fport%>0 THEN PRINT "(";fnetwork%;".";FNpad0(fstation%);fstation%;" port ";fport%;")"
  IF auto%=0 THEN PRINT '" Enable";CHR$(130);"<A>utomated";CHR$(135);"page-turning/saving" ELSE PRINT '" Change";CHR$(130);"<A>utomated";CHR$(135);"page-turning (";auto%;"s)"
  PRINT 'CHR$(130);"<D>elete";CHR$(135);"a score"
  PRINT 'CHR$(130);"<S>ave";CHR$(135);"or";CHR$(130);"<L>oad";CHR$(135);"scores"
  PRINT '" Enter";CHR$(130);"<M>OS";CHR$(135);"star-commands"
  PRINT 'CHR$(130);"<R>eturn";CHR$(135);"to scoreboard"
  PRINT 'CHR$(130);"<Q>uit"
  q$=GET$
  IF q$="P" OR q$="p" THEN INPUT TAB(0,22);"Enter the new port number (1-255):"'port%:PROCdeleteReceiveBlock:rxcb_number%=FNopenReceiveBlock(port%)
  IF q$="F" OR q$="f" THEN PROCforwarding
  IF q$="D" OR q$="d" THEN PROCdelete(dn%,ds%)
  IF q$="S" OR q$="s" THEN INPUT TAB(0,22);"Enter the filename to save:"'file$:IF file$<>"" THEN PROCsave(file$)
  IF q$="L" OR q$="l" THEN INPUT TAB(0,22);"Enter the filename to load:"'file$:IF file$<>"" THEN PROCload(file$)
  IF q$="A" OR q$="a" THEN PROCauto
  IF q$="M" OR q$="m" THEN CLS:PRINT "Enter MOS star-commands here"'"Press RETURN to return to the menu"':PROCstarCommand
  IF q$="Q" OR q$="q" THEN PRINT TAB(0,22);"Are you sure you want to quit (Y/N)?":REPEAT:a$=GET$:UNTIL a$="Y" OR a$="y" OR a$="N" OR a$="n":IF a$="Y" OR a$="y" THEN PROCend
 UNTIL q$="R" OR q$="r"
 CLS
 autoTime%=TIME+auto%*100
ENDPROC
:
DEF PROCforwarding
 PRINT TAB(0,19);"To disable forwarding, just press"'"RETURN for all three values"
 INPUT TAB(0,22);"Enter the network number to forward to:"'fnetwork%
 PRINT TAB(0,23);SPC(40);
 INPUT TAB(0,22);"Enter the station number to forward to:"'fstation%
 PRINT TAB(0,23);SPC(40);
 INPUT TAB(0,22);"Enter the port number to forward to:   "'fport%
ENDPROC
:
DEF PROCauto
 PRINT TAB(0,19);"To disable automated page-turning, just"'"press RETURN"
 REPEAT
  PRINT TAB(0,24);SPC(39);
  INPUT TAB(0,22);"Enter the page-turning interval in"'"seconds (10 to 500): " auto%
 UNTIL auto%=0 OR (auto%>=10 AND auto%<=500)
 PRINT TAB(0,19);"To skip screen-saving on page turns,   "'"just press RETURN"
 PRINT TAB(0,23);SPC(39);
 INPUT TAB(0,22);"Enter the screen filename to save: "'auto$
ENDPROC
:
DEF PROCdelete(dn%,ds%)
 INPUT TAB(0,22);"Enter the network number of the score"'"to delete: " dn%
 PRINT TAB(0,23);SPC(40);
 INPUT TAB(0,22);"Enter the station number of the score"'"to delete: " ds%
 PRINT TAB(0,22);SPC(40);TAB(0,23);SPC(40);
 nomatch%=TRUE
 FOR J%=cmdrs%-1 TO 0 STEP -1
  IF network%(J%)=dn% AND station%(J%)=ds% THEN PROCconfirmDeletion(J%):nomatch%=FALSE
 NEXT
 IF nomatch% THEN PRINT TAB(0,22);"No players found on ";dn%;".";FNpad0(ds%);ds%:PROCbeep(0)
ENDPROC
:
DEF PROCstarCommand
 ON ERROR PROCinlineError(""):PROCstarCommand:PROCmainMenu:PROCmainLoop
 REPEAT
  INPUT "*" C$
  IF C$<>"" THEN OSCLI(C$)
 UNTIL C$=""
 ON ERROR PROCend
ENDPROC
:
DEF PROCconfirmDeletion(cm%)
 S%=station%(cm%)
 PRINT TAB(0,22);"Delete player ";name$(cm%);" on ";network%(cm%);".";FNpad0(S%);S%;" (Y/N)?"
 d$=GET$
 IF NOT(d$="Y" OR d$="y") THEN PRINT TAB(0,23);"Player not deleted":PROCbeep(0):ENDPROC
 IF cmdrs%>1 THEN PROCdeleteCmdr(cm%)
 IF cmdrs%>0 THEN cmdrs%=cmdrs%-1
 PRINT TAB(0,23);"Player deleted"
 PROCbeep(1)
ENDPROC
:
DEF PROCdeleteCmdr(cm%)
 PROCshuffleRows(cm%,0)
 PROCshuffleRows(cm%,1)
 PROCshuffleCmdr(cm%)
ENDPROC
:
DEF PROCshuffleRows(cm%,st%)
 oldrow%=FNfindCmdrRow(cm%,st%)
 IF oldrow%=cmdrs%-1 THEN ENDPROC
 FOR I%=oldrow% TO cmdrs%-2
  rowCmdr%(I%,st%)=rowCmdr%(I%+1,st%)
 NEXT
ENDPROC
:
DEF PROCshuffleCmdr(cm%)
 IF cm%=cmdrs%-1 THEN ENDPROC
 name$(cm%)=name$(cmdrs%-1)
 legal%(cm%)=legal%(cmdrs%-1)
 condition%(cm%)=condition%(cmdrs%-1)
 kills%(cm%)=kills%(cmdrs%-1)
 deaths%(cm%)=deaths%(cmdrs%-1)
 credits%(cm%)=credits%(cmdrs%-1)
 machine%(cm%)=machine%(cmdrs%-1)
 station%(cm%)=station%(cmdrs%-1)
 network%(cm%)=network%(cmdrs%-1)
 FOR I%=0 TO cmdrs%-2
  IF rowCmdr%(I%,0)=cmdrs%-1 THEN rowCmdr%(I%,0)=cm%
  IF rowCmdr%(I%,1)=cmdrs%-1 THEN rowCmdr%(I%,1)=cm%
 NEXT
ENDPROC
:
DEF PROCupdateTable(all%)
 start%=page%*20
 IF start%+19>cmdrs%-1 THEN end%=cmdrs%-1 ELSE end%=start%+19
 FOR R%=start% TO end%
  C%=rowCmdr%(R%,sort%)
  IF all%=1 OR rowUpdt%(R%)=1 THEN PROCprintCmdr(C%,R%+4-start%)
  rowUpdt%(R%)=0
 NEXT
ENDPROC
:
DEF PROCprintCmdr(cm%,row%)
 PRINT TAB(0,row%);SPC(40);
 IF cmrec%=cm% THEN flag$="*":star%=row% ELSE flag$=" "
 N%=network%(cm%):L%=legal%(cm%):S%=station%(cm%)
 PRINT TAB(0,row%);flag$;CHR$(134);M$(machine%(cm%));SPC(3-FNdigits(N%));N%;".";FNpad0(S%);S%;
 K%=kills%(cm%):D%=deaths%(cm%)
 Z%=FNdigits(K%)+FNdigits(D%)
 IF Z%>2 THEN N$=LEFT$(name$(cm%),7-(Z%-2)) ELSE N$=name$(cm%)
 PRINT TAB(12,row%);C$(condition%(cm%));CHR$(172);L$(legal%(cm%));CHR$(134);N$;
 PRINT TAB(28-Z%,row%);CHR$(130);K%;"/";D%;
 K$=" ":M%=credits%(cm%)
 IF M%>99999 AND M%<=99999999 THEN K$="k":M%=M%/1000
 IF M%>99999999 THEN K$="m":M%=M%/1000000
 @%=&2010A:PRINT TAB(37-FNdigits(M%),row%);M%/10;K$;:@%=10
ENDPROC
:
DEF PROCsave(file$)
 IF cmdrs%=0 THEN PRINT TAB(0,24);"There are no scores to save":PROCbeep(1):ENDPROC
 ON ERROR PROCfileError(""):PROCmainMenu:PROCmainLoop
 F%=OPENOUT(file$)
 IF F%=0 THEN PROCfileError("Can't open file"):PROCmainMenu:PROCmainLoop
 PRINT TAB(0,24);"Saving file...";
 PRINT#F%,cmdrs%
 FOR I%=0 TO cmdrs%-1
  PRINT TAB(15,24);INT(100*(I%+1)/cmdrs%);"%";
  PRINT#F%,rowCmdr%(I%,0),rowCmdr%(I%,1),rowUpdt%(I%)
  PRINT#F%,name$(I%),kills%(I%),deaths%(I%)
  PRINT#F%,credits%(I%),condition%(I%),legal%(I%)
  PRINT#F%,machine%(I%),network%(I%),station%(I%)
 NEXT
 PRINT TAB(0,24);"File saved";SPC(9);
 CLOSE#F%
 PROCbeep(1)
 ON ERROR PROCend
ENDPROC
:
DEF PROCload(file$)
 ON ERROR PROCfileError(""):PROCmainMenu:PROCmainLoop
 F%=OPENIN(file$)
 IF F%=0 THEN PROCfileError("Can't open file"):PROCmainMenu:PROCmainLoop
 PRINT TAB(0,24);"Loading file...";
 INPUT#F%,cmdrs%
 FOR I%=0 TO cmdrs%-1
  PRINT TAB(16,24);INT(100*(I%+1)/cmdrs%);"%";
  INPUT#F%,rowCmdr%(I%,0),rowCmdr%(I%,1),rowUpdt%(I%)
  INPUT#F%,name$(I%),kills%(I%),deaths%(I%)
  INPUT#F%,credits%(I%),condition%(I%),legal%(I%)
  INPUT#F%,machine%(I%),network%(I%),station%(I%)
 NEXT
 PRINT TAB(0,24);"File loaded";SPC(9);
 CLOSE#F%
 PROCbeep(1)
 cmrec%=-1
 ON ERROR PROCend
ENDPROC
:
DEF PROCfileError(e$)
 IF e$="" THEN PRINT TAB(0,23);:REPORT ELSE PRINT TAB(0,24);e$;
 PROCbeep(0)
 ON ERROR PROCend
ENDPROC
:
DEF PROCinlineError(e$)
 IF e$="" THEN REPORT:PRINT ELSE PRINT e$
 PROCbeep(0)
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
DEF PROCforward(fs%,fn%,fp%)
 REM Set bytes 17 and 18 of forwarded data to player address
 rxbuffer%?17=cblock%?3
 rxbuffer%?18=cblock%?4
 :
 REM Send forwarded data
 ?cblock%=&80
 cblock%?1=fp%
 cblock%?2=fs%
 cblock%?3=fn%
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
