\ ******************************************************************************
\
\ DISC ELITE BOOT FILE
\
\ Elite was written by Ian Bell and David Braben and is copyright Acornsoft 1984
\
\ The code on this site has been reconstructed from a disassembly of the version
\ released on Ian Bell's personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * EliteB.bin
\
\ ******************************************************************************

 GUARD &0D00            \ Guard against assembling over MOS space

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 ZP = &32               \ Use the XX15 block for the loading code, so it doesn't
                        \ clash with any persistent variables

 BRKV = &0202           \ The break vector that we intercept to enable us to
                        \ load the configuration file, if there is one

 S% = &12E3             \ The address of the main entry point workspace in the
                        \ main game code

 OSARGS = &FFDA         \ The address for the OSARGS routine

 OSCLI = &FFF7          \ The address for the OSCLI routine

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

 CODE% = &0B00          \ The address where the loader code runs

 LOAD% = &0B00          \ The address where the loader code loads

 ORG CODE%

\ ******************************************************************************
\
\       Name: Elite boot command
\       Type: Subroutine
\   Category: Loader
\    Summary: Does the job of the !BOOT file but in a machine code file so it
\             can be run with a star-command from a BBC Micro
\
\ ------------------------------------------------------------------------------
\
\ This part implements the following loader commands:
\
\   *EliteB             Perform sideways RAM checks and run the correct disc
\                       version of Elite:
\
\                         * ELTBI for the sideways RAM version (INTRO in the
\                           original version)
\                           
\                         * ELTAI for the standard version (ELITE4 in the
\                           original version)
\
\   *EliteB A to P      Load a ship blueprints file for the standard version
\                       (*LOAD D.MO0 in the original)
\
\   *EliteB Q           Run the docked code for the standard version and dock
\                       with the station (*RUN T.CODE in the original)
\
\   *EliteB R           Run the docked code for the sideways RAM version and
\                       dock with the station (*RUN T.CODE in the original)
\
\   *EliteB S           Load the docked code for the standard version and
\                       restart the game (*LOAD T.CODE in the original)
\
\   *EliteB T           Load the docked code for the sideways RAM version and
\                       restart the game (*LOAD T.CODE in the original)
\
\   *EliteB U           Run the flight code for the standard version
\                       (*RUN D.CODE in the original)
\
\   *EliteB V           Run the flight code for the sideways RAM version
\                       (*RUN D.CODE in the original)
\
\ ******************************************************************************

.ENTRY

 LDA #1                 \ Set ZP(1 0) to the address of the argument to the
 LDX #ZP                \ *EliteB command
 LDY #0
 JSR OSARGS

 LDA BRKV               \ Fetch the current value of the break vector
 STA oldBRKV
 LDA BRKV+1
 STA oldBRKV+1

 SEI                    \ Disable interrupts while we update the break vector

 LDA #LO(chek1)         \ Set BRKV to point to chek1 below, so if there is no
 STA BRKV               \ configuration file, we simply restore the break vector
 LDA #HI(chek1)         \ and keep going
 STA BRKV+1

 CLI                    \ Enable interrupts again

 LDX #LO(MESS10)        \ Set (Y X) to point to MESS10 ("LOAD EliteConf xxxx")
 LDY #HI(MESS10)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS10 to load
                        \ the game binary path from EliteConf into the OS
                        \ command string in MESS1, so if there is a
                        \ configuration file, we change directory to the
                        \ configureed directory rather than $.EliteGame

.chek1

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

                        \ We need to check for NFS 3.34 as this has a bug in it
                        \ that points ZP(1 0) to the start of the command rather
                        \ than the argument

 LDA #0                 \ Fetch the filing system type into A
 LDY #0
 JSR OSARGS

 CMP #5                 \ If this is not NFS (type 5), jump to chek2 to skip the
 BNE chek2              \ bug fix, as the bug only applies to NFS

 LDA #2                 \ Fetch the version of NFS
 LDY #0
 JSR OSARGS

 CMP #2                 \ If this is NFS 3.34, then the version returned is 2,
 BNE chek2              \ so if this is not NFS 3.34, jump to chek2 to skip the
                        \ bug fix

                        \ This is NFS 3.34, which contains the bug, so we add 7
                        \ to the address in ZP(1 0) so that it points to the
                        \ argument to the *EliteB command (as "EliteB " contains
                        \ seven characters)

 LDY #6                 \ If the *EliteB has no parameter then the seventh
 LDA (ZP),Y             \ character in the command string will be a carriage
 CMP #&0D               \ return (&0D), so jump to chek9 to load the game
 BEQ chek9

                        \ Otherwise the command has a parameter, so we now set
                        \ ZP(1 0) to point to that parameter

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) + 7
 CLC                    \
 ADC #7                 \ So ZP(1 0) points to the correct address of the
 STA ZP                 \ argument to the *EliteB command for NFS 3.34
 BCC chek2
 INC ZP+1

.chek2

 LDY #0                 \ If the argument is not T (i.e. *EliteB T), jump to
 LDA (ZP),Y             \ chek3 to keep looking
 CMP #'T'
 BNE chek3

                        \ If we get here then the command is *EliteB T, which
                        \ loads the docked code for the sideways RAM version
                        \ and restarts the game (*LOAD T.CODE in the original)

 LDX #LO(MESS4)         \ Set (Y X) to point to MESS4 ("LOAD ELTBT")
 LDY #HI(MESS4)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS4, which
                        \ *LOADs the docked code

 JMP S%+3               \ Jump to the second JMP instruction in the docked code,
                        \ which is a JMP DOBEGIN that restarts the game

