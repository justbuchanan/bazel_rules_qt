load("//:qt.bzl", "qt_resource")

qt_resource(
    name = "resources",
    files = [
        "file1.txt",
        "subdir/file2.txt",
    ],
)

# TODO(justbuchanan): refactor this into a cc_test
# For now, test with:
#   bazel run //tests/qt_resource:main
cc_binary(
    name = "main",
    srcs = ["main.cc"],
    deps = [
        ":resources",
        "@qt//:qt_core",
    ],
)
