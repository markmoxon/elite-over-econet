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
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
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

 PUTFILE "elite-source-code-bbc-master/3-assembled-output/M128Elt.bin", "G.ELTME", &000E00, &000E43
 PUTFILE "elite-source-code-bbc-master/3-assembled-output/BDATA.bin", "G.ELTMD", &001300, &001300
 PUTFILE "elite-source-code-bbc-master/3-assembled-output/BCODE.bin", "G.ELTMC", &001300, &002C6C

\ 6502SP Elite (Econet version) = *RUN EliteSP

 PUTFILE "elite-source-code-6502-second-processor/3-assembled-output/ELITE.bin", "G.ELTSE", &FF1FDC, &FF2085
 PUTFILE "elite-source-code-6502-second-processor/3-assembled-output/ELITEa.bin", "G.ELTSA", &FF2000, &FF2000
 PUTFILE "elite-source-code-6502-second-processor/3-assembled-output/I.CODE.bin", "G.ELTSI", &FF2400, &FF2C89
 PUTFILE "elite-source-code-6502-second-processor/3-assembled-output/P.CODE.bin", "G.ELTSP", &001000, &0010D1

\ BBC Micro Disc Elite (Econet Sideways RAM version) = *RUN EliteB

 PUTFILE "elite-source-code-bbc-micro-disc/1-source-files/boot-files/$.SCREEN.bin", "G.ELTBS", &007800, &007BE8
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/ELTROM.bin", "G.ELTBR", &003400, &003400
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/MNUCODE.bin", "G.ELTBM", &007400, &00743B
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/sELITE4.bin", "G.ELTBI", &001900, &00197B
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/sD.CODE.bin", "G.ELTBD", &0012E3, &0012E3
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/sT.CODE.bin", "G.ELTBT", &0012E3, &0012E3

\ BBC Micro Disc Elite (standard version) = *RUN EliteB

 PUTFILE "2-assembled-output/ELTAB.bin", "G.ELTAB", &002400, &002400
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/ELITE4.bin", "G.ELTAI", &001900, &00197B
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.CODE.bin", "G.ELTAD", &0012E3, &0012E3
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/T.CODE.bin", "G.ELTAT", &0012E3, &0012E3

\ ReadMe files

 PUTFILE "2-assembled-output/Version.txt", "G.Version", &FFFFFF, &FFFFFF
 PUTFILE "2-assembled-output/ReadMe.txt", "ReadMe", &FFFFFF, &FFFFFF
