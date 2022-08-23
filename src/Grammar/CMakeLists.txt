find_package(FLEX 2.6 REQUIRED)
find_package(BISON 3.5 REQUIRED)

set(FLEX_INPUT ${CMAKE_CURRENT_SOURCE_DIR}/scanner.l)
set(FLEX_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/scanner.cpp)
set(FLEX_DEFINE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/scanner.hpp)


set(BISON_INPUT ${CMAKE_CURRENT_SOURCE_DIR}/parser.y)
set(BISON_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/parser.cpp)
set(BISON_DEFINE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/parser.hpp)

IF(FLEX_FOUND)
flex_target(SCANNER   # Name 
            "${FLEX_INPUT}"
            "${FLEX_OUTPUT}"
            DEFINES_FILE "${FLEX_DEFINE_FILE}"
            )
ENDIF()

IF(BISON_FOUND)
bison_target(PARSER
            "${BISON_INPUT}"
            "${BISON_OUTPUT}"
            DEFINES_FILE "${BISON_DEFINE_FILE}"
            )
ENDIF()

add_flex_bison_dependency(SCANNER PARSER)

add_library(grammar "${FLEX_OUTPUT}" "${BISON_OUTPUT}")
target_include_directories(grammar PRIVATE

                            )