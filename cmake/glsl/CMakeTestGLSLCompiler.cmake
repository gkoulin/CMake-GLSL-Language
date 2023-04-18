if(CMAKE_GLSL_COMPILER_FORCED)
    # The compiler configuration was forced by the user. Assume the user has configured all compiler
    # information.
    set(CMAKE_GLSL_COMPILER_WORKS TRUE)
    return()
endif()

include(CMakeTestCompilerCommon)

# Remove any cached result from an older CMake version. We now store this in
# CMakeGLSLCompiler.cmake.
unset(CMAKE_GLSL_COMPILER_WORKS CACHE)

# This file is used by EnableLanguage in cmGlobalGenerator to determine that the selected compiler
# can actually compile and link the most basic of programs. If not, a fatal error is set and cmake
# stops processing commands and will not generate any makefiles or projects.
if(NOT CMAKE_GLSL_COMPILER_WORKS)
    PrintTestCompilerStatus("GLSL")
    string(
        CONCAT __TestCompiler_testGLSLCompilerSource
               "#version 450\n"
               "void main()\n"
               "{\n"
               "   uint gID = gl_GlobalInvocationID.x\;\n"
               "}\n")
    file(WRITE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/main.glsl.comp
         ${__TestCompiler_testGLSLCompilerSource})
    unset(__TestCompiler_testGLSLCompilerSource)

    # Clear result from normal variable.
    unset(CMAKE_GLSL_COMPILER_WORKS)

    # Make sure we try to compile as a STATIC_LIBRARY
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
    __testcompiler_settrycompiletargettype()

    # Puts test result in cache variable.
    try_compile(
        CMAKE_GLSL_COMPILER_WORKS ${CMAKE_BINARY_DIR}
        ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/main.glsl.comp
        OUTPUT_VARIABLE __CMAKE_GLSL_COMPILER_OUTPUT)
    # Move result from cache to normal variable.
    set(CMAKE_GLSL_COMPILER_WORKS ${CMAKE_GLSL_COMPILER_WORKS})
    unset(CMAKE_GLSL_COMPILER_WORKS CACHE)
    set(GLSL_TEST_WAS_RUN 1)

    __testcompiler_restoretrycompiletargettype()
endif()

if(NOT CMAKE_GLSL_COMPILER_WORKS)
    printtestcompilerresult(CHECK_FAIL "broken")
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
         "Determining if the GLSL compiler works failed with "
         "the following output:\n${__CMAKE_GLSL_COMPILER_OUTPUT}\n\n")
    string(REPLACE "\n" "\n  " _output "${__CMAKE_GLSL_COMPILER_OUTPUT}")
    message(
        FATAL_ERROR
            "The GLSL compiler\n  \"${CMAKE_GLSL_COMPILER}\"\n"
            "is not able to compile a simple test program.\nIt fails "
            "with the following output:\n  ${_output}\n\n"
            "CMake will not be able to correctly generate this project.")
else()
    if(GLSL_TEST_WAS_RUN)
        printtestcompilerresult(CHECK_PASS "works")
        file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
             "Determining if the GLSL compiler works passed with "
             "the following output:\n${__CMAKE_GLSL_COMPILER_OUTPUT}\n\n")
    endif()

    # Unlike C and CXX we do not yet detect any information about the GLSL ABI. However, one of the
    # steps done for C and CXX as part of that detection is to initialize the implicit include
    # directories. That is relevant here.
    set(CMAKE_GLSL_IMPLICIT_INCLUDE_DIRECTORIES "${_CMAKE_GLSL_IMPLICIT_INCLUDE_DIRECTORIES_INIT}")

    # Re-configure to save learned information.
    configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeGLSLCompiler.cmake.in
                   ${CMAKE_PLATFORM_INFO_DIR}/CMakeGLSLCompiler.cmake @ONLY)
    include(${CMAKE_PLATFORM_INFO_DIR}/CMakeGLSLCompiler.cmake)
endif()

unset(__CMAKE_GLSL_COMPILER_OUTPUT)
