#!/bin/bash

# Copyright (c) 2012
# Artur de S. L. Malabarba

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

### USAGE ####
# To use this script, place this script, pianobar-notify.sh, and
# pandora.jpg in your config folder and configure the three variables below
# according to your needs.
#
# # # Start pianobar by running 'control-pianobar.sh p'
#
# These variables should match YOUR configs
  # Your config folder
  fold="${XDG_CONFIG_HOME:-$HOME/.config}/pianobar"
  # The pianobar executable
  pianobar="pianobar"
  # A blank icon to show when no albumart is found. I prefer to use
  # the actual pandora icon for this, which you can easily find and
  # download yourself. I don't include it here for copyright concerns.
  blankicon="$fold/pandora.jpg"
  
# You probably shouldn't mess with these (or anything else)
if [[ "$fold" == "/pianobar" ]]; then
	fold="$HOME/.config/pianobar"
  blankicon="$fold""$blankicon"
fi
notify="notify-send --hint=int:transient:1"
zenity="zenity"
logf="$fold/log"
ctlf="$fold/ctl"
an="$fold/artname"
np="$fold/nowplaying"
ds="$fold/durationstation"
ip="$fold/isplaying"
ine="$fold/ignextevent"
stl="$fold/stationlist"
dn="$fold/downloadname"
dd="$fold/downloaddir"
du="$fold/downloadurl"

[[ -n "$2" ]] && sleep "$2"

echo "" > "$logf"
case $1 in

p|pause|play)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "p" > "$ctlf"
		if [[ "$(cat $ip)" == 1 ]]; then
			echo "0" > "$ip"
			$notify -t 2500 -i "`cat $an`" "Song Paused" "`cat $fold/nowplaying`"
		else
			echo "1" > "$ip"
			$notify -t 2500 -i "`cat $an`" "Song Playing" "`cat $fold/nowplaying`"
		fi
	else
		mkdir -p "$fold/albumart"
		rm "$logf" 2> /dev/null
		rm "$ctlf" 2> /dev/null
		mkfifo "$ctlf"
		$notify -t 2500 "Starting Pianobar" "Logging in..."
		"$pianobar" | tee "$logf"
	fi;;
    
download|d)
	if [[ -n `pidof pianobar` ]]; then	
		echo -n "$" > "$ctlf"
		tac "$logf" | grep -am1 audioUrl | sed '{ s/^.*audioUrl:\t//; }' | cat > "$du"
		mkdir -p "$fold/songs/`cat $dd`"
		cd "$fold/songs/`cat $dd`"
		if [[ -z `cat "$du" | grep mp3` ]]; then ext="m4a"
		else ext="mp3"
		fi
		
		minsize=500000 # minimum size in bytes, 500k
		basefilename="$(cat $dn).$ext"
		filename="$(readlink -f .)/$basefilename"
		filesize=$(wc -c <"$filename")
		filesize_mb=$(printf "%.2f\n" $(bc -l <<< "$filesize/1000000"))
		if [ $minsize -ge $filesize ]; then
			$notify -t 3000 "Redownloading..." "Last attempt for $basefilename failed, retrying"
			rm $filename 2> /dev/null
		fi

		if [[ ! -e "`cat $dn`.$ext" ]]; then
			$notify -t 4000 "Downloading..." "'$basefilename' to `cat $dd`"
			wget -q -O "`cat $dn`.$ext" "`cat $du`" &
		else
			$notify -t 2000 "$basefilename" "Already exists in `cat $dd` ($filesize_mb MB)"
		fi
	fi;;

love|l|+)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "+" > "$ctlf"
	fi;;
    
ban|b|-|hate)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "-" > "$ctlf"
	fi;;
    
next|n)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "n" > "$ctlf"
	fi;;

tired|t)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "t" > "$ctlf"
		$notify -t 2000 "Tired" "We won't play this song for at least a month."
	fi;;
    
stop|quit|q)
	if [[ -n `pidof pianobar` ]]; then
		$notify -t 1000 "Quitting Pianobar"
		echo -n "q" > "$ctlf"
		echo "0" > "$ip"
		sleep 1
		if [[ -n $(pidof pianobar) ]]; then
			$notify -t 1000 "Oops" "Something went wrong. \n Force quitting..."
			kill -9 $(pidof pianobar)
			if [[ -n $(pidof pianobar) ]]; then
				$notify -t 2000 "I'm Sorry" "I don't know what's happening. Could you try killing it manually?"
			else
				$notify -t 2000 "Success" "Pianobar closed."
			fi
		fi
	fi;;
    
