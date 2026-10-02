BEEBASM?=beebasm
DISC?=oaknut-disc
DSD?=4-compiled-game-discs/elite-over-econet.dsd
L3FS=4-compiled-game-discs/elite-over-econet-scsi0.dat

.PHONY:all
all: build-ssd build-dsd build-l3fs

.PHONY:build-ssd
build-ssd:
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-version.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-disc.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc-1.asm -do 3-assembled-output/side1.ssd
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc-2.asm -do 3-assembled-output/side2.ssd

.PHONY:build-dsd
build-dsd:
	$(DISC) create $(DSD) --title "E L I T E"
	$(DISC) cp -r "3-assembled-output/side1.ssd:*" $(DSD)
	$(DISC) cp -r "3-assembled-output/side2.ssd:*" $(DSD)::2.

.PHONY:build-l3fs
build-l3fs:
	$(DISC) create $(L3FS) --geometry capacity=10MB --title Server
	$(DISC) cp "1-source-files/econet-server/FS3v126.ssd:$$.FS3v126" "$(L3FS):$$.FS3v126"
ifeq ($(rtc), no)
	$(DISC) put --load 0xFFFFFFFF --exec 0xFFFFFFFF "$(L3FS):$$.!BOOT" "1-source-files/econet-server/$$.!BOOT-no-rtc.bin"
else
	$(DISC) put --load 0xFFFFFFFF --exec 0xFFFFFFFF "$(L3FS):$$.!BOOT" "1-source-files/econet-server/$$.!BOOT-rtc.bin"
endif
	$(DISC) opt $(L3FS) EXEC
	$(DISC) afs init $(L3FS) --disc-name Server --user Syst:S:5MB --user ELITE:2MB --omit-user Welcome --emplace Library --emplace Library1
	$(DISC) cp -r --access WR/ "$(DSD)::2.C.MAX" "$(L3FS):afs:$$.ELITE.EliteCmdrs.MAX"
	$(DISC) cp -r --access R/R "$(DSD)::0.G.*" "$(L3FS):afs:$$.EliteGame."
	$(DISC) cp -r --access R/R "$(DSD)::2.G.*" "$(L3FS):afs:$$.EliteGame."
	$(DISC) cp -r --access R/R "$(DSD)::2.D.*" "$(L3FS):afs:$$.EliteGame.D."
	$(DISC) cp -r --access R/R "$(DSD)::2.L.*" "$(L3FS):afs:$$.Library."
	$(DISC) cp -r --access R/R "$(DSD)::2.L.*" "$(L3FS):afs:$$.Library1."

.PHONY:b2
b2:
	curl -G "http://localhost:48075/reset/b2"
	curl -H "Content-Type:application/binary" --upload-file "4-compiled-game-discs/elite-over-econet.dsd" "http://localhost:48075/run/b2?name=elite-over-econet.dsd"
