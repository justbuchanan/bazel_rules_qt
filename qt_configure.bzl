def _get_env_var(repository_ctx, name, default = None):
    """Returns a value from an environment variable."""
    for key, value in repository_ctx.os.environ.items():
        if name == key:
            return value
    return default

def qt_autoconf_impl(repository_ctx):
    """
    Generate BUILD file with 'local_qt_path' function to get the Qt local path.

    Args:
       repository_ctx: repository context
    """
    os_name = repository_ctx.os.name.lower()
    if os_name.find("windows") == -1 and os_name.find("linux") == -1:
        fail("Unsupported OS: %s" % os_name)
    is_linux_machine = os_name.find("windows") == -1

    # Location of the different Qt artifacts on Linux system installed standalone as well as Windows
    # Qt includes
    # <location>/include
    #
    # Qt libraries
    # <location>/lib
    #
    # uic, rcc, moc
    # <location>/bin

    # Location of the different Qt artifacts on Linux system installed with apt
    # Qt includes
    # /usr/include/x86_64-linux-gnu/qt5
    #
    # Qt libraries
    # /lib/x86_64-linux-gnu/
    # /usr/lib/x86_64-linux-gnu/
    #
    # uic, rcc, moc
    # /usr/bin/

    # If QT_DIR is defined and it exists, we consider that it is a standalone installation
    # Only in the case that is linux and QT_DIR is not defined it is considerd a none standalone
    # installation
    qt_dir_path = _get_env_var(repository_ctx, "QT_DIR", None)
    is_standalone = qt_dir_path != None and repository_ctx.path(qt_dir_path).exists
    if not is_linux_machine:
        # Inside this folder, in Windows you can find include, lib and bin folder
        default_qt_path = "C:\\\\Qt\\\\5.9.9\\\\msvc2017_64\\\\"
        qt_prefix = default_qt_path
        if is_standalone:
            qt_prefix = qt_dir_path
        qt_includes = qt_prefix + "\\\\include"
        qt_libs = qt_prefix + "\\\\lib"
        qt_bins = qt_prefix + "\\\\bin"
    else:
        if is_standalone:
            qt_prefix = qt_dir_path
            qt_includes = qt_prefix + "/include"
            qt_libs = qt_prefix + "/lib"
            qt_bins = qt_prefix + "/bin"
        else:
            default_qt_include_path = "/usr/include/x86_64-linux-gnu/qt5"
            if repository_ctx.path(default_qt_include_path).exists:
                qt_includes = default_qt_include_path
            else:
                qt_includes = "/usr/include/qt"
            qt_libs = "/lib/x86_64-linux-gnu/"
            qt_bins = "/usr/bin/"

    print("Qt installation found in:")
    print("Qt includes: ", qt_includes)
    print("Qt libs: ", qt_libs)
    print("Qt bins: ", qt_bins)

    repository_ctx.file("BUILD", "# empty BUILD file so that bazel sees this as a valid package directory")
    repository_ctx.template(
        "local_qt.bzl",
        repository_ctx.path(Label("//:BUILD.local_qt.tpl")),
        {"%{path}": qt_includes},
    )

qt_autoconf = repository_rule(
    implementation = qt_autoconf_impl,
    configure = True,
)

def qt_configure():
    qt_autoconf(name = "local_config_qt")
