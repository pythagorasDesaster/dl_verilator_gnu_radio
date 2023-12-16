find_package(PkgConfig)

PKG_CHECK_MODULES(PC_GR_DLVERILOG gnuradio-dlverilog)

FIND_PATH(
    GR_DLVERILOG_INCLUDE_DIRS
    NAMES gnuradio/dlverilog/api.h
    HINTS $ENV{DLVERILOG_DIR}/include
        ${PC_DLVERILOG_INCLUDEDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/include
          /usr/local/include
          /usr/include
)

FIND_LIBRARY(
    GR_DLVERILOG_LIBRARIES
    NAMES gnuradio-dlverilog
    HINTS $ENV{DLVERILOG_DIR}/lib
        ${PC_DLVERILOG_LIBDIR}
    PATHS ${CMAKE_INSTALL_PREFIX}/lib
          ${CMAKE_INSTALL_PREFIX}/lib64
          /usr/local/lib
          /usr/local/lib64
          /usr/lib
          /usr/lib64
          )

include("${CMAKE_CURRENT_LIST_DIR}/gnuradio-dlverilogTarget.cmake")

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GR_DLVERILOG DEFAULT_MSG GR_DLVERILOG_LIBRARIES GR_DLVERILOG_INCLUDE_DIRS)
MARK_AS_ADVANCED(GR_DLVERILOG_LIBRARIES GR_DLVERILOG_INCLUDE_DIRS)
