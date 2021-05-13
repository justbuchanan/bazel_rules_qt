|                                                                                                 Circle CI (Linux)                                                                                                  |                                                                               AppVeyor (Windows)                                                                               |                                                                 Bazel CI                                                                 |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------: |
| [![ci status](https://circleci.com/gh/justbuchanan/bazel_rules_qt.png?circle-token=9077bf6ecc5554e3ddbdc4d3947784460eb1df72)](https://app.circleci.com/pipelines/github/justbuchanan/bazel_rules_qt?branch=master) | [![ci status](https://ci.appveyor.com/api/projects/status/3klljux2otuk69u2/branch/master?svg=true)](https://ci.appveyor.com/project/justbuchanan/bazel-rules-qt/branch/master) | [![ci status](https://badge.buildkite.com/a1033836f9522e389316105837b79c67e5a749c23ba62cdc20.svg)](https://buildkite.com/bazel/rules-qt) |

# Bazel rules for Qt

These bazel rules and BUILD targets make it easy to use Qt from C++ projects built with bazel.

Note that unlike many libraries used through bazel, it requires Qt to be installed when building the application.
Also keep in mind that this rules only allow to link Qt dynamically.
In addition in the case of Linux it also requires Qt to be installed on the system when running it.
For Windows, it is not needed to have Qt installed in the system to run your program. The needed dll files are copied to the output folder to make it self contained. However qt is still dynamically linked.

## Platform support

This project currently only works on Linux and Windows, eventually Mac OS X might be supported as well.

## Usage

You can either copy the qt.BUILD and qt.bzl files into your project, add this project as a submodule if you're using git or use a git_repository rule to fetch the rules.

Configure your WORKSPACE to include the qt libraries:

```python
# WORKSPACE

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@com_justbuchanan_rules_qt//tools:qt_toolchain.bzl", "register_qt_toolchains")

git_repository(
    name = "com_justbuchanan_rules_qt",
    remote = "https://github.com/justbuchanan/bazel_rules_qt.git",
    branch = "master",
)

new_local_repository(
    name = "qt",
    build_file = "@com_justbuchanan_rules_qt//:qt.BUILD",
    path = "/usr/include/qt", # May need configuring for your installation
    # For Qt5 on Ubuntu 16.04
    # path = "/usr/include/x86_64-linux-gnu/qt5/"
)

register_qt_toolchains()
```

Use the build rules provided by qt.bzl to build your project. See qt.bzl for which rules are available.

```python
# BUILD

load("@com_justbuchanan_rules_qt//:qt.bzl", "qt_cc_library", "qt_ui_library")

qt_cc_library(
    name = "MyWidget",
    srcs = ["MyWidget.cc"],
    hdrs = ["MyWidget.h"],
    deps = ["@qt//:qt_widgets"],
)

qt_ui_library(
    name = "mainwindow",
    ui = "mainwindow.ui",
    deps = ["@qt//:qt_widgets"],
)

cc_binary(
    name = "main",
    srcs = ["main.cpp"],
    copts = ["-fpic"],
    deps = [
        "@qt//:qt_widgets",
        ":MyWidget",
        ":mainwindow",
    ],
)
```

## Credits

This is a fork of https://github.com/bbreslauer/qt-bazel-example with many modifications.
