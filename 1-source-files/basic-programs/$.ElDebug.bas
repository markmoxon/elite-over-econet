REM ElDebug - Traffic monitor for Elite over Econet
REM By Mark Moxon
:
max%=99
DIM cblock% 40,tblock% 40,rxbuffer% 40
DIM fstation%(4),fnetwork%(4),fport%(4),fname$(4)
DIM dM$(5):dM$(0)="BBC B+":dM$(1)="Master":dM$(2)="6502SP"
dM$(3)="BBC B":dM$(4)="Archimedes":dM$(5)="Electron"
DIM dC$(3):dC$(0)="Docked":dC$(1)="Green":dC$(2)="Yellow":dC$(3)="Red"
DIM dL$(2):dL$(0)="Clean":dL$(1)="Offender":dL$(2)="Fugitive"
DIM cname$(24):cname$(0)="ALEX":cname$(1)="ELYSSIA":cname$(2)="JAMESON"
cname$(3)="RAXXLA":cname$(4)="RAFE":cname$(5)="LISTER":cname$(6)="RIMMER"
cname$(7)="HAN":cname$(8)="LEIA":cname$(9)="YODA":cname$(10)="ARTHUR"
cname$(11)="LUKE":cname$(12)="SPOCK":cname$(13)="KIRK":cname$(14)="RIPLEY"
cname$(15)="DECKARD":cname$(16)="ZAPHOD":cname$(17)="PICARD":cname$(18)="FORD"
cname$(19)="MARVIN":cname$(20)="R2D2":cname$(21)="C3PO":cname$(22)="ORAC"
cname$(23)="FLASH":cname$(24)="HAL"
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA:TIME=0
ostation%=0:onetwork%=0:log$="":fcount%=0
A%=0:X%=1:os%=((USR OSBYTE) AND &FF00) DIV 256
:
*FX4,0
*FX200,0
MODE 7
ON ERROR PROCerror
choice%=FNstartMenu
IF choice%>=4 THEN END
PROCgetStationNumber
thisStn$=STR$(snetwork%)+"."+FNpad0(sstation%)+STR$(sstation%)
PRINT '"This machine: ";thisStn$
IF choice%=1 OR choice%=2 THEN PRINT "Receiving scores on port number: ";port%
IF log$<>"" THEN F%=OPENOUT(log$):PROClogHeader:PRINT "Logging configured to ";log$
PROCforwardNames
IF choice%=1 OR choice%=2 THEN PROCprintForwarding
IF choice%=3 THEN PRINT "Sending test data to ";fname$(0)
PRINT '"Press P at any time to pause"
PRINT '"Press any key to start":a$=GET$:PRINT'"Starting..."
:
IF choice%=3 THEN PROCinitTestCmdrs
REPEAT
 IF choice%=1 THEN PROCmonitorLoop
 IF choice%=2 THEN PROCforwardLoop
 IF choice%=3 THEN PROCtestLoop
UNTIL FALSE
:
DEF PROCerror
 REPORT
 PRINT " at line ";ERL
 IF log$<>"" THEN PRINT "Closing log file":CLOSE#F%
 END
ENDPROC
:
DEF PROCprintTitle
 CLS
 PRINT TAB(5,0);CHR$(141);"Elite over Econet Debug Tool"
 PRINT TAB(5,1);CHR$(141);"Elite over Econet Debug Tool"
ENDPROC

DEF FNstartMenu
 PROCprintTitle
 PRINT '"Please choose an option:"
 PRINT '"1. Monitor and log scoreboard traffic"
 PRINT '"2. Forward scores to multiple stations"
 PRINT '"3. Generate test scoreboard traffic"
 PRINT '"4. Convert a score file to TSV"
 PRINT '"5. Merge score files"
 PRINT '"6. Quit"
 INPUT '"Enter a number to continue: " a$
 IF a$="1" THEN PROCmonitorMenu:=1
 IF a$="2" THEN PROCforwardMenu:=2
 IF a$="3" THEN PROCtestMenu:=3
 IF a$="4" THEN PROCtsvMenu:=4
 IF a$="5" THEN PROCmergeMenu:=5
