#!/bin/bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.10.0
# ARG_POSITIONAL_SINGLE([command])
# ARG_OPTIONAL_SINGLE([file-name], [f], [a verilog file])
# ARG_OPTIONAL_SINGLE([top-name], [t], [name of top module])
# ARG_OPTIONAL_SINGLE([auto-clk], [a], [automatically clock this port with samplerate])
# ARG_OPTIONAL_BOOLEAN([copy-so], [c], [will copy the shared object to your current directory])
# ARG_OPTIONAL_BOOLEAN([install], [i], [also install object into gnu radio])
# ARG_TYPE_GROUP_SET([commands], [COMMAND], [command], [list, rm, build])
# ARG_DEFAULTS_POS
# ARG_HELP([The Dynamicaly Linked Verilator Tool v1.1])
# ARGBASH_GO

# [ <-- needed because of Argbash

BUILD_DIR=/tmp/dl_verilator
SHARE=/home/thomas/Sync/projects/private/dl_verilog_gnuradio/dl_verilator
GR_BLOCKS=/usr/share/gnuradio/grc/blocks/

if [ "$_arg_command" = "list" ]; then
	ls $GR_BLOCKS | grep ^dlverilog_ | grep -Po 'dlverilog_\K.*?(?=_verilog\.block\.yml)'
	exit
fi
if [ "$_arg_command" = "rm" ]; then

	if [ "$_arg_top_name" = "" ]; then
		echo "ERROR: missing top name !!!"
		exit 1
	fi

	sudo -v
	if [ ! $? = 0 ]; then exit; fi

	echo "deleting module $_arg_top_name"
#	set -o xtrace

	sudo rm $GR_BLOCKS/dlverilog_"$_arg_top_name"_verilog.block.yml
	if [ ! $? = 0 ]; then exit; fi

	rm $SHARE/modules/lib$_arg_top_name.so

	exit
fi
if [ "$_arg_command" = "build" ]; then
	if [ "$_arg_file_name" = "" ]; then
		echo "ERROR: missing file !!!"
		exit 1
	fi
	if [ "$_arg_top_name" = "" ]; then
		echo "ERROR: missing top name !!!"
		exit 1
	fi
	if [ "$_arg_install" = "on" ]; then
		sudo -v
		if [ ! $? = 0 ]; then exit; fi
	fi

	echo "building $_arg_top_name from $_arg_file_name"

#	set -o xtrace

	mkdir -p $BUILD_DIR

	echo "generating IO map ..."
	python3 $SHARE/scripts/gen_ios.py $_arg_file_name $_arg_top_name $BUILD_DIR/ios.json $_arg_auto_clk
	if [ ! $? = 0 ]; then exit; fi

	echo "generating Cpp wrapper ..."
	python3 $SHARE/scripts/gen_wrapper.py $BUILD_DIR/ios.json $SHARE/templates/v_wrapper.cpp $BUILD_DIR/wrapper.cpp
	if [ ! $? = 0 ]; then exit; fi

	echo "running verilator ..."
	verilator --cc --build $_arg_file_name $BUILD_DIR/wrapper.cpp --top-module $_arg_top_name --lib-create $_arg_top_name --Mdir $BUILD_DIR/obj_dir
	if [ ! $? = 0 ]; then exit; fi

	if [ "$_arg_copy_so" = "on" ]; then
		echo "copying shared object ..."
		cp $BUILD_DIR/obj_dir/lib$_arg_top_name.so .
	fi

	if [ "$_arg_install" = "on" ]; then
		echo "installing module ..."
		cp $BUILD_DIR/obj_dir/lib$_arg_top_name.so $SHARE/modules/

		echo "generating gnu radio block ..."
		python3 $SHARE/scripts/gen_yaml.py $BUILD_DIR/ios.json $SHARE/templates/dlverilog_template_verilog.block.yml $SHARE/modules/lib$_arg_top_name.so $_arg_auto_clk 
		if [ ! $? = 0 ]; then exit; fi

		echo "installing into gnu radio ..."
		sudo mv dlverilog_"$_arg_top_name"_verilog.block.yml $GR_BLOCKS
	fi

	exit
fi
exit 0

# ] <-- needed because of Argbash
