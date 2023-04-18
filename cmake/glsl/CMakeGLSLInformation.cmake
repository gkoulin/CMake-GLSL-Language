# Load compiler-specific information.
if(CMAKE_GLSL_COMPILER_ID)
    include(Compiler/${CMAKE_GLSL_COMPILER_ID}-GLSL OPTIONAL)

    if(CMAKE_SYSTEM_PROCESSOR)
        include(
            Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_GLSL_COMPILER_ID}-GLSL-${CMAKE_SYSTEM_PROCESSOR}
            OPTIONAL)
    endif()

    include(Platform/${CMAKE_EFFECTIVE_SYSTEM_NAME}-${CMAKE_GLSL_COMPILER_ID}-GLSL OPTIONAL)
endif()

include(CMakeCommonLanguageInclude)

#[[
now define the following rules:
CMAKE_GLSL_CREATE_SHARED_LIBRARY
CMAKE_GLSL_CREATE_SHARED_MODULE
CMAKE_GLSL_ARCHIVE_CREATE
CMAKE_GLSL_ARCHIVE_APPEND
CMAKE_GLSL_ARCHIVE_FINISH
CMAKE_GLSL_COMPILE_OBJECT
#]]

# Create a static archive incrementally for large object file counts. For now just do no-op. In the
# future we might want to zip .spirv objects or something
if(NOT DEFINED CMAKE_GLSL_ARCHIVE_CREATE)
    # No-op command
    set(CMAKE_GLSL_ARCHIVE_CREATE "cd .")
endif()

if(NOT DEFINED CMAKE_GLSL_ARCHIVE_APPEND)
    # No-op command
    set(CMAKE_GLSL_ARCHIVE_APPEND "cd .")
endif()

if(NOT DEFINED CMAKE_GLSL_ARCHIVE_FINISH)
    # No-op command
    set(CMAKE_GLSL_ARCHIVE_FINISH "cd .")
endif()

# Compile objects.
if(NOT CMAKE_GLSL_COMPILE_OBJECT)
    set(CMAKE_GLSL_COMPILE_OBJECT
        "<CMAKE_GLSL_COMPILER> ${_CMAKE_GLSL_EXTRA_FLAGS} <DEFINES> <INCLUDES> <FLAGS> ${_CMAKE_COMPILE_AS_GLSL_FLAG} -o <OBJECT> <SOURCE>"
    )
endif()

set(CMAKE_GLSL_INFORMATION_LOADED 1)