=6
:
DEF PROCmonitorMenu
 PROCprintTitle
 PRINT '"Option chosen:"
 PRINT '"1. Monitor and log scoreboard traffic"
 INPUT '"Enter the port number to monitor: " port%
 PRINT '"Press RETURN to skip an option"
 INPUT '"Enter the filename of the log file: "'log$
 INPUT '"Enter the network number of the"'"forwarding destination: " fnetwork%(0)
 INPUT '"Enter the station number of the"'"forwarding destination: " fstation%(0)
 INPUT '"Enter the port number of the"'"forwarding destination: " fport%(0)
 fcount%=1
ENDPROC
:
DEF PROCforwardMenu
 PROCprintTitle
 PRINT '"Option chosen:"
 PRINT '"2. Forward scores to multiple stations"
 INPUT '"Enter the port number to receive on: " port%
 PRINT '"Press RETURN for all three questions"'"to stop configuring stations"
 I%=0:end%=FALSE
 REPEAT
  PRINT '"Enter the network number of forwarding"'"destination ";STR$(I%+1);": ";
  INPUT fnetwork%(I%)
  PRINT '"Enter the station number of forwarding"'"destination ";STR$(I%+1);": ";
  INPUT fstation%(I%)
  PRINT '"Enter the port number of forwarding"'"destination ";STR$(I%+1);": ";
  INPUT fport%(I%)
  I%=I%+1
 UNTIL I%=5 OR fstation%(I%-1)=0
 fcount%=I%
ENDPROC
:
DEF PROCtestMenu
 PROCprintTitle
 PRINT '"Option chosen:"
 PRINT '"3. Generate test scoreboard traffic"
 INPUT '"Please enter the network number of the"'"scoreboard to test: " fnetwork%(0)
 INPUT '"Please enter the station number of the"'"scoreboard to test: " fstation%(0)
 INPUT '"Please enter the port number of the"'"scoreboard to test: " fport%(0)
 INPUT '"Please enter the number of players"'"to emulate: " cmdrs%
 fcount%=1
 DIM name$(cmdrs%),credits%(cmdrs%),kills%(cmdrs%),deaths%(cmdrs%)
 DIM machine%(cmdrs%),condition%(cmdrs%),legal%(cmdrs%),network%(cmdrs%),station%(cmdrs%)
ENDPROC
:
DEF PROCtsvMenu
 PROCprintTitle
 PRINT '"Option chosen:"
 PRINT '"4. Convert a score file to TSV"
 INPUT '"Please enter the filename to load: "'ifile$
 INPUT '"Please enter the filename to save: "'ofile$
 F%=OPENIN(ifile$)
 INPUT#F%,cmdrs%
 DIM rowCmdr%(cmdrs%,1),rowUpdt%(cmdrs%)
 DIM name$(cmdrs%),credits%(cmdrs%),kills%(cmdrs%),deaths%(cmdrs%)
 DIM machine%(cmdrs%),condition%(cmdrs%),legal%(cmdrs%),network%(cmdrs%),station%(cmdrs%)
 PROCload(ifile$,cmdrs%)
 PROCsaveTSV(ofile$,cmdrs%)
