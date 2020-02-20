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
    deps = [":qt_core", ":qt_gui"],
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
        ":qt_qml",
        ":qt_qml_models",
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
    name = "qt_qml_models",
    linkopts = [
        "-lQt5QmlModels",
    ],
    hdrs = glob(
        ["QtQmlModels/**"],
    ),
    includes = ["."],
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

cc_library(
    name = "qt_opengl",
    hdrs = glob(["QtOpenGL/**"]),
    includes = ["."],
    linkopts = ["-lQt5OpenGL"],
)

cc_library(
    name = "qt_3d",
    hdrs = glob([
        "Qt3DAnimation/**",
        "Qt3DCore/**",
        "Qt3DExtras/**",
        "Qt3DInput/**",
        "Qt3DLogic/**",
        "Qt3DQuick/**",
        "Qt3DQuickAnimation/**",
        "Qt3DQuickExtras/**",
        "Qt3DQuickInput/**",
        "Qt3DQuickRender/**",
        "Qt3DQuickScene2D/**",
        "Qt3DRender/**",
    ]),
    includes = ["."],
    linkopts = [
        "-lQt53DAnimation",
        "-lQt53DCore",
        "-lQt53DExtras",
        "-lQt53DInput",
        "-lQt53DLogic",
        "-lQt53DQuick",
        "-lQt53DQuickAnimation",
        "-lQt53DQuickExtras",
        "-lQt53DQuickInput",
        "-lQt53DQuickRender",
        "-lQt53DQuickScene2D",
        "-lQt53DRender",
    ],
)
