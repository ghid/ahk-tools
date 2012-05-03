/*
:encoding=UTF-8:
:mode=AutoHotkey:
:folding=explicit:
*/

#Include <logging>
#Include <string>
#Include <console>

;{{{ AHKInSync
AHKInSync:
	_logMain := new Logger("app.ahkinsync" A_ThisFunc)

	strSourcePath = %1%
	_logMain.Input("strSourcePath", strSourcePath)
	
	ProcessFiles(strSourcePath)
	
exitapp _logMain.Exit()
;}}}

;{{{ ProcessFiles
ProcessFiles(pSourcePath = "", pRecursiv = 1) {
	_log := new Logger("app.ahkinsync." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("pSourcePath", pSourcePath)
		_log.Input("pRecursiv", pRecursiv)
	}
	
	if (pSourcePath = "") {
		pSourcePath := A_WorkingDir
	}
	
	strSourcePath := RegExReplace(pSourcePath, "[\s\\]+$", "") "\"
	
	hSysOut := new Console()
	nCurrentAttributes := hSysOut.wAttributes
	
	strUserLibDir := A_MyDocuments "\AutoHotkey\Lib"
	SplitPath A_AhkPath,, strStdLibDir 
	strStdLibDir .= "\Lib"
	
	if (_log.Logs(Logger.Finest)) {
		_log.Finest("strSourcePath = " strSourcePath)
		_log.Finest("strUserLibDir = " strUserLibDir)
		_log.Finest("strStdLibDir = " strStdLibDir)
	}
	
	hSysOut.Writeln("# Start in directory " strSourcePath)
	loop %strSourcePath%*.ahk, 0, %pRecursiv%
	{
		if (RegExMatch(A_LoopFileName, "\.ahk$")) {
			strSearchFileName := RegExReplace(A_LoopFileDir "\" A_LoopFileName, "^" String.AsRegEx(strSourcePath), "")
			_log.Detail("Found " strSearchFileName)
			tsUserLibFileModifyTime := GetLibTimestamp(strUserLibDir, strSearchFileName)
			tsStdLibFileModifyTime := GetLibTimestamp(strStdLibDir, strSearchFileName)
			if (_log.Logs(Logger.Detail)) {
				_log.Detail("tsUserLibFileModifyTime for " strSearchFileName " = " tsUserLibFileModifyTime)
				_log.Detail("tsStdLibFileModifyTime for " strSearchFileName " = " tsStdLibFileModifyTime)
			}
			strUserLibFileState := CompareTimestamps(A_LoopFileTimeModified, tsUserLibFileModifyTime)
			strStdLibFileState := CompareTimestamps(A_LoopFileTimeModified, tsStdLibFileModifyTime)
			if (strUserLibFileState <> "" or strStdLibFileState <> "") {
				_log.Info(strSearchFileName " " strUserLibFileState " " strStdLibFileState)
				hSysOut.Write("#`t" strSearchFileName.Pad(String.PAD_LEFT, 64) " " strUserLibFileState.Pad(String.PAD_LEFT, 5) " " strStdLibFileState.Pad(String.PAD_LEFT, 5))
			}
		}
	}
	
	return _log.Exit()
}
;}}}

;{{{ GetLibTimestamp
GetLibTimestamp(pLibDir, pLibName) {
	_log := new Logger("app.ahkinsync." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("pLibDir", pLibDir)
		_log.Input("pLibName", pLibName)
	}
	
	try {
		FileGetTime, tsModifyTime, %pLibDir%\%pLibName%
		if (_log.Logs(Logger.Finest)) {
			_log.Finest("tsModifyTime = " tsModifyTime)
		}
	} catch exFileGetTime {
		tsModifyTime := ""
	}
	
	return _log.Exit(tsModifyTime)
}
;}}}

;{{{ CompareTimestamps
CompareTimestamps(tsFirst, tsSecond) {
	_log := new Logger("app.ahkinsync." A_ThisFunc)
	
	if (_log.Logs(Logger.Input)) {
		_log.Input("tsFirst", tsFirst)
		_log.Input("tsSecond", tsSecond)
	}
	
	return _log.Exit(tsSecond = "" ? "" : (tsFirst > tsSecond) ? "Newer" : "Synch")
}
;}}}

