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

 ZP = &70               \ Use language-safe zero page locations, so they don't
                        \ clash with BASIC

 BRKV = &0202           \ The break vector that we intercept to enable us to
                        \ load the configuration file, if there is one

 OSARGS = &FFDA         \ The address for the OSARGS routine

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
\ ------------------------------------------------------------------------------
\
\ This part implements the following loader commands:
\
\   *Elite              Detect the current machine and run the correct version
\                       of Elite
\
\   *Elite X            Run the Executive version of 6502 Second Processor Elite
\
\   *Elite S            Run the ElScore scoreboard program
\
\   *Elite D            Run the ElDebug debugger program
\
\   *Elite V            Show the contents of the Version file
\
\ ******************************************************************************

.ENTRY

 TSX                    \ Store the stack pointer in stack so we can restore it
 STX stack              \ if there's an error

 LDA BRKV               \ Fetch the current value of the break vector
 STA oldBRKV
 LDA BRKV+1
 STA oldBRKV+1

 SEI                    \ Disable interrupts while we update the break vector

 LDA #LO(NoConfFile)    \ Set BRKV to point to NoConfFile, so if there is no
 STA BRKV               \ configuration file, we jump to NoConfFile where we
 LDA #HI(NoConfFile)    \ clear the break condition and return to chek1 to
 STA BRKV+1             \ restore the break vector and keep going

 CLI                    \ Enable interrupts again

 LDX #LO(MESS10)        \ Set (Y X) to point to MESS10 ("LOAD EliteConf xxxx")
 LDY #HI(MESS10)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS10 to load
                        \ the game binary path from EliteConf into the OS
                        \ command string in MESS1, so if there is a
                        \ configuration file, we change directory to the
                        \ configured directory rather than $.EliteGame

.chek1

 SEI                    \ Disable interrupts while we update the break vector

 LDA oldBRKV            \ Restore BRKV
 STA BRKV
 LDA oldBRKV+1
 STA BRKV+1

 CLI                    \ Enable interrupts again

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

                        \ This is NFS 3.34, which contains the bug, so we add 6
                        \ to the address in ZP(1 0) so that it points to the
                        \ argument to the *Elite command (as "Elite " contains
                        \ six characters)

 LDY #5                 \ If the *Elite has no parameter then the sixth
 LDA (ZP),Y             \ character in the command string will be a carriage
 CMP #&0D               \ return (&0D), so jump to chek6 to load the game
 BNE P%+5
 JMP chek6

                        \ Otherwise the command has a parameter, so we now set
                        \ ZP(1 0) to point to that parameter

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) + 6
 CLC                    \
 ADC #6                 \ So ZP(1 0) points to the correct address of the
 STA ZP                 \ argument to the *Elite command for NFS 3.34
 BCC chek2
 INC ZP+1

.chek2

 LDA #1                 \ Set ZP(1 0) to the address of the argument to the
 LDX #ZP                \ *Elite command
 LDY #0
 JSR OSARGS

 LDY #0                 \ If the argument is not X (i.e. *Elite X), jump to
 LDA (ZP),Y             \ chek3 to keep looking
 CMP #'X'
 BNE chek3

                        \ If we get here then the command is *Elite X, which
                        \ loads the Executive version

 LDA #LO(LOAD5)         \ Set ZP(1 0) to the text at LOAD5
 STA ZP
 LDA #HI(LOAD5)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD5

 LDX #LO(MESS5)         \ Set (Y X) to point to MESS5 ("EliteX")
 LDY #HI(MESS5)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS5 to run the
                        \ Executive version of Elite over Econet

