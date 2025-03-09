REM ElDebug - Traffic monitor for Elite over Econet
REM By Mark Moxon
:
DIM cblock% 40,tblock% 40,rxbuffer% 40
DIM fstation%(4),fnetwork%(4),fport%(4),fname$(4)
DIM dM$(4):dM$(0)="BBC B+":dM$(1)="Master":dM$(2)="6502SP":dM$(3)="BBC B":dM$(4)="Archimedes"
DIM dC$(3):dC$(0)="Docked":dC$(1)="Green":dC$(2)="Yellow":dC$(3)="Red"
DIM dL$(2):dL$(0)="Clean":dL$(1)="Offender":dL$(2)="Fugitive"
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA:TIME=0
ostation%=0:onetwork%=0:file$="":fcount%=0
A%=0:X%=1:os%=((USR OSBYTE) AND &FF00) DIV 256
:
*FX4,0
*FX200,0
MODE 7
ON ERROR PROCerror
choice%=FNstartMenu
IF choice%=4 THEN END
PROCgetStationNumber
PRINT '"This machine's network: ";snetwork%
PRINT "This machine's station: ";FNpad0(sstation%);sstation%
IF choice%=1 OR choice%=2 THEN PRINT "Receiving scores on port number: ";port%
IF file$<>"" THEN F%=OPENOUT(file$):PROClogHeader:PRINT "Logging configured to ";file$
PROCforwardNames
IF choice%=1 OR choice%=2 THEN PROCprintForwarding
IF choice%=3 THEN PRING "Sending test data to ";fname$(0)
PRINT '"Press P at any time to pause"
PRINT '"Press any key to start":a$=GET$
:
IF choice%=3 THEN PROCinitCmdrs
REPEAT
  IF choice%=1 THEN PROCmonitorLoop
  IF choice%=2 THEN PROCforwardLoop
  IF choice%=3 THEN PROCtestLoop
UNTIL FALSE
:
DEF PROCerror
  REPORT
  PRINT " at line ";ERL
  IF file$<>"" THEN PRINT "Closing log file":CLOSE#F%
  END
ENDPROC
:
DEF FNstartMenu
  PRINT TAB(5,0);CHR$(141);"Elite over Econet Debug Tool"
  PRINT TAB(5,1);CHR$(141);"Elite over Econet Debug Tool"
  PRINT '"Please choose an option:"
  PRINT '"1. Monitor and log scoreboard traffic"
  PRINT '"2. Forward scores to multiple stations"
  PRINT '"3. Generate test scoreboard traffic"
  PRINT '"4. Quit"
  INPUT '"Enter a number to continue: " a$
  IF a$="1" THEN PROCmonitorMenu:=1
  IF a$="2" THEN PROCforwardMenu:=2
  IF a$="3" THEN PROCtestMenu:=3
=4
:
DEF PROCmonitorMenu
  PRINT '"Option chosen:"
  PRINT '"1. Monitor and log scoreboard traffic"
  INPUT '"Enter the port number to monitor: " port%
  PRINT '"Press Return to skip the following"'"options"
  INPUT '"Enter the full filename of the log file"'"(e.g. &.SCORES): " file$
  INPUT '"Enter the network number of the"'"forwarding destination: " fnetwork%(0)
  INPUT '"Enter the station number of the"'"forwarding destination: " fstation%(0)
  INPUT '"Enter the port number of the"'"forwarding destination: " fport%(0)
  fcount%=1
ENDPROC
:
DEF PROCforwardMenu
  PRINT '"Option chosen:"
  PRINT '"2. Forward scores to multiple stations"
  INPUT '"Enter the port number to receive: " port%
  PRINT '"Press Return to stop configuring stations"
  I%=0:end%=FALSE
  REPEAT
    INPUT '"Enter the network number of forwarding"'"destination ";I%;": " fnetwork%(I%)
    IF fnetwork%(I%)<>0 THEN INPUT '"Enter the station number of forwarding"'"destination ";I%;": " fstation%(I%)
    IF fnetwork%(I%)<>0 THEN INPUT '"Enter the port number of forwarding"'"destination ";I%;": " fport%(I%)
    I%=I%+1
  UNTIL I%=5 OR fnetwork%(I%-1)=0
  fcount%=I%
