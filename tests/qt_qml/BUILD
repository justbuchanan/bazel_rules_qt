load("//:qt.bzl", "qt_resource")

# simple demo binary that shows how to use qml
cc_binary(
    name = "main",
    srcs = ["main.cc"],
    deps = [
        ":main_qrc",
        "@qt//:qt_qml",
        "@qt//:qt_quick",
        "@qt//:qt_widgets",
    ],
)

qt_resource(
    name = "main_qrc",
    files = [
        "main.qml",
    ],
)
