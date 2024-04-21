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
 EQUS "* BBC Micro Model B & 16K Sideways RAM"
 EQUB 10, 13
 EQUS "* BBC Micro Model B+ 64K"
 EQUB 10, 13
 EQUS "* BBC Micro Model B+ 128K"
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
 EQUS "2. Create a directory called Elite in"
 EQUB 10, 13
 EQUS "the top level of the main directory for"
 EQUB 10, 13
 EQUS "each user who wants to play Elite, and"
 EQUB 10, 13
 EQUS "copy the MAX file into this directory"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "3. If you want all users to be able to"
 EQUB 10, 13
 EQUS "play Elite, copy all the Elite* files"
 EQUB 10, 13
 EQUS "into $.Library and $.Library1 and"
 EQUB 10, 13
 EQUS "ensure all users have their library set"
 EQUB 10, 13
 EQUS "set accordingly"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "If you want to restrict it to specific"
 EQUB 10, 13
 EQUS "users, copy all the Elite* files into"
 EQUB 10, 13
 EQUS "the Elite folder that you just created"
 EQUB 10, 13
 EQUS "in the users' main directories"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "4. Users can then play Elite by typing:"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "*Elite"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "which will load the correct version of"
 EQUB 10, 13
 EQUS "Elite for their machine."
 EQUB 10, 13
 EQUB 10, 13
 EQUS "If you restricted Elite to specific"
 EQUB 10, 13
 EQUS "users, they will need to *DIR into"
 EQUB 10, 13
 EQUS "their own Elite folders first"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "You can run specific versions using:"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "*EliteB  (for BBC Micro Elite)"
 EQUB 10, 13
 EQUS "*EliteM  (for BBC Master 128 Elite)"
 EQUB 10, 13
 EQUS "*EliteSP (for 6502 Second Proc Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "5. Commander files will be saved into"
 EQUB 10, 13
 EQUS "each individual user's Elite folder"
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

