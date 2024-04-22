REM ElDebug - Traffic monitor for Elite over Econet
REM By Mark Moxon
:
DIM cblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:TIME=0
X%=cblock%:Y%=cblock% DIV 256:A%=&13:!cblock%=8:CALL OSWORD
snetwork%=cblock%?2:sstation%=cblock%?1
:
CLS
PROCstartMenu
REPEAT
  PROCreceive
  PROCprintData
UNTIL FALSE
:
DEF PROCstartMenu
  PRINT TAB(6,0);"Elite over Econet Debug Tool"
  PRINT TAB(6,1);"----------------------------"
  PRINT '"Please enter the port number to monitor:"
  INPUT port%
  PRINT '"This machine's network: ";snetwork%
  PRINT "This machine's station: ";sstation%
  PRINT "Port number: ";port%
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
  PRINT "Kills: ";rxbuffer%?10+256*rxbuffer%?11
  PRINT "Credits: ";(rxbuffer%!12)/10
  PRINT "Machine: ";rxbuffer%?16
  PRINT "Port: ";cblock%?2
  PRINT "Player station: ";cblock%?3
  PRINT "Player network: ";cblock%?4
ENDPROC
