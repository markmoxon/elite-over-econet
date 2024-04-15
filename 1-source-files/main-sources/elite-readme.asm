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
\   * ReadMe.txt
\
\ ******************************************************************************

.readme

 EQUB 10, 13
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
 EQUS "* BBC Micro with 16K Sideways RAM"
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
 EQUS "and this ReadMe file into the directory"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "2. Either copy EliteB, M and SP into"
 EQUB 10, 13
 EQUS "$.Library and $.Library1 (if you want"
 EQUB 10, 13
 EQUS "all users to be able to play Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Or copy EliteB, M and SP into each"
 EQUB 10, 13
 EQUS "user's main directory (if you want"
 EQUB 10, 13
 EQUS "to restrict it to those users only)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "3. Create a directory called Elite in"
 EQUB 10, 13
 EQUS "the top level of each user's main"
 EQUB 10, 13
 EQUS "directory, and copy the MAX file there"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "4. Users can then play Elite by typing:"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "*EliteB  (for BBC Micro SRAM Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "*EliteM  (for BBC Master 128 Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "*EliteSP (for 6502 Second Proc Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "If you copied EliteB, M and SP into"
 EQUB 10, 13
 EQUS "the user's directory, they will need to"
 EQUB 10, 13
 EQUS "use *DIR to go to that directory first"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "5. Commander files will be saved into"
 EQUB 10, 13
 EQUS "the individual user's Elite folder"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "See www.bbcelite.com/hacks for details"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Build: ", TIME$("%F %T")
 EQUB 10, 13
 EQUS "---------------------------------------"
 EQUB 10, 13

 SAVE "2-assembled-output/ReadMe.txt", readme, P%

