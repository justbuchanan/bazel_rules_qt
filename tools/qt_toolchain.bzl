QtToolsInfo = provider(
    doc = "Information about how to invoke qt tools.",
    fields = ["rcc_path", "uic_path", "moc_path"],
)

def _qt_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        qtinfo = QtToolsInfo(
            rcc_path = ctx.attr.rcc_path,
            uic_path = ctx.attr.uic_path,
            moc_path = ctx.attr.moc_path,
        ),
    )
    return [toolchain_info]

qt_toolchain = rule(
    implementation = _qt_toolchain_impl,
    attrs = {
        "rcc_path": attr.string(),
        "uic_path": attr.string(),
        "moc_path": attr.string(),
    },
)
