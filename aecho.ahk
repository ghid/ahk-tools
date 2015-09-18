#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , H ;if unstable, comment or remove this line
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

#include <logging>
#include <ansi>
#include <system>
#include <optparser>

Main:
	global G_new_line, G_reset, G_help, G_prompt, G_concealed

	op := new OptParser(["[-n] [-r] <string>"
					   , "-p [-c]"])
	op.Add(new OptParser.Boolean("n", "new-line", G_new_line, "Append a new line character"))
	op.Add(new OptParser.Boolean("r", "reset", G_reset, "Turn all attributes off after writing the string (default)", OptParser.OPT_NEG|OptParser.OPT_NEG_USAGE, true))
	op.Add(new OptParser.Boolean("p", "prompt", G_prompt, "Read from standard input"))
	op.Add(new OptParser.Boolean("c", "concealed", G_concealed, "Concealed input (e.g. for passwords)"))
	op.Add(new OptParser.Boolean("h", "help", G_help, "Display help", OptParser.OPT_HIDDEN))
	op.Add(new OptParser.Group("`n    $E will be transformed to Ansi escape code \033 (0x1b)"))

	try {
		args := op.Parse(System.vArgs)

		OutputDebug % "args:`n" LoggingHelper.Dump(args)
		OutputDebug % "G_new_line = " G_new_line
		OutputDebug % "G_reset = " G_reset
		OutputDebug % "G_help = " G_help
		OutputDebug % "G_concealed = " G_concealed
		OutputDebug % "G_prompt = " G_prompt

		if (G_help) {
			Ansi.WriteLine(op.Usage())
			exitapp
		}
		if (!G_prompt) {
			if (args.MaxIndex() > 1)
				throw Exception("error: Too many arguments")
			else if (args.MaxIndex() < 1)
				throw Exception("error: Missing argument")
			if (G_concealed)
				throw Exception("error: Invalid argument")
		} else {
			if (args.MaxIndex())
				throw Exception("error: Too many arguments")
			if (G_new_line)
				throw Exception("eror: Invalid argument")
		}

		if (!G_prompt) {
			string := RegExReplace(args[1], "(?<!\$)\$E", Ansi.ESC)

			if (G_new_line)
				Ansi.WriteLine(string)
			else
				Ansi.Write(string)
		} else {
			if (G_concealed)
				Input, data,, {Enter}
			else {
				data := Ansi.ReadLine()
				OutputDebug % "data = " data
			}

			Ansi.Write(data)
		}
			
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
		exitapp _ex.Extra
	} finally {
		if (G_reset) {
			OutputDebug Reset all attributes
			Ansi.Write(Ansi.ESC "[0m")
		}
	}
exitapp
