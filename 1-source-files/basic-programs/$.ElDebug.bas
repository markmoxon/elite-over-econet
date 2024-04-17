REM ElDebug - Traffic monitor for Elite over Econet
REM By Mark Moxon
REM
OSWORD=&FFF1:OSBYTE=&FFF4
DIM cblock% 40,rxbuffer% 40
INPUT "Port",port%
X%=cblock%:Y%=cblock% DIV 256:A%=&13:!cblock%=8:CALL OSWORD
CLS
PRINT "Scoreboard network: ";cblock%?2
PRINT "Scoreboard station: ";cblock%?1
PRINT "Port number: ";port%
REPEAT
PROCreceive
PROCprintdata
UNTIL FALSE
REM
DEF PROCreceive
?cblock%=0
cblock%?1=&7F
cblock%?2=port%
cblock%!3=0
cblock%!5=rxbuffer%
cblock%!9=rxbuffer%+20
REM Open RECEIVE block, read control block number
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
REM
DEFPROCprintdata
PRINT '"Name: ";$rxbuffer%
PRINT "Legal status: ";rxbuffer%?8
PRINT "Condition: ";rxbuffer%?9
PRINT "Rank: ";rxbuffer%?10+256*rxbuffer%?11
PRINT "Credits: ";(rxbuffer%!12)/10
PRINT "Machine: ";rxbuffer%?16
PRINT "Port: ";cblock%?2
PRINT "Cmdr station: ";cblock%?3
PRINT "Cmdr network: ";cblock%?4
ENDPROC
