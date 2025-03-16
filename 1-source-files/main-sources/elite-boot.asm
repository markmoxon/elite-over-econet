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

 OSWORD = &FFF1         \ The address for the OSWORD routine

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

 LDA #234               \ Call OSBYTE with A = 234, X = 0 and Y= 255 to read the
 LDX #0                 \ "Tube present" flag into X
 LDY #255
 JSR OSBYTE

 STX tubePresent        \ Store the "Tube present" flag in tubePresent

 LDA #1                 \ Set ZP(1 0) to the address of the argument to the
 LDX #ZP                \ *Elite command
 LDY #0
 JSR OSARGS

                        \ We need to check for NFS 3.34 as this has a bug in it
                        \ that points ZP(1 0) to the start of the command rather
                        \ than the argument

 LDA #0                 \ Fetch the filing system type into A
 LDY #0
 JSR OSARGS

 CMP #5                 \ If this is not NFS (type 5), jump to entr1 to skip the
 BNE entr1              \ bug fix, as the bug only applies to NFS

 LDA #2                 \ Fetch the version of NFS
 LDY #0
 JSR OSARGS

 CMP #2                 \ If this is NFS 3.34, then the version returned is 2,
 BNE entr1              \ so if this is not NFS 3.34, jump to entr1 to skip the
                        \ bug fix

                        \ This is NFS 3.34, which contains the bug, so we add 6
                        \ to the address in ZP(1 0) so that it points to the
                        \ argument to the *Elite command (as "Elite " contains
                        \ six characters)

 LDY #5                 \ If the *Elite has no parameter then the sixth
 LDA (ZP),Y             \ character in the command string will be a carriage
 STA argument           \ return (&0D), so store this in argument and jump to
 CMP #&0D               \ entr3 to move on to the next step
 BEQ entr3

                        \ Otherwise the command has a parameter, so we now set
                        \ ZP(1 0) to point to that parameter

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) + 6
 CLC                    \
 ADC #6                 \ So ZP(1 0) points to the correct address of the
 STA ZP                 \ argument to the *Elite command for NFS 3.34
 BCC entr1
 INC ZP+1

.entr1

 LDX tubePresent        \ If the Tube is not active, jump to entr2 to skip the
 CPX #&FF               \ following
 BNE entr2

 LDX #ZP                \ Fetch the byte at address ZP(1 0), which contain the
 LDY #0                 \ command agrument, from the I/O Processor into byte #4
 LDA #5                 \ of the ZP block
 JSR OSWORD

 LDA ZP+4               \ Store the command argument
 STA argument

 JMP entr3              \ Skip the following

.entr2

 LDY #0                 \ Store the command argument (or &0D if there is no
 LDA (ZP),Y             \ argument)
 STA argument

