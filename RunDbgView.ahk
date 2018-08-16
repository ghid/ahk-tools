#NoTrayIcon
#include <logging>
#include <base64>
#include <string>

DetectHiddenWindows On

proc_names := [ "Unify.OpenScape.exe"
			  , "wfica32.exe"
			  , "igfxpers.exe"
			  , "conhost.exe"
			  , "svchost.exe"
			  , "explorer.exe"
			  , "backgroundTaskHost.exe"
			  , "RuntimeBroker.exe"
			  , "sihost.exe" ]

pid_list := {}

for i, proc in proc_names
	ex := get_pids(proc)

ex := ""
for pid, proc in pid_list
{
	ex .= (ex <> "" ? ";" : "") "[" pid "]"
}

ex.Put(ansi)
hexstr := Base64.Encode(ansi, StrLen(ex), Base64.CRYPT_STRING_NOCRLF|Base64.CRYPT_STRING_HEXRAW) "0000"

RegWrite REG_BINARY, HKEY_CURRENT_USER, Software\Sysinternals\DbgView, ExFilters, %hexstr% 
Run %comspec% /c ""c:\opt\DebugView\Dbgview.exe" /f",, Hide

exitapp

get_pids(proc_name)
{
	global pid_list

	WinGet p_list, List, ahk_exe %proc_name%
	loop %p_list%
	{
		p_id := p_list%A_Index%
		WinGet ps, PID, ahk_id %p_id%
		if (ps)
			pid_list[ps] := proc_name
	}
}
