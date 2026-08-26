BEEBASM?=beebasm
DISC?=oaknut-disc
DSD?=4-compiled-game-discs/elite-over-econet-flicker-free.dsd

.PHONY:all
all: build-ssd build-dsd

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

.PHONY:b2
b2:
	curl -G "http://localhost:48075/reset/b2"
	curl -H "Content-Type:application/binary" --upload-file "3-compiled-game-discs/elite-over-econet-flicker-free.dsd" "http://localhost:48075/run/b2?name=elite-over-econet-flicker-free.dsd"
