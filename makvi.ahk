;@Ahk2Exe-ConsoleApp
class MakVi {

    static options = MakVi.SetDefaults()

    SetDefaults() {
        return { arch: 64
            , h: false
            , v: false
            , appname: ""
            , version: "" }
    }

    Cli() {
        op := new OptParser("makvi [-x=< 86 | 64 >] <appname> <version> [build]")
        op.Add(new OptParser.String("x", "", MakVi.options, "arch", "86|64"
            , "generate version info for x86 or x64 architecture (default is 64)"
            , OptParser.OPT_ARG,, MakVi.options.arch))
        op.Add(new OptParser.Line("build", ["e.g. ""git rev-parse --short HEAD"""
            , "or   ""cmd /c echo Alpha"""
            , "Default will be a timestamp"]))
        op.Add(new OptParser.Group("Example:`n"
            . "`t#Include myVersionInfoClassFile`n"
            . "`t...`n"
            . "`tabout() {`n"
            . "`t`treturn [1mVersion.Info[0m`n"
            . "`t}"))
        op.Add(new OptParser.Boolean("h", "help", MakVi.options, "h"
            , "Help usage"
            , OptParser.OPT_HIDDEN))
        op.Add(new OptParser.Boolean("v", "version", MakVi.options, "v"
            , "Version info"
            , OptParser.OPT_HIDDEN))

        return op
    }

    Run(args) {
        try {
            op := MakVi.Cli()
            args := op.Parse(args)

            MakVi.options.appname := Arrays.Shift(args)
            MakVi.options.version := Arrays.Shift(args)
            MakVi.options.build := Arrays.Shift(args)

            if (MakVi.options.h) {
                Ansi.WriteLine(op.Usage())
            } else if (MakVi.options.v) {
                Ansi.WriteLine(Version.Info)
            } else {
                if (MakVi.options.appname = "")
                    throw Exception("error: missing argument 'appname'")

                if (MakVi.options.version = "")
                    throw Exception("error: missing argument 'version'")

                if (MakVi.options.Build = "")
                    FormatTime build,, yyyyMMdd_HHmmss
                else
                    build := RegExReplace(System.runProcess(MakVi.options.Build), "[\n\r]*$", "")
                MakVi.options.build := build

                if (Arrays.Shift(args))
                    throw Exception("error: invalid argument(s)")
                Ansi.writeLine(MakVi.generateVersionClass(MakVi.options.appname
                    , MakVi.options.version, MakVi.options.arch
                    , MakVi.options.build)) 
            }
        } catch _ex {
            Ansi.WriteLine(_ex.Message)
            Ansi.WriteLine(op.Usage())
        }

        return
    }

    generateVersionClass(appName, version, arch, build) {
        return "class Version {`n  Info {`n    get {`n"
                . Format("      return ""AHK {:s} version {:s}/x{:s}-{:s}"""
                , appName, version, arch, build)
                . "`n    }`n  }`n}"
    }
}

#NoEnv                                          ; NOTEST-BEGIN
#Include <ansi>
#Include <optparser>
#Include <string>
#Include <system>
#Include <arrays>
#Include *i %A_ScriptDir%\makvi.versioninfo

Main:
exitapp MakVi.Run(System.vArgs)     ; NOTEST-END
