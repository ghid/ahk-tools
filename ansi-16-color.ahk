; ahk: console
#NoEnv
#Warn All, StdOut

#Include <cui-libs>

main() {
	fgs := [  39
			, 30, 90
			, 31, 91
			, 32, 92
			, 33, 93
			, 34, 94
			, 35, 95
			, 36, 96
			, 37, 97 ]

	bgs := [  49
			, 40, 100
			, 41, 101
			, 42, 102
			, 43, 103
			, 44, 104
			, 45, 105
			, 46, 106
			, 47, 107 ]
	text := " xxx "

	Ansi.write(Format("{:4s} | ", ""))
	for _, bg in bgs {
		Ansi.write(Format(" {:-4s} ", bg))
	}
	Ansi.writeLine()

	loop 5 {
		Ansi.write("─")
	}
	Ansi.write("┼")

	loop % 1+StrLen(text)*bgs.count()+(bgs.count()-1) {
		Ansi.write("─")
	}
	Ansi.writeLine()

	for _, fg in fgs {
		Ansi.write(Format("{:4s} │ ", fg))
		for _, bg in bgs {
			Ansi.write(Format("[{:s}m[{:s}m{:s}[0m ", bg, fg, text))
		}
		Ansi.writeLine()
	}
}

main()
