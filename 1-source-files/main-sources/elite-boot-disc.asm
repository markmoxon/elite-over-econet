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

 GUARD &6000            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 ZP = &32               \ Use the XX15 block for the loading code, so it doesn't
                        \ clash with any persistent variables

 S% = &12E3             \ The address of the main entry point workspace in the
                        \ main game code

 sram% = &7400          \ The sideways RAM table in the SRAM loader

 used% = &7410          \ The used ROM table in the SRAM loader

 dupl% = &7420          \ The duplicate ROM table in the SRAM loader

 eliterom% = &7430      \ The Elite ROM bank number in the SRAM loader

 testbbc% = &7432       \ The ROM bank test routine in the SRAM loader

 loadrom% = &7438       \ The Elite ROM load routine in the SRAM loader

 OSARGS = &FFDA         \ The address for the OSARGS routine

 OSWRCH = &FFEE         \ The address for the OSWRCH routine

 OSBYTE = &FFF4         \ The address for the OSBYTE routine

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

 CMP #5                 \ If this is not NFS (type 5), jump to chek1 to skip the
 BNE chek1              \ bug fix, as the bug only applies to NFS

 LDA #2                 \ Fetch the version of NFS
 LDY #0
 JSR OSARGS

 CMP #2                 \ If this is NFS 3.34, then the version returned is 2,
 BNE chek1              \ so if this is not NFS 3.34, jump to chek1 to skip the
                        \ bug fix

                        \ This is NFS 3.34, which contains the bug, so we add 7
                        \ to the address in ZP(1 0) so that it points to the
                        \ argument to the *EliteB command (as "EliteB " contains
                        \ seven characters)

 LDY #6
 LDA (ZP),Y
 CMP #&0D
 BEQ chek8

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) + 7
 CLC                    \
 ADC #7                 \ So ZP(1 0) points to the correct address of the
 STA ZP                 \ argument to the *EliteB command for NFS 3.34
 BCC chek1
 INC ZP+1

.chek1

 LDY #0                 \ If the argument is not T (i.e. *EliteB T), jump to
 LDA (ZP),Y             \ chek2 to keep looking
 CMP #'T'
 BNE chek2

                        \ If we get here then the command is *EliteB T, which
                        \ loads the docked code for the sideways RAM version
                        \ and restarts the game (*LOAD T.CODE in the original)

 LDX #LO(MESS8)         \ Set (Y X) to point to MESS8 ("LOAD ELTBT")
 LDY #HI(MESS8)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS8, which
                        \ *LOADs the docked code

 JMP S%+3               \ Jump to the second JMP instruction in the docked code,
                        \ which is a JMP DOBEGIN that restarts the game

.chek2

 CMP #'R'               \ If the argument is not R (i.e. *EliteB R), jump to
 BNE chek3              \ chek3 to keep looking

                        \ If we get here then the command is *EliteB R, which
                        \ runs the docked code for the sideways RAM version
                        \ and docks with the station (*RUN T.CODE in the
                        \ original)

 LDX #LO(MESS4)         \ Set (Y X) to point to MESS4 ("RUN ELTBT")
 LDY #HI(MESS4)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3, which *RUNs
                        \ the flight code (and calls the DOENTRY routine to dock
                        \ at the station), returning from the subroutine using
                        \ a tail call

.chek3

 CMP #'V'               \ If the argument is not V (i.e. *EliteB V), jump to
 BNE chek4              \ chek4 to keep looking

                        \ If we get here then the command is *EliteB V, which
                        \ runs the flight code for the sideways RAM version
                        \ (*RUN D.CODE in the original)

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("RUN ELTBD")
 LDY #HI(MESS3)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3, which *RUNs
                        \ the flight code, returning from the subroutine using
                        \ a tail call

.chek4

 CMP #'S'               \ If the argument is not S (i.e. *EliteB S), jump to
 BNE chek5              \ chek5 to keep looking

                        \ If we get here then the command is *EliteB S, which
                        \ loads the docked code for the standard version and
                        \ restarts the game (*LOAD T.CODE in the original)

 LDX #LO(MESS11)        \ Set (Y X) to point to MESS11 ("LOAD ELTAT")
 LDY #HI(MESS11)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS8, which
                        \ *LOADs the docked code

 JMP S%+3               \ Jump to the second JMP instruction in the docked code,
                        \ which is a JMP DOBEGIN that restarts the game

