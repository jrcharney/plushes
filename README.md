Plushes
=====

PLUSHES (Power Linux User SHEll Scripts)

Plushes is a series of Bash scripts (and eventually Python Scripts) that make using things easy.

Plushes are what I like to call "kitchen sink scripts".  Linux gives you all sorts of tools to work with to do stuff with, but nothing practical to do things like enable Wifi.

## Why should I trust you, Jason?

There is kind of an exclusion barrier on Linux, namely because Linux is not Windows or Mac. No "nerds at the genius bar" to fix what you break. Which to be honest, the only time you should need to see them if is if it is a major hardware issue.

If you are a "normal" user who doesn't code, who has no interested in coding, has no patience, or just don't like to solve puzzle or fix things yourself, you're not going to like Linux.  For those who want to try, Plushes can help.

I write these things because I like to translate Nerd into English and because a lot of nerds write stuff like the expect you to know what is in their head.  Do you have time to interpolate a data into a Pivot Table in Microsoft Excel?

**If your answered *"What?"* Then I'm your guy.**

(BTW, that is just Nerd for "Insert data into a Pivot Table into Excel to make a graph out of something."  I think.)

## Meet Me Here on IRC!

Generally I hang out on the Freenode network in the ##Linux chat room, though you could also catch me in #bash or #RaspberryPi.  I haven't been hanging around there as much these days, what with Slack being such a big thing.

I've been trying to score enough points to ask questions on Stack Overflow.

## Support Plushes!

Plushes is currently my most active Github repo as of late.  It's given me something to do while a find a better job than the one I have.  **Until then, [support Plushes by tossing in a few bucks into my Ko-Fi cup!](https://ko-fi.com/jrcharney)**

## If you happen to have a tech job in the St. Louis Area...

Hey! Are you in the St. Louis, Missouri area?  Do you work for some kind of tech company in the St. Louis Area?

I like being here!  I hate getting phone calls from randos who want me to move out of town. I'm too broke to leave at the moment.  In fact, I take the bus to work.

If you have a job that I can do that has me doing this kind of stuff for a living, and you're not some rando looking for me to work at some "secret clearance" government job at a place like Boeing, Scott Air Force Base, or the Natioanl Personal Records Center, then you have my attention.

I don't have any problem working for the government, just the parts that want me to not talk about work and that spend billions blowing up villages and incarcerating children in baby internment camps to "Make America Great Again".

Basically, if you aren't from some agency in the U.S. Department of Commerce (like the National Weather Service or Census Bureau), I don't want to talk to you.

However, if you are from a local tech company (World Wide Technoligies, Asynchrony, Graybar, etc.), or the Department of Commerce (we got that Census 2020 coming up), please for the love of Dennis Ritchie, contact me!

## Scripts

* `wifi.sh` - Make sense of wifi, all in the command line!  (Currently only WPA Supplcant setups (essid and psk) work.  But what if you want to connect to something that doesn't use it.)
* `flu.sh` - Make [lolcat](https://github.com/busyloop/lolcat) use the [toilet](http://caca.zoy.org/wiki/toilet). :3
* `deli.sh` - Download a file, privately so that it doesn't appear when you type `history`.
* `bye.sh` - A more mnemonic way to shut down and restart from the command line.
* `zippy.sh` - If you have an account with the United States Postal Service, `zippy` will get zip code data. It requires creating an API key. zippy will store this information in a file called `.zippyrc`
* `geocoord.sh` - Probably a better program than `zippy`. It uses data from the US Census Bureau to fetch coordinates of place. This app will also let you find zip codes if you don't know the city and find cities if you don't if you just have the address and zip code. It's still a bit beta because it still requires a little bit of user intervention (see `zippy.sh help` as to why.)

## Comming Soon
* MOTD scripting! - create a Message-of-the-Day (MOTD) that loads when you start up your system or login to SSH. I'd eventually like to create a warning prompt (which is more of a MOTD) before you log in. This is used to warn intruders to keep out, but it's also a creative way of showing information about your computer when loggin in.

* A new `weather.sh` script that gets data from the National Weather Service rather than Accuweather. (FREE GOVERNMENT STUFF!)

## Things I've been thinking about that I may or may not work on

* A script that is a companion to `deli.sh` that does other thing clandestinely (moving, renaming, copying, etc.)
* A script that finds files that isn't as complicated as using `find` or `grep`.
* A script to download image galleries from sites like Imgur. (I had it at one time, but I forgot where I put it.)  The archives could be saved as `.cbr`, `.cbz`, or `.pdf` format.
* A script that downloads everything you need to get Software Defined Radio (SD) installed from source. (EVERYTHING most binary repos is too old!)
* A script that operates SDR.
* Mandelbrot and Julia stuff. (I really want to do some fun fractal stuff.)
* Develop or find some super-light browser that let's you tinker with a JavaScript, CSS3, HTML5, and Canvas browser that doesn't eat up resources. (ARM users, you know you want than!)
* A script that gets Spotify set up for textual interfaces. (There are programs that do this, but I just want to get it set up. This might be part of my Hacktop project along with the SDR idea.)
* A script that sets up `zsh` the right way. (Don't use antigen explicity! Use Zplug!)
* A script that sets up `vim` the right way. (Plugins make everything better. Also a better `.vimrc` for root. I really want to see EditConfig and some sort of auto complete be used.)
* A script that sets up `i3-gaps` for Debian systems (Great for Hacktops if you use Raspbian. Why should those Arch Linux nerds have all the fun?!)
* A few script that promote some lesser known programs that do some cool stuff.

## Projects not by me that you should check out.
* [gitignore.io](https://gitignore.io/) - Need help setting up your `.gitignore` file? Give them a try.
* [cheat.sh](https://github.com/chubin/cheat.sh) - "The only cheat sheet you need". Curl help for learning how to code.
* [rate.sx](https://github.com/chubin/rate.sx) - Curl Cryptocurrencies exchange rates. Even if you aren't into cryptocurrenies, you have to admit this is a beautiful demonstration of the power of command line! Using braile characters to act as block characters for drawing charts!
* [lolcat](https://github.com/busyloop/lolcat/) - "Rainbows and unicorns!" 256 blended color cat command. This is why you need to set your terminal to 256 colors!
* [Winds](https://github.com/GetStream/Winds) - Open Source RSS & Podcast App powered by GetStrea.io. RSS is back!

## Requirements

Most of these scripts are designed for use with Bash, sed, gawk, grep, or find.

Flush requires Toilet or Figlet, Ruby and the Lolcat gem.

Delish reqires `curl`, and possible `tar`, `unzip`, and whatever's require for `.gz`, `.bz2`, and `.xz`.

Many of these scripts may require adminstrative access so passwords may be requires to do some stuff.

Bash, Sed, Awk - Use these scripts as coding examples for your scripts.

## Will any of this ever be done?

It depends.  Bits and pieces over time.  Rome wasn't built in a day.

I've made some good progress so far.

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
* `echo $PATH | tr ':' '\n'`

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
