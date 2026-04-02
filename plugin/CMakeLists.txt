cmake_minimum_required(VERSION 3.16)
project(amigainfothumbnail)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 REQUIRED COMPONENTS Core Gui)
find_package(KF5 REQUIRED COMPONENTS KIO CoreAddons)

kcoreaddons_add_plugin(amigainfothumbnail SOURCES amigainfothumbnail.cpp INSTALL_NAMESPACE "kf5/thumbcreator")
target_link_libraries(amigainfothumbnail PRIVATE Qt5::Core Qt5::Gui KF5::KIOGui)
