workspace(name = "com_justbuchanan_rules_qt")

load("@com_justbuchanan_rules_qt//:qt_configure.bzl", "qt_configure")

qt_configure()

load("@local_config_qt//:local_qt.bzl", "local_qt_path")

new_local_repository(
    name = "qt",
    build_file = "@com_justbuchanan_rules_qt//:qt.BUILD",
    path = local_qt_path(),
)

register_toolchains(
    "//tools:qt_linux_toolchain",
    "//tools:qt_windows_toolchain",
)
