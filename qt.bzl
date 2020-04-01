#
# Copyright 2020 Justin Buchanan
# Copyright 2016 Ben Breslauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
    qrc_output = ctx.outputs.qrc
    qrc_content = "<RCC>\n  <qresource prefix=\\\"/\\\">"
    for f in ctx.files.files:
        qrc_content += "\n    <file>%s</file>" % f.path
    qrc_content += "\n  </qresource>\n</RCC>"
    cmd = ["echo", "\"%s\"" % qrc_content, ">", qrc_output.path]
    ctx.actions.run_shell(
        command = " ".join(cmd),
        outputs = [qrc_output],
    )
    return [OutputGroupInfo(qrc = depset([qrc_output]))]

genqrc = rule(
    implementation = _genqrc,
    attrs = {
        "files": attr.label_list(allow_files = True, mandatory = True),
        "qrc": attr.output(),
    },
)

def qt_resource(name, files, **kwargs):
    """Creates a cc_library containing the contents of all input files using qt's `rcc` tool.

    Args:
      name: rule name
      files: a list of files to be included in the resource bundle
      kwargs: extra args to pass to the cc_library
    """
    qrc_file = name + "_qrc.qrc"
    genqrc(name = name + "_qrc", files = files, qrc = qrc_file)

    # every resource cc_library that is linked into the same binary needs a
    # unique 'name'.
    rsrc_name = native.package_name().replace("/", "_") + "_" + name

    outfile = name + "_gen.cpp"
    native.genrule(
        name = name + "_gen",
        srcs = [qrc_file] + files,
        outs = [outfile],
        cmd = "cp $(location %s) . && rcc --name %s --output $(OUTS) %s" % (qrc_file, rsrc_name, qrc_file),
    )
    native.cc_library(
        name = name,
        srcs = [outfile],
        alwayslink = 1,
        **kwargs
    )

def qt_cc_library(name, srcs, hdrs, normal_hdrs = [], deps = None, **kwargs):
    """Compiles a QT library and generates the MOC for it.

    If a UI file is provided, then it is also compiled with UIC.

    Args:
      name: A name for the rule.
      srcs: The cpp files to compile.
      hdrs: The header files that the MOC compiles to src.
      normal_hdrs: Headers which are not sources for generated code.
      deps: cc_library dependencies for the library.
      kwargs: Any additional arguments are passed to the cc_library rule.
    """
    _moc_srcs = []
    for hdr in hdrs:
        header_path = "%s/%s" % (native.package_name(), hdr) if len(native.package_name()) > 0 else hdr
        moc_name = "%s_moc" % hdr.replace(".", "_")
        native.genrule(
            name = moc_name,
            srcs = [hdr],
            outs = [moc_name + ".cc"],
            cmd = "moc $(location %s) -o $@ -f'%s'" %
                  (hdr, header_path),
        )
        _moc_srcs += [":" + moc_name]

    native.cc_library(
        name = name,
        srcs = srcs + _moc_srcs,
        hdrs = hdrs + normal_hdrs,
        deps = deps,
        **kwargs
    )
