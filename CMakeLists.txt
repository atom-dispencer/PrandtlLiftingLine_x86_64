cmake_minimum_required(VERSION 3.16)
project(prandtl_lifting_line_x86_64 LANGUAGES C ASM)

enable_language(ASM)

set(CMAKE_ASM_SOURCE_FILE_EXTENSIONS S)

set(SOURCES
    pll.S
)

add_executable(prandtl_lifting_line ${SOURCES})
target_link_libraries(prandtl_lifting_line -static-libgcc)
