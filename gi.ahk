#Include <logging>
#Include <system>
#Include <optparser>
#Include <ansi>
#Include *i %A_ScriptDir%\gi.versioninfo

Main:
	_main := new Logger("app.gi." A_ThisFunc)
	
	global G_lower, G_upper, G_verbose, G_output, G_append, G_host := "LX150W05.viessmann.com", G_help, G_version

	rc := 0

	op := new OptParser("gi [-l|-u] [-v] [-o|-a <file-name>] [-h <ldap-server>] <cn>")
	op.Add(new OptParser.String("h", "host", G_host, "host-name", "Hostname des LDAP-Servers",, G_host, G_host))
	op.Add(new OptParser.Boolean("l", "lower", G_lower, "Ergebnis in Kleinbuchstaben ausgeben"))
	op.Add(new OptParser.Boolean("u", "upper", G_upper, "Ergebnis in Großbuchstaben ausgeben"))
	op.Add(new OptParser.Boolean("v", "verbose", G_verbose, "Verarbeitungsprotokoll ausgeben"))
	op.Add(new OptParser.String("o", "", G_output, "file-name", "In Datei ausgeben"))
	op.Add(new OptParser.String("a", "append", G_append, "file-name", "An vorhandene Datei anhängen"))
	op.Add(new OptParser.Boolean(0, "version", G_version, "Print version info"))
	op.Add(new OptParser.Boolean(0, "help", G_help, "Print help", OptParser.OPT_HIDDEN))

	try {
		args := op.Parse(System.vArgs)

		if (_main.Logs(Logger.Finest)) {
			_main.Finest("G_host", G_host)
			_main.Finest("G_lower", G_lower)
			_main.Finest("G_upper", G_upper)
			_main.Finest("G_verbose", G_verbose)
			_main.Finest("G_output", G_output)
			_main.Finest("G_append", G_append)
			_main.Finest("version", version)
			_main.Finest("help", help)
		}

		if (G_help) {
			Ansi.WriteLine(op.Usage())
			exitapp _main.Return()
		} else if (G_version) {
			Ansi.WriteLine(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD)
			exitapp _main.Return()
		}
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
	}
		
	_main.Exit(rc)
exitapp	rc
