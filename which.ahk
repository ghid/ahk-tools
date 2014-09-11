#NoEnv

G_VERSION_INFO := {NAME: "AHK which version ß", ARCH: "generic", BUILD: "n/a"}

#Include <logging>
#Include <console>
#Include <optparser>
#Include <system>
#Include *i %A_ScriptDir%\which.versioninfo

Main:
	_main := new Logger("app.which.Main")
	
	RC := ""

	op := new OptParser("which [options] <programname> [programname...]")
	op.Add(new OptParser.Group("Options:"))
	op.Add(new OptParser.Boolean("v", "version", G_version, "Print version and exit successfully"))
	op.Add(new OptParser.Boolean("h", "help", G_help, "Print this help and exit successfully"))

	try {
		progs := op.Parse(System.vArgs)

		if (_main.Logs(Logger.Finest)) {
			_main.Finest("G_version", G_version)
			_main.Finest("G_help", G_help)
		}

		if (G_version) {
			Console.Write(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD ", Copyright (C) 2014 K.-P. Schreiner.`n")
			exitapp _main.Exit(0x00)
		} else if (G_help) {
			Console.Write(op.Usage() "`n")
			exitapp _main.Exit(0xff)
		}

		if (!progs.MaxIndex()) {
			throw Exception("",, -1)
			exitapp _main.Exit(255)
		}

		RC := which(progs)
	} catch _ex {
		if (_ex.Message)
			Console.Write(_ex.Message "`n")
		Console.Write(op.Usage() "`n")

		RC := _ex.Extra
	}

exitapp _main.Exit(RC)

which(progs) {
	_log := new Logger("app.which." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("progs", progs)
		if (_log.Logs(Logger.All)) {
			_log.All("progs:`n" LoggingHelper.Dump(progs))
		}
	}
	
	static default_exts := ["", ".COM", ".EXE", ".BAT", ".CMD"]

	failed := 0

	EnvGet path, PATH
	path_list := StrSplit(path, ";")
	path_list.Insert(1, ".")
	if (_log.Logs(Logger.Finest)) {
		_log.Finest("path", path)
		_log.Finest("path_list:`n" LoggingHelper.Dump(path_list))
	}

__loop_progs__:
	loop % progs.MaxIndex() {
		prog := progs[A_Index]
		SplitPath prog, file_name, file_dir, file_ext
		if (_log.Logs(Logger.Finest)) {
			_log.Finest("prog", prog)
			_log.Finest("file_name", file_name)
			_log.Finest("file_dir", file_dir)
			_log.Finest("file_ext", file_ext)
		}
		if (file_dir) {
			found := ""
			loop % default_exts.MaxIndex() {
				search_prog := prog default_exts[A_Index]
				if (check_file(search_prog))
					break __loop_progs__
			}
			not_found(prog, path, failed)
		} else {
			loop % path_list.MaxIndex() {
				search_path := path_list[A_Index]
				loop % default_exts.MaxIndex() {
					search_prog := search_path "\" prog default_exts[A_Index]
					if (check_file(search_prog))
						break __loop_progs__
				}
			}
			not_found(prog, path, failed)
		}
	}

	return _log.Exit(failed)
}

check_file(file_name) {
	_log := new Logger("app.which." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("file_name", file_name)
	}

	if (RegExMatch(FileExist(file_name), "[RASHNOCT]")) {
		Console.Write(file_name "`n")
		return _log.Exit(true)
	}
	
	return _log.Exit(false)
}

not_found(prog, path, ByRef failed = 0) {
	_log := new Logger("app.which." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("prog", prog)
		_log.Input("path", path)
		_log.Input("failed", failed)
	}
	
	if (_log.Logs(Logger.Output)) {
		_log.Output("failed", failed)
	}

	Console.Write(A_ScriptName ": no " prog " in (" path ")`n")
	failed++

	return _log.Exit()
}
