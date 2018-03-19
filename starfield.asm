:BasicUpstart2(start)


.var debug = false
//--------------------------------------------
// Functions for calculating vic values and other stuff
// (normally we would put these in a library)

.var music = LoadSid("Girl_in_Town.sid")

.function screenToD018(addr) {										// <- This is how we define a function
	.return ((addr&$3fff)/$400)<<4
}
.function charsetToD018(addr) {
	.return ((addr&$3fff)/$800)<<1
}
.function toD018(screen, charset) {
	.return screenToD018(screen) | charsetToD018(charset)			//<- This is how we call functions
}

.function toSpritePtr(addr) {
	.return (addr&$3fff)/$40
}

.function sinus(i, amplitude, center, noOfSteps) {
	.return round(center+amplitude*sin(toRadians(i*360/noOfSteps)))	
}
.macro setSpriteEnable() {
	sta $d015
}
.macro moveSpriteX(i) {
	sta $d000+(i*2)		// i is sprite number (0-7)
}

.macro moveSpriteY(i) {
	sta $d000+(i*2)+1	// i is sprite number (0-7)
}

.macro setNewY(i) {
	random()			// random into accumulator
	sta $d000+(i*2)+1	// i is sprite number (0-7)
}

.macro random() { // random byte (0-255) to accumulator
	lda $d012 
	eor $dc04 
	sbc $dc05
	//lda #$00	// make random use timer seeds
	//jsr $e09a // kernal RND subroutine
	//lda $63
}

.macro random4() { // random byte (0-3) to accumulator
	random()
	and #3
}

.macro SetBorderColor(color) {		// <- This is how macros are defined
	lda #color
	sta $d020
}

.macro SetBackgroundColor(color) {		// <- This is how macros are defined
	lda #color
	sta $d021
}

//--------------------------------------------
			*=$2200 "Program"
start: 		sei
			
			SetBorderColor(BLACK)
			SetBackgroundColor(BLACK)
			.if(debug) SetBackgroundColor(DARK_GRAY)
			// Print chars to screen
			ldx #0
			lda #5
!loop: 		sta screen,x			// <- '!' in front of a label means a multilabel (You can have several labels with the same name)
			sta screen+$100,x
			sta screen+$200,x
			sta screen+$300,x
			//sec
			//sbc #1
			//bcs !over+			// <- Referencing forward to the nearest a multilabel called 'over'
			//lda #5				
//!over:
			inx
			bne !loop-			// <- Referencing backward to the nearest multilabel called 'loop'
			
			
			lda #toD018(screen, charset)	// <- The d018 value is calculated by a function. You can move graphics around and not worry about d018 is properly set
			sta $d018							
			
			



			// Setup some sprites
			lda #$ff	// All sprites enabled
			:setSpriteEnable()
			ldx #7
!loop:		lda spritePtrs,x
			sta screen+$3f8,x
			//txa
			//lsr
			lda #$01		// white
			sta $d027,x 	// sprite color
			dex
			bpl !loop-
			
			jsr initSprites

		/*	
			// music time (i think)
			ldx #0
			ldy #0
			lda #music.startSong-1						//<- Here we get the startsong and init address from the sid file
			jsr music.init	
			sei
			lda #<irq1
			sta $0314
			lda #>irq1
			sta $0315
			lda #$1b
			sta $d011
			lda #$80
			sta $d012
			lda #$7f
			sta $dc0d
			sta $dd0d
			lda #$81
			sta $d01a
			lda $dc0d
			lda $dd0d
			asl $d019
			cli
			//jmp *



			*=music.location "Music"
			.fill music.size, music.getData(i)				// <- Here we put the music in memory
			*/

			// Make an effect loop with nonsense sprite movement
			ldx #0
			ldy #$0

!loop:		.if(debug) SetBorderColor(BLACK)
			cli
!frame: 	lda $d012		// Wait for frame. 
							// There should be free time here to do music.
			cmp #$ff		// If the raster line is not yet 256
			bne !frame-		// Jump UP to the nearest "loop" label
			.if(debug) SetBorderColor(RED)
			sei

