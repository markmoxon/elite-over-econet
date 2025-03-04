\ ******************************************************************************
\
\ BBC MASTER ELITE ECONET BOOT FILE
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
\   * EliteM.bin
\
\ ******************************************************************************

 GUARD &C000            \ Guard against assembling over MOS memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 BRKV = &0202           \ The break vector that we intercept to enable us to
                        \ load the configuration file, if there is one

 OSCLI = &FFF7          \ The address for the OSCLI routine

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

 CODE% = &2000
 LOAD% = &2000

 ORG CODE%

\ ******************************************************************************
\
\       Name: Elite boot command
\       Type: Subroutine
\   Category: Loader
\    Summary: Does the job of the !BOOT file but in a machine code file so it
\             can be run with a star-command from a BBC Micro
\
\ ******************************************************************************

.ENTRY

 LDA BRKV               \ Fetch the current value of the break vector
 STA oldBRKV
 LDA BRKV+1
 STA oldBRKV+1

 SEI                    \ Disable interrupts while we update the break vector

 LDA #LO(NoConfFile)    \ Set BRKV to point to NoConfFile, so if there is no
 STA BRKV               \ configuration file, we jump to NoConfFile where we
 LDA #HI(NoConfFile)    \ clear the break condition and return to entr1 to
 STA BRKV+1             \ restore the break vector and keep going

 CLI                    \ Enable interrupts again

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("LOAD EliteConf xxxx")
 LDY #HI(MESS3)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS3 to load
                        \ the game binary path from EliteConf into the OS
                        \ command string in MESS1, so if there is a
                        \ configuration file, we change directory to the
                        \ configured directory rather than $.EliteGame

.entr1

 SEI                    \ Disable interrupts while we update the break vector

 LDA oldBRKV            \ Restore BRKV
 STA BRKV
 LDA oldBRKV+1
 STA BRKV+1

 CLI                    \ Enable interrupts again

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR $.EliteGame")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to change
                        \ to the game folder

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("RUN ELTME")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the game in ELTME, returning from the subroutine using
                        \ a tail call

\ ******************************************************************************
\
\       Name: NoConfFile
\       Type: Subroutine
\   Category: Loader
\    Summary: A break handler for when there is no EliteConf file
\
\ ******************************************************************************

.NoConfFile

                        \ If we get here then the *LOAD EliteConf file returned
                        \ an error and this routine was called as the break
                        \ handler, so we now need to tidy things up and return
                        \ to the main program above
                        \
                        \ This lets us load the EliteConf file if there is one,
                        \ while handling things cleanly if there isn't

 PLP                    \ Restore the status register from the stack

 PLA                    \ Remove the return address from the stack
 PLA

 JMP entr1              \ Return to just after the failed load command to
                        \ continue with the loader

\ ******************************************************************************
\
\       Name: oldBRKV
\       Type: Variable
\   Category: Loader
\    Summary: Storage for the old break vector
\
\ ******************************************************************************

.oldBRKV

 EQUW 0

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Run Elite
\
\ ******************************************************************************

.MESS2

 EQUS "RUN ELTME"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS1
\       Type: Variable
\   Category: Loader
\    Summary: Switch to the game directory
\
\ ******************************************************************************

.MESS1

 EQUS "DIR $.EliteGame"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: Load the Elite configuration file that contains the full path of
\             the game binary directory, just after the *DIR in command MESS1
\
\ ******************************************************************************

.MESS3

 EQUS "LOAD EliteConf "
 EQUS STR$~(MESS1 + 4)
 EQUB 13

\ ******************************************************************************
\
\ Save ELITEM.bin
\
\ ******************************************************************************

 PRINT "S.EliteM ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/EliteM.bin", CODE%, P%, LOAD%