.chek3

 CMP #'S'               \ If the argument is not S (i.e. *Elite S), jump to
 BNE chek4              \ chek4 to keep looking

                        \ If we get here then the command is *Elite S, which
                        \ loads the scoreboard

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR $.EliteGame")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to change
                        \ to the game folder

 LDA #LO(LOAD6)         \ Set ZP(1 0) to the text at LOAD6
 STA ZP
 LDA #HI(LOAD6)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD6

 LDA #225               \ Call OSBYTE with A = 225 and X = 1 to set the function
 LDX #1                 \ keys to expand as normal soft keys
 JSR OSBYTE

 LDX #LO(MESS6)         \ Set (Y X) to point to MESS6 (KEY 0 CHAIN "ElScore"|M)
 LDY #HI(MESS6)

.runBasic

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS6 to run the
                        \ scoreboard

 LDA #15                \ Call OSBYTE with A = 15 and X = 0 to flush all buffers
 LDX #0
 JSR OSBYTE

 LDA #138               \ Call OSBYTE with A = 138, X = 0 and Y = 128 to insert
 LDX #0                 \ the f0 key into the keyboard buffer
 LDY #128
 JSR OSBYTE

 LDX #LO(MESS8)         \ Set (Y X) to point to MESS8 ("BASIC")
 LDY #HI(MESS8)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS8 to switch
                        \ to BASIC and return from the subroutine using a tail
                        \ call

.chek4

 CMP #'D'               \ If the argument is not D (i.e. *Elite D), jump to
 BNE chek5              \ chek5 to keep looking

                        \ If we get here then the command is *Elite D, which
                        \ loads the debugger

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR $.EliteGame")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to change
                        \ to the game folder

 LDA #LO(LOAD7)         \ Set ZP(1 0) to the text at LOAD7
 STA ZP
 LDA #HI(LOAD7)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD6

 LDA #225               \ Call OSBYTE with A = 225 and X = 1 to set the function
 LDX #1                 \ keys to expand as normal soft keys
 JSR OSBYTE

 LDX #LO(MESS7)         \ Set (Y X) to point to MESS7 (KEY 0 CHAIN "ElDebug"|M)
 LDY #HI(MESS7)

 BNE runBasic           \ Jump up to switch to BASIC and "press" f0 (this BNE is
                        \ effectively a JMP as Y is never zero)

.chek5

 CMP #'V'               \ If the argument is not V (i.e. *Elite V), jump to
 BNE chek6              \ chek6 to keep looking

                        \ If we get here then the command is *Elite V, which
                        \ prints the version

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR $.EliteGame")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to change
                        \ to the game folder

 LDX #LO(MESS9)         \ Set (Y X) to point to MESS9 ("TYPE Version")
 LDY #HI(MESS9)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS9 to show the
                        \ version number and return from the subroutine using a
                        \ tail call

 LDX stack              \ Restore the value of the stack pointer from when we
 TXS                    \ started

 RTS                    \ Return from the subroutine

.chek6

 LDA #234               \ Call OSBYTE with A = 234, X = 0 and Y= 255 to read the
 LDX #0                 \ Tube present flag into X
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

 LDA #LO(LOAD3)         \ Set ZP(1 0) to the text at LOAD3
 STA ZP
 LDA #HI(LOAD3)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD3

 LDX #LO(MESS3)         \ Set (Y X) to point to MESS3 ("EliteM")
 LDY #HI(MESS3)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS3 to run the
                        \ BBC Master version of Elite over Econet

.bbc

 LDA #LO(LOAD2)         \ Set ZP(1 0) to the text at LOAD2
 STA ZP
 LDA #HI(LOAD2)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD2

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("EliteB")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2 to run the
                        \ BBC Micro version of Elite over Econet

.copro

                        \ This is a 6502 Second Processor

 LDA #LO(LOAD4)         \ Set ZP(1 0) to the text at LOAD4
 STA ZP
 LDA #HI(LOAD4)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD4

 LDX #LO(MESS4)         \ Set (Y X) to point to MESS4 ("EliteSP")
 LDY #HI(MESS4)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS4 to run the
                        \ 6502 Second Processor version of Elite over Econet

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

 LDX stack              \ Restore the value of the stack pointer from when we
 TXS                    \ started

 JMP chek1              \ Return to just after the failed load command to
                        \ continue with the loader

