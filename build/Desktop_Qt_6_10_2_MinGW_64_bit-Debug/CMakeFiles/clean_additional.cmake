# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appSpotlightSearch_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appSpotlightSearch_autogen.dir\\ParseCache.txt"
  "appSpotlightSearch_autogen"
  )
endif()