ENDPROC
:
DEF PROCmergeMenu
 PROCprintTitle
 PRINT '"Option chosen:"
 PRINT '"5. Merge score files"
 INPUT '"Please enter the first filename: "'file1$
 INPUT '"Please enter the second filename: "'file2$
 INPUT '"Please enter the filename to save: "'ofile$
 F%=OPENIN(file1$)
 INPUT#F%,cmdrs1%
 G%=OPENIN(file2$)
 INPUT#G%,cmdrs2%
 cmdrs%=cmdrs1%+cmdrs2%
 truncateWarn%=FALSE
 IF cmdrs%>max%+1 THEN PROCtruncateWarning:cmdrs%=max%+1
 DIM rowCmdr%(max%+1,1),rowUpdt%(max%+1)
 DIM name$(max%+1),credits%(max%+1),kills%(max%+1),deaths%(max%+1)
 DIM machine%(max%+1),condition%(max%+1),legal%(max%+1),network%(max%+1),station%(max%+1)
 PROCload(file1$,cmdrs1%)
 PROCmerge(file2$,cmdrs1%,cmdrs2%)
 PROCsave(ofile$,cmdrs%)
ENDPROC
:
DEF PROCtruncateWarning
 truncateWarn%=TRUE
 PRINT '"File ";file1$;" contains ";cmdrs1%;" scores"
 PRINT "File ";file2$;" contains ";cmdrs2%;" scores"
 PRINT '"That's a total of ";cmdrs%;" scores"
 PRINT '"The maximum in one file is ";max%+1;" scores"
 PRINT '"If there are any scores that don't fit"
 PRINT "then I will list them at the end"
ENDPROC
:
DEF PROCmonitorLoop
 PROCreceive
 t$=FNprintData
 IF log$<>"" THEN PROClogData(t$)
 IF fstation%(0)>0 AND fport%(0)>0 THEN PRINT "Forwarding to: ";f$:PROCforward(fstation%(0),fnetwork%(0),fport%(0))
ENDPROC
:
DEF PROCforwardLoop
 PROCreceive
 FOR I%=0 TO fcount%-1
  IF fstation%(I%)>0 AND fport%(I%)>0 THEN PRINT "Forwarding from ";thisStn$;" to ";fname$(I%):PROCforward(fstation%(I%),fnetwork%(I%),fport%(I%))
 NEXT
ENDPROC
:
DEF PROCtestLoop
 I%=RND(cmdrs%)-1
 PROCupdateCmdr(I%)
 PROCprocessKeys
 PROCpause
ENDPROC
:
DEF PROCprocessKeys
 K%=INKEY(0)
 IF K%=ASC("P") THEN PRINT'"Paused - press R to resume":REPEAT:UNTIL INKEY(0)=ASC("R")
ENDPROC
:
DEF PROCforwardNames
 FOR I%=0 TO fcount%-1
  IF fstation%(I%)>0 AND fport%(I%)>0 THEN fname$(I%)=STR$(fnetwork%(I%))+"."+FNpad0(fstation%(I%))+STR$(fstation%(I%))
 NEXT
ENDPROC
:
DEF PROCprintForwarding
 FOR I%=0 TO fcount%-1
  IF fstation%(I%)>0 AND fport%(I%)>0 THEN PRINT "Forwarding configured to ";fname$(I%)
 NEXT
ENDPROC
:
DEF FNprintData
 IF os%>2 THEN t$=TIME$ ELSE t$=STR$(TIME)
 IF os%>2 THEN PRINT '"Timestamp: ";t$ ELSE PRINT '"Timestamp: ";t$
 IF rxbuffer%?17>0 THEN PRINT "Data forwarded from: ";onetwork%;".";FNpad0(ostation%);ostation%
 PRINT "Data received by ";thisStn$;" on port ";cblock%?2
 PRINT "Player address: ";cblock%?4;".";FNpad0(cblock%?3);cblock%?3
 rxbuffer%?7=13:PRINT "Player name: ";$rxbuffer%
 PRINT "Legal status: ";rxbuffer%?8
 PRINT "Condition: ";rxbuffer%?9
 PRINT "Kills: ";rxbuffer%?10+256*rxbuffer%?19
 PRINT "Deaths: ";rxbuffer%?11
 PRINT "Credits: ";(rxbuffer%!12)/10
 PRINT "Machine type: ";rxbuffer%?16
