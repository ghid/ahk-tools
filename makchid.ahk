; ahk: console
#Include <logging>
#Include <ansi>
#Include <optparser\optparser>
#Include <system>
#Include <calendar\calendar>
#Include <string>
#Include *i %A_ScriptDir%\makchid.versioninfo

class Opt {
	arch := "64"
	appname := ""
	version := ""
	v := false
}

Main:
	_main := new Logger("app.makchid." A_ThisFunc)

	op := new OptParser("makchid")
	op.add(new OptParser.Boolean("v", "version", Opt, "v", "Version info", OptParser.OPT_HIDDEN))
	
	try {
		args := op.parse(System.vArgs)

		if (_main.Logs(Logger.Finest)) {
			_main.Finest("Opt:`n" LoggingHelper.dump(Opt))
		}

		if (Opt.v) {
			Ansi.writeLine(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD)
			exitapp _main.Exit()
		}

		cal := new Calendar()
		nsecs0 := new Calendar(A_YYYY A_MM A_DD).compare(cal, Calendar.UNITS.MINUTES)
		cid := SubStr(cal.asYear(), -1) "-" (cal.asJulian() nsecs0).asHex(String.ASHEX_UPPER|String.ASHEX_NOPREFIX, 5)

		Ansi.writeLine(cid)
	} catch _ex {
		Ansi.writeLine(_ex.message)
		Ansi.writeLine(op.usage())
	}

exitapp _main.Exit()

