#NoTrayIcon
#include <logging>
#include <base64>
#include <string>

DetectHiddenWindows On
ex := ""
WinGet ps, PID, ahk_exe Unify.OpenScape.exe
if (ps) 
	ex .= (ex <> "" ? ";" : "") "[" ps "]"
WinGet ps, PID, ahk_exe wfica32.exe
if (ps) 
	ex .= (ex <> "" ? ";" : "") "[" ps "]"
WinGet ps, PID, ahk_exe igfxpers.exe
if (ps) 
	ex .= (ex <> "" ? ";" : "") "[" ps "]"
ex.Put(ansi)
hexstr := Base64.Encode(ansi, StrLen(ex), Base64.CRYPT_STRING_NOCRLF|Base64.CRYPT_STRING_HEXRAW) "0000"

RegWrite REG_BINARY, HKEY_CURRENT_USER, Software\Sysinternals\DbgView, ExFilters, %hexstr% 
Run %comspec% /c ""C:\Program Files (x86)\DebugView\Dbgview.exe" /f",, Hide

exitapp