=t$
:
DEF PROClogHeader
 PROClogStringTab("Time")
 PROClogStringTab("Port")
 PROClogStringTab("Player network")
 PROClogStringTab("Player station")
 PROClogStringTab("Player name")
 PROClogStringTab("Legal status")
 PROClogStringTab("Condition")
 PROClogStringTab("Kills")
 PROClogStringTab("Deaths")
 PROClogStringTab("Credits")
 PROClogStringTab("Machine type")
 PROClogStringTab("Forwarded from network")
 PROClogString("Forwarded from station")
 BPUT#F%,13
 BPUT#F%,10
ENDPROC
:
DEF PROClogData(t$)
 PRINT "Logging to: ";log$
 PROClogStringTab(t$)
 PROClogNumberTab(cblock%?2):REM Port
 PROClogNumberTab(cblock%?4):REM Player network
 PROClogNumberTab(cblock%?3):REM Player station
 rxbuffer%?7=13:PROClogStringTab($rxbuffer%):REM Player name
 PROClogStringTab(dL$(rxbuffer%?8)):REM Legal status
 PROClogStringTab(dC$(rxbuffer%?9)):REM Condition
 PROClogNumberTab(rxbuffer%?10+256*rxbuffer%?19):REM Kills
 PROClogNumberTab(rxbuffer%?11):REM Deaths
 PROClogNumberTab((rxbuffer%!12)/10):REM Credits
 PROClogStringTab(dM$(rxbuffer%?16)):REM Machine type
 IF rxbuffer%?17>0 THEN PROClogNumberTab(onetwork%):PROClogString(STR$(ostation%)) ELSE BPUT#F%,9
 BPUT#F%,13
 BPUT#F%,10
ENDPROC
:
DEF PROClogNumberTab(n)
 PROClogString(STR$(n))
 BPUT#F%,9
ENDPROC
:
DEF PROClogStringTab(s$)
 PROClogString(s$)
 BPUT#F%,9
ENDPROC
:
DEF PROClogString(s$)
 IF s$="" THEN ENDPROC
 FOR J%=1 TO LEN(s$)
  BPUT#F%,ASC(MID$(s$,J%,1))
 NEXT
ENDPROC
:
DEF PROCinitTestCmdrs
 FOR I%=0 TO cmdrs%-1
  IF I%>=25 THEN name$(I%)=LEFT$(cname$(I% MOD 25),6)+STR$(I% DIV 25) ELSE name$(I%)=cname$(I% MOD 25)
  legal%(I%)=0
  condition%(I%)=0
  kills%(I%)=0
  deaths%(I%)=0
  credits%(I%)=1000
  machine%(I%)=RND(5)-1
  network%(I%)=RND(127)
  station%(I%)=RND(250)
  PROCsendCmdr(I%)
  PROCprocessKeys
  PROCpause
 NEXT
ENDPROC
:
DEF PROCsendCmdr(cm%)
 PRINT "Sending data for ";name$(cm%);" to ";fname$(0)
 $rxbuffer%=name$(cm%)
 rxbuffer%?8=legal%(cm%)
 rxbuffer%?9=condition%(cm%)
 rxbuffer%?10=kills%(cm%) MOD 256
 rxbuffer%?19=kills%(cm%) DIV 256
 rxbuffer%?11=deaths%(cm%)
 rxbuffer%!12=credits%(cm%)
 rxbuffer%?16=machine%(cm%)
 cblock%?3=station%(cm%)
 cblock%?4=network%(cm%)
 PROCforward(fstation%(0),fnetwork%(0),fport%(0))
ENDPROC
:
DEF PROCupdateCmdr(cm%)
 IF RND(7)=1 THEN legal%(I%)=RND(3)-1
 IF RND(5)=1 THEN condition%(I%)=RND(4)-1
 IF RND(4)=1 THEN kills%(I%)=kills%(I%)+1
 IF RND(10)=1 AND deaths%(I%)<255 THEN deaths%(I%)=deaths%(I%)+1
 IF RND(4)=1 THEN credits%(I%)=credits%(I%)+RND(1000)
 PROCsendCmdr(cm%)
