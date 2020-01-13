; ahk: console
#Warn all, StdOut

; @todo Define main project class
class Sun {

	requires() {
		return [Ansi, OptParser, String]
	}
	
	class Options {
		static n1 := 0
		static n2 := 0
		static help := false
	}

	; @todo Add neccessary methods
	add() {
		if (!System.typeOf(Sun.Options.n1, "number")) {
			throw Exception("Add: n1 is not a number: " Sun.Options.n1)
		}
		if (!System.typeOf(Sun.Options.n2, "number")) {
			throw Exception("Add: n2 is not a number: " Sun.Options.n2)
		}
		return Sun.Options.n1 "+" Sun.Options.n2
				. "=" (Sun.Options.n1 + Sun.Options.n2)
	}

	; @todo 'cli' method to create the CLI
	cli() {
		op := new OptParser("Sun: --lat=x.x --lon=x.x --rise --set [--date=YYYYMMDD]")
		op.add(new OptParser.String(0, "lat"
				, Sun.Options, "latitude", "decimal-degrees"
				, "Latitude", OptParser.OPT_ARGREQ))
		op.add(new OptParser.String(0, "lon"
				, Sun.Options, "longitude", "decimal-degrees"
				, "Longitude", OptParser.OPT_ARGREQ))
		op.add(new OptParser.Boolean("r", "rise"
				, Sun.Options, "sunrise"
				, "Print sunrise"))
		op.add(new OptParser.Boolean("s", "set"
				, Sun.Options, "sunset"
				, "Print sunset"))
		op.add(new OptParser.String(0, "date"
				, Sun.Options, "date", "YYYYMMDD"
				, "Use date for calculation"))
		op.add(new OptParser.Callback("o", "operation"
				, Sun.Options, "operation"
				, "Operations", "operation"
				, ["Define which operation to be performed:"
				, ". add: perform addition"
				, ". sub: perform substraction"] , OptParser.OPT_ARG))
		op.add(new OptParser.String(0, "n1"
				, Sun.Options, "n1", "value-1"
				, "The first value for the calculation"))
		op.add(new OptParser.String(0, "n2"
				, Sun.Options, "n2", "value-2"
				, "The second value for the calculation"))
		op.add(new OptParser.Boolean("h", "help"
				, Sun.Options, "help"
				, "Display usage", OptParser.OPT_HIDDEN))
		return op
	}

	; @todo 'run' method to parse and process cli options
	run(args) {
		try {
			rc := 1
			op := Sun.cli()
			args := op.parse(args)
			if (Sun.Options.help) {
				Ansi.writeLine(op.usage())
				rc := ""
			} else if (!Sun.Options.operation) {
				throw Exception("Specify an operation")
			} else if (Sun.Options.operation = "add") {
				Ansi.writeLine(Sun.add())
			} else {
				throw Exception("Unimplemented operation: "
						. Sun.Options.operation)
			}
		} catch e {
			Ansi.writeLine(e.message)
			Ansi.writeLine(op.usage())
			rc := 0
		}
		return rc
	}
}

; @todo Define other functions (e.g. callback functions for parser)
operations(aValue) {
	if (RegExMatch(aValue, "i)^(add|sub)$", $)) {
		return $
	} else {
		throw Exception("Invalid operation: " aValue)
	}
}

; @todo Add #Directives - not testable code til exitapp...
#NoEnv ; notest-begin
#Include <app>
#Include <lib2>
#Include <structure>

#Include <modules\structure\CONSOLE_SCREEN_BUFFER_INFO>
#Include <modules\structure\COORD>
#Include <modules\structure\SMALL_RECT>

; @todo Implement main routine
Main:
exitapp App.checkRequiredClasses(Sun).run(A_Args) ; notest-end
