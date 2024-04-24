
---------------------------------------
Acornsoft Elite (Econet version)

Econet conversion by Mark Moxon

For the following networked machines:

* BBC Micro Model B
* BBC Micro Model B & 16K Sideways RAM
* BBC Micro Model B+ 64K
* BBC Micro Model B+ 128K
* BBC Micro with 6502 Second Processor
* BBC Master 128
* BBC Master ET
* BBC Master Turbo

To install Elite on your network, copy
files from this disc to your server as
follows (files have been grouped into
DFS directories to make this easier):

1. Create a $.EliteGame directory on
the server and copy all the files from
DFS directory G to there

2. Create an EliteCmdrs directory in
the top level of the main directory for
each user who wants to play Elite, and
copy all the files from DFS directory
C to there

3. If you want all users to be able to
play Elite, copy all the files from DFS
directory L into $.Library and
$.Library1 and ensure all users have
their library set accordingly

If you want to restrict it to specific
users, copy all the files from DFS
directory L into the EliteCmdrs folder
that you created in the users' main
directories

4. Users can then play Elite by typing:

*Elite

which will load the correct version of
Elite for their machine.

If you restricted Elite to specific
users, they will need to *DIR into
their own EliteCmdrs folder first

You can run specific versions using:

*EliteB  (for BBC Micro Elite)
*EliteM  (for BBC Master 128 Elite)
*EliteSP (for 6502 Second Proc Elite)

5. Commander files are saved into each
individual user's EliteCmdrs folder

See www.bbcelite.com/hacks for details

Build: 2024-04-24 16:26:49
---------------------------------------