ENDPROC
:
DEF PROCsave(file$,size%)
 PRINT '"Saving file ";file$;"...";
 F%=OPENOUT(file$)
 PRINT#F%,size%
 FOR I%=0 TO size%-1
  PRINT ".";
  PRINT#F%,rowCmdr%(I%,0),rowCmdr%(I%,1),rowUpdt%(I%)
  PRINT#F%,name$(I%),kills%(I%),deaths%(I%)
  PRINT#F%,credits%(I%),condition%(I%),legal%(I%)
  PRINT#F%,machine%(I%),network%(I%),station%(I%)
 NEXT
 PRINT ''"File ";file$;" saved"
 CLOSE#F%
ENDPROC
:
DEF PROCload(file$,size%)
 PRINT '"Loading file ";file$;"...";
 FOR I%=0 TO size%-1
  PRINT ".";
  INPUT#F%,rowCmdr%(I%,0),rowCmdr%(I%,1),rowUpdt%(I%)
  INPUT#F%,name$(I%),kills%(I%),deaths%(I%)
  INPUT#F%,credits%(I%),condition%(I%),legal%(I%)
  INPUT#F%,machine%(I%),network%(I%),station%(I%)
 NEXT
 PRINT ''"File ";file$;" loaded"
 CLOSE#F%
ENDPROC
:
DEF PROCmerge(file$,start%,size%)
 PRINT '"Merging file ";file$;"...";
 truncate$=""
 C%=start%
 FOR I%=start% TO start%+size%-1
  PRINT ".";
  INPUT#G%,rowCmdr%(C%,0),rowCmdr%(C%,1),rowUpdt%(C%)
  INPUT#G%,name$(C%),kills%(C%),deaths%(C%)
  INPUT#G%,credits%(C%),condition%(C%),legal%(C%)
  INPUT#G%,machine%(C%),network%(C%),station%(C%)
  rowCmdr%(C%,0)=C%:rowCmdr%(C%,1)=C%:rowUpdt%(C%)=0
  M%=FNfindCmdr(name$(C%),network%(C%),station%(C%),start%)
  IF M%>=0 THEN PROCmergeCmdr(M%,C%) ELSE C%=C%+1
  IF C%>max%+1 THEN C%=max%+1:truncate$=truncate$+CHR$(10)+CHR$(13)+STR$(network%(C%))+"."+FNpad0(station%(C%))+STR$(station%(C%))+" "+name$(C%)
 NEXT
 cmdrs%=C%
 PRINT ''"Sorting by kills...";
 PROCquickSort(0,cmdrs%,0)
 PRINT ''"Sorting by credits...";
 PROCquickSort(0,cmdrs%,1)
 PRINT ''"File ";file$;" merged"
 IF truncate$<>"" THEN PRINT '"There was no room for the following"'"scores from file ";file$;":"'truncate$ ELSE IF truncateWarn% THEN PRINT '"All scores were successfully merged"
 CLOSE#G%
ENDPROC
:
DEF PROCmergeCmdr(old%,new%)
 IF kills%(new%)<kills%(old%) OR deaths%(new%)>deaths%(old%) THEN ENDPROC
 IF kills%(new%)>kills%(old%) OR deaths%(new%)<deaths%(old%) THEN PROCcopyCmdr(old%,new%):ENDPROC
 IF credits%(new%)>credits%(old%) PROCcopyCmdr(old%,new%)
ENDPROC
:
DEF PROCcopyCmdr(old%,new%)
 PRINT "Copy (";STR$(old%)";";STR$(new%)")"
 kills%(old%)=kills%(new%)
 deaths%(old%)=deaths%(new%)
 credits%(old%)=credits%(new%)
 condition%(old%)=condition%(new%)
 legal%(old%)=legal%(new%)
