cmake_minimum_required(VERSION 3.16)

project(Trinode 
    VERSION 1.0.0 
    DESCRIPTION "A minimalist Spotlight-style search for Windows"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Optimization for Release builds
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    if(MSVC)
        add_compile_options(/O2 /GL /MD)
        add_link_options(/LTCG /INCREMENTAL:NO /OPT:REF /OPT:ICF)
    else()
        add_compile_options(-O3 -flto)
        add_link_options(-flto)
    endif()
endif()

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets Gui)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appTrinode
    main.cpp
    backend.cpp
    backend.h
)

qt_add_qml_module(appTrinode
    URI Trinode
    QML_FILES
        Main.qml
    RESOURCES
        assets/search.svg
        assets/return.svg
        assets/logo.png
)

set_target_properties(appTrinode PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

# Icon for Windows
if(WIN32)
    set(APP_ICON_RESOURCE "${CMAKE_CURRENT_SOURCE_DIR}/assets/logo.png")
    # In a real scenario, you'd convert this to .ico or use a .rc file
endif()

target_link_libraries(appTrinode
    PRIVATE Qt6::Quick Qt6::Widgets Qt6::Gui
)

include(GNUInstallDirs)
install(TARGETS appTrinode
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
