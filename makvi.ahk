#Include <logging>
#Include <ansi>
#Include <optparser>
#Include <system>
#Include <arrays>

Main:
	_main := new Logger("app.makvi." A_ThisFunc)

	global G_arch, G_appname, G_version

	G_arch := 64
	
	op := new OptParser("makvi [-x=< 86 | 64 >] <appname> <version>")
	op.Add(new OptParser.String("x", "", G_arch, "86|64", "generate version info for x86 or x64 architecture (default is 64)", OptParser.OPT_ARG,, G_arch))
	
	try {
		args := op.Parse(System.vArgs)

		if (args.MaxIndex() <> 2)
			throw Exception("error: missing or invalid argument(s)")

		op.TrimArg(G_arch)

		G_appname := Arrays.Shift(args)
		G_version := Arrays.Shift(args)

		if (_main.Logs(Logger.Finest)) {
			_main.Finest("G_arch", G_arch)
			_main.Finest("G_appname", G_appname)
			_main.Finest("G_version", G_version)
		}

		FormatTime build_time,, yyyyMMdd_HHmmss
		Ansi.WriteLine("G_VERSION_INFO := {NAME: ""AHK " G_appname " version " G_version """, ARCH: ""x" G_arch """, BUILD: """ build_time """}")
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
	}

exitapp _main.Exit()

