\ ******************************************************************************
\
\ DISC ELITE LOADER
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
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * ELTAB.bin
\
\ ******************************************************************************

 GUARD &7C00            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 ZP = &32               \ Use the XX15 block for the loading code, so it doesn't
                        \ clash with any persistent variables

 sram% = &7400          \ The sideways RAM table in the SRAM loader

 used% = &7410          \ The used ROM table in the SRAM loader

 dupl% = &7420          \ The duplicate ROM table in the SRAM loader

 eliterom% = &7430      \ The Elite ROM bank number in the SRAM loader

 testbbc% = &7432       \ The ROM bank test routine in the SRAM loader

 loadrom% = &7438       \ The Elite ROM load routine in the SRAM loader

 OSWRCH = &FFEE         \ The address for the OSWRCH routine

 OSBYTE = &FFF4         \ The address for the OSBYTE routine

 OSCLI = &FFF7          \ The address for the OSCLI routine

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

 CODE% = &2400          \ The address where the loader code runs

 LOAD% = &2400          \ The address where the loader code loads

 ORG CODE%

\ ******************************************************************************
\
\       Name: Elite loader
\       Type: Subroutine
\   Category: Loader
\    Summary: Check PAGE and load the correct version of BBC Micro Elite,
\             depending on the machine's configuration
\
\ ******************************************************************************

.ENTRY

                        \ First we check the value of PAGE, and if it is bigger
                        \ than &1200, we terminate with a message about FixPAGE

 LDA #131               \ Call OSBYTE with A = 131 to read the value of OSHWM,
 JSR OSBYTE             \ which is also known as PAGE, into (Y X)
 
 CPY #&13               \ If (Y X) > &1200, jump to load1 to display an error,
 BCS load1              \ otherwise jump to check10 to keep going
 CPY #&12
 BNE load2
 CPX #0
 BEQ load2

.load1

 JMP load9              \ Jump to load9 to print an error

.load2

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

.load3

 LDA (ZP),Y             \ Pass the Y-th byte of the B% table to OSWRCH
 JSR OSWRCH

 INY                    \ Increment the loop counter

 CPY #12                \ Loop back for the next byte until we have done them
 BNE load3              \ all 12

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("RUN ELTBS")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to show the
                        \ Acornsoft loading screen

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("LOAD ELTBM")
 LDY #HI(MESS2)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS2 to load the
                        \ menu code

 JSR testbbc%           \ Test all the ROM banks for sideways RAM

 LDY eliterom%          \ If bit 7 of eliterom% is clear then the Elite ROM has
 BPL load5              \ already been loaded, so jump to load5 to skip the
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

.load4

 LDA (ZP+1),Y           \ If sram% for this bank is not &FF, move on to the next
 CMP #&FF                \ bank
 BNE load6

 LDA (ZP+3),Y           \ If used% for this bank is not 0, move on to the next
 BNE load6              \ bank

 LDA (ZP+5),Y           \ If dupl% for this bank is not the bank number itself,
 STY ZP                 \ move on to the next bank
 CMP ZP
 BNE load6

                        \ If we get here then this bank contains sideways RAM,
                        \ it doesn't already contain a ROM, and it is not a
                        \ duplicate of another ROM, so we can use this bank

.load5

 STY ZP                 \ Store the bank number in ZP

 JMP load7              \ Jump to load7 to load the ROM image

.load6

 DEY                    \ Decrement the ROM counter

 BPL load4              \ Loop back until we have checked all 16 ROM banks

 JMP load8              \ If we get here then there is no sideways RAM that
                        \ we can use, so jump to load8 to print an error
                        \ message and quit

.load7

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("LOAD ELTBR 3400")
 LDY #HI(MESS3)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS3 to load the
                        \ Elite ROM

 LDX ZP                 \ Set X to the sideways RAM bank number

 JSR loadrom%           \ Move the ROM code into sideways RAM

 LDX #LO(MESS4)         \ Set (Y X) to point to MESS4 ("RUN ELTBI")
 LDY #HI(MESS4)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS4, which *RUNs
                        \ the game in ELTBI, returning from the subroutine using
                        \ a tail call

.load8

                        \ If we get here then there is no sideways RAM, so run
                        \ the standard version

 LDX #LO(MESS5)         \ Set (Y X) to point to MESS5 ("RUN ELTAI")
 LDY #HI(MESS5)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS5, which *RUNs
                        \ the game in ELTAI, returning from the subroutine using
                        \ a tail call

.load9

 LDA #18                \ Reset the soft key buffer in page &B, so FixPAGE will
 JSR OSBYTE             \ work correctly

 LDX #LO(MESS6)         \ Set (Y X) to point to MESS6 ("RUN FixPAGE")
 LDY #HI(MESS6)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS6, which *RUNs
                        \ FixPAGE, returning from the subroutine using a tail
                        \ call

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
 EQUB 0, 0, 0           \ This disbles the cursor

\ ******************************************************************************
\
\       Name: MESS1
\       Type: Variable
\   Category: Loader
\    Summary: Run the code that displays the Acornsoft loading screen (SCREEN)
\
\ ******************************************************************************

.MESS1

 EQUS "RUN ELTBS"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Load the sideways RAM loader routines (MNUCODE)
\
\ ******************************************************************************

.MESS2

 EQUS "LOAD ELTBM"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: Load the Elite ROM image to &3400, so it can be copied to sideways
\             RAM by the LoadRom routine
\
\ ******************************************************************************

.MESS3

 EQUS "LOAD ELTBR 3400"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS4
\       Type: Variable
\   Category: Loader
\    Summary: Run the loader for sideways RAM Elite (INTRO)
\
\ ******************************************************************************

.MESS4

 EQUS "RUN ELTBI"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS5
\       Type: Variable
\   Category: Loader
\    Summary: Run the loader for standard Elite (ELITE4)
\
\ ******************************************************************************

.MESS5

 EQUS "RUN ELTAI"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS6
\       Type: Variable
\   Category: Loader
\    Summary: Run FixPAGE
\
\ ******************************************************************************

.MESS6

 EQUS "RUN FixPAGE"
 EQUB 13

\ ******************************************************************************
\
\ Save ELTAB.bin
\
\ ******************************************************************************

 PRINT "S.ELTAB ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/ELTAB.bin", CODE%, P%, LOAD%