explain|e)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "e" > "$ctlf"
	fi;;
    
playing|current|c)
	if [[ -n `pidof pianobar` ]]; then
		sleep 1
		time="$(grep "#" "$logf" --text | tail -1 | sed 's/.*# \+-\([0-9:]\+\)\/\([0-9:]\+\)/\\\\-\1\\\/\2/')"
		$notify -t 5000 -i "`cat $an`" "$(cat "$np")" "$(sed "1 s/.*/$time/" "$ds")"
	fi;;
    
nextstation|ns)
	if [[ -n `pidof pianobar` ]]; then
		stat="$(grep --text "^Station: " "$ds" | sed 's/Station: //')"
		newnum="$((`grep --text "$stat" "$stl" | sed 's/\([0-9]\+\)).*/\1/'`+1))"
		newstt="$(sed "s/^$newnum) \(.*\)/-->\1/" "$stl" | sed 's/^[0-9]\+) \(.*\)/* \1/')"
		if [[ -z "$(grep "^-->" "$newstt")" ]]; then
			newnum=0
			newstt="$(sed "s/^$newnum) \(.*\)/-->\1/" "$stl" | sed 's/^[0-9]\+) \(.*\)/* \1/')"
		fi
		echo "s$newnum" > "$ctlf"
		$notify -t 2000 "Switching station" "$newstt"
	fi;;
    
prevstation|ps)
	if [[ -n `pidof pianobar` ]]; then
		stat="$(grep --text "^Station: " "$ds" | sed 's/Station: //')"
		newnum="$((`grep --text "$stat" "$stl" | sed 's/\([0-9]\+\)).*/\1/'`-1))"
		[[ "$newnum" -lt 0 ]] && newnum=$(($(wc -l < "$stl")-1))
		newstt="$(sed "s/^$newnum) \(.*\)/-->\1/" "$stl" | sed 's/^[0-9]\+) \(.*\)/* \1/')"
		echo "s$newnum" > "$ctlf"
		$notify -t 2000 "Switching station" "$newstt"
	fi;;
    
switchstation|ss)
	if [[ -n `pidof pianobar` ]]; then
		text="$(grep --text "[0-9]\+)" "$logf" | sed 's/.*\t\(.*)\) *\(Q \+\)\?\([^ ].*\)/\1 \3/')""\n \n Type a number."
		newnum="$($zenity --entry --title="Switch Station" --text="$(cat "$stl")\n Pick a number.")"
		if [[ -n "$newnum" ]]; then
			newstt="$(sed "s/^$newnum) \(.*\)/-->\1/" "$stl" | sed 's/^[0-9]\+) \(.*\)/* \1/')"
			echo "s$newnum" > "$ctlf"
			$notify -t 2000 "Switching station" "$newstt"
		fi
	fi;;
	

switchstationlist|ssl)
	if [[ -n `pidof pianobar` ]]; then
		text="$(grep --text "[0-9]\+)" "$logf" | sed 's/.*\t\(.*)\) *\(Q \+\)\?\([^ ].*\)/\1 \3/')""\n \n Type a number."
		newnum="$(echo "$(cat "$stl")" | $zenity --list --column="Station" --title="Switch Station" --text="Pick a number." | awk -F')' '{print $1}')"
		if [[ -n "$newnum" ]]; then
			newstt="$(sed "s/^$newnum) \(.*\)/-->\1/" "$stl" | sed 's/^[0-9]\+) \(.*\)/* \1/')"
			echo "s$newnum" > "$ctlf"
			$notify -t 2000 "Switching station" "$newstt"
		fi
	fi;;
    
upcoming|queue|u)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "u" > "$ctlf"
		sleep .5
		list="$(grep --text '[0-9])' $logf | sed 's/.*\t [0-9])/*/; s/&/\&amp;/; s/</\&lt;/')"
		if [[ -z "$list" ]]; then
			$notify "No Upcoming Songs" "This is probably the last song in the list."
		else
			$notify -t 5000 "Upcoming Songs" "$list"
		fi
	fi;;    

