; ahk: console
#Warn all, StdOut

class B64Dec extends B64Tool {

	requires() {
		return [B64Tool]
	}
	
	main(args) {
		try {
			rc := 1
			op := B64Dec.cli()
			args := op.parse(args)
			if (B64Dec.Options.help) {
				Ansi.writeLine(op.usage())
				rc := ""
			} else {
				Ansi.write(B64Dec.decode(args))
			}
		} catch e {
			Ansi.writeLine(e.message)
			Ansi.writeLine(op.usage())
			rc := 0
		}
		return rc
	}

	decode(args) {
		OutputDebug % Format("{:s}: codepage = {:s}", A_ThisFunc
				, B64Dec.Options.encoding)
		length := Base64.decode(B64Dec.stringToDecode(args)
				, 0, Base64.CRYPT_STRING_BASE64, decodedString)
		return StrGet(&decodedString, length, B64Dec.Options.encoding)
	}

	stringToDecode(args) {
		switch args.count() {
		case 0:
			return Trim(Ansi.stdIn.readline(), "`r`n")
		case 1:
			return args[1]
		default:
			throw Exception("error: Too many arguments")
		}
	}
}

#NoEnv ; notest-begin
#Include <app>
#Include <cui-libs>
#Include <Base64>

#Include %A_LineFile%\..\b64tool.ahk

App.checkRequiredClasses(B64Dec).main(A_Args) ; notest-end
