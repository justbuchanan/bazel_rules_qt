package(default_visibility = ["//visibility:public"])

load(":qt_toolchain.bzl", "qt_toolchain")
load("@local_config_qt//:local_qt.bzl", "local_qt_bin_dir")

toolchain_type(name = "toolchain_type")

qt_toolchain(
    name = "qt_linux",
    # TODO: determine paths in qt_configure.bzl
    moc_path = local_qt_bin_dir() + "/moc",
    rcc_path = local_qt_bin_dir() + "/rcc",
    uic_path = local_qt_bin_dir() + "/uic",
)

qt_toolchain(
    name = "qt_windows",
    # TODO: determine paths in qt_configure.bzl
    moc_path = "moc",
    rcc_path = "rcc",
    uic_path = "uic",
)

toolchain(
    name = "qt_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":qt_linux",
    toolchain_type = "@com_justbuchanan_rules_qt//tools:toolchain_type",
)

toolchain(
    name = "qt_windows_toolchain",
    exec_compatible_with = [
        "@platforms//os:windows",
    ],
    target_compatible_with = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":qt_windows",
    toolchain_type = "@com_justbuchanan_rules_qt//tools:toolchain_type",
)
