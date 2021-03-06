FIND_PACKAGE(PkgConfig)
PKG_CHECK_MODULES(PC_ICE Ice-3.4)

#set(ICE_MANUAL_INSTALL_PATH /opt/Ice-3.4.2/)
FIND_PATH(
    ICE_INCLUDE_DIR 
    NAMES IceUtil/IceUtil.h Ice/Ice.h IceStorm/IceStorm.h icestorm_publisher_template.h 
    HINTS ${CMAKE_INSTALL_PREFIX}/${HEADER_DIR} ${ICE_MANUAL_INSTALL_PATH}/include/
)

set(ICE_LIBRARY )

FIND_LIBRARY(
    ICE_ICESTORM IceStorm 
    PATHS ENV LD_LIBRARY_PATH 
    HINTS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS}  ${ICE_MANUAL_INSTALL_PATH}/lib64/
)

FIND_LIBRARY(
  ICE_ICESTORM IceStorm
  PATHS HINTS ${CMAKE_INSTALL_PREFIX}/lib64/ ${CMAKE_INSTALL_PREFIX}/lib/
  PATHS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS} ${ICE_MANUAL_INSTALL_PATH}/lib64/
  ENV LD_LIBRARY_PATH
)
FIND_LIBRARY(
  ICE_ICE Ice
  PATHS HINTS ${CMAKE_INSTALL_PREFIX}/lib64/ ${CMAKE_INSTALL_PREFIX}/lib/
  PATHS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS} ${ICE_MANUAL_INSTALL_PATH}/lib64/
  ENV LD_LIBRARY_PATH
)
FIND_LIBRARY(
  ICE_ICEGRID IceGrid
  PATHS HINTS ${CMAKE_INSTALL_PREFIX}/lib64/ ${CMAKE_INSTALL_PREFIX}/lib/
  PATHS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS} ${ICE_MANUAL_INSTALL_PATH}/lib64/
  ENV LD_LIBRARY_PATH
)
FIND_LIBRARY(
  ICE_ICEUTIL IceUtil
  PATHS HINTS ${CMAKE_INSTALL_PREFIX}/lib64/ ${CMAKE_INSTALL_PREFIX}/lib/
  PATHS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS} ${ICE_MANUAL_INSTALL_PATH}/lib64/
  ENV LD_LIBRARY_PATH
)
FIND_LIBRARY(
  ICE_GLACIER2 Glacier2
  PATHS HINTS ${CMAKE_INSTALL_PREFIX}/lib64/ ${CMAKE_INSTALL_PREFIX}/lib/
  PATHS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS} ${ICE_MANUAL_INSTALL_PATH}/lib64/
  ENV LD_LIBRARY_PATH
)

if(APPLE)
  FIND_LIBRARY(
    ICE_ZEROCICE ZeroCIce
    PATHS HINTS ${CMAKE_INSTALL_PREFIX}/lib64/ ${CMAKE_INSTALL_PREFIX}/lib/
    PATHS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS} ${ICE_MANUAL_INSTALL_PATH}/lib64/
    ENV LD_LIBRARY_PATH
    )
endif(APPLE)

FIND_LIBRARY(
  ICE_PTHREAD NAMES pthread pthread-2.13
  PATHS HINTS ${CMAKE_INSTALL_PREFIX}/lib64/ ${CMAKE_INSTALL_PREFIX}/lib/
  PATHS ${PC_ICE_LIBDIR} ${PC_ICE_LIBRARY_DIRS} /lib/i386-linux-gnu /lib/x86_64-linux-gnu /usr/lib /lib /lib64
  ENV LD_LIBRARY_PATH
)

list(APPEND ICE_LIBRARY
    ${ICE_ICESTORM}
    ${ICE_ICE}
    ${ICE_ICEGRID}
    ${ICE_ICEUTIL}
    ${ICE_GLACIER2}
    ${ICE_ZEROCICE}
    ${ICE_PTHREAD}
)

FIND_PROGRAM(ICE_SLICE2CPP slice2cpp HINTS ${CMAKE_INSTALL_PREFIX}/bin ${ICE_MANUAL_INSTALL_PATH}/bin/)
FIND_PROGRAM(ICE_SLICE2PY slice2py HINTS ${CMAKE_INSTALL_PREFIX}/bin ${ICE_MANUAL_INSTALL_PATH}/bin/)

set(ICE_LIBRARIES ${ICE_LIBRARY})
set(ICE_INCLUDE_DIRS ${ICE_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ICE DEFAULT_MSG ICE_LIBRARY ICE_INCLUDE_DIR)
mark_as_advanced(ICE_INCLUDE_DIR ICE_LIBRARY)
