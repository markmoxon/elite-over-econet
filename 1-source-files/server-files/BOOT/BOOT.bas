MODE 7
*FX 4,1
*FX 200,1
VDU 23,1,0;0;0;0;
PROCmenu
REPEAT
 A$=GET$
 IF A$="1" THEN PROCcommand("*I AM ELITE|M")
 IF A$="2" THEN PROCcommand("*I AM ELITEO|M")
 IF A$="3" THEN PROCcommand("*I AM ELITEX|M")
 IF A$="4" THEN PROCarchimedes
 IF A$="5" THEN PROCcommand("*I AM UTILS|M*ELITE S|M")
 IF A$="6" THEN PROCcommand("*I AM UTILS|M*ELITE D|M")
 IF A$="7" THEN PROCversion
 IF A$="8" THEN PROCabout
 PRINT 'CHR$(131);" Press any key to return to the menu"
 A$=GET$
 PROCmenu
UNTIL FALSE
END
:
DEF PROCmenu
 CLS
 PRINT TAB(4,0);CHR$(141);CHR$(130);"Welcome to Elite over Econet"
 PRINT TAB(4,1);CHR$(141);CHR$(130);"Welcome to Elite over Econet"
 PRINT TAB(6,2);CHR$(129);"on the TNMoC Econet Cloud"
 PRINT 'CHR$(131);"  Please choose from the following:"
 PRINT '"1.";CHR$(134);"Play flicker-free Elite over Econet"'CHR$(132);"  (BBC Micro, BBC Master, 6502 SP)"
 PRINT '"2.";CHR$(134);"Play original Elite over Econet"'CHR$(132);"  (BBC Micro, BBC Master, 6502 SP)"
 PRINT '"3.";CHR$(134);"Play Executive Elite over Econet"'CHR$(132);"  (6502 Second Processor only)"
 PRINT '"4.";CHR$(134);"Play Archimedes Elite over Econet"
 PRINT '"5.";CHR$(134);"Run the Elite over Econet Scoreboard"
 PRINT '"6.";CHR$(134);"Run the Elite over Econet Debugger"
 PRINT '"7.";CHR$(134);"Show version information"
 PRINT '"8.";CHR$(134);"About Elite over Econet"
ENDPROC
:
DEF PROCcommand(C$)
 CLS
 OSCLI("KEY 0 "+C$)
 *FX 4,0
 *FX 200,0
 VDU 23,1,1;0;0;0;
 *FX 138,0,128
 END
ENDPROC
:
DEF PROCversion
 CLS
 PRINT TAB(8,0);CHR$(141);CHR$(130);"Version information"
 PRINT TAB(8,1);CHR$(141);CHR$(130);"Version information"
 PRINT
 *I AM UTILS
 *ELITE V
ENDPROC
:
DEF PROCarchimedes
 CLS
 PRINT TAB(4,0);CHR$(141);CHR$(130);"Archimedes Elite over Econet"
 PRINT TAB(4,1);CHR$(141);CHR$(130);"Archimedes Elite over Econet"
 PRINT '"To play Archimedes Elite over Econet,"
 PRINT "do the following:"
 PRINT '" * In the RISC OS Desktop, login to"
 PRINT "   user ARCELITE on server 63.13"
 PRINT "   from the Econet fileserver icon"
 PRINT "   (there is no password)"
 PRINT '" * Follow the instructions in the"
 PRINT "   !ReadMe file"
 PRINT '"Archimedes Elite over Econet runs on"
 PRINT "RISC OS 3 and above."
ENDPROC
:
DEF PROCabout
 CLS
 PRINT TAB(6,0);CHR$(141);CHR$(130);"About Elite over Econet"
 PRINT TAB(6,1);CHR$(141);CHR$(130);"About Elite over Econet"
 PRINT '"In the old days, Elite didn't work over"
 PRINT "an Econet network. Those days are gone!"
 PRINT '"Not only does Elite now load from all"
 PRINT "Econet fileservers, but you can join"
 PRINT "multiplayer competitions and compete"
 PRINT "for the highest scores against players"
 PRINT "from all over the world."
 PRINT '"This server always hosts the very"
 PRINT "latest version of the game, for the"
 PRINT "BBC Micro, BBC Master, 6502 Second"
 PRINT "Processor and Acorn Archimedes."
 PRINT '"For more information, visit the project"
 PRINT "website at";CHR$(129);"bbcelite.com/econet"
ENDPROC