.entr3

 JSR TryLoadingConf     \ Try loading EliteConf from the currently selected
                        \ directory, to support installing Elite for a single
                        \ user

                        \ We now fetch the Econet user environment, which gives
                        \ us the handles of the URD (the user's root directory),
                        \ the CSD (currently selected directory) and LIB (the
                        \ library directory)
                        \
                        \ We can then manipulate the user environment to change
                        \ the currently selected directory to the library, so we
                        \ can load the EliteConf file, if there is one

 LDA #6                 \ Set the first byte of the OSWORD block to 6, which is
 STA oswordBlock        \ the command number for reading the Econet user
                        \ environment using OSWORD &13

 LDA #&13               \ Call OSWORD with A = &13 to read the Econet user
 LDX #LO(oswordBlock)   \ environment (URD, CSD and LIB) into bytes 1 to 3 of
 LDY #HI(oswordBlock)   \ the OSWORD block
 JSR OSWORD

 LDA oswordBlock+1      \ Copy the Econet user environment into userEnv, so we
 STA userEnv            \ can restore it below
 LDA oswordBlock+2
 STA userEnv+1
 LDA oswordBlock+3
 STA userEnv+2

 STA oswordBlock+2      \ Set the CSD handle in the OSWORD block to the LIB
                        \ handle, so when we write this block back, this will
                        \ change the current directory to the library directory

 LDA #7                 \ Set the first byte of the OSWORD block to 7, which is
 STA oswordBlock        \ the command number for writing the Econet user
                        \ environment using OSWORD &13

 LDA #&13               \ Call OSWORD with A = &13 to set the CSD to LIB, so if
 LDX #LO(oswordBlock)   \ we now do a *LOAD EliteConf command, it will look in
 LDY #HI(oswordBlock)   \ the library directory
 JSR OSWORD

 JSR TryLoadingConf     \ Try loading EliteConf from the library directory

 LDA #7                 \ Set the first byte of the OSWORD block to 7, which is
 STA oswordBlock        \ the command number for writing the Econet user
                        \ environment using OSWORD &13

 LDA userEnv            \ Copy the Econet user environment from userEnv into the
 STA oswordBlock+1      \ OSWORD block
 LDA userEnv+1
 STA oswordBlock+2
 LDA userEnv+2
 STA oswordBlock+3

 LDA #&13               \ Call OSWORD with A = &13 to set the Econet user
 LDX #LO(oswordBlock)   \ environment back to its original setting
 LDY #HI(oswordBlock)
 JSR OSWORD

 LDA argument           \ Fetch the command argument

 AND #%11011111         \ Convert the argument to upper case

 CMP #'X'               \ If the argument is not X (i.e. *Elite X), jump to
 BNE entr5              \ entr5 to keep looking

                        \ If we get here then the command is *Elite X, which
                        \ loads the Executive version

 LDA #LO(LOAD5)         \ Set ZP(1 0) to the text at LOAD5 ("Loading
 STA ZP                 \ Executive...")
 LDA #HI(LOAD5)
 STA ZP+1

 LDX #'X'               \ Set X and Y so that RunElite does a *RUN ELTXE command
 LDY #'E'

 JMP RunElite           \ Run the Executive version of Elite over Econet,
                        \ returning from the subroutine using a tail call

.entr5

 CMP #'S'               \ If the argument is not S (i.e. *Elite S), jump to
 BNE entr6              \ entr6 to keep looking

                        \ If we get here then the command is *Elite S, which
                        \ loads the scoreboard

 LDA #LO(LOAD6)         \ Set ZP(1 0) to the text at LOAD6
 STA ZP
 LDA #HI(LOAD6)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD6 ("Loading scoreboard...")

 JSR ChangeToKey        \ Change the start of MESS1 to create a KEY 0 command in
                        \ MESS6

 JSR ChangeToKeyScore   \ Change the end of MESS1 to create a KEY 0 command in
                        \ MESS6 to load the scoreboard

.runBasic

 LDA #225               \ Call OSBYTE with A = 225, X = 1 and Y = 0 to set the
 LDX #1                 \ function keys to expand as normal soft keys
 LDY #0
 JSR OSBYTE

 LDX #LO(MESS6)         \ Set (Y X) to point to MESS6 (KEY 0 CHAIN "ElScore"|M)
 LDY #HI(MESS6)

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

.entr6

 CMP #'D'               \ If the argument is not D (i.e. *Elite D), jump to
 BNE entr7              \ entr7 to keep looking

                        \ If we get here then the command is *Elite D, which
                        \ loads the debugger

 LDA #LO(LOAD7)         \ Set ZP(1 0) to the text at LOAD7
 STA ZP
 LDA #HI(LOAD7)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD7 ("Loading debugger...")

 JSR ChangeToKey        \ Change the start of MESS1 to create a KEY 0 command in
                        \ MESS6

 JSR ChangeToKeyDebug   \ Change the end of MESS1 to create a KEY 0 command in
                        \ MESS6 to load the debugger

 JMP runBasic           \ Jump up to runBasic to switch to BASIC and "press" f0

.entr7

 CMP #'V'               \ If the argument is not V (i.e. *Elite V), jump to
 BNE entr8              \ entr8 to keep looking

                        \ If we get here then the command is *Elite V, which
                        \ prints the version

 JSR ChangeToVersion

 LDX #LO(MESS1-1)       \ Set (Y X) to point to MESS1-1 ("TYPE Version")
 LDY #HI(MESS1-1)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS1-1 to show
                        \ the version number and return from the subroutine
                        \ using a tail call

.entr8

 LDX tubePresent        \ Fetch the "Tube present" flag from tubePresent into X

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

 LDA #LO(LOAD3)         \ Set ZP(1 0) to the text at LOAD3 ("Loading BBC
 STA ZP                 \ Master...")
 LDA #HI(LOAD3)
 STA ZP+1

 LDX #'M'               \ Set X and Y so that RunElite does a *RUN ELTME command
 LDY #'E'

 JMP RunElite           \ Run the BBC Master version of Elite over Econet,
                        \ returning from the subroutine using a tail call

.bbc

 LDA #LO(LOAD2)         \ Set ZP(1 0) to the text at LOAD2
 STA ZP
 LDA #HI(LOAD2)
 STA ZP+1

 JSR PrintMessage       \ Print the text at LOAD2 ("Loading BBC Micro...")

 LDX #LO(MESS2)         \ Set (Y X) to point to MESS2 ("EliteB")
 LDY #HI(MESS2)

 JMP OSCLI              \ Call OSCLI to run the OS command in MESS2 to run the
                        \ BBC Micro version of Elite over Econet, returning from
                        \ the subroutine using a tail call

.copro

                        \ This is a 6502 Second Processor

 LDA #LO(LOAD4)         \ Set ZP(1 0) to the text at LOAD4 ("Loading 6502 Second
 STA ZP                 \ Processor...")
 LDA #HI(LOAD4)
 STA ZP+1

 LDX #'S'               \ Set X and Y so that RunElite does a *RUN ELTSE command
 LDY #'E'

 JMP RunElite           \ Run the 6502 Second Processor version of Elite over
                        \ Econet, returning from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: TryLoadingConf
\       Type: Subroutine
\   Category: Loader
\    Summary: Try loading the EliteConf file and consume any errors
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   C flag              Clear if the EliteConf file was loaded, set if it wasn't
\
\ ******************************************************************************

.TryLoadingConf

 TSX                    \ Store the stack pointer in stack so we can restore it
 STX stack              \ if there's an error

 LDA BRKV               \ Fetch the current value of the break vector
 STA oldBRKV
 LDA BRKV+1
 STA oldBRKV+1

 SEI                    \ Disable interrupts while we update the break vector

 LDA #LO(NoConfFile)    \ Set BRKV to point to NoConfFile, so if there is no
 STA BRKV               \ configuration file, we jump to NoConfFile where we
 LDA #HI(NoConfFile)    \ clear the break condition and return to entr4 to
 STA BRKV+1             \ restore the break vector and keep going

 CLI                    \ Enable interrupts again

 LDX #LO(MESS10)        \ Set (Y X) to point to MESS10 ("LOAD EliteConf xxxx")
 LDY #HI(MESS10)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS10 to load
                        \ the game binary path from EliteConf into the OS
                        \ command string in MESS1, so if there is a
                        \ configuration file, we change the command to use the
                        \ configured directory rather than $.EliteGame

 CLC                    \ Clear the C flag to indicate the file was loaded

.entr4

 SEI                    \ Disable interrupts while we update the break vector

 LDA oldBRKV            \ Restore BRKV
 STA BRKV
 LDA oldBRKV+1
 STA BRKV+1

 CLI                    \ Enable interrupts again

 RTS                    \ Return from the subroutine

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

 SEC                    \ Set the C flag to indicate the file was not loaded

 JMP entr4              \ Jump to entr4 to reset the break vector and return
                        \ from the subroutine

\ ******************************************************************************
\
\       Name: ChangeToKey
\       Type: Subroutine
\   Category: Loader
\    Summary: Change the start of MESS1 to create a KEY 0 command in MESS6
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   Y                   The offset from ZP(1 0) of the end of the directory path
\
\ ******************************************************************************

.ChangeToKey

 LDA #'I'               \ Replace the first four characters of MESS 1 with the
 STA MESS1              \ characters IN " so the command at MESS6 changes from:
 LDA #'N'               \
 STA MESS1+1            \   KEY 0 CHADIR $...
 LDA #' '               \
 STA MESS1+2            \ to:
 LDA #'"'               \
 STA MESS1+3            \   KEY 0 CHAIN "$...

                        \ Fall through into FindEndOfPath to set Y to the end of
                        \ the directory path

\ ******************************************************************************
\
\       Name: FindEndOfPath
\       Type: Subroutine
\   Category: Loader
\    Summary: Find the end of the directory path in the MESS1 string
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   Y                   The offset from ZP(1 0) of the end of the directory path
\
\ ******************************************************************************

.FindEndOfPath

                        \ We now work our way along the directory path in the
                        \ MESS1 command, until we reach the end

 LDA #LO(MESS1+4)       \ Set ZP(1 0) = MESS1+4, which is the address of the
 STA ZP                 \ directory path in the MESS1 command
 LDA #HI(MESS1+4)
 STA ZP+1

 LDY #0                 \ Set Y to use as an index counter

.path1

 LDA (ZP),Y             \ If the Y-th character of the directory path is null or
 BEQ path2              \ a carriage return, then we have reached the end, so
 CMP #&0D               \ jump to path2 to append the BASIC program name
 BEQ path2

 INY                    \ Increment the index counter

 BNE path1              \ Loop back for the next character (this BNE is
                        \ effectively a JMP as Y is never zero)

.path2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ChangeToKeyScore
\       Type: Subroutine
\   Category: Loader
\    Summary: Change the end of MESS1 to create a KEY 0 command in MESS6 to load
\             the scoreboard
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   Y                   The offset from ZP(1 0) of the end of the directory path
\
\ ******************************************************************************

.ChangeToKeyScore

 LDX #0                 \ Set X = 0 to act as an index into the string to copy

.csco1

 LDA MESS7s,X           \ Copy the X-th byte of MESS7s to the Y-th byte of the
 STA (ZP),Y             \ KEY 0 command

 CMP #&0D               \ If we just copied a carriage return then we have
 BEQ csco2              \ copied the whole string, so jump to csco2 to return
                        \ from the subroutine

 INY                    \ Increment the index into the KEY 0 command

 INX                    \ Increment the index into the MESS7s string

 BNE csco1              \ Loop back to copy the next character (this BNE is
                        \ effectively a JMP as X is never zero)

.csco2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ChangeToKeyDebug
\       Type: Subroutine
\   Category: Loader
\    Summary: Change the end of MESS1 to create a KEY 0 command in MESS6 to load
\             the debugger
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   Y                   The offset from ZP(1 0) of the end of the directory path
\
\ ******************************************************************************

.ChangeToKeyDebug

 LDX #0                 \ Set X = 0 to act as an index into the string to copy

.cdeb1

 LDA MESS7d,X           \ Copy the X-th byte of MESS7d to the Y-th byte of the
 STA (ZP),Y             \ KEY 0 command

 CMP #&0D               \ If we just copied a carriage return then we have
 BEQ cdeb2              \ copied the whole string, so jump to cdeb2 to return
                        \ from the subroutine

 INY                    \ Increment the index into the KEY 0 command

 INX                    \ Increment the index into the MESS7d string

 BNE cdeb1              \ Loop back to copy the next character (this BNE is
                        \ effectively a JMP as X is never zero)

.cdeb2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ChangeToVersion
\       Type: Subroutine
\   Category: Loader
\    Summary: Change the end of MESS1 to create a TYPE command in MESS6 to show
\             the version file
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   Y                   The offset from ZP(1 0) of the end of the directory path
\
\ ******************************************************************************

.ChangeToVersion 

 LDA #'T'               \ Replace the first four characters of MESS-1 with the
 STA MESS1-1            \ characters TYPE so the command at MESS-1 changes from:
 LDA #'Y'               \
 STA MESS1              \   ADIR $...
 LDA #'P'               \
 STA MESS1+1            \   TYPE $...
 LDA #'E'
 STA MESS1+2

 JSR FindEndOfPath      \ Call FindEndOfPath to set Y to the end of the
                        \ directory path

 LDX #0                 \ Set X = 0 to act as an index into the string to copy

.cver1

 LDA MESS7v,X           \ Copy the X-th byte of MESS7d to the Y-th byte of the
 STA (ZP),Y             \ KEY 0 command

 CMP #&0D               \ If we just copied a carriage return then we have
 BEQ cver2              \ copied the whole string, so jump to cver2 to return
                        \ from the subroutine

 INY                    \ Increment the index into the KEY 0 command

 INX                    \ Increment the index into the MESS7d string

 BNE cver1              \ Loop back to copy the next character (this BNE is
                        \ effectively a JMP as X is never zero)

.cver2

 RTS                    \ Return from the subroutine

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
\       Name: argument
\       Type: Variable
\   Category: Loader
\    Summary: Storage for the command's single-letter argument
\
\ ******************************************************************************

.argument

 EQUB 0

\ ******************************************************************************
\
\       Name: tubePresent
\       Type: Variable
\   Category: Loader
\    Summary: Storage for the "Tube present" flag
\
\ ******************************************************************************

.tubePresent

 EQUB 0

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
\       Name: userEnv
\       Type: Variable
\   Category: Loader
\    Summary: Storage for the current Econet user environment (URD, CSD, LIB)
\
\ ******************************************************************************

.userEnv

 EQUW 0
 EQUB 0

\ ******************************************************************************
\
\       Name: oswordBlock
\       Type: Variable
\   Category: Loader
\    Summary: OSWORD block for accessing the Econet user environment
\
\ ******************************************************************************

.oswordBlock

 EQUD 0

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
\       Name: RunElite
\       Type: Subroutine
\   Category: Loader
\    Summary: Run an Elite binary
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   ZP(1 0)             The address of the text to print
\
\   X                   The first character in the binary to run (ELTXY)
\
\   Y                   The second character in the binary to run (ELTXY)
\
\ ******************************************************************************

.RunElite

 STX runElt+7           \ Set the command in runElt to run the ELT file with the
 STY runElt+8           \ name specified in X and Y ("*RUN ELTXY")

 JSR PrintMessage       \ Print the text at ZP(1 0)

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("DIR $.EliteGame")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1 to change to
                        \ the game binary folder

 LDX #LO(runElt)        \ Set (Y X) to point to runElt ("*RUN ELTXY")
 LDY #HI(runElt)

 JMP OSCLI              \ Call OSCLI to run the OS command in runElt to run the
                        \ BBC Micro version of Elite over Econet

\ ******************************************************************************
\
\       Name: runElt
\       Type: Variable
\   Category: Loader
\    Summary: The OS command to run an Elite binary
\
\ ******************************************************************************

.runElt

 EQUS "RUN ELTXX"
 EQUB 13


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
\       Name: MESS7s
\       Type: Variable
\   Category: Loader
\    Summary: The last part of the f0 definition to run the scoreboard
\
\ ******************************************************************************

.MESS7s

 EQUS ".ElScore"
 EQUB &22
 EQUS "|M"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS7d
\       Type: Variable
\   Category: Loader
\    Summary: The last part of the f0 definition to run the debugger
\
\ ******************************************************************************

.MESS7d

 EQUS ".ElDebug"
 EQUB &22
 EQUS "|M"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS7v
\       Type: Variable
\   Category: Loader
\    Summary: The last part of the f0 definition to show the version
\
\ ******************************************************************************

.MESS7v

 EQUS ".Version"
 EQUB 13

\ ******************************************************************************
\
\       Name: MESS6
\       Type: Variable
\   Category: Loader
\    Summary: Set up f0 to run the scoreboard or debugger
\
\ ******************************************************************************

.MESS6

 EQUS "KEY 0 CHA"

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