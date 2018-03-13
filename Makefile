jar=/Applications/KickAssembler/KickAss.jar

all: starfield.prg

star1.gif:
	gm convert -size 24x21 xc:Black +antialias -fill White -draw 'point 12,10' $@
star2.gif:
	gm convert -size 24x21 xc:Black +antialias -fill White -draw 'circle 12,10 12,9' $@
star3.gif:
	gm convert -size 24x21 xc:Black +antialias -fill White -draw 'circle 12,10 12,8' $@
star4.gif:
	gm convert -size 24x21 xc:Black +antialias -fill White -draw 'circle 12,10 12,7' $@

sprites = star1.gif star2.gif star3.gif star4.gif
sprites: $(sprites)

clean: clean_sprites clean_prg

clean_sprites:
	rm $(sprites)

clean_prg:
	rm starfield.prg starfield.sym

starfield.prg: sprites
	java -jar "$(jar)" starfield.asm