.chek3

 CMP #'R'               \ If the argument is not R (i.e. *EliteB R), jump to
 BNE chek4              \ chek4 to keep looking

                        \ If we get here then the command is *EliteB R, which
                        \ runs the docked code for the sideways RAM version
                        \ and docks with the station (*RUN T.CODE in the
                        \ original)

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("RUN ELTBT")
 LDY #HI(MESS3)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the flight code (and calls the DOENTRY routine to dock
                        \ at the station), returning from the subroutine using
                        \ a tail call

.chek4

 CMP #'V'               \ If the argument is not V (i.e. *EliteB V), jump to
 BNE chek5              \ chek5 to keep looking

                        \ If we get here then the command is *EliteB V, which
                        \ runs the flight code for the sideways RAM version
                        \ (*RUN D.CODE in the original)

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("RUN ELTBD")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the flight code, returning from the subroutine using
                        \ a tail call

.chek5

 CMP #'S'               \ If the argument is not S (i.e. *EliteB S), jump to
 BNE chek6              \ chek6 to keep looking

                        \ If we get here then the command is *EliteB S, which
                        \ loads the docked code for the standard version and
                        \ restarts the game (*LOAD T.CODE in the original)

 LDX #LO(MESS7)         \ Set (Y X) to point to MESS7 ("LOAD ELTAT")
 LDY #HI(MESS7)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS4, which
                        \ *LOADs the docked code

 JMP S%+3               \ Jump to the second JMP instruction in the docked code,
                        \ which is a JMP DOBEGIN that restarts the game

.chek6

 CMP #'Q'               \ If the argument is not Q (i.e. *EliteB Q), jump to
 BNE chek7              \ chek7 to keep looking

                        \ If we get here then the command is *EliteB Q, which
                        \ runs the docked code for the standard version and
                        \ docks with the station (*RUN T.CODE in the original)

 LDX #LO(MESS6)         \ Set (Y X) to point to MESS6 ("RUN ELTAT")
 LDY #HI(MESS6)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the flight code (and calls the DOENTRY routine to dock
                        \ at the station), returning from the subroutine using
                        \ a tail call

.chek7

 CMP #'U'               \ If the argument is not U (i.e. *EliteB U), jump to
 BNE chek8              \ chek8 to keep looking

                        \ If we get here then the command is *EliteB U, which
                        \ runs the flight code for the standard version
                        \ (*RUN D.CODE in the original)

 LDX #LO(MESS5)         \ Set (Y X) to point to MESS5 ("RUN ELTAD")
 LDY #HI(MESS5)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the flight code, returning from the subroutine using
                        \ a tail call

.chek8

 CMP #'A'               \ If the argument is not in the range A to P (so that's
 BCC chek9              \ *EliteB A to *EliteB P), jump to chek9 to keep
 CMP #'Q'               \ looking
 BCS chek9

                        \ If we get here then the command is *EliteB A to P,
                        \ which loads a ship blueprints file for the standard
                        \ version (*LOAD D.MO0 in the original, where 0 is the
                        \ argument)

 STA MESS9+9            \ Store the letter of the ship blueprints file we want
                        \ in the tenth byte of the command string at MESS9, so
                        \ it overwrites the "0" in "D.MO0" with the file letter
                        \ to load, from D.MOA to D.MOP

 LDX #LO(MESS9)         \ Set (Y X) to point to MESS9 ("LOAD D.MO0")
 LDY #HI(MESS9)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS9, which
                        \ *LOADs the ship blueprints file, returning from the
                        \ subroutine using a tail call

.chek9

                        \ If we get here then there is no valid argument to
                        \ *EliteB, so now we need to load the game from the
                        \ start

 LDX #LO(MESS8)         \ Set (Y X) to point to MESS8 ("RUN ELTAB")
 LDY #HI(MESS8)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS8, which
                        \ *RUNs the disc version loader, which checks PAGE and
                        \ sideways RAM and runs the correct game, returning from
                        \ the subroutine using a tail call

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
\       Name: MESS9
\       Type: Variable
\   Category: Loader
\    Summary: Load a ship file for standard Elite (D.MOx)
\
\ ******************************************************************************

.MESS9

 EQUS "LOAD D.MO0"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS8
\       Type: Variable
\   Category: Loader
\    Summary: Run the loader for BBC Micro disc Elite, which checks for sideways
\             RAM and loads the relevant version of BBC Micro Elite
\
\ ******************************************************************************

.MESS8

 EQUS "RUN ELTAB"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS7
\       Type: Variable
\   Category: Loader
\    Summary: Load the docked code for standard disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS7

 EQUS "LOAD ELTAT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS6
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for standard disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS6

 EQUS "RUN ELTAT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS5
\       Type: Variable
\   Category: Loader
\    Summary: Run the flight code for standard disc Elite (D.CODE)
\
\ ******************************************************************************

.MESS5

 EQUS "RUN ELTAD"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS4
\       Type: Variable
\   Category: Loader
\    Summary: Load the docked code for sideways RAM disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS4

 EQUS "LOAD ELTBT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for sideways RAM disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS3

 EQUS "RUN ELTBT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Run the flight code for sideways RAM disc Elite (D.CODE)
\
\ ******************************************************************************

.MESS2

 EQUS "RUN ELTBD"
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
\       Name: MESS10
\       Type: Variable
\   Category: Loader
\    Summary: Load the Elite configuration file that contains the full path of
\             the game binary directory, just after the *DIR in command MESS1
\
\ ******************************************************************************

.MESS10

 EQUS "LOAD EliteConf "
 EQUS STR$~(MESS1 + 4)
 EQUB 13

\ ******************************************************************************
\
\ Save EliteB.bin
\
\ ******************************************************************************

 PRINT "S.EliteB ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/EliteB.bin", CODE%, P%, LOAD%