\ ******************************************************************************
\
\       Name: stack
\       Type: Variable
\   Category: Loader
\    Summary: Storage for the stack pointer
\
\ ******************************************************************************

.stack

 EQUW 0

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
\       Name: MESS2
\       Type: Variable
\   Category: Loader
\    Summary: Run the BBC Micro version of Elite
\
\ ******************************************************************************

.MESS2

 EQUS "EliteB"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS3
\       Type: Variable
\   Category: Loader
\    Summary: Run the BBC Master version of Elite
\
\ ******************************************************************************

.MESS3

 EQUS "EliteM"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS4
\       Type: Variable
\   Category: Loader
\    Summary: Run the 6502 Second Processor version of Elite
\
\ ******************************************************************************

.MESS4

 EQUS "EliteSP"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS5
\       Type: Variable
\   Category: Loader
\    Summary: Run the Executive version of Elite
\
\ ******************************************************************************

.MESS5

 EQUS "EliteX"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS6
\       Type: Variable
\   Category: Loader
\    Summary: Set up f0 to run the scoreboard
\
\ ******************************************************************************

.MESS6

 EQUS "KEY 0 CHAIN "
 EQUB &22
 EQUS "ElScore"
 EQUB &22
 EQUS "|M"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS7
\       Type: Variable
\   Category: Loader
\    Summary: Set up f0 to run the debugger
\
\ ******************************************************************************

.MESS7

 EQUS "KEY 0 CHAIN "
 EQUB &22
 EQUS "ElDebug"
 EQUB &22
 EQUS "|M"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS8
\       Type: Variable
\   Category: Loader
\    Summary: Switch to BASIC
\
\ ******************************************************************************

.MESS8

 EQUS "BASIC"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS9
\       Type: Variable
\   Category: Loader
\    Summary: Show the version number
\
\ ******************************************************************************

.MESS9

 EQUS "TYPE Version"
 EQUB 13

\ ******************************************************************************
\
\       Name: LOAD2
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the BBC Micro version
\
\ ******************************************************************************

.LOAD2

 EQUS "Loading Elite over Econet for the"
 EQUB 10, 13
 EQUS "BBC Micro..."
 EQUB 0

\ ******************************************************************************
\
\       Name: LOAD3
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the BBC Master version
\
\ ******************************************************************************

.LOAD3

 EQUS "Loading Elite over Econet for the"
 EQUB 10, 13
 EQUS "BBC Master..."
 EQUB 0

\ ******************************************************************************
\
\       Name: LOAD4
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the 6502 Second Processor version
\
\ ******************************************************************************

.LOAD4

 EQUS "Loading Elite over Econet for the"
 EQUB 10, 13
 EQUS "6502 Second Processor..."
 EQUB 0

\ ******************************************************************************
\
\       Name: LOAD5
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the Executive version
\
\ ******************************************************************************

.LOAD5

 EQUS "Loading the Executive version of"
 EQUB 10, 13
 EQUS "Elite over Econet..."
 EQUB 0

\ ******************************************************************************
\
\       Name: LOAD6
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the scoreboard
\
\ ******************************************************************************

.LOAD6

 EQUS "Loading the scoreboard for"
 EQUB 10, 13
 EQUS "Elite over Econet..."
 EQUB 10, 13
 EQUB 0

\ ******************************************************************************
\
\       Name: LOAD7
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the scoreboard
\
\ ******************************************************************************

.LOAD7

 EQUS "Loading the debugger for"
 EQUB 10, 13
 EQUS "Elite over Econet..."
 EQUB 10, 13
 EQUB 0

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
\ Save Elite.bin
\
\ ******************************************************************************

 PRINT "S.Elite ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/Elite.bin", CODE%, P%, LOAD%