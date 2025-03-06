REM ElDebug - Traffic monitor for Elite over Econet
REM By Mark Moxon
:
DIM cblock% 40,tblock% 40,rxbuffer% 40
DIM M$(4):M$(0)="BBC B+":M$(1)="Master":M$(2)="6502SP":M$(3)="BBC B":M$(4)="Archimedes"
DIM C$(3):C$(0)="Docked":C$(1)="Green":C$(2)="Yellow":C$(3)="Red"
DIM L$(2):L$(0)="Clean":L$(1)="Offender":L$(2)="Fugitive"
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA:TIME=0
ostation%=0:onetwork%=0:file$=""
A%=0:X%=1:os%=((USR OSBYTE) AND &FF00) DIV 256
:
*FX4,0
*FX200,0
ON ERROR PROCerror
PROCstartMenu
PROCgetStationNumber
PRINT '"This machine's network: ";snetwork%
PRINT "This machine's station: ";FNpad0(sstation%);sstation%
PRINT "Port number: ";port%
PRINT '"Press P to pause"'
IF file$<>"" THEN F%=OPENOUT(file$):PROClogHeader
:
REPEAT
  PROCreceive
  IF file$<>"" THEN PROClogData ELSE PROCprintData
  IF fstation%>0 AND fport%>0 THEN PROCforward
UNTIL FALSE
:
DEF PROCerror
  REPORT
  PRINT " at line ";ERL
  IF file$<>"" THEN PRINT "Closing log file":CLOSE#F%
  END
ENDPROC
:
DEF PROCstartMenu
  CLS
  PRINT TAB(5,0);CHR$(141);"Elite over Econet Debug Tool"
  PRINT TAB(5,1);CHR$(141);"Elite over Econet Debug Tool"
  PRINT '"Please enter the port number to monitor:"
  INPUT port%
  PRINT '"Please enter the name of the log file"'"(press Return to skip):"
  INPUT file$
  PRINT '"Please enter the network number to"'"forward to (press Return to skip):"
  INPUT fnetwork%
  PRINT '"Please enter the station number to"'"forward to (press Return to skip):"
  INPUT fstation%
  PRINT '"Please enter the port number to"'"forward to (press Return to skip):"
  INPUT fport%
ENDPROC
:
DEF PROCprocessKeys
  K%=INKEY(0)
  IF K%=ASC("P") THEN PRINT'"Paused - press R to resume":REPEAT:UNTIL INKEY(0)=ASC("R")
ENDPROC
:
DEF PROCprintData
  IF os%>2 THEN PRINT '"Timestamp: ";TIME$ ELSE PRINT '"Timestamp: ";TIME
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
ENDPROC
:
DEF PROClogHeader
  PRINT "Logging to: ";file$
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
DEF PROClogData
  IF os%>2 THEN PRINT "Timestamp: ";TIME$:PROClogStringTab(TIME$) ELSE PRINT "Timestamp: ";TIME:PROClogStringTab(STR$(TIME))
  PROClogNumber(cblock%?2):REM Port
  PROClogNumber(cblock%?4):REM Player network
  PROClogNumber(cblock%?3):REM Player station
  PROClogStringTab($rxbuffer%):REM Player name
  PROClogStringTab(L$(rxbuffer%?8)):REM Legal status
  PROClogStringTab(C$(rxbuffer%?9)):REM Condition
  PROClogNumber(rxbuffer%?10):REM Kills
  PROClogNumber(rxbuffer%?11):REM Deaths
  PROClogNumber((rxbuffer%!12)/10):REM Credits
  PROClogStringTab(M$(rxbuffer%?16)):REM Machine type
  IF rxbuffer%?17>0 THEN PROClogNumber(onetwork%):PROClogString(STR$(ostation%)) ELSE BPUT#F%,9
  BPUT#F%,13
  BPUT#F%,10
ENDPROC
:
DEF PROClogNumber(n)
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
