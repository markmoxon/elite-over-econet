# Elite over Econet

[BBC Micro cassette Elite](https://github.com/markmoxon/cassette-elite-beebasm) | [BBC Micro disc Elite](https://github.com/markmoxon/disc-elite-beebasm) | [6502 Second Processor Elite](https://github.com/markmoxon/6502sp-elite-beebasm) | [BBC Master Elite](https://github.com/markmoxon/master-elite-beebasm) | [Acorn Electron Elite](https://github.com/markmoxon/electron-elite-beebasm) | [NES Elite](https://github.com/markmoxon/nes-elite-beebasm) | [Elite-A](https://github.com/markmoxon/elite-a-beebasm) | [Teletext Elite](https://github.com/markmoxon/teletext-elite) | [Elite Universe Editor](https://github.com/markmoxon/elite-universe-editor) | [Elite Compendium](https://github.com/markmoxon/elite-compendium) | **Elite over Econet** | [Flicker-free Commodore 64 Elite](https://github.com/markmoxon/c64-elite-flicker-free) | [BBC Micro Aviator](https://github.com/markmoxon/aviator-beebasm) | [BBC Micro Revs](https://github.com/markmoxon/revs-beebasm) | [Archimedes Lander](https://github.com/markmoxon/archimedes-lander)

![Screenshot of the Elite Compendium menu screen](https://www.bbcelite.com/images/elite_over_econet/scoreboard.png)

This repository contains source code for Elite over Econet for the BBC Micro, BBC Master 128 and 6502 Second Processor.

Elite over Econet enables you to load Elite over an Acorn network. It also provides multiplayer scoreboard support, so you can run live Elite competitions over the network. For more information, see the [bbcelite.com website](https://www.bbcelite.com/hacks/elite_over_econet.html).

This repository contains submodules for each of the individual programs on the disc. Each submodule points to a branch called `econet` that contains the version of that program to be included in the Elite over Econet disc.

The repository also contains the loader code and build process for producing the final DSD disc. It does this by producing two SSD images, one for each side, and then combining them into a DSD image (as BeebAsm can only create SSD images).

See the individual subprojects for more information.

* [BBC Micro disc Elite](https://github.com/markmoxon/disc-elite-beebasm)
* [6502 Second Processor Elite](https://github.com/markmoxon/6502sp-elite-beebasm)
* [BBC Master Elite](https://github.com/markmoxon/master-elite-beebasm)

---

Right on, Commanders!

_Mark Moxon_
