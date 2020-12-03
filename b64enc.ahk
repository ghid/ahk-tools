;@Ahk2Exe-ConsoleApp
#Warn all, StdOut

class B64Enc extends B64Tool {

	requires() {
		return [B64Tool]
	}
	
	main(args) {
		try {
			rc := 1
			op := B64Enc.cli()
			args := op.parse(args)
			if (B64Enc.Options.help) {
				Ansi.writeLine(op.usage())
				rc := ""
			} else {
				Ansi.write(B64Enc.encode(args))
			}
		} catch e {
			Ansi.writeLine(e.message)
			Ansi.writeLine(op.usage())
			rc := 0
		}
		return rc
	}

	encode(args) {
		OutputDebug % Format("{:s}: codepage = {:s}", A_ThisFunc
				, B64Enc.Options.encoding)
		length := B64Enc.strPutVar(B64Enc.stringToEncode(args)
				, encodedString, B64Enc.Options.encoding)
		return Base64.encode(encodedString, length)
	}

	stringToEncode(args) {
		result := ""
		switch args.count() {
		case 0:
			result := Trim(Ansi.stdIn.readline(), "`r`n")
		case 1:
			result := args[1]
		default:
			throw Exception("error: Too many arguments")
		}
		return result
	}

	strPutVar(string, ByRef var, encoding) {
		VarSetCapacity(var, StrPut(string, encoding)
				* ((encoding = "cp1200" || encoding = "cp65001") ? 2 : 1) )
		l := StrPut(string, &var, encoding)
		return l-1
	}
}

#NoEnv ; notest-begin
#Include <app>
#Include <cui-libs>
#Include <Base64>

#Include %A_LineFile%\..\b64tool.ahk

App.checkRequiredClasses(B64Enc).main(A_Args) ; notest-end
