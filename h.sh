#!/bin/bash

# DESCRIPTION:
#   * h highlights with color specified keywords when you invoke it via pipe
#   * h is just a tiny wrapper around the powerful 'ag'. you need 'ag' installed to use h. ack website: https://github.com/ggreer/the_silver_searcher/
# INSTALL:
#   * put something like this in your .bashrc:
#     . /path/to/h.sh
#   * or just copy and paste the function in your .bashrc
# TEST ME:
#   * try to invoke:
#     echo "abcdefghijklmnopqrstuvxywz" | h   a b c d e f g h i j
# GITHUB
#   * https://github.com/cbensemann/hhighlighter

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='0;30'        # Black
Red='0;31'          # Red
Green='0;32'        # Green
Yellow='0;33'       # Yellow
Blue='0;34'         # Blue
Purple='0;35'       # Purple
Cyan='0;36'         # Cyan
White='0;37'        # White

# Bold on Background
On_Black='4;30'       # Black
On_Red='4;31'         # Red
On_Green='4;32'       # Green
On_Yellow='4;33'      # Yellow
On_Blue='4;34'        # Blue
On_Purple='4;35'      # Purple
On_Cyan='4;36'        # Cyan
On_White='4;37'       # White

h() {

	_usage() {
		echo "usage: YOUR_COMMAND | h [-idn] args...
	-i : ignore case
	-d : disable regexp
	-n : invert colors"
	}

	local _OPTS

	# detect pipe or tty
	if test -t 0; then
		_usage
		return
	fi

	# manage flags
	while getopts ":idnQ" opt; do
		case $opt in
			i) _OPTS+=" -i " ;;
			d)  _OPTS+=" -Q " ;;
			n) n_flag=true ;;
			Q)  _OPTS+=" -Q " ;;
				# let's keep hidden compatibility with -Q for original ack users
			\?) _usage
				return ;;
		esac
	done

	shift $(($OPTIND - 1))

	# check maximum allowed input
	if (( ${#@} > 12)); then
		echo "Too many terms. h supports a maximum of 12 groups. Consider relying on regular expression supported patterns like \"word1\\|word2\""
		return -1
	fi;

	# set zsh compatibility
	[[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays && setopt ignorebraces

	local _i=0

	if [ -z $n_flag ]; then
		#inverted-colors-last scheme
		_COLORS=( "$Red" "$Green" "$Yellow" "$Blue" "$Purple" "$Cyan" "$On_Red" "$On_Green" "$On_Yellow" "$On_Blue" "$On_Purple" "$On_Cyan" )
	else
		#inverted-colors-first scheme
		_COLORS=( "bold on_red" "bold on_green" "bold black on_yellow" "bold on_blue" "bold on_magenta" "bold on_cyan" "bold black on_white" "underline bold red" "underline bold green" "underline bold yellow" "underline bold blue" "underline bold magenta" )
	fi

	local AG=ag
	if ! which $AG >/dev/null 2>&1; then
		echo "Could not find ag"
		return -1
	fi

	# build the filtering command
	for keyword in "$@"
	do
		local _COMMAND=$_COMMAND"$AG $_OPTS --passthru --color --color-match \"${_COLORS[$_i]}\" '$keyword' |"
		_i=$_i+1
	done
	#trim ending pipe
	_COMMAND=${_COMMAND%?}
	#echo "$_COMMAND"
	cat - | eval $_COMMAND
}