"history"|h)
	if [[ -n `pidof pianobar` ]]; then
		echo -n "h" > "$ctlf"
		text="$(grep --text "[0-9]\+)" "$logf" | sed 's/.*\t\(.*) *[^ ].*\)/\1/')""\n \n Type a number."
		snum="$($zenity --entry --title="History" --text="$text")"
		if [[ -n "$snum" ]]; then
			echo "1" > "$ine"
			echo "$snum" > "$ctlf"
			echo -n "$($zenity --entry --title="Do what?" --text="Love[+], Ban[-], or Tired[t].")" > "$ctlf"
		else
			echo "" > "$ctlf"
		fi
	fi;;
    
*)


echo -e "
\\033[1mWhat's the point?\\033[0m
This script takes a single argument. Possible arguments are:
\\033[1;34m play, love, hate, next, stop, explain, playing, upcoming,
history, download, (next|prev|switch)station\\033[0m.
The behavior is mostly the same as running the respective action
inside pianobar, except you interact with notification bubbles.

THIS INTERACTION WILL ONLY WORK CORRECTLY IF YOU START PIANOBAR
THROUGH THE SCRIPT! SEE **USAGE** FOR INSTRUCTION.

This script is meant to be used as a hidden interface for
pianobar. It is invoked by keyboard shortcuts assigned by you, and
interacts with you through the use of pretty notification
bubbles. The point is that you are able to interact with pianobar
without having to focus the terminal you invoked it in. It also
shows album art, which pianobar can't do since it is terminal-
focused. If you prefer, you could also assign aliases instead of
keyboard shortcuts.

\\033[1;31mIMPORTANT:\\033[0;31m
This script depends on two commands: zenity and notify-send. As of
this writting libnotify-bin provides a buggy version of the
notify-send command in Ubuntu, so some options of the command don't
work. On Ubuntu, it is recommended that you install some patched[1]
version of the package that fixes the bug. Without this fix, you
might not get album art, and all your notification will have the
same duration of 10 seconds, which gets annoying fast. On other
systems, you'll get varying behavior. It is also recommended that
you create a file \".notify-osd\" in your \$HOME with the line
\"bubble-icon-size = 70px\". This will make the album art icons
bigger and more visible, but be aware that it will also affect
notifications from other software.

The download command uses wget to download the songs into directories
named after their respective stations. If you have low speed internet,
or there are lots of people hogging the bandwidth so you can't download
and play pianobar at the same time; try adding '--limit-rate=25K' to the
wget command above.\\033[0;30m

\\033[1mUSAGE:\\033[0m
Bind \"PATH/TO/control-pianobar.sh <argument>\" to a hotkey in your
distro's keyboard shortcut manager. Start pianobar with the command
\"PATH/TO/control-pianobar.sh p\" (or the appropriate hotkey.

\\033[1m Suggestions:\\033[0m
Bind this key - To this command
\\033[1;34m Media Play/Pause\\033[0m - control-pianobar.sh p;
\\033[1;34m Media Stop\\033[0m - control-pianobar.sh quit;
\\033[1;34m Media Previous\\033[0m - control-pianobar.sh history;
\\033[1;34m Media Next\\033[0m - control-pianobar.sh next;
\\033[1;34m Ctrl + Media Previous\\033[0m - control-pianobar.sh previousstation;
\\033[1;34m Ctrl + Media Next\\033[0m - control-pianobar.sh nextstation;
\\033[1;34m Browser Favorites\\033[0m - control-pianobar.sh love;
\\033[1;34m Browser Stop\\033[0m - control-pianobar.sh ban;
\\033[1;34m Browser Search\\033[0m - control-pianobar.sh explain;
\\033[1;34m Super + Search\\033[0m - control-pianobar.sh switchstation;
\\033[1;34m Alt + D\\033[0m - control-pianobar.sh download;

This script does take a second argument, but the user need not
worry about it. It's used by notify-pianobar.sh to make some
notifications behave right. If a second argument is provided, it
must be a positive integer. This number is the number of seconds the
script waits before running.

[1]From the date of this writting (2011) I am using a patched version
found in the ppa ppa:leolik/leolik. I take no responsibility
regarding the contents of this ppa, I'm simply stating it's the one
I used.
http://www.webupd8.org/2010/05/finally-easy-way-to-customize-notify.html";;
esac
