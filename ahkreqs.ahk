;@Ahk2Exe-ConsoleApp
#NoEnv
#Warn All, StdOut

Main:
	stdOut := FileOpen("*", "w")
	if (A_Args.maxIndex() == "") {
		stdOut.writeLine("usage: ahkreqs [-lib] <file-name>[#requirement-number]")
	} else {
		try {
			useLib := ""
			if (A_Args[1] == "-lib") {
				useLib := A_MyDocuments "\autohotkey\lib\"
				A_Args.removeAt(1)
			}
			loop % A_Args.maxIndex() {
				fileName := A_Args[A_Index]
				RegExMatch(fileName, "^(?P<Name>.*?)((#)(?P<Requirement>\d+))?$"
						, file)
				stdOut.writeLine("Examine " useLib fileName ":")
				stdOut.flush()
				sourceFile := FileOpen(useLib fileName, "r")
				content := sourceFile.read()
				RegExMatch(content, "ims`a)^\s*version\(\)\s+\{.*?return\s+""(?P<version>.*?)"".*?\}", $)
				stdOut.writeLine("Version: " $version)
				RegExMatch(content, "ims`a)^\s*requires\(\)\s+\{.*?return\s+\[(?P<libs>.*?)\].*?\}", $)
				if ($libs) {
					if (fileRequirement) {
						libList := StrSplit($libs, ",", A_Space A_Tab)
						stdOut.writeLine("Requirement #" fileRequirement ": " libList[fileRequirement])
					} else {
						libList := RegExReplace($libs, "ms)\s*,\s*", ", ")
						stdOut.writeLine("Requires: " libList)
					}
				} else {
					stdOut.writeLine("No requirements provided")
				}
			}
		} finally {
			if (sourceFile) {
				sourceFile.close()
			}
			stdOut.flush()
			stdOut.close()
		}
	}
exitapp
