REM ElDebug - Traffic monitor for Elite over Econet
REM By Mark Moxon
:
DIM cblock% 40,tblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA:TIME=0
A%=0:X%=1:os%=((USR OSBYTE) AND &FF00) DIV 256
*FX4,0
*FX200,0
:
PROCstartMenu
PROCgetStationNumber
PRINT '"This machine's network: ";snetwork%
PRINT "This machine's station: ";sstation%
PRINT "Port number: ";port%
:
REPEAT
  PROCreceive
  PROCprintData
  IF fstation%>0 AND fport%>0 THEN PROCforward
UNTIL FALSE
:
DEF PROCstartMenu
  CLS
  PRINT TAB(6,0);"Elite over Econet Debug Tool"
  PRINT TAB(6,1);"----------------------------"
  PRINT '"Please enter the port number to monitor:"
  INPUT port%
  PRINT '"Please enter the network number to"'"forward to (0 for no forwarding):"
  INPUT fnetwork%
  PRINT '"Please enter the station number to"'"forward to (0 for no forwarding):"
  INPUT fstation%
  PRINT '"Please enter the port number to"'"forward to (0 for no forwarding):"
  INPUT fport%
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
DEFPROCprintData
  IF os%>2 THEN PRINT '"Timestamp: ";TIME$ ELSE PRINT '"Timestamp: ";TIME
  PRINT "Player name: ";$rxbuffer%
  PRINT "Legal status: ";rxbuffer%?8
  PRINT "Condition: ";rxbuffer%?9
  PRINT "Kills: ";rxbuffer%?10
  PRINT "Deaths: ";rxbuffer%?11
  PRINT "Credits: ";(rxbuffer%!12)/10
  PRINT "Machine type: ";rxbuffer%?16
  PRINT "Player network: ";cblock%?4
  PRINT "Player station: ";cblock%?3
  PRINT "Port: ";cblock%?2
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
