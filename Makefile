BEEBASM?=beebasm

.PHONY:all
all:
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-version.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-master.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-6502sp.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-disc.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 3-compiled-game-discs/elite-over-econet.ssd -title "E L I T E"

.PHONY:b2
b2:
	curl -G "http://localhost:48075/reset/b2"
	curl -H "Content-Type:application/binary" --upload-file "3-compiled-game-discs/elite-over-econet.ssd" "http://localhost:48075/run/b2?name=elite-over-econet.ssd"