ENDPROC
:
DEF PROCtestMenu
  PRINT '"Option chosen:"
  PRINT '"3. Generate test scoreboard traffic"
  INPUT '"Please enter the network number of the"'"scoreboard to test: " fnetwork%(0)
  INPUT '"Please enter the station number of the"'"scoreboard to test: " fstation%(0)
  INPUT '"Please enter the port number of the"'"scoreboard to test: " fport%(0)
  INPUT '"Please enter the number of players"'"to emulate: " max%
  max%=max%-1
  fcount%=1
  DIM name$(max%),credits%(max%),kills%(max%),deaths%(max%)
  DIM machine%(max%),condition%(max%),legal%(max%),network%(max%),station%(max%)
ENDPROC
:
DEF PROCmonitorLoop
  PROCreceive
  t$=FNprintData
  IF file$<>"" THEN PROClogData(t$)
  IF fstation1%>0 AND fport1%>0 THEN PRINT "Forwarding to: ";f$:PROCforward(fstation1%,fnetwork1%,fport1%)
ENDPROC
:
DEF PROCforwardLoop
  PROCreceive
  FOR I%=0 TO fcount%-1
    IF fstation%(I%)>0 AND fport%(I%)>0 THEN PRINT "Forwarding to: ";fname$(I%)$:PROCforward(fstation%(I%),fnetwork%(I%),fport%(I%))
  NEXT
ENDPROC
:
DEF PROCtestLoop
  I%=RND(max%+1)-1
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
    IF fstation%(I%)>0 AND fport%(I%)>0 THEN fname$(I%)=STR$(fnetwork%(I%))+"."+FNpad0(fstation%(I%))+STR$(fstation%(I%)):PRINT "Forwarding configured to ";fname$(I%)
  NEXT
ENDPROC
:
DEF PROCprintForwarding
  FOR I%=0 TO fcount%-1
    PRINT "Forwarding configured to ";fname$(I%)
  NEXT
ENDPROC
:
DEF FNprintData
  IF os%>2 THEN t$=TIME$ ELSE t$=STR$(TIME)
  IF os%>2 THEN PRINT '"Timestamp: ";t$ ELSE PRINT '"Timestamp: ";t$
  IF rxbuffer%?17>0 THEN PRINT "Data has been forwarded from: ";onetwork%;".";FNpad0(ostation%);ostation%
  PRINT "Data received on port: ";cblock%?2
  PRINT "Player address: ";cblock%?4;".";FNpad0(cblock%?3);cblock%?3
  PRINT "Player name: ";$rxbuffer%
  PRINT "Legal status: ";rxbuffer%?8
  PRINT "Condition: ";rxbuffer%?9
  PRINT "Kills: ";rxbuffer%?10
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
  PRINT "Logging to: ";file$
  PROClogStringTab(t$)
  PROClogNumberTab(cblock%?2):REM Port
  PROClogNumberTab(cblock%?4):REM Player network
  PROClogNumberTab(cblock%?3):REM Player station
  PROClogStringTab($rxbuffer%):REM Player name
  PROClogStringTab(dL$(rxbuffer%?8)):REM Legal status
  PROClogStringTab(dC$(rxbuffer%?9)):REM Condition
  PROClogNumberTab(rxbuffer%?10):REM Kills
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
  FOR I%=1 TO LEN(s$)
    BPUT#F%,ASC(MID$(s$,I%,1))
  NEXT
ENDPROC
:
DEF PROCinitCmdrs
  FOR I%=0 TO max%
    name$(I%)="Cmdr"+STR$(I%)
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
  PRINT "Sending data for ";name$(cm%)
  $rxbuffer%=name$(cm%)
  rxbuffer%?8=legal%(cm%)
  rxbuffer%?9=condition%(cm%)
  rxbuffer%?10=kills%(cm%)
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
  IF RND(10)=1 THEN deaths%(I%)=deaths%(I%)+1
  IF RND(4)=1 THEN credits%(I%)=credits%(I%)+RND(1000)
  PROCsendCmdr(cm%)
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
