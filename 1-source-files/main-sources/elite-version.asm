\ ******************************************************************************
\
\ ELITE OVER ECONET VERSION FILE
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
\ This source file produces the following binary file:
\
\   * Version.txt
\
\ ******************************************************************************

.version

 EQUS "---------------------------------------"
 EQUB 10, 13
 EQUS "Acornsoft Elite (Econet version)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "With flicker-free ships and planets"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Econet conversion by Mark Moxon"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "See www.bbcelite.com/hacks for details"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Build: ", TIME$("%F %T")
 EQUB 10, 13
 EQUS "---------------------------------------"
 EQUB 10, 13

 SAVE "2-assembled-output/Version.txt", version, P%

