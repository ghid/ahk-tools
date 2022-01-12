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
        op := new OptParser("makvi [-x=< 86 | 64 >] <appname> <version> <build>")
        op.Add(new OptParser.String("x", "", MakVi.options, "arch", "86|64"
            , "generate version info for x86 or x64 architecture (default is 64)"
            , OptParser.OPT_ARG,, MakVi.options.arch))
        op.Add(new OptParser.Boolean("h", "help", MakVi.options, "h"
            , "Help usage"
            , OptParser.OPT_HIDDEN))
        op.Add(new OptParser.Boolean("v", "version", MakVi.options, "v"
            , "Version info"
            , OptParser.OPT_HIDDEN))
        op.Add(new OptParser.Line("<build>", ["e.g. ""git rev-parse --short HEAD"""
            , "or   ""cmd /c echo Alpha"""
            , "Default will be a timestamp"]))
        op.Add(new OptParser.Group("Example:`n"
            . "`tabout() {`n"
            . "`t`tglobal G_VERSION_INFO`n`n"
            . "`t`tversion_info := G_VERSION_INFO.NAME`n"
            . "`t`t`t . ""/""  G_VERSION_INFO.ARCH`n"
            . "`t`t`t . ""-b"" G_VERSION_INFO.BUILD`n"
            . "`t}"))

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
                #Include *i %A_ScriptDir%\makvi.versioninfo
                Ansi.WriteLine(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD)
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

                Ansi.WriteLine("G_VERSION_INFO := {NAME: ""AHK " MakVi.options.appname " version " MakVi.options.version """, ARCH: ""x" MakVi.options.arch """, BUILD: """ MakVi.options.build """}")
            }
        } catch _ex {
            Ansi.WriteLine(_ex.Message)
            Ansi.WriteLine(op.Usage())
        }

        return
    }
}

#NoEnv                                          ; NOTEST-BEGIN
#Include <ansi>
#Include <optparser>
#Include <system>
#Include <arrays>

Main:
exitapp MakVi.Run(System.vArgs)     ; NOTEST-END

