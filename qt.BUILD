package(default_visibility = ["//visibility:public"])

cc_library(
    name = "qt_core",
    hdrs = glob(["QtCore/**"]),
    includes = ["."],
    linkopts = [
        "-lQt5Core",
    ],
)

cc_library(
    name = "qt_network",
    hdrs = glob(["QtNetwork/**"]),
    includes = ["."],
    linkopts = [
        "-lQt5Network",
    ],
)

cc_library(
    name = "qt_widgets",
    hdrs = glob(["QtWidgets/**"]),
    includes = ["."],
    linkopts = [
        "-lQt5Widgets",
    ],
    deps = [":qt_core"],
)

cc_library(
    name = "qt_quick",
    hdrs = glob(["QtQuick/**"]),
    includes = ["."],
    linkopts = [
        "-lQt5Quick",
    ],
    deps = [
        ":qt_gui",
    ],
)

cc_library(
    name = "qt_qml",
    hdrs = glob(["QtQml/**"]),
    includes = ["."],
    linkopts = [
        "-lQt5Qml",
    ],
    deps = [
        ":qt_core",
        ":qt_network",
    ],
)

cc_library(
    name = "qt_gui",
    hdrs = glob(["QtGui/**"]),
    includes = ["."],
    linkopts = [
        "-lQt5Gui",
    ],
    deps = [":qt_core"],
)
