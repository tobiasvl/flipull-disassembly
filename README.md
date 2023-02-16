Flipull disassembly
===================

A simple disassembly of Flipull for Game Boy. Work in progress.

Disassembling
-------------

The disassembly was created like this (from the ROM `flipull.gb`, which must be supplied):

```
python mgbdis/mgbdis.py --disable-halt-nops --disable-auto-ldh --output-dir . --print-hex --uppercase-db --align-operands --uppercase-hex --ldh_a8 ldh_ffa8 --ld_c ldh_c --tiny --overwrite flipull.gb
```

The `flipull.sym` file is manually created and updated; I add to it manually as I discover things, and then re-disassemble with the above command.

At some point (when I want to do something that `mgbdis` can't reproduce) I will then remove the `mgbdis` dependency and the manual `flipull.sym` file, and do the rest by hand.

Reassembling
------------

You'll need [RGBDS](https://github.com/rednex/rgbds). Then just run

```
make
```

and it will create `game.gb`, which should be identical to the supplied `flipull.gb`. Its MD5 hash should be `4fcc13db8144687e6b28200387aed25c`.

Why?
----

* For fun (it's a simple game without an MBC, so it should be fairly easy to disassemble)
* To investigate why the game reaches a kill screen on level 49, and maybe fix it
