\ ******************************************************************************
\
\ ELITE OVER ECONET README
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
\ This source file produces the following binary file:
\
\   * README.txt
\
\ ******************************************************************************

.readme

 EQUS "---------------------------------------"
 EQUB 10, 13
 EQUS "Acornsoft Elite (Econet version)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Econet conversion by Mark Moxon"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "For the following networked machines:"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "* BBC Micro with 6502 Second Processor"
 EQUB 10, 13
 EQUS "* BBC Master 128"
 EQUB 10, 13
 EQUS "* BBC Master Turbo"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "To install Elite on your network:"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "1. Create a directory called $.Elite on"
 EQUB 10, 13
 EQUS "the server and copy all the ELT* files"
 EQUB 10, 13
 EQUS "in there"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "2. Either copy EliteM and EliteSP into"
 EQUB 10, 13
 EQUS "$.Library and $.Library1 (if you want"
 EQUB 10, 13
 EQUS "all users to be able to play Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Or copy EliteM and EliteSP into each"
 EQUB 10, 13
 EQUS "user's main directory (if you want"
 EQUB 10, 13
 EQUS "to restrict it to those users only)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "3. Create a directory called Elite in"
 EQUB 10, 13
 EQUS "each user's main directory, and copy"
 EQUB 10, 13
 EQUS "the MAX file in there"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "4. Users can then play Elite by typing:"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "*EliteM  (for BBC Master 128 Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "*EliteSP (for 6502 Second Proc Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Commander files will be saved into the"
 EQUB 10, 13
 EQUS "user's Elite folder"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "See www.bbcelite.com/hacks for details"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Build: ", TIME$("%F %T")
 EQUB 10, 13
 EQUS "---------------------------------------"

 SAVE "2-assembled-output/README.txt", readme, P%

