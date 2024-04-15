\ ******************************************************************************
\
\ 6502 SECOND PROCESSOR ELITE BOOT FILE
\
\ 6502 Second Processor Elite was written by Ian Bell and David Braben and is
\ copyright Acornsoft 1985
\
\ The code on this site is identical to the source discs released on Ian Bell's
\ personal website at http://www.elitehomepage.org/ (it's just been reformatted
\ to be more readable)
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
\   * EliteSP.bin
\
\ ******************************************************************************

 GUARD &6000            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 ZP = &70

 sram% = &7400

 used% = &7410

 dupl% = &7420

 eliterom% = &7430

 testbbc% = &7432

 loadrom% = &7438

 OSARGS = &FFDA         \ The address for the OSARGS routine

 OSWRCH = &FFEE         \ The address for the OSWRCH routine

 OSBYTE = &FFF4         \ The address for the OSBYTE routine

 OSCLI = &FFF7          \ The address for the OSCLI routine

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

 CODE% = &12E3
 LOAD% = &12E3

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

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR $.Elite")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to change
                        \ to the game folder

 LDA #1                 \ Set ZP(1 0) to the address of the argument to the
 LDX #ZP                \ *EliteB command
 LDY #0
 JSR OSARGS

                        \ We need to check for NFS 3.34 as this has a bug in it
                        \ that points ZP(1 0) to the start of the command, so
                        \ we now set Y to an additional index to the argument in
                        \ the *EliteB command (which will be zero for all
                        \ versions except NFS 3.34)

 LDA #0                 \ Fetch the filing system type into A
 LDY #0
 JSR OSARGS

 CMP #5                 \ If this is not NFS (type 5), jump to chek1 to set
 BNE chek1              \ Y = 0

 LDA #2                 \ Fetch the version of NFS
 LDY #0
 JSR OSARGS

 CMP #2                 \ If this is NFS 3.34, then the version returned is 2,
 BNE chek1              \ so if this is not NFS 3.34, jump to chek1 to set Y = 0

 LDY #7                 \ This is NFS 3.34, which contains the bug, so set Y = 7
                        \ so adding it to the address in ZP(1 0) will point to
                        \ the argument x in *EliteB x

 BNE chek2              \ Jump to chek2 to skip the following (this BNE is
                        \ effectively a JMP as Y is never zero)

.chek1

 LDY #0                 \ This is not NFS 3.34, so set Y = 0

.chek2

 CLC                    \ Set ZP(1 0) = ZP(1 0) + Y
 TYA
 ADC ZP+1
 STA ZP+1
 BCC chek3
 INC ZP

.chek3

 LDY #0                 \ If the argument is not T (i.e. *EliteB T), jump to
 LDA (ZP),Y             \ chek4 to keep looking
 CMP #'T'
 BNE chek4

 LDX #LO(MESS4)         \ Set (Y X) to point to MESS4 ("RUN ELTTC")
 LDY #HI(MESS4)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS4, which *RUNs
                        \ the docked code, returning from the subroutine using
                        \ a tail call

.chek4

 CMP #'D'               \ If the argument is not D (i.e. *EliteB D), jump to
 BNE chek5              \ chek5 to load the game

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("RUN ELTDC")
 LDY #HI(MESS3)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3, which *RUNs
                        \ the flight code, returning from the subroutine using
                        \ a tail call

.chek5

                        \ There is no D or T argument to *EliteB, so now we need
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

.entr1

 LDA (ZP),Y             \ Pass the Y-th byte of the B% table to OSWRCH
 JSR OSWRCH

 INY                    \ Increment the loop counter

 CPY #12                \ Loop back for the next byte until we have done them
 BNE entr1              \ all 12

 LDX #LO(MESS5)         \ Set (Y X) to point to MESS5 ("RUN ELTSC")
 LDY #HI(MESS5)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS5 to show the
                        \ Acornsoft loading screen

 LDX #LO(MESS6)         \ Set (Y X) to point to MESS6 ("LOAD ELTMN")
 LDY #HI(MESS6)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS6 to load the
                        \ menu code

 JSR testbbc%           \ Test all the ROM banks for sideways RAM

 BIT eliterom%          \ If bit 7 of eliterom% is clear then the Elite ROM has
 BPL entr4              \ already been loaded, so jump to entr4 to skip the
                        \ following

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

