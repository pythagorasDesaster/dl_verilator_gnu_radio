# Copyright 2011,2012,2016,2018,2019 Free Software Foundation, Inc.
#
# This file was generated by gr_modtool, a tool from the GNU Radio framework
# This file is a part of gr-dlverilog
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

########################################################################
# Setup library
########################################################################
include(GrPlatform) #define LIB_SUFFIX

list(APPEND dlverilog_sources
    base_verilog_impl.cc dl_verilator.cpp
)

set(dlverilog_sources "${dlverilog_sources}" PARENT_SCOPE)
if(NOT dlverilog_sources)
    MESSAGE(STATUS "No C++ sources... skipping lib/")
    return()
endif(NOT dlverilog_sources)

add_library(gnuradio-dlverilog SHARED ${dlverilog_sources})
target_link_libraries(gnuradio-dlverilog gnuradio::gnuradio-runtime)
target_link_libraries(gnuradio-dlverilog "-ljsoncpp")
target_include_directories(gnuradio-dlverilog
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
    PUBLIC $<INSTALL_INTERFACE:include>
  )
set_target_properties(gnuradio-dlverilog PROPERTIES DEFINE_SYMBOL "gnuradio_dlverilog_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-dlverilog PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
include(GrMiscUtils)
GR_LIBRARY_FOO(gnuradio-dlverilog)

########################################################################
# Print summary
########################################################################
message(STATUS "Using install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Building for version: ${VERSION} / ${LIBVER}")

########################################################################
# Build and register unit test
########################################################################
include(GrTest)

# If your unit tests require special include paths, add them here
#include_directories()
# List all files that contain Boost.UTF unit tests here
list(APPEND test_dlverilog_sources
)
# Anything we need to link to for the unit tests go here
list(APPEND GR_TEST_TARGET_DEPS gnuradio-dlverilog)

if(NOT test_dlverilog_sources)
    MESSAGE(STATUS "No C++ unit tests... skipping")
    return()
endif(NOT test_dlverilog_sources)

foreach(qa_file ${test_dlverilog_sources})
    GR_ADD_CPP_TEST("dlverilog_${qa_file}"
        ${CMAKE_CURRENT_SOURCE_DIR}/${qa_file}
    )
endforeach(qa_file)
