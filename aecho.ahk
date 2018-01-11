#NoEnv
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

#include <logging>
#include <ansi>
; #include d:\work\ahk\projects\Lib2\ansi.ahk
#include <system>
#include <optparser>

Main:
	global G_new_line, G_reset, G_help, G_prompt, G_concealed, G_ansi_disabled, G_disable_ansi, G_default

	op := new OptParser(["[-n] [-r] <string>"
					   , "-p [-c] [-D]"])
	op.Add(new OptParser.Boolean("n", "new-line", G_new_line, "Append a new line character"))
	op.Add(new OptParser.Boolean("r", "reset", G_reset, "Turn all attributes off after writing the string (default)", OptParser.OPT_NEG|OptParser.OPT_NEG_USAGE, true))
	op.Add(new OptParser.Boolean("p", "prompt", G_prompt, "Read from standard input"))
	op.Add(new OptParser.Boolean("c", "concealed", G_concealed, "Concealed input (e.g. for passwords)"))
	op.Add(new OptParser.String("D", "default", G_default, "Default value to return if nothing entered while prompted"))
	op.Add(new OptParser.String(0, "debug", G_debug, "debug-message", "Write debug output"))
	op.Add(new OptParser.Boolean(0, "is-ansi-disabled", G_ansi_disabled, "Show if the DISABLE_ANSI is set"))
	op.Add(new OptParser.Boolean(0, "disable-ansi", G_disable_ansi, "Disable the Ansi feature by setting DISABLE_ANSI env var", OptParser.OPT_NEG, -1))
	op.Add(new OptParser.Boolean("h", "help", G_help, "Display help", OptParser.OPT_HIDDEN))
	op.Add(new OptParser.Group("`n    $E will be transformed to Ansi escape code \033 (0x1b)"
	                         . "`n    $C will be transformed to carriage return (0x0d)"
	                         . "`n    $L will be transformed to line feed (0x0a)"
	                         . "`n    $T will be transformed to a tab (0x0f)"))

	try {
		args := op.Parse(System.vArgs)

		OutputDebug % "args:`n" LoggingHelper.Dump(args)
		OutputDebug % "G_new_line = " G_new_line
		OutputDebug % "G_reset = " G_reset
		OutputDebug % "G_help = " G_help
		OutputDebug % "G_concealed = " G_concealed
		OutputDebug % "G_default = " G_default
		OutputDebug % "G_prompt = " G_prompt
		OutputDebug % "G_ansi_disabled = " G_ansi_disabled
		OutputDebug % "G_disabled_ansi = " G_disabled_ansi


		if (G_help) {
			Ansi.WriteLine(op.Usage())
			exitapp
		}

		if (G_debug) {
			OptParser.TrimArg(G_Debug, false)
			OutputDebug %G_Debug%
		}
		
		if (G_disable_ansi = true)
			EnvSet DISABLE_ANSI, AECHO
		else if (G_disable_ansi = false)
			EnvSet DISABLE_ANSI, % ""

		if (G_ansi_disabled) {
			EnvGet disable_ansi, DISABLE_ANSI
			Ansi.WriteLine((disable_ansi ? "ANSI is disabled (" disable_ansi ")" : "ANSI is enabled"))
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
			string := RegExReplace(string, "(?<!\$)\$C", "`r")
			string := RegExReplace(string, "(?<!\$)\$L", "`n")
			string := RegExReplace(string, "(?<!\$)\$T", "`t")

			if (G_new_line)
				Ansi.WriteLine(string)
			else
				Ansi.Write(string)
		} else {
			if (G_concealed) {
				Input, data,, {Enter}
			} else {
				data := Ansi.ReadLine()
			}
			if (data = "")
				data := G_default

			OutputDebug % "data = " data
			Ansi.WriteLine(data)
		}

	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())
		exitapp _ex.Extra
	} finally {
		if (G_reset & !G_concealed & !G_Prompt) {
			OutputDebug Reset all attributes
			Ansi.Write(Ansi.ESC "[0m")
		}
		if (G_prompt)
			Ansi.FlashInput()
	}
exitapp
