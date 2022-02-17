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
    is_linux_machine = False
    if os_name.find("windows") != -1:
        # Inside this folder, in Windows you can find include, lib and bin folder
        default_qt_path = "C:\\\\Qt\\\\5.9.9\\\\msvc2017_64\\\\"
        # If predefined path does not exist search for an alternative e.g. "C:\\\\Qt\\\\5.12.10\\\\msvc2017_64\\\\"
        if not repository_ctx.path(default_qt_path).exists:
            win_path_env = _get_env_var(repository_ctx, "PATH")
            start_index = win_path_env.index("C:\\Qt\\5.")
            end_index = win_path_env.index("msvc2017_64\\", start_index) + len("msvc2017_64")
            default_qt_path = win_path_env[start_index:end_index+1]
            default_qt_path = default_qt_path.replace('\\', "\\\\")
    elif os_name.find("linux") != -1:
        is_linux_machine = True

        # In Linux, this is the equivalent to the include folder, the binaries are located in
        # /usr/bin/
        # This would be the path if it has been installed using a package manager
        default_qt_path = "/usr/include/x86_64-linux-gnu/qt5"
        if not repository_ctx.path(default_qt_path).exists:
            default_qt_path = "/usr/include/qt"
    elif os_name.find("mac") != -1:
        # assume Qt was installed using `brew install qt@5`
        default_qt_path = "/usr/local/opt/qt5"
    else:
        fail("Unsupported OS: %s" % os_name)

    if repository_ctx.path(default_qt_path).exists:
        print("Installation available on the default path: ", default_qt_path)

    qt_path = _get_env_var(repository_ctx, "BAZEL_RULES_QT_DIR", default_qt_path)
    if qt_path != default_qt_path:
        print("However BAZEL_RULES_QT_DIR is defined and will be used: ", qt_path)

        # In Linux in case that we have a standalone installation, we need to provide the path inside the include folder
        qt_path_with_include = qt_path + "/include"
        if is_linux_machine and repository_ctx.path(qt_path_with_include).exists:
            qt_path = qt_path_with_include
   
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
