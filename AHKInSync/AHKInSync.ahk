/*
:encoding=UTF-8:
:mode=AutoHotkey:
:folding=explicit:
*/

#Include <logging>

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
	
	strUserLibDir := A_MyDocuments "\AutoHotkey\Lib"
	SplitPath A_AhkPath,, strStdLibDir 
	strStdLibDir .= "\Lib"
	
	if (_log.Logs(Logger.Finest)) {
		_log.Finest("strSourcePath = " strSourcePath)
		_log.Finest("strUserLibDir = " strUserLibDir)
		_log.Finest("strStdLibDir = " strStdLibDir)
	}
	
	loop %strSourcePath%*.ahk, 0, %pRecursiv%
	{
		if (RegExMatch(A_LoopFileName, "\.ahk$")) {
			strSearchFileName := RegExReplace(A_LoopFileDir "\" A_LoopFileName, "^" string_As_Reg_Ex(strSourcePath), "")
			_log.Detail("Found " strSearchFileName)
			if (! (tsModifyTime := GetLibTimestamp(strUserLibDir, strSearchFileName))) {
				tsModifyTime := GetLibTimestamp(strStdLibDir, strSearchFileName)
			}
			_log.Info("tsModifyTime for " strSearchFileName " = " tsModifyTime)
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

