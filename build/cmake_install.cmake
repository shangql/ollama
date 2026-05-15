# Install script for directory: /Users/sql/GitHub/ollama

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/Users/sql/GitHub/ollama/dist/darwin-amd64")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/sql/GitHub/ollama/build/ml/backend/ggml/ggml/src/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-base.0.0.0.dylib;/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-base.0.dylib")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE SHARED_LIBRARY FILES
    "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-base.0.0.0.dylib"
    "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-base.0.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-base.0.0.0.dylib"
      "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-base.0.dylib"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/usr/bin/strip" -x "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-base.dylib")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE SHARED_LIBRARY FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-base.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-x64.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-x64.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-x64.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-x64.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-x64.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sse42.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-sse42.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sse42.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sse42.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sse42.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sandybridge.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-sandybridge.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sandybridge.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sandybridge.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sandybridge.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-ivybridge.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-ivybridge.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-ivybridge.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-ivybridge.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-ivybridge.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-piledriver.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-piledriver.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-piledriver.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-piledriver.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-piledriver.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-haswell.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-haswell.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-haswell.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-haswell.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-haswell.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-skylakex.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-skylakex.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-skylakex.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-skylakex.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-skylakex.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cannonlake.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-cannonlake.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cannonlake.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cannonlake.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cannonlake.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cascadelake.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-cascadelake.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cascadelake.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cascadelake.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cascadelake.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-icelake.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-icelake.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-icelake.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-icelake.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-icelake.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cooperlake.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-cooperlake.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cooperlake.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cooperlake.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-cooperlake.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-zen4.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-zen4.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-zen4.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-zen4.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-zen4.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-alderlake.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-alderlake.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-alderlake.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-alderlake.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-alderlake.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sapphirerapids.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-sapphirerapids.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sapphirerapids.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sapphirerapids.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-cpu-sapphirerapids.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  file(GET_RUNTIME_DEPENDENCIES
    RESOLVED_DEPENDENCIES_VAR _CMAKE_DEPS
    LIBRARIES
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-base.dylib"
    MODULES
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-x64.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-sse42.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-sandybridge.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-ivybridge.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-piledriver.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-haswell.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-skylakex.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-cannonlake.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-cascadelake.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-icelake.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-cooperlake.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-zen4.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-alderlake.so"
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-cpu-sapphirerapids.so"
    PRE_EXCLUDE_REGEXES
      ".*"
    POST_EXCLUDE_FILES_STRICT
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-base.dylib"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(_CMAKE_TMP_dep IN LISTS _CMAKE_DEPS)
    if(NOT _CMAKE_TMP_dep MATCHES "\\.framework/")
      foreach(_cmake_abs_file IN LISTS _CMAKE_TMP_dep)
        get_filename_component(_cmake_abs_file_name "${_cmake_abs_file}" NAME)
        list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/${_cmake_abs_file_name}")
      endforeach()
      unset(_cmake_abs_file_name)
      unset(_cmake_abs_file)
      if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE SHARED_LIBRARY FILES ${_CMAKE_TMP_dep}
        FOLLOW_SYMLINK_CHAIN)
      get_filename_component(_CMAKE_TMP_dep_name "${_CMAKE_TMP_dep}" NAME)
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "CPU" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(_CMAKE_TMP_dep IN LISTS _CMAKE_DEPS)
    if(_CMAKE_TMP_dep MATCHES "^(.*/)?([^/]*\\.framework)/(.*)$")
      set(_CMAKE_TMP_dir "${CMAKE_MATCH_1}")
      set(_CMAKE_TMP_name "${CMAKE_MATCH_2}")
      set(_CMAKE_TMP_file "${CMAKE_MATCH_3}")
      set(_CMAKE_TMP_path "${_CMAKE_TMP_dir}${_CMAKE_TMP_name}")
      foreach(_cmake_abs_file IN LISTS _CMAKE_TMP_path)
        get_filename_component(_cmake_abs_file_name "${_cmake_abs_file}" NAME)
        list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/${_cmake_abs_file_name}")
      endforeach()
      unset(_cmake_abs_file_name)
      unset(_cmake_abs_file)
      if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE DIRECTORY FILES ${_CMAKE_TMP_path}
        USE_SOURCE_PERMISSIONS)
    endif()
  endforeach()
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/Users/sql/GitHub/ollama/build/ml/backend/ggml/ggml/src/ggml-vulkan/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Vulkan" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-vulkan.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE MODULE FILES "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-vulkan.so")
  if(EXISTS "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-vulkan.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-vulkan.so")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -x "$ENV{DESTDIR}/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libggml-vulkan.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Vulkan" OR NOT CMAKE_INSTALL_COMPONENT)
  file(GET_RUNTIME_DEPENDENCIES
    RESOLVED_DEPENDENCIES_VAR _CMAKE_DEPS
    MODULES
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-vulkan.so"
    PRE_INCLUDE_REGEXES
      "vulkan"
    PRE_EXCLUDE_REGEXES
      ".*"
    POST_EXCLUDE_FILES_STRICT
      "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-base.dylib"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Vulkan" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(_CMAKE_TMP_dep IN LISTS _CMAKE_DEPS)
    if(NOT _CMAKE_TMP_dep MATCHES "\\.framework/")
      foreach(_cmake_abs_file IN LISTS _CMAKE_TMP_dep)
        get_filename_component(_cmake_abs_file_name "${_cmake_abs_file}" NAME)
        list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/${_cmake_abs_file_name}")
      endforeach()
      unset(_cmake_abs_file_name)
      unset(_cmake_abs_file)
      if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE SHARED_LIBRARY FILES ${_CMAKE_TMP_dep}
        FOLLOW_SYMLINK_CHAIN)
      get_filename_component(_CMAKE_TMP_dep_name "${_CMAKE_TMP_dep}" NAME)
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Vulkan" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(_CMAKE_TMP_dep IN LISTS _CMAKE_DEPS)
    if(_CMAKE_TMP_dep MATCHES "^(.*/)?([^/]*\\.framework)/(.*)$")
      set(_CMAKE_TMP_dir "${CMAKE_MATCH_1}")
      set(_CMAKE_TMP_name "${CMAKE_MATCH_2}")
      set(_CMAKE_TMP_file "${CMAKE_MATCH_3}")
      set(_CMAKE_TMP_path "${_CMAKE_TMP_dir}${_CMAKE_TMP_name}")
      foreach(_cmake_abs_file IN LISTS _CMAKE_TMP_path)
        get_filename_component(_cmake_abs_file_name "${_cmake_abs_file}" NAME)
        list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/${_cmake_abs_file_name}")
      endforeach()
      unset(_cmake_abs_file_name)
      unset(_cmake_abs_file)
      if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
      endif()
      file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE DIRECTORY FILES ${_CMAKE_TMP_path}
        USE_SOURCE_PERMISSIONS)
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Vulkan" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan/libMoltenVK.dylib")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/vulkan" TYPE FILE FILES "/Users/sql/GitHub/ollama/build/moltenvk-sdk/dynamic/dylib/macOS/libMoltenVK.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Go" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE PROGRAM FILES "/Users/sql/GitHub/ollama/build/lib/ollama/ollama")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Go" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE PROGRAM FILES "/Users/sql/GitHub/ollama/build/lib/ollama/ollama-runner")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Go" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/bin/ollama")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/bin" TYPE PROGRAM FILES "/Users/sql/GitHub/ollama/build/lib/ollama/ollama")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Go" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama/ollama-runner")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/lib/ollama" TYPE PROGRAM FILES "/Users/sql/GitHub/ollama/build/lib/ollama/ollama-runner")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Go" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/Users/sql/GitHub/ollama/dist/darwin-amd64/bin/libMoltenVK.dylib;/Users/sql/GitHub/ollama/dist/darwin-amd64/bin/libggml-base.0.0.0.dylib")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/Users/sql/GitHub/ollama/dist/darwin-amd64/bin" TYPE FILE FILES
    "/Users/sql/GitHub/ollama/build/moltenvk-sdk/dynamic/dylib/macOS/libMoltenVK.dylib"
    "/Users/sql/GitHub/ollama/build/lib/ollama/libggml-base.0.0.0.dylib"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Go" OR NOT CMAKE_INSTALL_COMPONENT)
  
        set(_bin "${CMAKE_INSTALL_PREFIX}/bin")
        execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
            "libggml-base.0.0.0.dylib" "libggml-base.dylib"
            WORKING_DIRECTORY "${_bin}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
            "libggml-base.0.0.0.dylib" "libggml-base.0.dylib"
            WORKING_DIRECTORY "${_bin}")
    
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/sql/GitHub/ollama/build/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/sql/GitHub/ollama/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
