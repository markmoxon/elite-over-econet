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
 EQUS "Copy all the EL* files into the"
 EQUB 10, 13
 EQUS "$.LIBRARY directory on the server"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Create a directory called ELITE in"
 EQUB 10, 13
 EQUS "the user's main directory, and copy"
 EQUB 10, 13
 EQUS "the MAX file in there"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Users can then play Elite by typing:"
 EQUB 10, 13
 EQUS "  *ELITE (for BBC Master 128 Elite)"
 EQUB 10, 13
 EQUS "  *ELITESP (for 6502 Second Proc Elite)"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Commander files will be saved into the"
 EQUB 10, 13
 EQUS "user's ELITE folder"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "See www.bbcelite.com for details"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Build: ", TIME$("%F %T")
 EQUB 10, 13
 EQUS "---------------------------------------"

 SAVE "2-assembled-output/README.txt", readme, P%