.chek5

 CMP #'Q'               \ If the argument is not Q (i.e. *EliteB Q), jump to
 BNE chek6              \ chek6 to keep looking

                        \ If we get here then the command is *EliteB Q, which
                        \ runs the docked code for the standard version and
                        \ docks with the station (*RUN T.CODE in the original)

 LDX #LO(MESS10)        \ Set (Y X) to point to MESS10 ("RUN ELTAT")
 LDY #HI(MESS10)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3, which *RUNs
                        \ the flight code (and calls the DOENTRY routine to dock
                        \ at the station), returning from the subroutine using
                        \ a tail call

.chek6

 CMP #'U'               \ If the argument is not U (i.e. *EliteB U), jump to
 BNE chek7              \ chek7 to keep looking

                        \ If we get here then the command is *EliteB U, which
                        \ runs the flight code for the standard version
                        \ (*RUN D.CODE in the original)

 LDX #LO(MESS9)         \ Set (Y X) to point to MESS9 ("RUN ELTAD")
 LDY #HI(MESS9)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3, which *RUNs
                        \ the flight code, returning from the subroutine using
                        \ a tail call

.chek7

 CMP #'A'               \ If the argument is not in the range A to P (so that's
 BCC chek8              \ *EliteB A to *EliteB P), jump to chek8 to keep
 CMP #'Q'               \ looking
 BCS chek8

                        \ If we get here then the command is *EliteB A to P,
                        \ which loads a ship blueprints file for the standard
                        \ version (*LOAD D.MO0 in the original, where 0 is the
                        \ argument)

 STA MESS13+9           \ Store the letter of the ship blueprints file we want
                        \ in the tenth byte of the command string at MESS13, so
                        \ it overwrites the "0" in "D.MO0" with the file letter
                        \ to load, from D.MOA to D.MOP

 LDX #LO(MESS13)        \ Set (Y X) to point to MESS13 ("LOAD D.MO0")
 LDY #HI(MESS13)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS13, which
                        \ *LOADs the ship blueprints file, returning from the
                        \ subroutine using a tail call

.chek8

                        \ There is no valid argument to *EliteB, so now we need
                        \ to load the game from the loading screen

 LDA #4                 \ Call OSBYTE with A = 4, X = 1 and Y = 0 to disable
 LDX #1                 \ cursor editing, so the cursor keys return ASCII values
 JSR OSBYTE             \ and can therefore be used in-game

 LDA #200               \ Call OSBYTE with A = 200, X = 1 and Y = 0 to disable
 LDX #1                 \ the ESCAPE key and disable memory clearing if the
 JSR OSBYTE             \ BREAK key is pressed

 LDA #LO(B%)            \ Set the low byte of ZP(1 0) to point to the VDU code
 STA ZP                 \ table at B%

 LDA #HI(B%)            \ Set the high byte of ZP(1 0) to point to the VDU code
 STA ZP+1               \ table at B%

 LDY #0                 \ We are now going to print the VDU commands from B%

.chek9

 LDA (ZP),Y             \ Pass the Y-th byte of the B% table to OSWRCH
 JSR OSWRCH

 INY                    \ Increment the loop counter

 CPY #12                \ Loop back for the next byte until we have done them
 BNE chek9              \ all 12

 LDX #LO(MESS5)         \ Set (Y X) to point to MESS5 ("RUN ELTBS")
 LDY #HI(MESS5)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS5 to show the
                        \ Acornsoft loading screen

 LDX #LO(MESS6)         \ Set (Y X) to point to MESS6 ("LOAD ELTBM")
 LDY #HI(MESS6)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS6 to load the
                        \ menu code

 JSR testbbc%           \ Test all the ROM banks for sideways RAM

 LDY eliterom%          \ If bit 7 of eliterom% is clear then the Elite ROM has
 BPL chek11             \ already been loaded, so jump to chek11 to skip the
                        \ ROM checks and load the game into this bank

 LDA #LO(sram%)         \ Set ZP(2 1) = &7400 = sram%
 STA ZP+1
 LDA #HI(sram%)
 STA ZP+2

 LDA #LO(used%)         \ Set ZP(4 3) = &7410 = used%
 STA ZP+3
 LDA #HI(used%)
 STA ZP+4

 LDA #LO(dupl%)         \ Set ZP(6 5) = &7420 = dupl%
 STA ZP+5
 LDA #HI(dupl%)
 STA ZP+6

 LDY #15                \ We now loop through the ROM banks to check for
                        \ sideways RAM, so set a counter in Y

