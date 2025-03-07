BEEBASM?=beebasm

.PHONY:all
all:
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-version.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-master.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-6502sp.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-6502sp-executive.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot-disc.asm -v > 2-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc-loader.asm -v >> 2-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-boot.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc-1.asm -do 2-assembled-output/side1.ssd
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc-2.asm -do 2-assembled-output/side2.ssd
	dfsimage create 3-compiled-game-discs/elite-over-econet-flicker-free.dsd
	dfsimage backup --title="E L I T E" --from 2-assembled-output/side1.ssd --to -1 3-compiled-game-discs/elite-over-econet-flicker-free.dsd
	dfsimage backup --title="E L I T E" --from 2-assembled-output/side2.ssd --to -2 3-compiled-game-discs/elite-over-econet-flicker-free.dsd

.PHONY:b2
b2:
	curl -G "http://localhost:48075/reset/b2"
	curl -H "Content-Type:application/binary" --upload-file "3-compiled-game-discs/elite-over-econet-flicker-free.dsd" "http://localhost:48075/run/b2?name=elite-over-econet-flicker-free.dsd"
