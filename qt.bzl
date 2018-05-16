def qt_ui_library(name, ui, deps):
  """Compiles a QT UI file and makes a library for it.

  Args:
    name: A name for the rule.
    src: The ui file to compile.
    deps: cc_library dependencies for the library.
  """
  native.genrule(
      name = "%s_uic" % name,
      srcs = [ui],
      outs = ["ui_%s.h" % ui.split('.')[0]],
      cmd = "uic $(locations %s) -o $@" % ui,
  )

  native.cc_library(
      name = name,
      hdrs = [":%s_uic" % name],
      deps = deps,
  )

# Turns a .qrc file into a cc_library.
# Note that deps must be listed explicitly because bazel doesn't allow reading
# files at analysis time
def qt_resource(name, qrc_file, deps):
  outfile = name + "_gen.cpp"
  native.genrule(
    name = name + "_gen",
    srcs = [qrc_file] + deps,
    outs = [outfile],
    cmd = "rcc --name $(OUTS) --output $(OUTS) $(location %s)" % qrc_file,
  )

  native.cc_library(
    name = name,
    srcs = [outfile],
    alwayslink = 1,
  )

def qt_cc_library(name, src, hdr, normal_hdrs=[], deps=None, **kwargs):
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
  header_path = '%s/%s' % (PACKAGE_NAME, hdr) if len(PACKAGE_NAME) > 0  else hdr
  native.genrule(
      name = "%s_moc" % name,
      srcs = [hdr],
      outs = ["moc_%s.cpp" % name],
      cmd =  "moc $(location %s) -o $@ -f'%s'" \
        % (hdr, header_path),
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
