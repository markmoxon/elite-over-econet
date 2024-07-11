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
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
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
 EQUS "* BBC Micro Model B"
 EQUB 10, 13
 EQUS "* BBC Micro Model B & 16K Sideways RAM"
 EQUB 10, 13
 EQUS "* BBC Micro Model B+ 64K and 128K"
 EQUB 10, 13
 EQUS "* BBC Micro with 6502 Second Processor"
 EQUB 10, 13
 EQUS "* BBC Master 128, ET and Turbo"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "To install on a Level 3 fileserver,"
 EQUB 10, 13
 EQUS "copy files from this disc to your"
 EQUB 10, 13
 EQUS "server as follows (files have been"
 EQUB 10, 13
 EQUS "grouped into DFS directories to make"
 EQUB 10, 13
 EQUS "this process easier):"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "1. Create a $.EliteGame directory on"
 EQUB 10, 13
 EQUS "the server and copy all the files from"
 EQUB 10, 13
 EQUS "DFS directory G (on both drive 0 and"
 EQUB 10, 13
 EQUS "drive 2) to there"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "2. Create a $.EliteGame.D directory on"
 EQUB 10, 13
 EQUS "the server and copy all the files from"
 EQUB 10, 13
 EQUS "DFS directory D (on drive 2) to there"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "3. Create an EliteCmdrs directory in"
 EQUB 10, 13
 EQUS "the top level of the main directory for"
 EQUB 10, 13
 EQUS "each user who wants to play Elite, and"
 EQUB 10, 13
 EQUS "copy all the files from DFS directory"
 EQUB 10, 13
 EQUS "C (on drive 2) to there"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "4. If you want all users to be able to"
 EQUB 10, 13
 EQUS "play Elite, copy all the files from DFS"
 EQUB 10, 13
 EQUS "directory L (on drive 2) into $.Library"
 EQUB 10, 13
 EQUS "and $.Library1 and ensure all users"
 EQUB 10, 13
 EQUS "have their library set accordingly"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "If you want to restrict it to specific"
 EQUB 10, 13
 EQUS "users, copy all the files from DFS"
 EQUB 10, 13
 EQUS "directory L (on drive 2) into the"
 EQUB 10, 13
 EQUS "EliteCmdrs directory that you created"
 EQUB 10, 13
 EQUS "in the users' main directories"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "5. Users can then play Elite by typing:"
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
 EQUS "their own EliteCmdrs directory first"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "6. Commander files are saved into each"
 EQUB 10, 13
 EQUS "individual user's EliteCmdrs directory"
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

.readmeArc

 EQUS "---------------------------------------"
 EQUB 10
 EQUS "Acornsoft Elite (Econet version)"
 EQUB 10
 EQUB 10
 EQUS "Econet conversion by Mark Moxon"
 EQUB 10
 EQUB 10
 EQUS "For the following networked machines:"
 EQUB 10
 EQUB 10
 EQUS "* BBC Micro Model B"
 EQUB 10
 EQUS "* BBC Micro Model B & 16K Sideways RAM"
 EQUB 10
 EQUS "* BBC Micro Model B+ 64K and 128K"
 EQUB 10
 EQUS "* BBC Micro with 6502 Second Processor"
 EQUB 10
 EQUS "* BBC Master 128, ET and Turbo"
 EQUB 10
 EQUB 10
 EQUS "To install on a Level 4 fileserver,"
 EQUB 10
 EQUS "copy the directories from this archive"
 EQUB 10
 EQUS "to your server as follows:"
 EQUB 10
 EQUB 10
 EQUS "1. Copy the EliteGame directory to your"
 EQUB 10
 EQUS "fileserver's root directory, to create"
 EQUB 10
 EQUS "a directory called $.EliteGame on the"
 EQUB 10
 EQUS "server"
 EQUB 10
 EQUB 10
 EQUS "2. Copy the EliteCmdrs directory to the"
 EQUB 10
 EQUS "top level of the main home directory"
 EQUB 10
 EQUS "for each user who wants to play Elite,"
 EQUB 10
 EQUS "e.g. $.Mark.EliteCmdrs for user Mark"
 EQUB 10
 EQUB 10
 EQUS "3. If you want all users to be able to"
 EQUB 10
 EQUS "play Elite, copy the files from the"
 EQUB 10
 EQUS "Library and Library1 directories into"
 EQUB 10
 EQUS "$.Library and $.Library1 on your"
 EQUB 10
 EQUS "fileserver, and ensure all users have"
 EQUB 10
 EQUS "their library set accordingly"
 EQUB 10
 EQUB 10
 EQUS "If you want to restrict it to specific"
 EQUB 10
 EQUS "users, copy all the files from the"
 EQUB 10
 EQUS "Library directory into the EliteCmdrs"
 EQUB 10
 EQUS "directory that you created in each of"
 EQUB 10
 EQUS "the users' main directories"
 EQUB 10
 EQUB 10
 EQUS "4. Users can then play Elite by typing:"
 EQUB 10
 EQUB 10
 EQUS "*Elite"
 EQUB 10
 EQUB 10
 EQUS "which will load the correct version of"
 EQUB 10
 EQUS "Elite for their machine."
 EQUB 10
 EQUB 10
 EQUS "If you restricted Elite to specific"
 EQUB 10
 EQUS "users, they will need to *DIR into"
 EQUB 10
 EQUS "their own EliteCmdrs directory first"
 EQUB 10
 EQUB 10
 EQUS "5. Commander files are saved into each"
 EQUB 10
 EQUS "individual user's EliteCmdrs directory"
 EQUB 10
 EQUB 10
 EQUS "See www.bbcelite.com/hacks for details"
 EQUB 10
 EQUB 10
 EQUS "Build: ", TIME$("%F %T")
 EQUB 10
 EQUS "---------------------------------------"
 EQUB 10

 SAVE "2-assembled-output/ReadMeArc.txt", readmeArc, P%
