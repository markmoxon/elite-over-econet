REM ElTest - Test tool for Elite over Econet
REM By Mark Moxon
:
DIM M$(4):M$(0)="B+":M$(1)="Ma":M$(2)="Sp":M$(3)="Bb":M$(4)="Ar"
DIM C$(3):C$(0)=CHR$(151):C$(1)=CHR$(146):C$(2)=CHR$(147):C$(3)=CHR$(145)
DIM L$(2):L$(0)=CHR$(130)+"Cln":L$(1)=CHR$(131)+"Off":L$(2)=CHR$(129)+"Fug"
DIM cblock% 40,tblock% 40,rxbuffer% 40
OSWORD=&FFF1:OSBYTE=&FFF4:OSARGS=&FFDA:TIME=0
ostation%=0:onetwork%=0
A%=0:X%=1:os%=((USR OSBYTE) AND &FF00) DIV 256
:
*FX4,0
*FX200,0
PROCstartMenu
:
DIM name$(max%),credits%(max%),kills%(max%),deaths%(max%)
DIM machine%(max%),condition%(max%),legal%(max%),network%(max%),station%(max%)
:
PROCgetStationNumber
PRINT '"Send test data to network: ";fnetwork%
PRINT "Send data to station: ";FNpad0(fstation%);fstation%
PRINT "Send data to port: ";fport%
:
PROCinitCmdrs
REPEAT
  I%=RND(max%+1)-1
  PROCupdateCmdr(I%)
  PROCpause
UNTIL FALSE
:
DEF PROCstartMenu
  CLS
  PRINT TAB(6,0);"Elite over Econet Test Tool"
  PRINT TAB(6,1);"---------------------------"
  PRINT '"Please enter the network number to hit:"
  INPUT fnetwork%
  PRINT '"Please enter the station number to hit:"
  INPUT fstation%
  PRINT '"Please enter the port number to hit:"
  INPUT fport%
  PRINT '"Please enter the max player count:"
  INPUT max%
ENDPROC
:
DEF PROCprocessKeys
  REM No key presses supported during debug (yet)
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
  PROCforward
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
