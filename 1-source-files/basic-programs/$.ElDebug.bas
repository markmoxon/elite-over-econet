REM ElDebug - Traffic monitor for Elite over Econet
REM By Mark Moxon
:
DIM cblock% 40,tblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA:TIME=0
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
  PRINT '"Please enter the port number to"'"forward to (0 for no forwarding):"
  INPUT fport%
  PRINT '"Please enter the network number to"'"forward to (0 for no forwarding):"
  INPUT fnetwork%
  PRINT '"Please enter the station number to"'"forward to (0 for no forwarding):"
  INPUT fstation%
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
  UNTIL (U% AND &8000)<>0
  REM Read control block back
  X%=cblock%:Y%=cblock% DIV 256:A%=&11
  ?cblock%=rxcb_number%:CALL OSWORD
ENDPROC
:
DEFPROCprintData
  PRINT '"Timestamp: ";TIME
  PRINT "Player name: ";$rxbuffer%
  PRINT "Legal status: ";rxbuffer%?8
  PRINT "Condition: ";rxbuffer%?9
  PRINT "Kills: ";rxbuffer%?10
  PRINT "Deaths: ";rxbuffer%?11
  PRINT "Credits: ";(rxbuffer%!12)/10
  PRINT "Machine type: ";rxbuffer%?16
  PRINT "Port: ";cblock%?2
  PRINT "Player station: ";cblock%?3
  PRINT "Player network: ";cblock%?4
ENDPROC
:
DEF PROCforward
  ?cblock%=&80:cblock%?1=fport%:cblock%?2=fstation%:cblock%?3=fnetwork%
  cblock%!4=rxbuffer%:cblock%!8=rxbuffer%+20
  X%=cblock%:Y%=cblock% DIV 256:A%=16:CALL OSWORD
ENDPROC
:
DEF PROCgetStationNumber
  X%=cblock%:Y%=cblock% DIV 256:A%=&13:!cblock%=8:CALL OSWORD
  sstation%=cblock%?1
  IF PAGE>&8000 THEN A%=0 ELSE A%=1:X%=&70:Y%=0:CALL OSARGS
  IF A%=5 THEN snetwork%=FNdoBridgeQuery ELSE snetwork%=FNgetNetworkNumber
ENDPROC
:
DEF FNgetNetworkNumber
  X%=cblock%:Y%=cblock% DIV 256:A%=&13:?cblock%=17:cblock%!1=0:CALL OSWORD
=cblock%?1
:
DEF FNdoBridgeQuery
  REM Open RECEIVE block on port &8A, read control block number
  ?cblock%=0
  cblock%?1=&7F
  cblock%?2=&8A
  cblock%!3=0
  cblock%!5=rxbuffer%
  cblock%!9=rxbuffer%+20
  X%=cblock%:Y%=cblock% DIV 256:A%=&11:CALL OSWORD
  rxcb_number%=?cblock%
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
    X%=tblock%:Y%=tblock% DIV 256:A%=&10:CALL OSWORD
    :
    REM Wait for broadcast to be sent
    A%=&32
    REPEAT
      U%=USR OSBYTE
    UNTIL (U% AND &8000)<>0
    X%=(U% AND &FF00) DIV &100
    attempts%=attempts%-1
  UNTIL attempts%=0 OR X%=&40 OR X%=&43 OR X%=&44 OR X%=0
  IF X%>0 THEN =-1
  :
  REM Fetch network number from response
  attempts%=20
  REPEAT
    REPEAT
      U%=USR OSBYTE
    UNTIL (U% AND &8000)<>0
    X%=(U% AND &FF00) DIV &100
    attempts%=attempts%-1
  UNTIL attempts%=0 OR X%>0
  IF X%>0 THEN result%=?rxbuffer% ELSE result%=-1
  :
  REM Delete control block
  A%=&34:X%=cblock%?0:CALL OSBYTE
=result%
