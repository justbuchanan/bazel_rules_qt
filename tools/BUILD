package(default_visibility = ["//visibility:public"])

load(":qt_toolchain.bzl", "qt_toolchain")

toolchain_type(name = "toolchain_type")

qt_toolchain(
    name = "qt_linux",
    # TODO: determine paths in qt_configure.bzl
    moc_path = "/usr/bin/moc",
    rcc_path = "/usr/bin/rcc",
    uic_path = "/usr/bin/uic",
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
