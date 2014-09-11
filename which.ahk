#NoEnv

G_VERSION_INFO := {NAME: "AHK which version ß", ARCH: "generic", BUILD: "n/a"}

#Include <logging>
#Include <console>
#Include <optparser>
#Include <system>
#Include *i %A_ScriptDir%\which.versioninfo

Main:
	RC := ""

	op := new OptParser("which [options] <programname> [programname...]")
	op.Add(new OptParser.Group("Options:"))
	op.Add(new OptParser.Boolean("v", "version", G_version, "Print version and exit successfully"))
	op.Add(new OptParser.Boolean("h", "help", G_help, "Print this help and exit successfully"))

	try {
		progs := op.Parse(System.vArgs)

		if (G_version) {
			Console.Write(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD ", Copyright (C) 2014 K.-P. Schreiner.`n")
			exitapp 0x00
		} else if (G_help) {
			Console.Write(op.Usage() "`n")
			exitapp 0xff
		}

		if (!progs.MaxIndex()) {
			throw Exception("",, -1)
			exitapp 255
		}

		RC := which(progs)
	} catch _ex {
		if (_ex.Message)
			Console.Write(_ex.Message "`n")
		Console.Write(op.Usage() "`n")

		RC := _ex.Extra
	}
exitapp RC

which(progs) {
	static default_exts := ["", ".COM", ".EXE", ".BAT", ".CMD"]

	failed := 0

	EnvGet path, PATH
	path_list := StrSplit(path, ";")
	path_list.Insert(1, ".")
__loop_progs__:
	loop % progs.MaxIndex() {
		prog := progs[A_Index]
		SplitPath prog, file_name, file_dir, file_ext
		if (file_dir) {
			found := ""
			loop % default_exts.MaxIndex() {
				search_prog := prog default_exts[A_Index]
				if (RegExMatch(FileExist(search_prog), "[RASHNOCT]")) {
					Console.Write(search_prog "`n")
					break __loop_progs__
				}
			}
			Console.Write(A_ScriptName ": no " prog " in (" file_dir ")`n")
			failed++
		} else {
			loop % path_list.MaxIndex() {
				search_path := path_list[A_Index]
				loop % default_exts.MaxIndex() {
					search_prog := search_path "\" prog default_exts[A_Index]
					if (RegExMatch(FileExist(search_prog), "[RASHNOCT]")) {
						Console.Write(search_prog "`n")
						break __loop_progs__
					}
				}
			}
			Console.Write(A_ScriptName ": no " prog " in (" path ")`n")
			failed++
		}
	}

	return failed
}
