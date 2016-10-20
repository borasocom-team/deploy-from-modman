#!/bin/bash

RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
NONE="\033[0m"

function _handle_input() {
    argument_found=0
    case $1 in
        --magentodir=*)
            magentodir="${1#*=}/"
            argument_found=1
            ;;
    esac
    if [ $argument_found -eq 0 ]; then
        _print_help
        echo -e "${RED}Error:${NONE}"
        echo "WRONG ARGUMENT PASSED"
        exit 0
    fi
}

function _search_for_modman_file() {
	if [ ! -f ./modman ]; then
    	_print_help
    	echo -e "${RED}Error:${NONE}"
    	echo "MODMAN FILE NOT IN ROOT DIRECTORY"
        exit 0
	fi
}

function _print_help() {
        echo "  ____             _                __                                           _             ";
		echo " |  _ \  ___ _ __ | | ___  _   _   / _|_ __ ___  _ __ ___    _ __ ___   ___   __| | __ _ _ __  ";
		echo " | | | |/ _ \ '_ \| |/ _ \| | | | | |_| '__/ _ \| '_ \` _ \  | '_ \` _ \ / _ \ / _\` |/ _\` | '_ \ ";
		echo " | |_| |  __/ |_) | | (_) | |_| | |  _| | | (_) | | | | | | | | | | | | (_) | (_| | (_| | | | |";
		echo " |____/ \___| .__/|_|\___/ \__, | |_| |_|  \___/|_| |_| |_| |_| |_| |_|\___/ \__,_|\__,_|_| |_|";
		echo "            |_|            |___/                                                               ";
        echo ""
        echo -e "${YELLOW}Usage${NONE}"
        echo " deploy-from-modman [options]"
        echo " call this command from your module root where your modman file is"
        echo ""
        echo -e "${YELLOW}Options:${NONE}"
        echo -e "${GREEN}--magentodir=DIRNAME${NONE}       [REQUIRED] Your magento root directory relative or absolute without trailing slash"
        echo ""
}

function _analyze_and_split_line() {
	if [[ $1 != *"#"* ]]
	then
		line=$1
  		from=$(echo "$line" | awk -F " " '{print $1}')
  		to=$(echo "$line" | awk -F " " '{print $2}')
        #echo "$(pwd)/$from - $magentodir$to"
        _compute_relative "$magentodir$to" "$(pwd)/$from"
  	fi
}

function _compute_relative() {
    source=$1
    target=$2

    common_part=$(dirname $source)
    result=""

    while [[ "${target#$common_part}" == "${target}" ]]; do
        common_part="$(dirname $common_part)"

        if [[ -z $result ]]; then
            result=".."
        else
            result="../$result"
        fi
    done

    if [[ $common_part == "/" ]]; then
        result="$result/"
    fi

    forward_part="${target#$common_part}"

    if [[ -n $result ]] && [[ -n $forward_part ]]; then
        result="$result$forward_part"
    elif [[ -n $forward_part ]]; then
        result="${forward_part:1}"
    fi

    if [ ! -d "$source" ]; then
        dir_source=$(dirname $source)
        if [ ! -d "$dir_source" ]; then
            mkdir -p "$dir_source";
            #echo "CREATE DIR $dir_source";
        fi
    else
        source=$(dirname $source);
    fi

    #echo $result
    ln -sf "$result" "$source"
}

_search_for_modman_file

if [ ! -z "$1" ]; then
   for argument in $@; do
        _handle_input $argument
   done
else
	_print_help   
	echo -e "${RED}Error:${NONE}"
	echo "NO ARGUMENT PASSED";
	exit 0
fi

if [ ! -d "$magentodir" ]; then
    	_print_help
    	echo -e "${RED}Error:${NONE}"
    	echo "MAGENTO ROOT IS NOT A DIRECTORY"
        exit 0
	fi

while IFS='' read -r line || [[ -n "$line" ]]; do
    _analyze_and_split_line "$line"
done < "./modman"

echo -e "${GREEN}ALL DONE!!!${NONE}"

