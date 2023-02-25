IMAGE_DEPS = gfx/Tiles.2bpp
#MD5 := $(shell if which md5sum &>/dev/null; then md5sum; else md5; fi)

all: flipull_us.gb flipull_jp.gb

%.2bpp: %.png
	rgbgfx -o $@ $<

%.1bpp: %.png
	rgbgfx -d 1 -o $@ $<

# The Japanese version is padded with 0xFF
flipull_jp.o: main.asm $(IMAGE_DEPS)
	rgbasm -h -L -o flipull_jp.o -p 0xFF -DREGION=JP main.asm

flipull_jp.gb: flipull_jp.o
	rgblink --tiny -n flipull_jp.sym -m flipull_jp.map -p 0xFF -o $@ $<
	rgbfix -v -p 0xFF $@

	@if which md5sum &>/dev/null; then md5sum $@; else md5 $@; fi

# The English version is padded with 0x00
flipull_us.o: main.asm $(IMAGE_DEPS)
	rgbasm -h -L -o flipull_us.o -p 0x00 -DREGION=US main.asm

flipull_us.gb: flipull_us.o
	rgblink --tiny -n flipull_us.sym -m flipull_us.map -p 0x00 -o $@ $<
	rgbfix -v -p 0x00 $@

	@if which md5sum &>/dev/null; then md5sum $@; else md5 $@; fi

clean:
	rm -f *.o flipull_{us,jp}.gb flipull_{us,jp}.sym flipull_{us,jp}.map
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' \) -exec rm {} +
