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

\ BBC Micro Disc Elite (standard version) ship blueprint files

 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOA.bin", "D.MOA", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOB.bin", "D.MOB", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOC.bin", "D.MOC", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOD.bin", "D.MOD", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOE.bin", "D.MOE", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOF.bin", "D.MOF", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOG.bin", "D.MOG", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOH.bin", "D.MOH", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOI.bin", "D.MOI", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOJ.bin", "D.MOJ", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOK.bin", "D.MOK", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOL.bin", "D.MOL", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOM.bin", "D.MOM", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MON.bin", "D.MON", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOO.bin", "D.MOO", &005600, &005600
 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/D.MOP.bin", "D.MOP", &005600, &005600

\ 6502SP Executive Elite (Econet version) = *RUN EliteSX

 PUTFILE "elite-source-code-6502-second-processor/4-reference-binaries/executive/ELITE.bin", "G.ELTXE", &FF1FDC, &FF2085
 PUTFILE "elite-source-code-6502-second-processor/4-reference-binaries/executive/ELITEa.bin", "G.ELTXA", &FF2000, &FF2000
 PUTFILE "elite-source-code-6502-second-processor/4-reference-binaries/executive/I.CODE.bin", "G.ELTXI", &FF2400, &FF2C89
 PUTFILE "elite-source-code-6502-second-processor/4-reference-binaries/executive/P.CODE.bin", "G.ELTXP", &001000, &0010D3

\ Boot files

 PUTFILE "2-assembled-output/EliteM.bin", "L.EliteM", &002000, &002000
 PUTFILE "2-assembled-output/EliteSP.bin", "L.EliteSP", &FF2000, &FF2000
 PUTFILE "2-assembled-output/EliteX.bin", "L.EliteX", &FF2000, &FF2000
 PUTFILE "2-assembled-output/EliteB.bin", "L.EliteB", &000B00, &000B00
 PUTFILE "2-assembled-output/Elite.bin", "L.Elite", &002400, &002400

\ Scoreboard

 PUTBASIC "1-source-files/basic-programs/$.ElScore.bas", "G.ElScore"
 PUTBASIC "1-source-files/basic-programs/$.ElDebug.bas", "G.ElDebug"

\ Utility programs

 PUTFILE "elite-source-code-bbc-micro-disc/3-assembled-output/FixPAGE.bin", "G.FixPAGE", &007400, &007400

\ Commander files

 PUTFILE "elite-source-code-bbc-master/1-source-files/other-files/E.MAX.bin", "C.MAX", &000000, &000000
