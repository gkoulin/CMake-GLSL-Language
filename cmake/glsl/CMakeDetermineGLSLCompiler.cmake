include(${CMAKE_ROOT}/Modules/CMakeDetermineCompiler.cmake)

# Local system-specific compiler preferences for this language.
include(Platform/${CMAKE_SYSTEM_NAME}-Determine-GLSL OPTIONAL)
include(Platform/${CMAKE_SYSTEM_NAME}-GLSL OPTIONAL)

if(NOT CMAKE_GLSL_COMPILER_NAMES)
    set(CMAKE_GLSL_COMPILER_NAMES glslc)
endif()

# Only supporting Ninja CMake Generator.
if("${CMAKE_GENERATOR}" MATCHES "^Ninja")
    if(CMAKE_GLSL_COMPILER)
        _cmake_find_compiler_path(GLSL)
    else()
        set(CMAKE_GLSL_COMPILER_INIT NOTFOUND)

        if(NOT $ENV{GLSLC} STREQUAL "")
            get_filename_component(
                CMAKE_GLSL_COMPILER_INIT
                $ENV{GLSLC}
                PROGRAM
                PROGRAM_ARGS
                CMAKE_GLSL_FLAGS_ENV_INIT)

            if(CMAKE_GLSL_FLAGS_ENV_INIT)
                set(CMAKE_GLSL_COMPILER_ARG1
                    "${CMAKE_GLSL_FLAGS_ENV_INIT}"
                    CACHE STRING "Arguments to the GLSL compiler")
            endif()

            if(NOT EXISTS ${CMAKE_GLSL_COMPILER_INIT})
                message(FATAL_ERROR "Could not find compiler set in environment variable GLSLC"
                                    "\n$ENV{GLSLC}." "\n${CMAKE_GLSL_COMPILER_INIT}")
            endif()
        endif()

        if(NOT CMAKE_GLSL_COMPILER_INIT)
            set(CMAKE_GLSL_COMPILER_LIST GLSL ${_CMAKE_TOOLCHAIN_PREFIX}GLSL)
        endif()

        _cmake_find_compiler(GLSL)
    endif()

    mark_as_advanced(CMAKE_GLSL_COMPILER)
else()
    message(FATAL_ERROR "GLSL language not supported by \"${CMAKE_GENERATOR}\" generator")
endif()

# Identify the compiler.
if(NOT CMAKE_GLSL_COMPILER_ID_RUN)
    set(CMAKE_GLSL_COMPILER_ID_RUN 1)

    execute_process(
        COMMAND "${CMAKE_GLSL_COMPILER}" --version
        OUTPUT_VARIABLE _output
        ERROR_VARIABLE _output
        RESULT_VARIABLE result
        TIMEOUT 10)

    # Try to identify the compiler.
    if(_output MATCHES [[(.*) GLSL version ([0-9]+\.[0-9]+(\.[0-9]+)?)]])
        set(CMAKE_GLSL_COMPILER_ID "${CMAKE_MATCH_1}")
        set(CMAKE_GLSL_COMPILER_VERSION "${CMAKE_MATCH_2}")
    endif()

    unset(_output)
endif()

if(NOT _CMAKE_TOOLCHAIN_LOCATION)
    get_filename_component(_CMAKE_TOOLCHAIN_LOCATION "${CMAKE_GLSL_COMPILER}" PATH)
endif()

set(_CMAKE_PROCESSING_LANGUAGE "GLSL")
include(CMakeFindBinUtils)
unset(_CMAKE_PROCESSING_LANGUAGE)

# configure variables set in this file for fast reload later on
configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeGLSLCompiler.cmake.in
               ${CMAKE_PLATFORM_INFO_DIR}/CMakeGLSLCompiler.cmake @ONLY)

set(CMAKE_GLSL_COMPILER_ENV_VAR "GLSLC")
