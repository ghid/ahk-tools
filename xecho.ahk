; ahk: console
class XEcho {

	requires() {
		return [Ansi, OptParser]
	}

	static options := XEcho.setDefaults()

	setDefaults() {
		return { new_line: false
				, reset: true
				, help: false
				, prompt: false
				, concealed: false
				, ansi_disabled: false
				, disable_ansi: false
				, default: false
				, enc: "cp850" }
	}

	cli() {
		op := new OptParser(["xecho [-n] [-r] [-e <enc>] <string> [<string>...]"
				, "xecho -p [-c] [-D]"],, "XECHO_OPTIONS")
		op.add(new OptParser.Boolean("n", "new-line", XEcho.options
				, "new_line"
				, "Append a new line character"))
		op.add(new OptParser.Boolean("r", "reset", XEcho.options
				, "reset"
				, "Turn all attributes off after writing the string (default)"
				, OptParser.OPT_NEG|OptParser.OPT_NEG_USAGE, true))
		op.add(new OptParser.String("e", "encoding", XEcho.options
				, "enc", "code-page"
				, "Specify a code page (cpnnn)"))
		op.add(new OptParser.Boolean("p", "prompt", XEcho.options
				, "prompt"
				, "Read from standard input"))
		op.add(new OptParser.Boolean("c", "concealed", XEcho.options
				, "concealed"
				, "Concealed input (e.g. for passwords)"))
		op.add(new OptParser.String("D", "default", XEcho.options
				, "default", "default-value"
				, "Default value to return if nothing entered while prompted"))
		op.add(new OptParser.String(0, "debug", XEcho.options
				, "debug", "debug-message"
				, "Write debug output"))
		op.add(new OptParser.Boolean(0, "is-ansi-disabled", XEcho.options
				, "ansi_disabled"
				, "Show if the DISABLE_ANSI is set"))
		op.add(new OptParser.Boolean(0, "disable-ansi", XEcho.options
				, "disable_ansi"
				, "Disable the Ansi feature by setting DISABLE_ANSI env var"
				, OptParser.OPT_NEG, -1))
		op.add(new OptParser.Boolean("h", "help", XEcho.options
				, "help"
				, "Display help", OptParser.OPT_HIDDEN))
		op.add(new OptParser.Boolean(0, "env", XEcho.ptions
				, "__env_dummy"
				, "Ignore environment variable XECHO_OPTIONS"
				, OptParser.OPT_NEG|OptParser.OPT_NEG_USAGE))
		op.add(new OptParser.Group("`n	  $E will be transformed to "
				.  "Ansi escape code \033 (0x1b)"
				. "`n	  $C will be transformed to carriage return (0x0d)"
				. "`n	  $L will be transformed to line feed (0x0a)"
				. "`n	  $T will be transformed to a tab (0x0f)"))

		return op
	}

	main(args) {
		try {
			op := XEcho.cli()
			args := op.parse(args)
			if (XEcho.options.help) {
				Ansi.writeLine(op.usage())
				exitapp
			}
			if (XEcho.options.debug) {
				OutputDebug % XEcho.options.debug
			}
			if (XEcho.options.disable_ansi = true) {
				EnvSet DISABLE_ANSI, XECHO
			} else if (XEcho.options.disable_ansi = false) {
				EnvSet DISABLE_ANSI, % ""
			}
			if (XEcho.options.ansi_disabled) {
				EnvGet disable_ansi, DISABLE_ANSI
				Ansi.writeLine((disable_ansi
						? "ANSI is disabled (" disable_ansi ")"
						: "ANSI is enabled"))
			}
			if (XEcho.options.enc) {
				Ansi.setEncoding(XEcho.options.enc)
			}
			OutputDebug % Console.bufferInfo.backgroundColor()
					. ";" Console.bufferInfo.foregroundColor()
			if (!XEcho.options.prompt) {
				if (args.maxIndex() < 1) {
					throw Exception("error: Missing argument")
				}
				if (XEcho.options.concealed) {
					throw Exception("error: Invalid argument")
				}
			} else {
				if (args.maxIndex()) {
					throw Exception("error: Too many arguments")
				}
				if (XEcho.options.new_line) {
					throw Exception("eror: Invalid argument")
				}
			}
			if (!XEcho.options.prompt) {
				loop % args.maxIndex() {
					string := substituePlaceholers(args[A_Index])
					if (XEcho.options.new_line && A_Index == args.maxIndex()) {
						Ansi.writeLine(string)
					} else {
						Ansi.write(string)
					}
				}
			} else {
				if (XEcho.options.concealed) {
					Input, data,, {Enter}
				} else {
					data := Ansi.readLine()
				}
				if (data = "") {
					data := XEcho.options.default
				}
				OutputDebug % "data = " data
				Ansi.write(data)
			}
		} catch _ex {
			Ansi.writeLine(_ex.message)
			Ansi.writeLine(op.usage())
			exitapp _ex.extra
		} finally {
			if (XEcho.options.reset
					& !XEcho.options.concealed
					& !XEcho.options.prompt)
			{
				OutputDebug Reset all attributes
				Ansi.write(Ansi.ESC "[0m")
			}
			if (XEcho.options.prompt) {
				Ansi.flashInput()
			}
		}
	}
}

substituePlaceholers(inString) {
	escSubstituted := RegExReplace(inString, "(?<!\$)\$E", Ansi.ESC)
	crSubstituted := RegExReplace(escSubstituted, "(?<!\$)\$C", "`r")
	nlSubstituted := RegExReplace(crSubstituted, "(?<!\$)\$L", "`n")
	tabSubstituted := RegExReplace(nlSubstituted, "(?<!\$)\$T", "`t")

	return tabSubstituted
}

mapConsoleColorsToAnsi() {
Console.Color.Foreground.BLACK
Console.Color.Foreground.BLUE
Console.Color.Foreground.GREEN
Console.Color.Foreground.TURQUOISE
Console.Color.Foreground.RED
Console.Color.Foreground.PURPLE
Console.Color.Foreground.OCHER
Console.Color.Foreground.LIGHTGREY
Console.Color.Foreground.DARKGREY
Console.Color.Foreground.LIGHTBLUE
Console.Color.Foreground.LIME
Console.Color.Foreground.AUQA
Console.Color.Foreground.LIGHTRED
Console.Color.Foreground.MAGENTA
Console.Color.Foreground.YELLOW
Console.Color.Foreground.WHITE
Console.Color.Background.BLACK
Console.Color.Background.BLUE
Console.Color.Background.GREEN
Console.Color.Background.TURQUOISE
Console.Color.Background.RED
Console.Color.Background.PURPLE
Console.Color.Background.OCHER
Console.Color.Background.LIGHTGREY
Console.Color.Background.DARKGREY
Console.Color.Background.LIGHTBLUE
Console.Color.Background.LIME
Console.Color.Background.AUQA
Console.Color.Background.LIGHTRED
Console.Color.Background.MAGENTA
Console.Color.Background.YELLOW
Console.Color.Background.WHITE
}

#NoEnv ; notest-begin
#SingleInstance Off
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

#Include <App>
#Include <cui-libs>

exitapp App.checkRequiredClasses(XEcho).main(A_Args) ; notest_end
