Circle CI (Linux) | AppVeyor (Windows)
:---: | :---:
[![ci status](https://circleci.com/gh/justbuchanan/bazel_rules_qt.png?circle-token=9077bf6ecc5554e3ddbdc4d3947784460eb1df72)](https://app.circleci.com/pipelines/github/justbuchanan/bazel_rules_qt?branch=master) | [![ci status](https://ci.appveyor.com/api/projects/status/<replace_for_project_id>/branch/master?svg=true)](https://ci.appveyor.com/project/justbuchanan/bazel-rules-qt/branch/master)

# Bazel rules for Qt

These bazel rules and BUILD targets make it easy to use Qt from C++ projects built with bazel.

Note that unlike many libraries used through bazel, qt is dynamically linked, meaning that the qt-dependent programs you build with bazel will use the qt libraries installed by the system package manager. Thus the users of your programs will also need to install qt.

## Platform support

This project currently only works on Linux, although eventually I'd like it to support Windows and Mac OS X as well.

## Usage

You can either copy the qt.BUILD and qt.bzl files into your project, add this project as a submodule if you're using git or use a git_repository rule to fetch the rules.

Configure your WORKSPACE to include the qt libraries:

```python
# WORKSPACE

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

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
