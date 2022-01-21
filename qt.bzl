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

load("@rules_cc//cc:defs.bzl", "cc_library")

def _gen_ui_header(ctx):
    info = ctx.toolchains["@com_justbuchanan_rules_qt//tools:toolchain_type"].qtinfo
    args = [ctx.file.ui_file.path, "-o", ctx.outputs.ui_header.path]
    ctx.actions.run(
        inputs = [ctx.file.ui_file],
        outputs = [ctx.outputs.ui_header],
        arguments = args,
        executable = info.uic_path,
    )
    return [OutputGroupInfo(ui_header = depset([ctx.outputs.ui_header]))]

gen_ui_header = rule(
    implementation = _gen_ui_header,
    attrs = {
        "ui_file": attr.label(allow_single_file = True, mandatory = True),
        "ui_header": attr.output(),
    },
    toolchains = ["@com_justbuchanan_rules_qt//tools:toolchain_type"],
)

def qt_ui_library(name, ui, deps, **kwargs):
    """Compiles a QT UI file and makes a library for it.

    Args:
      name: A name for the rule.
      src: The ui file to compile.
      deps: cc_library dependencies for the library.
    """
    gen_ui_header(
        name = "%s_uic" % name,
        ui_file = ui,
        ui_header = "ui_%s.h" % ui.split(".")[0],
    )
    cc_library(
        name = name,
        hdrs = [":%s_uic" % name],
        deps = deps,
        **kwargs
    )

def _gencpp(ctx):
    info = ctx.toolchains["@com_justbuchanan_rules_qt//tools:toolchain_type"].qtinfo

    resource_files = [(f, ctx.actions.declare_file(f.path)) for f in ctx.files.files]
    for target_file, output in resource_files:
        ctx.actions.symlink(
            output = output,
            target_file = target_file,
        )

    args = ["--name", ctx.attr.resource_name, "--output", ctx.outputs.cpp.path, ctx.file.qrc.path]
    ctx.actions.run(
        inputs = [resource for _, resource in resource_files] + [ctx.file.qrc],
        outputs = [ctx.outputs.cpp],
        arguments = args,
        executable = info.rcc_path,
    )
    return [OutputGroupInfo(cpp = depset([ctx.outputs.cpp]))]

gencpp = rule(
    implementation = _gencpp,
    attrs = {
        "resource_name": attr.string(),
        "files": attr.label_list(allow_files = True, mandatory = False),
        "qrc": attr.label(allow_single_file = True, mandatory = True),
        "cpp": attr.output(),
    },
    toolchains = ["@com_justbuchanan_rules_qt//tools:toolchain_type"],
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
    gencpp(
        name = name + "_gen",
        resource_name = rsrc_name,
        files = files,
        qrc = qrc_file,
        cpp = outfile,
    )
    cc_library(
        name = name,
        srcs = [outfile],
        alwayslink = 1,
        **kwargs
    )

def qt_cc_library(name, srcs, hdrs, normal_hdrs = [], deps = None, **kwargs):
    """Compiles a QT library and generates the MOC for it.

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
            cmd = select({
                "@platforms//os:linux": "moc $(location %s) -o $@ -f'%s'" % (hdr, header_path),
                "@platforms//os:windows": "$(location @qt//:moc) $(locations %s) -o $@ -f'%s'" % (hdr, header_path),
                "@platforms//os:osx": "moc $(location %s) -o $@ -f'%s'" % (hdr, header_path),
            }),
            tools = select({
                "@platforms//os:linux": [],
                "@platforms//os:windows": ["@qt//:moc"],
                "@platforms//os:osx": [],
            }),
        )
        _moc_srcs.append(":" + moc_name)
    cc_library(
        name = name,
        srcs = srcs + _moc_srcs,
        hdrs = hdrs + normal_hdrs,
        deps = deps,
        **kwargs
    )