!mvX:		// Unrolled x position "loop"

			.var i=0
			.for (;i<8;) {
				ldx #i
				lda $d000+(i*2)
				adc spriteSpeed,x
				bcs newY 			// See if the sprite should be recycled
				sta $d000+(i*2)
				.print i
				.eval i++
			}

			jmp !loop-

newY:		
			// new speed and spritepointer
			random4()
			tay

			// Sprite speed
			adc #1
			sta spriteSpeed,x
			// Sprite "size"
			lda spritePtrs,y
			sta screen+$3f8,x

			txa
			asl
			// reset X position 0
			tax
			lda #0
			sta $d000,x

			// Random Y position
			txa
			adc #1
			tax
			random()
			sta $d000,x

			clc
			jmp !loop-


irq1:  	    asl $d019
			inc $d020
			jsr music.play 									// <- Here we get the play address from the sid file
			dec $d020
			jmp $ea81


initSprites: {

			.var i=0
			.for (;i<8;) {
				// y pos from $30 to $f0... ish
				random()
				moveSpriteY(i)
				random()
				moveSpriteX(i)

				ldx #i
				random4()
				adc #1
				sta spriteSpeed,x

				.eval i++
			}
/*			:random()
			:moveSpriteY(0)
			:random()
			:moveSpriteY(1)
			:random()
			:moveSpriteY(2)
			:random()
			:moveSpriteY(3)
			:random()
			:moveSpriteY(4)
			:random()
			:moveSpriteY(5)
			:random()
			:moveSpriteY(6)
			:random()
			:moveSpriteY(7)*/
			rts
}
//--------------------------------------------
			
// TODO: Set sprite pointers according to speed.
spritePtrs:	.byte toSpritePtr(sprite1), toSpritePtr(sprite2)  // <- The spritePtr function is use to calculate the spritePtr
			.byte toSpritePtr(sprite3), toSpritePtr(sprite4)
			.byte toSpritePtr(sprite1), toSpritePtr(sprite2)
			.byte toSpritePtr(sprite3), toSpritePtr(sprite4)

// Random initial sprite speeds
spriteSpeed:	.byte random()*4
				.byte random()*4
				.byte random()*4
				.byte random()*4
				.byte random()*4
				.byte random()*4
				.byte random()*4
				.byte random()*4


sinus:		.fill $100, round($a0+$40*sin(toRadians(i*360/$100)))	 	// <- The fill functions takes two argument. 
																		// The number of bytes to fill and an expression to execute for each
																		// byte. 'i' is the byte number 

			.fill $100, sinus(i, $40, $a0, $100)			//<- Its easier to use a function when you use the expression many times			
//--------------------------------------------
			.align $0800		// <-- You can use align to align data to memory boundaries

charset: 	.byte %11111110
			.byte %10000010
			.byte %10000010
			.byte %10000010
			.byte %10000010
			.byte %10000010
			.byte %11111110
			.byte %00000000
			
			.byte %00000000
			.byte %01111100
			.byte %01000100
			.byte %01000100
			.byte %01000100
			.byte %01111100
			.byte %00000000
			.byte %00000000
		
			.byte %00000000
			.byte %00000000
			.byte %00111000
			.byte %00101000
			.byte %00111000
			.byte %00000000
			.byte %00000000
			.byte %00000000
		
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00010000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
		
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000

			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
			.byte %00000000
	
//--------------------------------------------

.macro LoadSpriteFromGif(filename) {
	.var gif = LoadPicture(filename)
	.for (var y=0; y<21; y++)
		.for (var x=0; x<3; x++)
			.byte gif.getSinglecolorByte(x,y) 
	.byte 0
}

			.align $40
sprite1:	LoadSpriteFromGif("star1.gif")
sprite2:	LoadSpriteFromGif("star2.gif")
sprite3:	LoadSpriteFromGif("star3.gif")
sprite4:	LoadSpriteFromGif("star4.gif")


//--------------------------------------------
			* = $3c00 "Virtual data" virtual		// <- Data in a virtual block is not entered into memory 
screen: 	.fill $0400, 0
			
	
	