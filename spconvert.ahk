#NoEnv
#NoTrayIcon
SetBatchLines -1

#Include <logging>
#Include <console>
#Include <string>
#Include <system>

main:
	_main := new Logger("spconvert.Main")
	
	nReturnCode := 0	

	try {
		if (System.vArgs.MaxIndex() = 4) {
			action := IsValidAction(System.vArgs[1])
			enc_in := IsValidEncoding(System.vArgs[2])
			file_in := IsInputFileAvailable(System.vArgs[3])
			enc_out := IsValidEncoding(System.vArgs[4])
		} else {
			throw _main.Exit("Invalid number of arguments: " System.vArgs.MaxIndex())
		}
		
		if (action = "--to-properties") {
			Console.Write("`nProcessed " Strings2Properties(enc_in, file_in, enc_out) " line(s)`n")
		} else {
			Console.Write("`nProcessed " Properties2Strings(enc_in, file_in, enc_out) " line(s)`n")
		}
		
	} catch _ex {
		Console.Write((_ex <> "" ? _ex "`n" : "")
					. "Usage: " A_ScriptName " --to-properties encoding-input strings-file encoding-output`n"
					. "       " A_ScriptName " --to-strings encoding-input properties-pattern encoding-output`n`n"
					. "Convert from .strings to .properties and vice-versa.`n`n"
					. "--to-properties     Convert from .strings to .properties`n"
					. "--to-strings        Convert from .properties to .strings`n"
					. "encoding-input      Encoding of the uses input file (UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW, CPnnn)`n"
					. "strings-file        Path and name of the .strings file`n"
					. "properties-pattern  Path and name pattern of .properties file(s)`n"
					. "encoding-output     Encoding of the uses input file (UTF-8, UTF-16, UTF-8-RAW, UTF-16-RAW, CPnnn)`n`n")
		nReturnCode := 1
	}
exitapp _main.Exit(nReturnCode)

IsValidEncoding(pstrEncoding) {
	if (!RegExMatch(pstrEncoding, "i)utf-8(-raw)?|utf-16(-raw)?|cp[0-9]{3,5}"))
		throw "Invalid encoding: " pstrEncoding
		
	return pstrEncoding
}

IsValidAction(pstrAction) {
	if (!RegExMatch(pstrAction, "--to-properties|--to-strings"))
		throw "Invalid action: " pstrAction
	
	return pstrAction
}

IsInputFileAvailable(pstrFileName) {
	if (!FileExist(pstrFileName))
		throw "File does not exist: " pstrFileName
		
	return pstrFileName
}

Strings2Properties(inEnc, inFile, outEnc) {
	_log := new Logger("spconvert." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("inEnc", inEnc)
		_log.Input("inFile", inFile)
		_log.Input("outEnc", outEnc)
	}
	
	SplitPath inFile,, inDir,, inNameNoExt
	
	outFile := (inDir <> "" ? inDir "\" : "") inNameNoExt ".properties"
	_log.Finest("outFile = " outFile)
	
	Console.Write("`nConvert from " inEnc " " inFile "`n"
				. "          to " outEnc " " outFile "`n`n")
		
	_isRangeComment := false
	n := 0
	hInFile := FileOpen(inFile, "r `r", inEnc)
	hOutFile := FileOpen(outFile, "w", outEnc)
	
	while(!hInFile.AtEOF) {
		n++
		line := RegExReplace(hInFile.ReadLine(), "[\r\n]*$", "")
		if (_log.Logs(Logger.All))
			_log.All("Line #" n ": " line)
		if (RegExMatch(line, "^\s*\/\*(.*?)\*\/.*", $)) {
			_log.Detail("Line comment")
			hOutFile.Write("#" $1 "`n")
		} else if (RegExMatch(line, "^\s*\/\*(.*)", $)) {
			_log.Detail("Begin of range comment")
			_isRangeComment := true
			hOutFile.Write("#" $1 "`n")
		} else if (RegExMatch(line, "^(.*?)\*\/\s*", $)) {
			_log.Detail("End of range comment")
			hOutFile.Write("#" $1 "`n")
			_isRangeComment := false
		} else if (!_isRangeComment && RegExMatch(line, "^""(.+?)""\s*=\s*""(.*?)"";", $)) {
			_log.Detail("key:" $1 " / value: " $2)
			if (Instr($1, "="))
				throw _log.Exit("Equal sign in keys are not supported. line #" A_Index " in " inFile ":`n" line)
			else if (RegExMatch($1, "^\s+"))
				throw _log.Exit("Leading spaces in keys ar not supported. line #" A_Index " in " inFile ":`n" line)
			else if (RegExMatch($1, "\s+$"))
				throw _log.Exit("Trailing spaces in keys ar not supported. line #" A_Index " in " inFile ":`n" line)
			hOutFile.Write($1 "=" $2 "`n")
		} else if (_isRangeComment && RegExMatch(line, "^(.*)$", $)) {
			_log.Detail("range comment")
			hOutFile.Write("#" $1 "`n")
		} else if (RegExMatch(line, "^\s*$")) {
			_log.Detail("Empty line")
			hOutFile.Write("`n")
		} else {
			throw _log.Exit("Invalid content in line #" A_Index  " of " inFile ":`n" line)
		}
	}
	
	hOutFile.Close()
	hInFile.Close()
	
	return _log.Exit(n)
}

Properties2Strings(inEnc, inFile, outEnc) {
	_log := new Logger("spconvert." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("inEnc", inEnc)
		_log.Input("inFile", inFile)
		_log.Input("outEnc", outFile)
	}
	
	Console.Write("`nConvert from " inEnc " " inFile "...`n")

	n := 0
	loop %inFile%
	{
		SplitPath A_LoopFileFullPath,, outDir,, outNameNoExt
		outFile := (outDir <> "" ? outDir "\" : "") outNameNoExt ".strings"
		_log.Finest("outFile = " outFile)
		hOutFile := FileOpen(outFile, "w", outEnc)
	
		Console.Write("          to " outEnc " " outFile "`n")

		_log.Detail("Reading " A_LoopFileFullPath)
		hInFile := FileOpen(A_LoopFileFullPath, "r", inEnc)
		
		strComment := ""
		while (!hInFile.AtEOF) {
			n++
			line := RegExReplace(hInFile.ReadLine(), "[\r\n]+$", "")
			if (_log.Logs(Logger.All))
				_log.All("Line #" n ": " line)
			if (RegExMatch(line, "^#(.*)$", $)) {
				_log.Detail("Comment line")
				if (strComment = "")
					strComment := "/*" $1
				else
					strComment .= "`n" $1
			} else if (RegExMatch(line, "^(.+?)\s*=\s*(.*$)", $)) {
				_log.Detail("key: " $1 " / value: " $2)
				if (strComment <> "") {
					hOutFile.Write(strComment "*/`n")
					strComment := ""
				}
				hOutFile.Write("""" $1 """ = """ $2 """;`n")
			} else if (RegExMatch(line, "^\s*")) {
				hOutFile.Write("`n")
			} else {
				_log.Exit(throw "Invalid content in line #" A_Index " of " inFile ":`n" line)
			}
		}
	}
	
	return _log.Exit(n)
}
