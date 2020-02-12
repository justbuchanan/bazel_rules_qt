load("//:qt.bzl", "qt_resource")

qt_resource(
    name = "resources",
    files = [
        "file1.txt",
        "subdir/file2.txt",
    ],
)

cc_binary(
    name = "main",
    srcs = ["main.cc"],
    deps = [
        ":resources",
        "@qt//:qt_core",
    ],
)
