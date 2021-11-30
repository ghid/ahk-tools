; ahk: console
#NoEnv
#Include <ansi\ansi>

Ansi.NO_BUFFER := true

while (A_Index <= A_Args.maxIndex()) {
	findIncludes(A_Args[A_Index])
}

findIncludes(sourceFileName) {
	static nestedLevel := 0

	OutputDebug %This_Func% : test %sourceFileName%
	if (includeDir == "") {
		includeDir := A_WorkingDir
	}
	sourceFile := FileOpen(sourceFileName, "r")
	while (!sourceFile.atEoF) {
		SplitPath sourceFileName, fileName, fileDir
		if (fileDir == "") {
			fileDir := A_WorkingDir
		}
		sourceLine := sourceFile.readLine()
		if RegExMatch(sourceLine, "i)^\s*#Include\s+(?P<IncludedFile>.*)\s*;?.*$"
				, match) {
			if (RegExMatch(matchIncludedFile, "\<(?P<Lib>.+)\>", match)) {
				include := A_MyDocuments "\AutoHotkey\lib\" matchLib ".ahk"
				includeDir := ""
			} else {
				substLineFile := StrReplace(matchIncludedFile
						, "%A_Linefile%", fileDir "\" fileName)
				include := StrReplace(substLineFile
						, "%A_ScriptDir", fileDir)
			}
			if (isDir(include)) {
				includeDir := include
			} else {
				Ansi.writeLine(nestedLevel ") Includes " includeDir include)
				nestedLevel++
				findIncludes(include)
				nestedLevel--
			}
		}
	}
	sourceFile.close()
}

isDir(fileName) {
	return Instr(FileExist(fileName), "D")
}
