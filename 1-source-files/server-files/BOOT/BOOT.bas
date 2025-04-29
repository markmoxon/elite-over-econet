MODE 7
*FX 4,1
*FX 200,1
VDU 23,1,0;0;0;0;
PRINT TAB(4,0);CHR$(141);CHR$(130);"Welcome to Elite over Econet"
PRINT TAB(4,1);CHR$(141);CHR$(130);"Welcome to Elite over Econet"
PRINT TAB(6,2);CHR$(129);"on the TNMoC Econet Cloud"
PRINT 'CHR$(131);"  Please choose from the following:"
PRINT '"1.";CHR$(134);"Play flicker-free Elite over Econet"'CHR$(132);"  (BBC Micro, BBC Master, 650SP)"
PRINT '"2.";CHR$(134);"Play original Elite over Econet"'CHR$(132);"  (BBC Micro, BBC Master, 650SP)"
PRINT '"3.";CHR$(134);"Play Executive Elite over Econet"'CHR$(132);"  (6502 Second Processor only)"
PRINT '"4.";CHR$(134);"Play Archimedes Elite over Econet"
PRINT '"5.";CHR$(134);"Run the Elite over Econet Scoreboard"
PRINT '"6.";CHR$(134);"Run the Elite over Econet Debugger"
PRINT '"7.";CHR$(134);"Show Elite over Econet version info"
REM PRINT '"8. About Elite over Econet"
PRINT
REPEAT
 A$=GET$
 IF A$="1" THEN PROCcommand("*I AM ELITE|M")
 IF A$="2" THEN PROCcommand("*I AM ELITEO|M")
 IF A$="3" THEN PROCcommand("*I AM UTILS|M*ELITE X|M")
 IF A$="4" THEN PROCarc
 IF A$="5" THEN PROCcommand("*I AM UTILS|M*ELITE S|M")
 IF A$="6" THEN PROCcommand("*I AM UTILS|M*ELITE D|M")
 IF A$="7" THEN PROCcommand("*I AM UTILS|M*ELITE V|M")
UNTIL FALSE
END
:
DEF PROCcommand(C$)
 CLS
 OSCLI("KEY0 "+C$)
 *FX 4,0
 *FX 200,0
 VDU 23,1,1;0;0;0;
 *FX 138,0,128
 END
ENDPROC
:
DEF PROCarc
 CLS
 PRINT '"To play Archimedes Elite over Econet:"
 PRINT '"* From the RISC OS Desktop, login to"
 PRINT "  user ARCELITE on server 63.13 from"
 PRINT "  the Econet fileserver icon"
 PRINT '"* Follow the instructions in the"
 PRINT "  !ReadMe file"'
 *FX 4,0
 *FX 200,0
 VDU 23,1,1;0;0;0;
 END
ENDPROC