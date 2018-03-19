C64 Starfield
=============

My first venture into assembly programming. Work in progress.

I started this to gain a deeper understanding of microprocessors and peripherals in general, and thought it would be interesting and fun to create something on this relatively simple platform that I remember for my childhood.

Uses GraphicsMagick/ImageMagick and KickAssembler to create a simple starfield simulation. I set up 4 "stars" of different size. The 8 available sprites are moved at a random speed across the screen and recycled (new Y pos and speed) each time they reach the right edge. 

The star speed also determines the size of the star that is used. Faster stars are closer and therefore bigger and vice versa.

The program is derived from one of the examples shipped with KickAssembler

TODO
----

* I still need to use the "ninth bit" for the X position.
* Would be cool to get sprite multiplexing so we could double the star count. And perhaps open the top and bottom border.
* Some nebulous graphics as a backdrop for the moving start might be cool.
* Hopefully I will be able to produce background music for this as well.


