# Fire is coming!

Implementation of DOOM fire effect as described by the [Fabien Sanglard](http://fabiensanglard.net/doom_fire_psx/).

Uses CHICKEN scheme 5.0 and sdl2 egg by the John Croisant.

![DOOM fire](/screenshot.png)

# Running the code

* Install CHICKEN scheme and sdl2 libraries for your system.

* Install sdl2 egg with
```sh
    chicken-install sdl2
```

* Compile and run with
```sh
    chicken-csc doom.scm && ./doom
```
