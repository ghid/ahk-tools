#Include <logging>
#Include <ansi>
#Include <optparser>
#Include <system>
#Include <arrays>
#Include *i %A_ScriptDir%\makvi.versioninfo

Main:
	_main := new Logger("app.makvi." A_ThisFunc)

	global G_arch, G_appname, G_version, G_v

	G_arch := 64
	
	op := new OptParser("makvi [-x=< 86 | 64 >] <appname> <version>")
	op.Add(new OptParser.String("x", "", G_arch, "86|64", "generate version info for x86 or x64 architecture (default is 64)", OptParser.OPT_ARG,, G_arch))
	op.Add(new OptParser.Boolean("v", "version", G_v, "Version info", OptParser.OPT_HIDDEN))
	
	try {
		args := op.Parse(System.vArgs)

		op.TrimArg(G_arch)

		G_appname := Arrays.Shift(args)
		G_version := Arrays.Shift(args)

		if (_main.Logs(Logger.Finest)) {
			_main.Finest("G_arch", G_arch)
			_main.Finest("G_appname", G_appname)
			_main.Finest("G_version", G_version)
			_main.Finest("G_v", G_v)
		}

		if (G_v) {
			Ansi.WriteLine(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD)
			exitapp _main.Return()
		}

		if (G_appname = "")
			throw Exception("error: missing argument 'appname'")

		if (G_version = "")
			throw Exception("error: missing argument 'version'")	

		if (Arrays.Shift(args))
			throw Exception("error: invalid argument(s)")

		FormatTime build_time,, yyyyMMdd_HHmmss
		Ansi.WriteLine("G_VERSION_INFO := {NAME: ""AHK " G_appname " version " G_version """, ARCH: ""x" G_arch """, BUILD: """ build_time """}")
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
	}

exitapp _main.Exit()

