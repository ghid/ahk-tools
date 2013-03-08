#NoEnv
#NoTrayIcon
SetBatchLines -1

#Include <logging>
#Include <console>
#Include <string>
#Include <system>

main:
	nReturnCode := 0	

	try {
		if (System.vArgs.MaxIndex() = 4) {
			action := IsValidAction(System.vArgs[1])
			enc_in := IsValidEncoding(System.vArgs[2])
			file_in := IsInputFileAvailable(System.vArgs[3])
			enc_out := IsValidEncoding(System.vArgs[4])
		} else {
			throw "Invalid number of arguments: " System.nArgs
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
exitapp %nReturnCode%

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
	SplitPath inFile,, inDir,, inNameNoExt
	
	outFile := (inDir <> "" ? inDir "\" : "") inNameNoExt ".properties"
	
	Console.Write("`nConvert from " inEnc " " inFile "`n"
				. "          to " outEnc " " outFile "`n`n")
		
	if (FileExist(outFile))
		FileDelete %outFile%

	FileEncoding %inEnc%
	
	_isRangeComment := false
	n := 0
	loop Read, %inFile%  
	{
		n++
		; OutputDebug `n%A_LoopReadLine%
		if (RegExMatch(A_LoopReadLine, "^\s*\/\*(.*?)\*\/.*$", $)) {
			; OutputDebug % "   Comment: <" $1 ">`n`n"
			FileAppend, #%$1%`r`n, %outFile%, %outEnc%
		} else if (RegExMatch(A_LoopReadLine, "^\s*\/\*(.*)$", $)) {
			; OutputDebug % "   Begin of block comment"
			_isRangeComment := true
			FileAppend #%$1%`r`n, %outFile%, %outEnc%
		} else if (RegExMatch(A_LoopReadLine, "^(.*?)\*\/\s*$", $)) {
			; OutputDebug % "   End of block comment"
			FileAppend #%$1%`r`n, %outFile%, %outEnc%
			_isRangeComment := false
		} else if (!_isRangeComment && RegExMatch(A_LoopReadLine, "^""(.+?)""\s*=\s*""(.*)"";$", $)) {
			; OutputDebug % "   Property: " $1 $2 $3 "`n`n"
			if (Instr($1, "="))
				throw "Equal sign in keys are not supported. line #" A_Index " in " inFile ":`n" A_LoopReadLine
			; TODO: Check for leading/trailing spaces
			else if (RegExMatch($1, "^\s+"))
				throw "Leading spaces in keys ar not supported. line #" A_Index " in " inFile ":`n" A_LoopReadLine
			else if (RegExMatch($1, "\s+$"))
				throw "Trailing spaces in keys ar not supported. line #" A_Index " in " inFile ":`n" A_LoopReadLine
			FileAppend %$1%=%$2%`r`n, %outFile%, %outEnc%
		} else if (_isRangeComment) {
			; OutputDebug % "   Line in block comment"
			FileAppend #%A_LoopReadLine%`r`n, %outFile%, %outEnc%
		} else if (RegExMatch(A_LoopReadLine, "^\s*$")) {
			; OutputDebug % "   Blank line`n`n"
			FileAppend `r`n, %outFile%, %outEnc%
		} else {
			throw "Invalid content in line #" A_Index  " of " inFile ":`n" A_LoopReadLine
		}
	}
	
	return n
}

Properties2Strings(inEnc, inFile, outEnc) {
	Console.Write("`nConvert from " inEnc " " inFile "...`n")

	n := 0
	loop %inFile%
	{
		SplitPath A_LoopFileFullPath,, outDir,, outNameNoExt
		outFile := (outDir <> "" ? outDir "\" : "") outNameNoExt ".strings"
		
		if (FileExist(outFile))
			FileDelete %outFile%
	
		Console.Write("          to " outEnc " " outFile "`n")

		FileEncoding %inEnc%
		
		strComment := ""
		loop Read, %A_LoopFileFullPath%  
		{
			n++
			; OutputDebug `n%A_LoopReadLine%
			if (RegExMatch(A_LoopReadLine, "^#(.*)$", $)) {
				if (strComment = "")
					strComment := "/*" $1
				else
					strComment .= "`n" $1
			} else if (RegExMatch(A_LoopReadLine, "^(.+?)\s*=\s*(.*)$", $)) {
				if (strComment <> "") {
					FileAppend % strComment "*/`n", *%outFile%, %outEnc%
					strComment := ""
				}
				FileAppend % """" $1 """ = " """" $2 """;`n", *%outFile%, %outEnc%
			} else if (RegExMatch(A_LoopReadLine, "^\s*$")) {
				FileAppend `n, *%outFile%, %outEnc%
			} else {
				throw "Invalid content in line #" A_Index  " of " inFile ":`n" A_LoopReadLine
			}
		}
	}
	
	return n
}