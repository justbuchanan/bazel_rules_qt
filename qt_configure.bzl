def _lookup_env_var(env, name, default = None):
    """Lookup environment variable case-insensitve.

    If a matching (case-insesitive) entry is found in the env dict both
    the key and the value are returned. The returned key might differ from
    name in casing.

    If a matching key was found its value is returned otherwise
    the default is returned.

    Return a (key, value) tuple"""
    for key, value in env.items():
        if name.lower() == key.lower():
            return (key, value)
    return (name, default)

def _get_env_var(repository_ctx, name, default = None):
    """Returns a value from an environment variable."""
    return _lookup_env_var(repository_ctx.os.environ, name, default)[1]

def qt_autoconf_impl(repository_ctx):
    """
    Generate BUILD file with 'local_qt_path' function to get the Qt local path.

    Args:
       repository_ctx: repository context
    """
    os_name = repository_ctx.os.name.lower()
    is_linux_machine = os_name.find("windows") == -1
    if not is_linux_machine:
        # Inside this folder, in Windows you can find include, lib and bin folder
        default_qt_path = "C:\\\\Qt\\\\5.9.9\\\\msvc2017_64\\\\"
    else:
        # In Linux, this is the equivalent to the include folder, the binaries are located in
        # /usr/bin/
        # This would be the path if it has been installed using a package manager
        default_qt_path = "/usr/include/x86_64-linux-gnu/qt5"
        if not repository_ctx.path(default_qt_path).exists:
            default_qt_path = "/usr/include/qt"

    if repository_ctx.path(default_qt_path).exists:
        print("Installation available on the default path: ", default_qt_path)

    qt_path = _get_env_var(repository_ctx, "QT_DIR", default_qt_path)
    if qt_path != default_qt_path:
        print("However QT_DIR is defined and will be used: ", qt_path)
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
