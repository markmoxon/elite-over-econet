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

 GUARD &2F00            \ Guard against assembling over the read buffer that's
                        \ just before the lowest possible screen memory (&3000)

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 bufferSize = 255       \ The size of the text buffer for reading the version
                        \ file with OSGBPB (must be < 256 bytes)

 ZP = &70               \ Use language-safe zero page locations, so they don't
                        \ clash with BASIC

 BRKV = &0202           \ The break vector that we intercept to enable us to
                        \ load the configuration file, if there is one

 OSFIND = &FFCE         \ The address for the OSFIND routine

 OSGBPB = &FFD1         \ The address for the OSGBPB routine

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

 BCC entr4              \ If EliteConf was loaded successfully, jump to entr4 to
                        \ skip loading from the library

                        \ We now fetch the Econet user environment, which gives
                        \ us the handles of the URD (the user's root directory),
                        \ the CSD (currently selected directory) and LIB (the
                        \ library directory)
                        \
                        \ We can then manipulate the user environment to change
                        \ the currently selected directory to the library, so we
                        \ can load the EliteConf file, if there is one

 LDA #6                 \ Read the Econet user environment (URD, CSD and LIB)
 JSR AccessUserEnv      \ into bytes 1 to 3 of the OSWORD block

 LDA oswordBlock+1      \ Copy the Econet user environment into restoreBlock, so
 STA restoreBlock+1     \ we can restore it below
 LDA oswordBlock+2
 STA restoreBlock+2
 LDA oswordBlock+3
 STA restoreBlock+3

 STA oswordBlock+2      \ Set the CSD handle in the OSWORD block to the LIB
                        \ handle, so when we write this block back to the user
                        \ environment, this will change the current directory to
                        \ the library directory

 LDA #7                 \ Write the updated Econet user environment to set the
 JSR AccessUserEnv      \ CSD to LIB, so if we now do a *LOAD EliteConf command,
                        \ it will look in the library directory

 JSR TryLoadingConf     \ Try loading EliteConf from the library directory

 LDA #&13               \ Call OSWORD with A = &13 to set the Econet user
 LDX #LO(restoreBlock)  \ environment back to its original setting, using the
 LDY #HI(restoreBlock)  \ restore block se set up above (the first byte of which
 JSR OSWORD             \ is already set to command number 7

.entr4

 LDA argument           \ Fetch the command argument

 AND #%11011111         \ Convert the argument to upper case

 CMP #'X'               \ If the argument is not X (i.e. *Elite X), jump to
 BNE entr5              \ entr5 to keep looking

                        \ If we get here then the command is *Elite X, which
                        \ loads the Executive version

 JSR PrintLoadMessage   \ Print "Loading Elite over Econet for the" and a
                        \ carriage return

 LDA #LO(executiveText) \ Set ZP(1 0) to the text at executiveText ("Executive
 STA ZP                 \ version...")
 LDA #HI(executiveText)
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

 LDA #LO(scoreText)     \ Set ZP(1 0) to the text at scoreText
 STA ZP
 LDA #HI(scoreText)
 STA ZP+1

 JSR PrintMessage       \ Print the text at scoreText ("Loading scoreboard...")

 JSR ChangeToKey        \ Change the start of osCommand to create a KEY 0
                        \ command in keyCommand

 JSR ChangeToKeyScore   \ Change the end of osCommand to create a KEY 0 command
                        \ in keyCommand to load the scoreboard

.runBasic

 LDA #225               \ Call OSBYTE with A = 225, X = 1 and Y = 0 to set the
 LDX #1                 \ function keys to expand as normal soft keys
 LDY #0
 JSR OSBYTE

 LDX #LO(keyCommand)    \ Set (Y X) to point to the key command for loading the
 LDY #HI(keyCommand)    \ scoreboard (KEY 0 CHAIN "ElScore"|M)

 JSR OSCLI              \ Call OSCLI to run the OS command in keyCommand to run
                        \ the scoreboard

 LDA #15                \ Call OSBYTE with A = 15 and X = 0 to flush all buffers
 LDX #0
 JSR OSBYTE

 LDA #138               \ Call OSBYTE with A = 138, X = 0 and Y = 128 to insert
 LDX #0                 \ the f0 key into the keyboard buffer
 LDY #128
 JSR OSBYTE

 LDX #LO(basicCommand)  \ Set (Y X) to point to basicCommand ("BASIC")
 LDY #HI(basicCommand)

 JMP OSCLI              \ Call OSCLI to run the OS command in basicCommand to
                        \ switch to BASIC and return from the subroutine using
                        \ a tail call

.entr6

 CMP #'D'               \ If the argument is not D (i.e. *Elite D), jump to
 BNE entr7              \ entr7 to keep looking

                        \ If we get here then the command is *Elite D, which
                        \ loads the debugger

 LDA #LO(debugText)     \ Set ZP(1 0) to the text at debugText
 STA ZP
 LDA #HI(debugText)
 STA ZP+1

 JSR PrintMessage       \ Print the text at debugText ("Loading debugger...")

 JSR ChangeToKey        \ Change the start of osCommand to create a KEY 0
                        \ command in keyCommand

 JSR ChangeToKeyDebug   \ Change the end of osCommand to create a KEY 0 command
                        \ in keyCommand to load the debugger

 JMP runBasic           \ Jump up to runBasic to switch to BASIC and "press" f0

.entr7

 CMP #'V'               \ If the argument is not V (i.e. *Elite V), jump to
 BNE entr8              \ entr8 to keep looking

                        \ If we get here then the command is *Elite V, which
                        \ prints the version

 JMP PrintVersionFile   \ Print the version file and return from the subroutine
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

 JSR PrintLoadMessage   \ Print "Loading Elite over Econet for the" and a
                        \ carriage return

 LDA #LO(masterText)    \ Set ZP(1 0) to the text at masterText ("BBC
 STA ZP                 \ Master...")
 LDA #HI(masterText)
 STA ZP+1

 LDX #'M'               \ Set X and Y so that RunElite does a *RUN ELTME command
 LDY #'E'

 JMP RunElite           \ Run the BBC Master version of Elite over Econet,
                        \ returning from the subroutine using a tail call

.bbc

 JSR PrintLoadMessage   \ Print "Loading Elite over Econet for the" and a
                        \ carriage return

 LDA #LO(bbcText)       \ Set ZP(1 0) to the text at bbcText
 STA ZP
 LDA #HI(bbcText)
 STA ZP+1

 JSR PrintMessage       \ Print the text at bbcText ("BBC Micro")

 LDX #LO(runEliteB)     \ Set (Y X) to point to runEliteB ("*EliteB")
 LDY #HI(runEliteB)

 JMP OSCLI              \ Call OSCLI to run the OS command in runEliteB to run
                        \ the BBC Micro version of Elite over Econet, returning
                        \ from the subroutine using a tail call

.copro

                        \ This is a 6502 Second Processor

 JSR PrintLoadMessage   \ Print "Loading Elite over Econet for the" and a
                        \ carriage return

 LDA #LO(spText)        \ Set ZP(1 0) to the text at spText ("6502 Second
 STA ZP                 \ Processor...")
 LDA #HI(spText)
 STA ZP+1

 LDX #'S'               \ Set X and Y so that RunElite does a *RUN ELTSE command
 LDY #'E'

 JMP RunElite           \ Run the 6502 Second Processor version of Elite over
                        \ Econet, returning from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: AccessUserEnv
\       Type: Subroutine
\   Category: Loader
\    Summary: Read or write the Econet user environment
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The command number (6 = read, 7 = write)
\
\ ******************************************************************************

.AccessUserEnv

 STA oswordBlock        \ Set the first byte of the OSWORD block to the command
                        \ number for reading (6) or writing (6) the Econet user
                        \ environment using OSWORD &13

 LDA #&13               \ Call OSWORD with A = &13 to read/write the Econet user
 LDX #LO(oswordBlock)   \ environment (URD, CSD and LIB) with bytes 1 to 3 of
 LDY #HI(oswordBlock)   \ the OSWORD block, returning from the subroutine using
 JMP OSWORD             \ a tail call

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

 LDA #LO(conf2)         \ Set BRKV to point to conf2 below, so if there is no
 STA BRKV               \ configuration file, we jump to conf2 where we clear
 LDA #HI(conf2)         \ the break condition and return to conf1 to restore the
 STA BRKV+1             \ break vector and keep going

 CLI                    \ Enable interrupts again

 LDX #LO(loadEliteConf) \ Set (Y X) to point to the loadEliteConf command
 LDY #HI(loadEliteConf) \ ("LOAD EliteConf xxxx")

 JSR OSCLI              \ Call OSCLI to run the OS command in loadEliteConf to
                        \ load the game binary path from EliteConf into the
                        \ osCommand command string at gamePath, so if there is a
                        \ configuration file, we change the command to use the
                        \ configured directory rather than $.EliteGame

 CLC                    \ Clear the C flag to indicate the file was loaded

.conf1

 SEI                    \ Disable interrupts while we update the break vector

 LDA oldBRKV            \ Restore BRKV
 STA BRKV
 LDA oldBRKV+1
 STA BRKV+1

 CLI                    \ Enable interrupts again

 RTS                    \ Return from the subroutine

.conf2

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

 JMP conf1              \ Jump to conf1 to reset the break vector and return
                        \ from the subroutine

\ ******************************************************************************
\
\       Name: ChangeToKey
\       Type: Subroutine
\   Category: Loader
\    Summary: Change the start of osCommand to create a KEY 0 command in
\             keyCommand
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   Y                   The offset from ZP(1 0) of the end of the directory path
\
\ ******************************************************************************

.ChangeToKey

 LDA #'I'               \ Replace the first four characters of osCommand with
 STA osCommand          \ the characters IN " so keyCommand changes from:
 LDA #'N'               \
 STA osCommand+1        \   KEY 0 CHADIR $...
 LDA #' '               \
 STA osCommand+2        \ to:
 LDA #'"'               \
 STA osCommand+3        \   KEY 0 CHAIN "$...

                        \ Fall through into FindEndOfPath to set Y to the end of
                        \ the directory path

\ ******************************************************************************
\
\       Name: FindEndOfPath
\       Type: Subroutine
\   Category: Loader
\    Summary: Find the end of the directory path in the osCommand string
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
                        \ osCommand command, until we reach the end

 LDA #LO(gamePath)      \ Set ZP(1 0) = gamePath, which is the address of the
 STA ZP                 \ directory path of the game binary
 LDA #HI(gamePath)
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
\    Summary: Change the end of osCommand to create a KEY 0 command in
\             keyCommand to load the scoreboard
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

 LDA elScoreName,X      \ Copy the X-th byte of elScoreName to the Y-th byte of
 STA (ZP),Y             \ the KEY 0 command

 CMP #&0D               \ If we just copied a carriage return then we have
 BEQ csco2              \ copied the whole string, so jump to csco2 to return
                        \ from the subroutine

 INY                    \ Increment the index into the KEY 0 command

 INX                    \ Increment the index into the elScoreName string

 BNE csco1              \ Loop back to copy the next character (this BNE is
                        \ effectively a JMP as X is never zero)

.csco2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ChangeToKeyDebug
\       Type: Subroutine
\   Category: Loader
\    Summary: Change the end of osCommand to create a KEY 0 command in
\             keyCommand to load the debugger
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

 LDA elDebugName,X      \ Copy the X-th byte of elDebugName to the Y-th byte of
 STA (ZP),Y             \ the KEY 0 command

 CMP #&0D               \ If we just copied a carriage return then we have
 BEQ cdeb2              \ copied the whole string, so jump to cdeb2 to return
                        \ from the subroutine

 INY                    \ Increment the index into the KEY 0 command

 INX                    \ Increment the index into the elDebugName string

 BNE cdeb1              \ Loop back to copy the next character (this BNE is
                        \ effectively a JMP as X is never zero)

.cdeb2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: PrintVersionFile
\       Type: Subroutine
\   Category: Loader
\    Summary: Print the version file
\
\ ******************************************************************************

.PrintVersionFile 

                        \ We start by appending ".Version" to the end of the
                        \ game binary path in gamePath, to give us the filename
                        \ of the installed game's version information

 JSR FindEndOfPath      \ Call FindEndOfPath to set Y to the end of the
                        \ directory path

 LDX #0                 \ Set X = 0 to act as an index into the string to copy

.cver1

 LDA versionName,X      \ Copy the X-th byte of versionName to the Y-th byte of
 STA (ZP),Y             \ the KEY 0 command

 CMP #&0D               \ If we just copied a carriage return then we have
 BEQ cver2              \ copied the whole string, so jump to cver2 to return
                        \ from the subroutine

 INY                    \ Increment the index into the KEY 0 command

 INX                    \ Increment the index into the versionName string

 BNE cver1              \ Loop back to copy the next character (this BNE is
                        \ effectively a JMP as X is never zero)

.cver2

 LDA #&40               \ Call OSFIND with A = &40 and (Y X) = gamePath to open
 LDX #LO(gamePath)      \ the version file and return the handle in A
 LDY #HI(gamePath)
 JSR OSFIND

 CMP #0                 \ If the file could not be opened, jump to cver7 to
 BEQ cver7              \ return from the subroutine

 STA osgbpbBlock        \ Set byte #0 of the OSGBPB block to the file handle

 LDA #3                 \ We start by calling OSGBPB with A = 4, to read the
                        \ first block (i.e. starting at a pointer of 0)

.cver3

 LDX #LO(osgbpbBlock)   \ Set (Y X) to the address of the OSGBPB block
 LDY #HI(osgbpbBlock)

 JSR OSGBPB             \ Read a block from the file into the buffer at &2F00

 PHP                    \ Store the C flag on the stack so we can retrieve it
                        \ below

 LDA #bufferSize        \ If the C flag is clear then we filled the whole
 BCC cver4              \ buffer, so set A to the maximum number of characters
                        \ to print (i.e. bufferSize)

 LDA #bufferSize        \ Otherwise set A = bufferSize - #characters left (from
 SBC osgbpbBlock+5      \ byte #5 of the OSGBPB block) to get the number of
                        \ characters we did fetch (the subtraction works as we
                        \ know the C flag is set)

.cver4

 TAX                    \ Set X to the number of characters to print from the
                        \ buffer at &2F00, to use as a character counter

 LDY #0                 \ Set Y = 0 to use as a character index into the buffer

.cver5

 LDA &2F00,Y            \ Print the Y-th character from the buffer at &2F00
 JSR OSWRCH

 INY                    \ Increment the character index in Y

 DEX                    \ Decrement the character counter in X

 BNE cver5              \ Loop back until we have printed X characters

 PLP                    \ Retrieve the flags that were returned by the call to
                        \ OSGBPB

 BCS cver6              \ If we have reached the end of the file then the C flag
                        \ will be set, so jump to cver6 to finish off

 LDA #&2F               \ Set the second entry in the OSGBPB block to the buffer
 STA osgbpbBlock+2      \ address &2F00 (as this will have been updated by the
 LDA #0                 \ call to OSGBPB)
 STA osgbpbBlock+1
 STA osgbpbBlock+3
 STA osgbpbBlock+4

 LDA #bufferSize        \ Set the third entry in the OSGBPB block to bufferSize
 STA osgbpbBlock+5      \ bytes (as this will have been updated by the call to
 LDA #0                 \ OSGBPB)
 STA osgbpbBlock+6
 STA osgbpbBlock+7
 STA osgbpbBlock+8

 LDA #4                 \ Otherwise jump to cver3 to call OSGBPB with A = 3 to
 BNE cver3              \ fetch the next block from the file (i.e. using the
                        \ updated pointer from the previous call)

.cver6

 LDA #0                 \ Call OSFIND with A = 0 and Y = filer handle to close
 LDY osgbpbBlock        \ the version file
 JSR OSFIND

.cver7

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: osgbpbBlock
\       Type: Variable
\   Category: Loader
\    Summary: OSGBPB block for loading the version file one block at a time
\
\ ******************************************************************************

.osgbpbBlock

 EQUB 0                 \ File handle

 EQUD &2F00             \ Address to load the version file

 EQUD bufferSize        \ Number of bytes to transfer in each block

 EQUD 0                 \ Sequential pointer

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
\       Name: restoreBlock
\       Type: Variable
\   Category: Loader
\    Summary: OSWORD block for restoring the current Econet user environment
\             (URD, CSD, LIB)
\
\ ******************************************************************************

.restoreBlock

 EQUB 7
 EQUB 0
 EQUB 0
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
\       Name: PrintLoadMessage
\       Type: Subroutine
\   Category: Loader
\    Summary: Print "Loading Elite over Econet for the"
\
\ ******************************************************************************

.PrintLoadMessage

 LDA #LO(loadMessage)   \ Set ZP(1 0) to the text at loadMessage
 STA ZP
 LDA #HI(loadMessage)
 STA ZP+1

 JMP PrintMessage       \ Print the text at loadMessage and return from the
                        \ subroutine using a tail call

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
\   X                   The first character in the binary to run (ELTxy)
\
\   Y                   The second character in the binary to run (ELTxy)
\
\ ******************************************************************************

.RunElite

 STX runElt+7           \ Set the command in runElt to run the ELT file with the
 STY runElt+8           \ name specified in X and Y ("*RUN ELTxy")

 JSR PrintMessage       \ Print the text at ZP(1 0)

 LDX #LO(osCommand)     \ Set (Y X) to point to osCommand ("DIR $.EliteGame")
 LDY #HI(osCommand)

 JSR OSCLI              \ Call OSCLI to run the OS command in osCommand to
                        \ change to the game binary folder

 LDX #LO(runElt)        \ Set (Y X) to point to runElt ("*RUN ELTxy")
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
\       Name: runEliteB
\       Type: Variable
\   Category: Loader
\    Summary: Run the BBC Micro version of Elite
\
\ ******************************************************************************

.runEliteB

 EQUS "EliteB"
 EQUB 13

\ ******************************************************************************
\
\       Name: basicCommand
\       Type: Variable
\   Category: Loader
\    Summary: Switch to BASIC
\
\ ******************************************************************************

.basicCommand

 EQUS "BASIC"
 EQUB 13

\ ******************************************************************************
\
\       Name: loadMessage
\       Type: Variable
\   Category: Loader
\    Summary: Message for the first part of the loading message
\
\ ******************************************************************************

.loadMessage

 EQUS "Loading Elite over Econet for the"
 EQUB 10, 13
 EQUB 0

\ ******************************************************************************
\
\       Name: bbcText
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the BBC Micro version
\
\ ******************************************************************************

.bbcText

 EQUS "BBC Micro..."
 EQUB 0

\ ******************************************************************************
\
\       Name: masterText
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the BBC Master version
\
\ ******************************************************************************

.masterText

 EQUS "BBC Master..."
 EQUB 0

\ ******************************************************************************
\
\       Name: spText
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the 6502 Second Processor version
\
\ ******************************************************************************

.spText

 EQUS "6502 Second Processor..."
 EQUB 0

\ ******************************************************************************
\
\       Name: executiveText
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the Executive version
\
\ ******************************************************************************

.executiveText

 EQUS "Executive version..."
 EQUB 0

\ ******************************************************************************
\
\       Name: scoreText
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the scoreboard
\
\ ******************************************************************************

.scoreText

 EQUS "Loading the scoreboard for"
 EQUB 10, 13
 EQUS "Elite over Econet..."
 EQUB 10, 13
 EQUB 0

\ ******************************************************************************
\
\       Name: debugText
\       Type: Variable
\   Category: Loader
\    Summary: Message for loading the scoreboard
\
\ ******************************************************************************

.debugText

 EQUS "Loading the debugger for"
 EQUB 10, 13
 EQUS "Elite over Econet..."
 EQUB 10, 13
 EQUB 0

\ ******************************************************************************
\
\       Name: elScoreName
\       Type: Variable
\   Category: Loader
\    Summary: The last part of the f0 definition to run the scoreboard
\
\ ******************************************************************************

.elScoreName

 EQUS ".ElScore"
 EQUB &22
 EQUS "|M"
 EQUB 13

\ ******************************************************************************
\
\       Name: elDebugName
\       Type: Variable
\   Category: Loader
\    Summary: The last part of the f0 definition to run the debugger
\
\ ******************************************************************************

.elDebugName

 EQUS ".ElDebug"
 EQUB &22
 EQUS "|M"
 EQUB 13

\ ******************************************************************************
\
\       Name: versionName
\       Type: Variable
\   Category: Loader
\    Summary: The last part of the f0 definition to show the version
\
\ ******************************************************************************

.versionName

 EQUS ".Version"
 EQUB 13

\ ******************************************************************************
\
\       Name: keyCommand
\       Type: Variable
\   Category: Loader
\    Summary: Set up f0 to run the scoreboard or debugger, or show the version
\
\ ******************************************************************************

.keyCommand

 EQUS "KEY 0 CHA"

\ ******************************************************************************
\
\       Name: osCommand
\       Type: Variable
\   Category: Loader
\    Summary: Switch to the game directory
\
\ ******************************************************************************

.osCommand

 EQUS "DIR "

\ ******************************************************************************
\
\       Name: gamePath
\       Type: Variable
\   Category: Loader
\    Summary: The directory path of the game binaries
\
\ ******************************************************************************

.gamePath

 EQUS "$.EliteGame"
 EQUB 13

\ ******************************************************************************
\
\       Name: loadEliteConf
\       Type: Variable
\   Category: Loader
\    Summary: Load the Elite configuration file that contains the full path of
\             the game binary directory, putting it into gamePath
\
\ ******************************************************************************

.loadEliteConf

 EQUS "LOAD EliteConf "
 EQUS STR$~(gamePath)
 EQUB 13

\ ******************************************************************************
\
\ Save Elite.bin
\
\ ******************************************************************************

 PRINT "S.Elite ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/Elite.bin", CODE%, P%, LOAD%