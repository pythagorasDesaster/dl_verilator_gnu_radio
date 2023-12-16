#/usr/bin/env bash

BUILD_DIR=/tmp/dl_verilator
SHARE=/home/thomas/Sync/projects/private/dl_verilog_gnuradio/dl_verilator
GR_BLOCKS=/usr/share/gnuradio/grc/blocks/

extract_opt_arg() {
	ARG_NAME=$1
	COMP_WORDS=$2
	I=0
	for E in "${COMP_WORDS[@]}"; do
		if [ "$E" = "$ARG_NAME" ]; then
			echo "${COMP_WORDS[$I+1]}"
			return
		fi
		I=$(expr $I + 1)
	done

	echo ""
	return
}

_dlv-tool_completions() {
	if [ "${#COMP_WORDS[@]}" -lt "3" ]; then
		COMPREPLY=("list" "rm" "build" "--help")
		return
	fi
	# optional arg completion
	if [ "${COMP_WORDS[${#COMP_WORDS[@]}-2]}" = "--top-name" ]; then
		if [ "${COMP_WORDS[1]}" = "build" ]; then

			FNAME="$(extract_opt_arg "--file-name" COMP_WORDS)"

			if [ "$FNAME" = "" ]; then
				COMPREPLY=("tell" "me" "file" "first")
				return
			fi

			COMPREPLY=("$(cat $FNAME | grep -Po '^module \K.*?(?=\()' | sed -e 's/^[ \t]*//' | sed -e 's/[ \t]*$//')")
			return
		fi
		COMPREPLY=($(ls $GR_BLOCKS | grep ^dlverilog_ | grep -Po 'dlverilog_\K.*?(?=_verilog\.block\.yml)'))
		return
	fi
	if [ "${COMP_WORDS[${#COMP_WORDS[@]}-2]}" = "--file-name" ]; then
		COMPREPLY=()
		return
	fi
	if [ "${COMP_WORDS[${#COMP_WORDS[@]}-2]}" = "--auto-clk" ]; then
		FNAME="$(extract_opt_arg "--file-name" COMP_WORDS)"
		if [ "$FNAME" = "" ]; then
			COMPREPLY=("tell" "me" "file" "first")
			return
		fi

		TNAME="$(extract_opt_arg "--top-name" COMP_WORDS)"
		if [ "$TNAME" = "" ]; then
			COMPREPLY=("tell" "me" "top" "first")
			return
		fi

		mkdir -p $BUILD_DIR

		python3 $SHARE/scripts/gen_ios.py $FNAME $TNAME $BUILD_DIR/ios.json

		COMPREPLY=($(python3 -c "import json ; from sys import argv ; file = open(argv[1], 'r') ; dat = json.load(file) ; print('\n'.join(i[0] for i in dat['inputs'] if i[1] == 1))" $BUILD_DIR/ios.json))
		return
	fi
	# subcommand completion
	if [ "${COMP_WORDS[1]}" = "build" ]; then
		COMPREPLY=("--file-name" "--top-name" "--install" "--copy-so" "--auto-clk")
		return
	fi
	if [ "${COMP_WORDS[1]}" = "rm" ]; then
		COMPREPLY=("--top-name")
		return
	fi
	if [ "${COMP_WORDS[1]}" = "list" ]; then
		COMPREPLY=()
		return
	fi
	COMPREPLY=("--file-name" "--top-name" "--install" "--copy-so" "--help")
	return
}

complete -o bashdefault -o default -F _dlv-tool_completions dlv-tool 