ENDPROC
:
DEF PROCsaveTSV(file$,size%)
 PRINT '"Saving TSV file ";file$;"...";
 F%=OPENOUT(file$)
 PROCtsvHeader
 FOR I%=0 TO size%-1
  PRINT ".";
  PROCtsvData(I%)
 NEXT
 PRINT ''"TSV file ";file$;" saved"
 CLOSE#F%
ENDPROC
:
DEF PROCtsvHeader
 PROClogStringTab("Machine type")
 PROClogStringTab("Player network")
 PROClogStringTab("Player station")
 PROClogStringTab("Condition")
 PROClogStringTab("Legal status")
 PROClogStringTab("Player name")
 PROClogStringTab("Kills")
 PROClogStringTab("Deaths")
 PROClogString("Credits")
 BPUT#F%,13
 BPUT#F%,10
ENDPROC
:
DEF PROCtsvData(row%)
 cm%=rowCmdr%(row%,0)
 PROClogStringTab(dM$(machine%(cm%)))
 PROClogNumberTab(network%(cm%))
 PROClogNumberTab(station%(cm%))
 PROClogStringTab(dC$(condition%(cm%)))
 PROClogStringTab(dL$(legal%(cm%)))
 PROClogStringTab(name$(cm%))
 PROClogNumberTab(kills%(cm%))
 PROClogNumberTab(deaths%(cm%))
 cr$=STR$(credits%(cm%) DIV 10)+"."+STR$(credits%(cm%) MOD 10)
 PROClogString(cr$)
 BPUT#F%,13
 BPUT#F%,10
ENDPROC
:
DEF PROCsortCmdr(cm%,st%,thisRow%)
 size%=thisRow%+1
 REPEAT
  sorted%=TRUE
  IF thisRow%=0 THEN prevCm%=-1 ELSE prevCm%=rowCmdr%(thisRow%-1,st%)
  IF thisRow%=size%-1 THEN nextCm%=-1 ELSE nextCm%=rowCmdr%(thisRow%+1,st%)
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
ENDPROC
:
DEF FNkillScore(cm%)
=100000*kills%(cm%)-deaths%(cm%)
:
DEF PROCquickSort(start%,size%,st%)
  LOCAL pivot%,left%,right%,end%
  IF size%<2 THEN ENDPROC
  end%=start%+size%-1
  left%=start%:right%=end%:P%=(left%+right%)DIV2
  IF st%=0 THEN pivot%=FNkillScore(rowCmdr%(P%,st%)) ELSE pivot%=credits%(rowCmdr%(P%,st%))
  REPEAT
    PRINT ".";
    REPEAT
      IF st%=0 THEN V%=FNkillScore(rowCmdr%(left%,st%)) ELSE V%=credits%(rowCmdr%(left%,st%))
      IF V%>pivot% THEN left%=left%+1:done%=FALSE ELSE done%=TRUE
    UNTIL done%
    REPEAT
      IF st%=0 THEN V%=FNkillScore(rowCmdr%(right%,st%)) ELSE V%=credits%(rowCmdr%(right%,st%))
      IF V%<pivot% THEN right%=right%-1:done%=FALSE ELSE done%=TRUE
    UNTIL done%
    IF left%<=right% THEN PROCswapRow(left%,right%,st%):left%=left%+1:right%=right%-1
  UNTIL left%>right%
  IF start%<right% THEN PROCquickSort(start%,right%-start%+1,st%)
  IF left%<end% THEN PROCquickSort(left%,end%-left%+1,st%)
ENDPROC
:
DEF FNfindCmdr(nm$,nw%,st%,start%)
 match%=-1
 FOR J%=0 TO start%-1
  IF station%(J%)=st% AND network%(J%)=nw% AND name$(J%)=nm$ THEN match%=J%:J%=start%-1
 NEXT
=match%
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
