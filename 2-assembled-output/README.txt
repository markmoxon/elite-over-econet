
---------------------------------------
Acornsoft Elite (Econet version)

Econet conversion by Mark Moxon

For the following networked machines:

* BBC Micro Model B
* BBC Micro Model B & 16K Sideways RAM
* BBC Micro Model B+ 64K and 128K
* BBC Micro with 6502 Second Processor
* BBC Master 128, ET and Turbo

To install on a Level 3 fileserver,
copy files from this disc to your
server as follows (files have been
grouped into DFS directories to make
this process easier):

1. Create a $.EliteGame directory on
the server and copy all the files from
DFS directory G (on both drive 0 and
drive 2) to there

2. Create a $.EliteGame.D directory on
the server and copy all the files from
DFS directory D (on drive 2) to there

3. Create an EliteCmdrs directory in
the top level of the main directory for
each user who wants to play Elite, and
copy all the files from DFS directory
C (on drive 2) to there

4. If you want all users to be able to
play Elite, copy all the files from DFS
directory L (on drive 2) into $.Library
and $.Library1 and ensure all users
have their library set accordingly

If you want to restrict it to specific
users, copy all the files from DFS
directory L (on drive 2) into the
EliteCmdrs directory that you created
in the users' main directories

5. Users can then play Elite by typing:

*Elite

which will load the correct version of
Elite for their machine.

If you restricted Elite to specific
users, they will need to *DIR into
their own EliteCmdrs directory first

6. Commander files are saved into each
individual user's EliteCmdrs directory

See www.bbcelite.com/hacks for details

Build: 2024-05-18 21:18:57
---------------------------------------
