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
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
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

 OSWORD = &FFF1         \ The address for the OSWORD routine

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

                        \ This is NFS 3.34, which contains the bug, so we add 7
                        \ to the address in ZP(1 0) so that it points to the
                        \ argument to the *EliteB command (as "EliteB " contains
                        \ seven characters)

 LDY #6                 \ If the *EliteB has no parameter then the seventh
 LDA (ZP),Y             \ character in the command string will be a carriage
 STA argument           \ return (&0D), so store this in argument and jump to
 CMP #&0D               \ entr2 to move on to the next step
 BEQ entr2

                        \ Otherwise the command has a parameter, so we now set
                        \ ZP(1 0) to point to that parameter

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) + 7
 CLC                    \
 ADC #7                 \ So ZP(1 0) points to the correct address of the
 STA ZP                 \ argument to the *EliteB command for NFS 3.34
 BCC entr1
 INC ZP+1

.entr1

 LDY #0                 \ Store the command argument (or &0D if there is no
 LDA (ZP),Y             \ argument)
 STA argument

.entr2

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

 LDX #LO(osCommand)     \ Set (Y X) to point to osCommand ("DIR $.EliteGame")
 LDY #HI(osCommand)

 JSR OSCLI              \ Call OSCLI to run the OS command in osCommand to
                        \ change to the game binary folder

 LDA argument           \ Fetch the command argument

 CMP #'T'               \ If the argument is not T (i.e. *EliteB T), jump to
 BNE entr4              \ entr4 to keep looking

                        \ If we get here then the command is *EliteB T, which
                        \ loads the docked code for the sideways RAM version
                        \ and restarts the game (*LOAD T.CODE in the original)

 LDX #'B'               \ Change the loadElt command to *LOAD ELTBT
 STX loadElt+8

 BNE loadDocked         \ Jump to loadDocked to load the docked code and jump to
                        \ the second JMP instruction in the docked code, which
                        \ is a JMP DOBEGIN that restarts the game (this BNE is
                        \ effectively a JMP as X is never zero)

.entr4

 CMP #'R'               \ If the argument is not R (i.e. *EliteB R), jump to
 BNE entr5              \ entr5 to keep looking

                        \ If we get here then the command is *EliteB R, which
                        \ runs the docked code for the sideways RAM version
                        \ and docks with the station (*RUN T.CODE in the
                        \ original)

 LDX #'B'               \ Set X and Y so that RunElite does a *RUN ELTBT command
 LDY #'T'

 JMP RunElite           \ Run the flight code (and call the DOENTRY routine to
                        \ dock at the station), returning from the subroutine
                        \ using a tail call

.entr5

 CMP #'V'               \ If the argument is not V (i.e. *EliteB V), jump to
 BNE entr6              \ entr6 to keep looking

                        \ If we get here then the command is *EliteB V, which
                        \ runs the flight code for the sideways RAM version
                        \ (*RUN D.CODE in the original)

 LDX #'B'               \ Set X and Y so that RunElite does a *RUN ELTBD command
 LDY #'D'

 JMP RunElite           \ Run the flight code, returning from the subroutine
                        \ using a tail call

.entr6

 CMP #'S'               \ If the argument is not S (i.e. *EliteB S), jump to
 BNE entr7              \ entr7 to keep looking

                        \ If we get here then the command is *EliteB S, which
                        \ loads the docked code for the standard version and
                        \ restarts the game (*LOAD T.CODE in the original)

.loadDocked

 LDX #LO(loadElt)       \ Set (Y X) to point to loadElt ("LOAD ELTAT")
 LDY #HI(loadElt)

 JSR OSCLI              \ Call OSCLI to run the OS command in loadElt, which
                        \ *LOADs the docked code

 JMP S%+3               \ Jump to the second JMP instruction in the docked code,
                        \ which is a JMP DOBEGIN that restarts the game

.entr7

 CMP #'Q'               \ If the argument is not Q (i.e. *EliteB Q), jump to
 BNE entr8              \ entr8 to keep looking

                        \ If we get here then the command is *EliteB Q, which
                        \ runs the docked code for the standard version and
                        \ docks with the station (*RUN T.CODE in the original)

 LDY #'T'               \ Set Y so that RunElite does a *RUN ELTAT command

 JMP RunElite+3         \ Run the flight code (and call the DOENTRY routine to
                        \ dock at the station), returning from the subroutine
                        \ using a tail call

.entr8

 CMP #'U'               \ If the argument is not U (i.e. *EliteB U), jump to
 BNE entr9              \ entr9 to keep looking

                        \ If we get here then the command is *EliteB U, which
                        \ runs the flight code for the standard version
                        \ (*RUN D.CODE in the original)

 LDY #'D'               \ Set X and Y so that RunElite does a *RUN ELTAD command

 JMP RunElite+3         \ Run the the flight code, returning from the subroutine
                        \ using a tail call

.entr9

 CMP #'A'               \ If the argument is not in the range A to P (so that's
 BCC entr10             \ *EliteB A to *EliteB P), jump to entr10 to keep
 CMP #'Q'               \ looking
 BCS entr10

                        \ If we get here then the command is *EliteB A to P,
                        \ which loads a ship blueprints file for the standard
                        \ version (*LOAD D.MO0 in the original, where 0 is the
                        \ argument)

 STA loadShipFile+9     \ Store the letter of the ship blueprints file we want
                        \ in the command string at loadShipFile, so we overwrite
                        \ the "0" in "D.MO0" with the file letter to load, in
                        \ the range D.MOA to D.MOP

 LDX #LO(loadShipFile)  \ Set (Y X) to point to loadShipFile ("LOAD D.MO0")
 LDY #HI(loadShipFile)

 JMP OSCLI              \ Call OSCLI to run the OS command in loadShipFile,
                        \ which *LOADs the ship blueprints file, returning from
                        \ the subroutine using a tail call

.entr10

                        \ If we get here then there is no valid argument to
                        \ *EliteB, so now we need to load the game from the
                        \ start

 JMP RunElite+6         \ Run the disc version loader with a *RUN ELTAB command,
                        \ which checks PAGE and sideways RAM and runs the
                        \ correct game, returning from the subroutine using a
                        \ tail call

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
\ ------------------------------------------------------------------------------
\
\ Other entry points:
\
\   RunElite+3          Set the first character to "A" (i.e. run ELTAY)
\
\   RunElite+6          Run the ELTAB binary
\
\ ******************************************************************************

.RunElite

 STX runElt+7           \ Set the command in runElt to run the ELT file with the
 STY runElt+8           \ name specified in X and Y ("*RUN ELTxy")

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

 EQUS "RUN ELTAB"
 EQUB 13

\ ******************************************************************************
\
\       Name: loadElt
\       Type: Variable
\   Category: Loader
\    Summary: The OS command to load an Elite binary
\
\ ******************************************************************************

.loadElt

 EQUS "LOAD ELTAT"
 EQUB 13

\ ******************************************************************************
\
\       Name: loadShipFile
\       Type: Variable
\   Category: Loader
\    Summary: Load a ship file for standard Elite (D.MOx)
\
\ ******************************************************************************

.loadShipFile

 EQUS "LOAD D.MO0"
 EQUB 13

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
\ Save EliteB.bin
\
\ ******************************************************************************

 PRINT "S.EliteB ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "2-assembled-output/EliteB.bin", CODE%, P%, LOAD%