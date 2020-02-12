def qt_ui_library(name, ui, deps, **kwargs):
    """Compiles a QT UI file and makes a library for it.

    Args:
      name: A name for the rule.
      src: The ui file to compile.
      deps: cc_library dependencies for the library.
    """
    native.genrule(
        name = "%s_uic" % name,
        srcs = [ui],
        outs = ["ui_%s.h" % ui.split(".")[0]],
        cmd = "uic $(locations %s) -o $@" % ui,
    )

    native.cc_library(
        name = name,
        hdrs = [":%s_uic" % name],
        deps = deps,
        **kwargs
    )

# generate a qrc file that lists each of the input files.
def _genqrc(ctx):
    qrc_content = "<RCC>\n  <qresource prefix=\\\"/\\\">"
    for f in ctx.files.files:
        qrc_content += "\n    <file>%s</file>" % f.path
    qrc_content += "\n  </qresource>\n</RCC>"
    cmd = ["echo", "\"%s\"" % qrc_content, ">", ctx.outputs.qrc.path]
    ctx.actions.run_shell(
        command = " ".join(cmd),
        outputs = [ctx.outputs.qrc],
    )

genqrc = rule(
    implementation = _genqrc,
    attrs = {
        "files": attr.label_list(allow_files = True, mandatory = True),
    },
    outputs = {"qrc": "%{name}.qrc"},
)

def qt_resource(name, files, **kwargs):
    """Creates a cc_library containing the contents of all input files using qt's `rcc` tool.

    Args:
      name: rule name
      files: a list of files to be included in the resource bundle
      kwargs: extra args to pass to the cc_library
    """
    qrc_file = name + "_qrc.qrc"
    genqrc(name = name + "_qrc", files = files)

    outfile = name + "_gen.cpp"
    native.genrule(
        name = name + "_gen",
        srcs = [qrc_file] + files,
        outs = [outfile],
        cmd = "cp $(location %s) . && rcc --name %s --output $(OUTS) %s" % (qrc_file, qrc_file, qrc_file),
    )
    native.cc_library(
        name = name,
        srcs = [outfile],
        alwayslink = 1,
        **kwargs
    )

def qt_cc_library(name, src, hdr, normal_hdrs = [], deps = None, **kwargs):
    """Compiles a QT library and generates the MOC for it.

    If a UI file is provided, then it is also compiled with UIC.

    Args:
      name: A name for the rule.
      src: The cpp file to compile.
      hdr: The single header file that the MOC compiles to src.
      normal_hdrs: Headers which are not sources for generated code.
      deps: cc_library dependencies for the library.
      ui: If provided, a UI file to compile with UIC.
      ui_deps: Dependencies for the UI file.
      kwargs: Any additional arguments are passed to the cc_library rule.
    """
    header_path = "%s/%s" % (native.package_name(), hdr) if len(native.package_name()) > 0 else hdr
    native.genrule(
        name = "%s_moc" % name,
        srcs = [hdr],
        outs = ["moc_%s.cpp" % name],
        cmd = "moc $(location %s) -o $@ -f'%s'" %
              (hdr, header_path),
    )
    srcs = [src, ":%s_moc" % name]

    hdrs = [hdr] + normal_hdrs

    native.cc_library(
        name = name,
        srcs = srcs,
        hdrs = hdrs,
        deps = deps,
        **kwargs
    )
