# Bazel rules for Qt

These bazel rules and BUILD targets make it easy to use Qt from C++ projects built with bazel.

## Usage

You can either copy the qt.BUILD and qt.bzl files into your project or if you're using git, add this project as a submodule.

Configure your WORKSPACE to include the qt libraries:

```
# WORKSPACE

new_local_repository(
    name = "qt",
    build_file = "bazel_rules_qt/qt.BUILD",
    path = "/usr/include/qt", # May need configuring for your installation
)
```

Use the build rules provided by qt.bzl to build your project. See qt.bzl for which rules are available.

```
# BUILD

load("@//bazel_rules_qt:qt.bzl", "qt_cc_library")

qt_cc_library(
    name = "MyWidget",
    src = "MyWidget.cc",
    hdr = "MyWidget.h",
    deps = ["@qt//:qt_widgets"],
)

cc_binary(
    name = "main",
    srcs = ["main.cpp"],
    copts = ["-fpic"],
    deps = [
        "@qt//:qt_widgets",
        ":MyWidget",
    ],
)
```

## Credits

This is a fork of https://github.com/bbreslauer/qt-bazel-example with many modifications.
