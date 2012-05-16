control-pianobar
================

Pair of scripts that interact with pianobar entirely through
notification bubles and hotkeys. No terminal necessary.

The point here is that once you set your bindings as described on
**USAGE** you'll be able to interact with pianobar without having
focus the terminal it's running in, which distracts you and switches
focus away from what you're doing.

REQUIRES
============

 - Some implementation of the `notify-send` command (included with
   most distros). In Ubuntu that's the `libnotify` package (but read
   the *NOTES* section below for a better alternative).
 - `pianobar` somewhere in your $PATH. If it's not in your $PATH edit
   the `$pianobar` variable inside the `control-pianobar.sh` script.

USAGE
============

 - Place all contents directly inside your pianobar config folder
   (defaults to `$XDG_CONFIG_HOME/pianobar`, which defaults to
   `$HOME/.config/pianobar`).
 - Make sure boths scripts are marked as executable.   
 - Using your desktop environment, bind different hotkeys to calling
   `control-pianobar.sh <argument>` with different arguments.
   
For example, bind `Media Play/Pause` to
`$HOME/.config/pianobar/control-pianobar.sh p`. Now whenever you press
`Media Play/Pause` pianobar will start in the background. If you have
a default station set, the script just starts playing, otherwise it
automatically ask you (with a popup) which station you want. From now
on, pressing `Media Play/Pause` pauses and resumes the music.
 
The `control-pianobar.sh` script takes many different arguments. You
should bind each argument to a different media key (or just a
hotkey). Running `control-pianobar.sh` with no arguments prints
instructions on usage with the following examples.

Bind this key => To this command:
 - **Media Play/Pause** => `control-pianobar.sh p;`
 - **Media Stop** => `control-pianobar.sh quit;`
 - **Media Previous** => `control-pianobar.sh history;`
 - **Media Next** => `control-pianobar.sh next;`
 - **Ctrl + Media Previous** => `control-pianobar.sh previousstation;`
 - **Ctrl + Media Next** => `control-pianobar.sh nextstation;`
 - **Browser Favorites** => `control-pianobar.sh love;`
 - **Browser Stop** => `control-pianobar.sh ban;`
 - **Browser Search** => `control-pianobar.sh explain;`
 - **Super + Search** => `control-pianobar.sh switchstation;`


NOTES
============

As of this writting `libnotify-bin` provides a buggy version of the
notify-send command in Ubuntu, so some options of the command don't
work. On Ubuntu, it is recommended that you install some patched
version of the package that fixes the bug. Without this fix, you might
not get album art, and all your notification will have the same
duration of 10 seconds, which gets annoying fast.

From the date of this writting (2012) I am using a patched version
found in the
[ppa:leolik/leolik](http://www.webupd8.org/2010/05/finally-easy-way-to-customize-notify.html).
I take no responsibility regarding the contents of this ppa, I'm
simply stating it's the one I used.

