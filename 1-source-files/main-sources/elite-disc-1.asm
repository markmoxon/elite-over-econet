\ ******************************************************************************
\
\ ELITE OVER ECONET DISC IMAGE SCRIPT
\
\ BBC Master Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1986
\
\ The code on this site has been reconstructed from a disassembly of the version
\ released on Ian Bell's personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces side 1 of the following DSD disc image:
\
\   * elite-over-econet.dsd
\
\ This can be loaded into an emulator or a real BBC Master.
\
\ ******************************************************************************

\ BBC Master Elite (Econet version) = *RUN EliteM

 PUTFILE "master-elite-beebasm/3-assembled-output/M128Elt.bin", "G.ELTME", &000E00, &000E43
 PUTFILE "master-elite-beebasm/3-assembled-output/BDATA.bin", "G.ELTMD", &001300, &001300
 PUTFILE "master-elite-beebasm/3-assembled-output/BCODE.bin", "G.ELTMC", &001300, &002C6C

\ 6502SP Elite (Econet version) = *RUN EliteSP

 PUTFILE "6502sp-elite-beebasm/3-assembled-output/ELITE.bin", "G.ELTSE", &FF1FDC, &FF2085
 PUTFILE "6502sp-elite-beebasm/3-assembled-output/ELITEa.bin", "G.ELTSA", &FF2000, &FF2000
 PUTFILE "6502sp-elite-beebasm/3-assembled-output/I.CODE.bin", "G.ELTSI", &FF2400, &FF2C89
 PUTFILE "6502sp-elite-beebasm/3-assembled-output/P.CODE.bin", "G.ELTSP", &001000, &00106A

\ BBC Micro Disc Elite (Econet Sideways RAM version) = *RUN EliteB

 PUTFILE "disc-elite-beebasm/1-source-files/boot-files/$.SCREEN.bin", "G.ELTBS", &007800, &007BE8
 PUTFILE "disc-elite-beebasm/3-assembled-output/ELTROM.bin", "G.ELTBR", &003400, &003400
 PUTFILE "disc-elite-beebasm/3-assembled-output/MNUCODE.bin", "G.ELTBM", &007400, &00743B
 PUTFILE "disc-elite-beebasm/3-assembled-output/sELITE4.bin", "G.ELTBI", &001900, &00197B
 PUTFILE "disc-elite-beebasm/3-assembled-output/sD.CODE.bin", "G.ELTBD", &0012E3, &0012E3
 PUTFILE "disc-elite-beebasm/3-assembled-output/sT.CODE.bin", "G.ELTBT", &0012E3, &0012E3

\ BBC Micro Disc Elite (standard version) = *RUN EliteB

 PUTFILE "disc-elite-beebasm/3-assembled-output/ELITE4.bin", "G.ELTAI", &001900, &00197B
 PUTFILE "disc-elite-beebasm/3-assembled-output/D.CODE.bin", "G.ELTAD", &0012E3, &0012E3
 PUTFILE "disc-elite-beebasm/3-assembled-output/T.CODE.bin", "G.ELTAT", &0012E3, &0012E3

\ Boot files

 PUTFILE "2-assembled-output/EliteM.bin", "L.EliteM", &002000, &002000
 PUTFILE "2-assembled-output/EliteSP.bin", "L.EliteSP", &FF2000, &FF2000
 PUTFILE "2-assembled-output/EliteB.bin", "L.EliteB", &000B00, &000B00
 PUTFILE "2-assembled-output/Elite.bin", "L.Elite", &002400, &002400

\ Scoreboard

 PUTBASIC "1-source-files/basic-programs/$.ElScore.bas", "G.ElScore"
 PUTBASIC "1-source-files/basic-programs/$.ElDebug.bas", "G.ElDebug"

\ Commander files

 PUTFILE "master-elite-beebasm/1-source-files/other-files/E.MAX.bin", "C.MAX", &000000, &000000

\ ReadMe files

 PUTFILE "2-assembled-output/Version.txt", "G.Version", &FFFFFF, &FFFFFF
 PUTFILE "2-assembled-output/ReadMe.txt", "ReadMe", &FFFFFF, &FFFFFF
