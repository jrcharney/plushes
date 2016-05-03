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

## To make this all work

In `~/profile', there should be a few lines that state that if `~/bin` is created, it is added to `$PATH`.  To get it working, we need to create that directory and then close the terminal (and terminal multiplexer if you are using that too), then start it up again.

```
$ mkdir ~/bin
$ exit
```

After we open up a new terminal (and tmux if we want to open that too), we should notice that `/home/$USER/bin` added to the beginning of `$PATH` where `$USER` is your user name.

If you'd like to see it better, you could run one of two commands

* `echo $PATH | sed -n -e 's/:/\n/g;p'`
* 'echo $PATH | tr ':' '\n'`

If you run one of those commands, you can better understand the order of which Linux accepts which programs to run.  Programs that run in `~/bin` will take higher precidence over what we add to our dot files (like `/opt/` directories), then the '/usr/local' directories (except for `/usr/local/games/`), then then our `/usr/` directories (`/usr/sbin` and `/usr/bin` but not `/usr/games`), then `/sbin` and `/bin`, then those games directories.

I prefer to put git projects that are not mine and that I am not forking into a directory called `~/Software`.  The ones that I do create or fork are put into `~/Projects`.  It's a good practice in my opinion for this next step to get things going.

```
$ [ ! -d ~/Software ] && mkdir ~/Software			# Create this directory if it doesn't exist.
$ cd ~/Software							# Go to that directory
$ git clone https://github.com/jrcharney.com/plushes		# Clone this repo into the ~/Software directory
$ cd plushes							# Got to the plushes directory
$ ./startup.sh							# Run this script!
```

So what does startup do?  Create `~/bin` if it doesn't exists. It also creates all the soft links in plushes that would go in `~/bin`
