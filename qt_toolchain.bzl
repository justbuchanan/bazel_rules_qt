QtSDK = provider(
    doc = "Contains information about the Qt SDK used in the toolchain",
    fields = {
        "qt_include_path": "Path where the Qt include files are located",
        "qt_lib_path": "Path where the Qt libraries are located",
        "rcc_path": "Path where the rcc binary is located",
        "moc_path": "Path where the moc binary is located",
        "uic_path": "Path where the uic binary is located",
    },
)

def _qt_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        qt_sdk = QtSDK(
            qt_include_path = ctx.attr.qt_include_path,
            qt_lib_path = ctx.attr.qt_lib_path,
            rcc_path = ctx.attr.rcc_path,
            moc_path = ctx.attr.moc_path,
            uic_path = ctx.attr.uic_path,
        ),
    )
    return [toolchain_info]

qt_toolchain = repository_rule(
    implementation = _qt_toolchain_impl,
    attrs = {
        "qt_include_path": attr.string(),
        "qt_lib_path": attr.string(),
        "rcc_path": attr.string(),
        "moc_path": attr.string(),
        "uic_path": attr.string(),
    },
)

def declare_windows_toolchain():
    toolchain_name = "qt_windows_amd64"
    toolchain_impl_name = toolchain_name + "_impl"
    qt_toolchain(
        name = toolchain_impl_name,
        tags = ["manual"],
    )
    native.toolchain(
        name = toolchain_name,
        exec_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        toolchain = ":" + toolchain_impl_name,
    )

def declare_linux_toolchain():
    toolchain_name = "qt_linux_amd64"
    toolchain_impl_name = toolchain_name + "_impl"
    qt_toolchain(
        name = toolchain_impl_name,
    )
    native.toolchain(
        name = toolchain_name,
        exec_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        toolchain = ":" + toolchain_impl_name,
    )

def declare_toolchains():
    declare_linux_toolchain()
    declare_windows_toolchain()
    native.register_toolchains(":qt_linux_amd64", ":qt_windows_amd64")
