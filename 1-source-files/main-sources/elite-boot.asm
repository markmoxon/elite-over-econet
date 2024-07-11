\ ******************************************************************************
\
\ ELITE OVER ECONET BOOT FILE
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
\   * Elite.bin
\
\ ******************************************************************************

 CPU 1                  \ Switch to 65SC12 assembly, as this code contains a
                        \ 6502 Second Processor DEC A instruction

 GUARD &6000            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 ZP = &32               \ Use the XX15 block for the loading code, so it doesn't
                        \ clash with any persistent variables

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
\       Name: Elite boot program
\       Type: Subroutine
\   Category: Loader
\    Summary: Detect the current machine and run the correct version of Elite
\
\ ******************************************************************************

.ENTRY

 LDA #234               \ Call OSBYTE with A = 234, X = 0 and Y= = 255 to read
 LDX #0                 \ the Tube present flag into X
 LDY #255
 JSR OSBYTE

 CPX #&FF               \ X will be &FF if this is a co-processor, so jump to
 BEQ copro              \ copro if this is the case

 LDA #0                 \ Call OSBYTE with A = 0 and X = 1 to return the machine
 LDX #1                 \ type in X
 JSR OSBYTE

 CPX #3                 \ If X < 3 or X > 5 then this is not a BBC Master so
 BCC bbc                \ jump to bbc to load the BBC Micro version
 CPX #6
 BCS bbc

                        \ This is a BBC Master

 LDA #LO(LOAD2)         \ Set ZP(1 0) to the text at LOAD2
 STA ZP
 LDA #HI(LOAD2)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD2

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("EliteM")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2 to run the
                        \ BBC Master version of Elite over Econet

.bbc

 LDA #LO(LOAD1)         \ Set ZP(1 0) to the text at LOAD1
 STA ZP
 LDA #HI(LOAD1)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD1

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("EliteB")
 LDY #HI(MESS1)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS1 to run the
                        \ BBC Micro version of Elite over Econet

.copro

                        \ This is a 6502 Second Processor

 LDA #LO(LOAD3)         \ Set ZP(1 0) to the text at LOAD3
 STA ZP
 LDA #HI(LOAD3)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD3

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("EliteSP")
 LDY #HI(MESS3)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3 to run the
                        \ 6502 Second Processor version of Elite over Econet

\ ******************************************************************************
\
\       Name: PrintMessage
\       Type: Subroutine
\   Category: Loader
\    Summary: Print the null-terminated string at ZP(1 0)
\
\ ******************************************************************************

.PrintMessage

 LDY #0                 \ We are now going to print the characters at ZP(1 0),
                        \ so set a byte counter in Y

.prin1

 LDA (ZP),Y             \ Fetch the Y-th byte of the string

 BEQ prin2              \ If A is null then we have reached the end of the
                        \ string, so jump to prin1 to return from the subroutine

 JSR OSWRCH             \ Print the character in A

 INY                    \ Increment the byte counter

 BNE prin1              \ Loop back for the next byte (this BNE is effectively a
                        \ JMP as Y is never zero)

.prin2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MESS1
\       Type: Variable
\   Category: Loader
\    Summary: Run the BBC Micro version of Elite
\
\ ******************************************************************************

.MESS1

 EQUS "EliteB"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Run the BBC Master version of Elite
\
\ ******************************************************************************

.MESS2

 EQUS "EliteM"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: Run the 6502 Second Processor version of Elite
\
\ ******************************************************************************

.MESS3

 EQUS "EliteSP"
 EQUB 13

\ ******************************************************************************
\
\       Name: LOAD1
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the BBC Micro version
\
\ ******************************************************************************

.LOAD1

 EQUS "Loading Elite over Econet for the"
 EQUB 10, 13
 EQUS "BBC Micro..."
 EQUB 0

\ ******************************************************************************
\
\       Name: LOAD2
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the BBC Master version
\
\ ******************************************************************************

.LOAD2

 EQUS "Loading Elite over Econet for the"
 EQUB 10, 13
 EQUS "BBC Master..."
 EQUB 0

\ ******************************************************************************
\
\       Name: LOAD3
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the 6502 Second Processor version
\
\ ******************************************************************************

.LOAD3

 EQUS "Loading Elite over Econet for the"
 EQUB 10, 13
 EQUS "6502 Second Processor..."
 EQUB 0

\ ******************************************************************************
\
\ Save Elite.bin
\
\ ******************************************************************************

 PRINT "S.Elite ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/Elite.bin", CODE%, P%, LOAD%