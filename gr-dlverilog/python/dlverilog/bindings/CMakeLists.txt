# Copyright 2020 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

########################################################################
# Check if there is C++ code at all
########################################################################
if(NOT dlverilog_sources)
    MESSAGE(STATUS "No C++ sources... skipping python bindings")
    return()
endif(NOT dlverilog_sources)

########################################################################
# Check for pygccxml
########################################################################
GR_PYTHON_CHECK_MODULE_RAW(
    "pygccxml"
    "import pygccxml"
    PYGCCXML_FOUND
    )

include(GrPybind)

########################################################################
# Python Bindings
########################################################################

list(APPEND dlverilog_python_files
    base_verilog_python.cc python_bindings.cc)

GR_PYBIND_MAKE_OOT(dlverilog
   ../../..
   gr::dlverilog
   "${dlverilog_python_files}")

# copy bindings extension for use in QA test module
add_custom_command(TARGET dlverilog_python POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:dlverilog_python>
    ${PROJECT_BINARY_DIR}/test_modules/gnuradio/dlverilog/
)

install(TARGETS dlverilog_python DESTINATION ${GR_PYTHON_DIR}/gnuradio/dlverilog COMPONENT pythonapi)
