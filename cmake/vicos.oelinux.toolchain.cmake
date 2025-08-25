cmake_minimum_required(VERSION 3.10)

if(VICOS_TOOLCHAIN_INCLUDED)
    return()
endif()
set(VICOS_TOOLCHAIN_INCLUDED TRUE)

# make sure sdk is set
if(NOT VICOS_SDK)
    if(DEFINED ENV{VICOS_SDK} AND IS_DIRECTORY "$ENV{VICOS_SDK}")
        set(VICOS_SDK "$ENV{VICOS_SDK}")
    elseif(DEFINED ENV{VICOS_SDK_HOME} AND IS_DIRECTORY "$ENV{VICOS_SDK_HOME}")
        set(VICOS_SDK "$ENV{VICOS_SDK_HOME}")
    elseif(DEFINED ENV{_VICOS_SDK} AND IS_DIRECTORY "$ENV{_VICOS_SDK}")
        set(VICOS_SDK "$ENV{_VICOS_SDK}")
    else()
        message(FATAL_ERROR "Invalid vicos SDK. define VICOS_SDK_HOME in env or set VICOS_SDK var.")
    endif()
endif()

set(ENV{_VICOS_SDK} "${VICOS_SDK}")
file(TO_CMAKE_PATH "${VICOS_SDK}" VICOS_SDK)

set(VICOS TRUE)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION "3.18")
set(CMAKE_SYSROOT /home/kerigan/projects/newvicos-sdk/sysroot/sysroots/armv7a-neon-vfpv4-oe-linux-gnueabi)

#set(CMAKE_SYSROOT "${VICOS_SDK}/sysroot")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_SYSTEM_PROCESSOR arm)

set(VICOS_TOOLCHAIN_NAME arm-oe-linux-gnueabi)
set(VICOS_LLVM_TRIPLE arm-oe-linux-gnueabi)

if(NOT CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER   ${VICOS_TOOLCHAIN_NAME}-gcc)
endif()
if(NOT CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_COMPILER ${VICOS_TOOLCHAIN_NAME}-g++)
endif()

#set(CMAKE_STRIP arm-oe-linux-gnueabi-strip CACHE FILEPATH "" FORCE)
#set(OBJCOPY_CMD arm-oe-linux-gnueabi-objcopy CACHE FILEPATH "" FORCE)
#set(CMAKE_LD arm-oe-linux-gnueabi-ld CACHE FILEPATH "" FORCE)

set(VICOS_COMPILER_FLAGS
    -w
    -DVICOS
    -ffunction-sections
    -fdata-sections
    -funwind-tables
    -fstack-protector-strong
    -fcompare-debug-second
    -march=armv7-a
    -mfpu=neon-vfpv4
    -mfloat-abi=softfp
    -fpermissive
    -mthumb
    -fPIC
)

set(VICOS_COMPILER_FLAGS_CXX
    -fexceptions
    -frtti
    -include ${CMAKE_SOURCE_DIR}/engine/fixIncludes.h
    -std=c++14
)

set(VICOS_COMPILER_FLAGS_DEBUG
    -O0
    -g
)

set(VICOS_COMPILER_FLAGS_RELEASE
    -O2
    -DNDEBUG
    -D_FORTIFY_SOURCE=2
)

set(VICOS_LINKER_FLAGS
    -Wl,--build-id
    -Wl,--warn-shared-textrel
    -Wl,--gc-sections
    -Wl,--allow-multiple-definition
    -Wl,--fix-cortex-a8
    -Wl,-z,noexecstack
    -Wl,-z,relro
    -Wl,-z,now
    -Wl,-rpath-link,${VICOS_SDK}/sysroot/lib
    -Wl,-rpath-link,${VICOS_SDK}/sysroot/usr/lib
)

set(VICOS_LINKER_FLAGS_EXE
    -pie
    -fPIE
)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    list(APPEND VICOS_LINKER_FLAGS_EXE
        -Wl,-rpath-link,${CMAKE_SOURCE_DIR}/_build/vicos/Debug/lib)
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    list(APPEND VICOS_LINKER_FLAGS_EXE
        -Wl,-rpath-link,${CMAKE_SOURCE_DIR}/_build/vicos/Release/lib)
endif()

set(CMAKE_C_STANDARD_LIBRARIES_INIT "-lm -lc -latomic -lpthread")
set(CMAKE_CXX_STANDARD_LIBRARIES_INIT "${CMAKE_C_STANDARD_LIBRARIES_INIT}")

string(REPLACE ";" " " VICOS_COMPILER_FLAGS         "${VICOS_COMPILER_FLAGS}")
string(REPLACE ";" " " VICOS_COMPILER_FLAGS_CXX     "${VICOS_COMPILER_FLAGS_CXX}")
string(REPLACE ";" " " VICOS_COMPILER_FLAGS_DEBUG   "${VICOS_COMPILER_FLAGS_DEBUG}")
string(REPLACE ";" " " VICOS_COMPILER_FLAGS_RELEASE "${VICOS_COMPILER_FLAGS_RELEASE}")
string(REPLACE ";" " " VICOS_LINKER_FLAGS           "${VICOS_LINKER_FLAGS}")
string(REPLACE ";" " " VICOS_LINKER_FLAGS_EXE       "${VICOS_LINKER_FLAGS_EXE}")

set(CMAKE_C_FLAGS             "${VICOS_COMPILER_FLAGS} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS           "${VICOS_COMPILER_FLAGS} ${VICOS_COMPILER_FLAGS_CXX} ${CMAKE_CXX_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG       "${VICOS_COMPILER_FLAGS_DEBUG} ${CMAKE_C_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_DEBUG     "${VICOS_COMPILER_FLAGS_DEBUG} ${CMAKE_CXX_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE     "${VICOS_COMPILER_FLAGS_RELEASE} ${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_RELEASE   "${VICOS_COMPILER_FLAGS_RELEASE} ${CMAKE_CXX_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS "${VICOS_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${VICOS_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS    "${VICOS_LINKER_FLAGS} ${VICOS_LINKER_FLAGS_EXE} ${CMAKE_EXE_LINKER_FLAGS}")

set(CMAKE_SIZEOF_VOID_P 4)

message(STATUS "CMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
message(STATUS "CMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
