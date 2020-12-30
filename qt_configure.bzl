def qt_autoconf_impl(repository_ctx):
    """
    Generate BUILD file with 'local_qt_path' function to get the Qt local path.

    Args:
       repository_ctx: repository context
    """
    os_name = repository_ctx.os.name.lower()
    qt_path = "dummy"
    if os_name.find("windows") != -1:
        qt_path = "C:\\\\Qt\\\\5.9.9\\\\msvc2017_64\\\\"
    else:
        qt_path = "/usr/include/x86_64-linux-gnu/qt5"
    repository_ctx.file("BUILD", "# empty BUILD file so that bazel sees this as a valid package directory")
    repository_ctx.template(
        "local_qt.bzl",
        repository_ctx.path(Label("//:BUILD.local_qt.tpl")),
        {"%{path}": qt_path},
    )

qt_autoconf = repository_rule(
    implementation = qt_autoconf_impl,
    configure = True,
)

def qt_configure():
    qt_autoconf(name = "local_config_qt")
