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
\   * elite-compendium.dsd
\
\ This can be loaded into an emulator or a real BBC Master.
\
\ ******************************************************************************

\ BBC Master Elite (Econet version) = *RUN EliteM

 PUTFILE "master-elite-beebasm/3-assembled-output/M128Elt.bin", "ELTMC", &000E00, &000E43
 PUTFILE "master-elite-beebasm/3-assembled-output/BDATA.bin", "ELTBD", &001300, &001300
 PUTFILE "master-elite-beebasm/3-assembled-output/BCODE.bin", "ELTBC", &001300, &002C6C

\ 6502SP Elite (Econet version) = *RUN EliteSP

 PUTFILE "6502sp-elite-beebasm/3-assembled-output/ELITE.bin", "ELTSP", &FF1FDC, &FF2085
 PUTFILE "6502sp-elite-beebasm/3-assembled-output/ELITEa.bin", "ELTIE", &FF2000, &FF2000
 PUTFILE "6502sp-elite-beebasm/3-assembled-output/I.CODE.bin", "ELTIC", &FF2400, &FF2C89
 PUTFILE "6502sp-elite-beebasm/3-assembled-output/P.CODE.bin", "ELTPC", &001000, &00106A

\ BBC Micro Disc Elite (Econet Sideways RAM version) = *RUN EliteB

 PUTFILE "disc-elite-beebasm/1-source-files/boot-files/$.SCREEN.bin", "ELTSC", &007800, &007BE8
 PUTFILE "disc-elite-beebasm/1-source-files/boot-files/$.ELTROMEC.bin", "ELTRM", &003400, &003400
 PUTFILE "disc-elite-beebasm/3-assembled-output/MNUCODE.bin", "ELTMN", &007400, &00743B
 PUTFILE "disc-elite-beebasm/3-assembled-output/ELITE4.bin", "ELTIN", &001900, &00197B
 PUTFILE "disc-elite-beebasm/3-assembled-output/D.CODE.bin", "ELTDC", &0012E3, &0012E3
 PUTFILE "disc-elite-beebasm/3-assembled-output/T.CODE.bin", "ELTTC", &0012E3, &0012E3

\ Boot files

 PUTFILE "2-assembled-output/EliteM.bin", "EliteM", &002000, &002000
 PUTFILE "2-assembled-output/EliteSP.bin", "EliteSP", &FF2000, &FF2000
 PUTFILE "2-assembled-output/EliteB.bin", "EliteB", &000B00, &000B00

\ Other files

 PUTFILE "master-elite-beebasm/1-source-files/other-files/E.MAX.bin", "MAX", &000000, &000000
 PUTFILE "2-assembled-output/ReadMe.txt", "ReadMe", &FFFFFF, &FFFFFF
