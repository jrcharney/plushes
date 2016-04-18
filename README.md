Plushes
=====

PLUSHES (Power Linux User SHEll Scripts)

Plushes is a series of Bash scripts that make using things easy.

Plushes are what I like to call "kitchen sink scripts".  Linux gives you all sorts of tools to work with to do stuff with, but nothing practical to do things like enable Wifi

## Meet Me Here on IRC!

Generally I hang out on the Freenode network in the ##Linux chat room, though you could also catch me in #bash or #RaspberryPi.

## Scripts

* `wifi.sh` - Make sense of wifi, all in the command line!  (Currently only WPA Supplcant setups (essid and psk) work.  But what if you want to connect to something that doesn't use it.)
* `flu.sh` - Make [lolcat](https://github.com/busyloop/lolcat) use the [toilet](http://caca.zoy.org/wiki/toilet). :3
* `deli.sh` - Download a file, privately so that it doesn't appear when you type `history`.

Things I've been thinking about that I may or may not work on

* A script that is a companion to `deli.sh` that does other thing clandestinely (moving, renaming, copying, etc.)
* A script that finds files that isn't as complicated as using `find` or `grep`.
* A script to download image galleries from sites like Imgur. (I had it at one time, but I forgot where I put it.)  The archives could be saved as `.cbr`, `.cbz`, or `.pdf` format.
* A script that downloads everything you need to get Software Defined Radio (SD) installed from source. (EVERYTHING most binary repos is too old!)
* A script that operates SDR.
* Mandelbrot and Julia stuff. (I really want to do some fun fractal stuff.)
* Develop or find some super-light browser that let's you tinker with a JavaScript, CSS3, HTML5, and Canvas browser that doesn't eat up resources. (ARM users, you know you want than!)
* A script that gets Spotify set up for textual interfaces. (There are programs that do this, but I just want to get it set up. This might be part of my Hacktop project along with the SDR idea.)
* A few script that promote some lesser known programs that do some cool stuff.

## Requirements

Most of these scripts are designed for use with Bash, sed, gawk, grep, or find.

Flush requires Toilet or Figlet, Ruby and the Lolcat gem.

Delish reqires `curl`, and possible `tar`, `unzip`, and whatever's require for `.gz`, `.bz2`, and `.xz`.

Many of these scripts may require adminstrative access so passwords may be requires to do some stuff.

## Will any of this ever be done?

It depends.  Bits and pieces over time.  Rome wasn't built in a day.

## Will you use anything else?

I could use something that uses Python, Ruby, C/C++, or Java.  Maybe some LaTeX or PostScript stuff because I like math.

## Why do any of this [insert program here] exists?

Because I can, and I need to clean up a lot of my repos.  Decommission some stuff. Put some things together. Impress people. That kinda stuff.