.entr2

 LDA (ZP+1),Y           \ If sram% for this bank is not &FF, move on to the next
 CMP #&FF               \ bank
 BNE entr3

 LDA (ZP+3),Y           \ If used% for this bank is not 0, move on to the next
 BNE entr3              \ bank

 LDA (ZP+5),Y           \ If dupl% for this bank is not the bank number itself,
 STY ZP                 \ move on to the next bank
 CMP ZP
 BNE entr3

                        \ If we get here then this bank contains sideways RAM,
                        \ it doesn't already contain a ROM, and it is not a
                        \ duplicate of another ROM, so we can use this bank

 STY ZP                 \ Store the bank number in ZP

 JMP entr4              \ Jump to entr4 to load the ROM image

.entr3

 DEY                    \ Decrement the ROM counter

 BPL entr2              \ Loop back until we have checked all 16 ROM banks

 JMP entr5              \ If we get here then there is no sideways RAM that
                        \ we can use, so jump to entr5 to print an error
                        \ message and quit

.entr4

 LDX #LO(MESS7)         \ Set (Y X) to point to MESS7 ("LOAD ELTRM 3400")
 LDY #HI(MESS7)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS7 to load the
                        \ Elite ROM

 LDX ZP                 \ Set X to the sideways RAM bank number

 JSR loadrom%           \ Move the ROM code into sideways RAM

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("RUN ELTIN")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2, which *RUNs
                        \ the game in ELTIN, returning from the subroutine using
                        \ a tail call

.entr5

                        \ If we get here then there is no sideways RAM, so print
                        \ an error message and quit

 LDA #LO(nosram)        \ Set the low byte of ZP(1 0) to point to the message
 STA ZP                 \ at nosram

 LDA #HI(nosram)        \ Set the high byte of ZP(1 0) to point to the message
 STA ZP+1               \ at nosram

 LDY #0                 \ We are now going to print the error message

.entr6

 LDA (ZP),Y             \ Pass the Y-th byte of the B% table to OSWRCH
 JSR OSWRCH

 INY                    \ Increment the loop counter

 CMP #13                \ Loop back until we have printed the whole message
 BNE entr6

 RTS                    \ Return from the subroutine

.nosram

 EQUB 22, 7
 EQUS "No sideways RAM found"
 EQUB 10, 13

\ ******************************************************************************
\
\       Name: B%
\       Type: Variable
\   Category: Drawing the screen
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
\       Name: MESS7
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for disc Elite
\
\ ******************************************************************************

.MESS7

 EQUS "LOAD ELTRM 3400"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS6
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for disc Elite
\
\ ******************************************************************************

.MESS6

 EQUS "LOAD ELTMN"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS5
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for disc Elite
\
\ ******************************************************************************

.MESS5

 EQUS "RUN ELTSC"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS4
\       Type: Variable
\   Category: Loader
\    Summary: Run the docked code for disc Elite
\
\ ******************************************************************************

.MESS4

 EQUS "RUN ELTTC"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: Run the flight code for disc Elite
\
\ ******************************************************************************

.MESS3

 EQUS "RUN ELTDC"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Run Elite
\
\ ******************************************************************************

.MESS2

 EQUS "RUN ELTIN"
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

 EQUS "DIR $.Elite"
 EQUB 13

\ ******************************************************************************
\
\ Save EliteSP.bin
\
\ ******************************************************************************

 PRINT "S.EliteB ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/EliteB.bin", CODE%, P%, LOAD%