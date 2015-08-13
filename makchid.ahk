#Include <logging>
#Include <ansi>
#Include <optparser>
#Include <system>
#Include <calendar>
#Include <string>
#Include *i %A_ScriptDir%\makchid.versioninfo

Main:
	_main := new Logger("app.makchid." A_ThisFunc)

	global G_arch, G_appname, G_version, G_v

	G_arch := 64
	
	op := new OptParser("makchid")
	op.Add(new OptParser.Boolean("v", "version", G_v, "Version info", OptParser.OPT_HIDDEN))
	
	try {
		args := op.Parse(System.vArgs)

		if (_main.Logs(Logger.Finest)) {
			_main.Finest("G_v", G_v)
		}

		if (G_v) {
			Ansi.WriteLine(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD)
			exitapp _main.Exit()
		}

		cal := new Calendar()
		nsecs0 := new Calendar(A_YYYY A_MM A_DD).Compare(cal, Calendar.UNITS.MINUTES)
		cid := (A_YYYY).SubStr(-1) "-" (cal.Julian() nsecs0).AsHex(String.ASHEX_UPPER|String.ASHEX_NOPREFIX, 5)

		Ansi.WriteLine(cid)
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
	}

exitapp _main.Exit()