.chek10

 LDA (ZP+1),Y           \ If sram% for this bank is not &FF, move on to the next
 CMP #&FF               \ bank
 BNE chek12

 LDA (ZP+3),Y           \ If used% for this bank is not 0, move on to the next
 BNE chek12             \ bank

 LDA (ZP+5),Y           \ If dupl% for this bank is not the bank number itself,
 STY ZP                 \ move on to the next bank
 CMP ZP
 BNE chek12

                        \ If we get here then this bank contains sideways RAM,
                        \ it doesn't already contain a ROM, and it is not a
                        \ duplicate of another ROM, so we can use this bank

.chek11

 STY ZP                 \ Store the bank number in ZP

 JMP chek13             \ Jump to chek13 to load the ROM image

.chek12

 DEY                    \ Decrement the ROM counter

 BPL chek10             \ Loop back until we have checked all 16 ROM banks

 JMP chek14             \ If we get here then there is no sideways RAM that
                        \ we can use, so jump to chek14 to print an error
                        \ message and quit

.chek13

 LDX #LO(MESS7)         \ Set (Y X) to point to MESS7 ("LOAD ELTBR 3400")
 LDY #HI(MESS7)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS7 to load the
                        \ Elite ROM

 LDX ZP                 \ Set X to the sideways RAM bank number

 JSR loadrom%           \ Move the ROM code into sideways RAM

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("RUN ELTBI")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the game in ELTBI, returning from the subroutine using
                        \ a tail call

.chek14

                        \ If we get here then there is no sideways RAM, so run
                        \ the standard version

 LDX #LO(MESS12)        \ Set (Y X) to point to MESS12 ("RUN ELTAI")
 LDY #HI(MESS12)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS12, which *RUNs
                        \ the game in ELTAI, returning from the subroutine using
                        \ a tail call

\ ******************************************************************************
\
\       Name: B%
\       Type: Variable
\   Category: Loader
\    Summary: VDU commands for the loader
\
\ ******************************************************************************

.B%

 EQUB 22, 7             \ Switch to screen mode 7

 EQUB 23, 0, 10, 32     \ Set 6845 register R10 = 32
 EQUB 0, 0, 0           \
 EQUB 0, 0, 0           \ This is the "cursor start" register, so this sets the
                        \ cursor start line at 0, effectively disabling the
                        \ cursor

\ ******************************************************************************
\
\       Name: MESS13
\       Type: Variable
\   Category: Loader
\    Summary: Load a ship file for standard Elite (D.MOx)
\
\ ******************************************************************************

.MESS13

 EQUS "LOAD D.MO0"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS12
\       Type: Variable
\   Category: Loader
\    Summary: Run the loader for standard Elite (ELITE4)
\
\ ******************************************************************************

.MESS12

 EQUS "RUN ELTAI"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS11
\       Type: Variable
\   Category: Loader
\    Summary: Load the docked code for standard disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS11

 EQUS "LOAD ELTAT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS10
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for standard disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS10

 EQUS "RUN ELTAT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS9
\       Type: Variable
\   Category: Loader
\    Summary: Run the flight code for standard disc Elite (D.CODE)
\
\ ******************************************************************************

.MESS9

 EQUS "RUN ELTAD"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS8
\       Type: Variable
\   Category: Loader
\    Summary: Load the docked code for sideways RAM disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS8

 EQUS "LOAD ELTBT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS7
\       Type: Variable
\   Category: Loader
\    Summary: Load the Elite ROM image to &3400, so it can be copied to sideways
\             RAM by the LoadRom routine
\
\ ******************************************************************************

.MESS7

 EQUS "LOAD ELTBR 3400"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS6
\       Type: Variable
\   Category: Loader
\    Summary: Load the sideways RAM loader routines (MNUCODE)
\
\ ******************************************************************************

.MESS6

 EQUS "LOAD ELTBM"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS5
\       Type: Variable
\   Category: Loader
\    Summary: Run the code that displays the Acornsoft loading screen (SCREEN)
\
\ ******************************************************************************

.MESS5

 EQUS "RUN ELTBS"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS4
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for sideways RAM disc Elite (T.CODE)
\
\ ******************************************************************************

.MESS4

 EQUS "RUN ELTBT"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: Run the flight code for sideways RAM disc Elite (D.CODE)
\
\ ******************************************************************************

.MESS3

 EQUS "RUN ELTBD"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Run the loader for sideways RAM Elite (INTRO)
\
\ ******************************************************************************

.MESS2

 EQUS "RUN ELTBI"
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
\ Save EliteB.bin
\
\ ******************************************************************************

 PRINT "S.EliteB ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/EliteB.bin", CODE%, P%, LOAD%