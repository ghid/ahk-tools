#NoEnv
#NoTrayIcon
#Persistent
SetBatchLines -1

#Include <logging>
#Include <console>

opt_TIMEOUT := 30000
opt_HIDE := false

params := ""
loop %0%
{
	if (%A_Index% = "--help")
		goto Usage
	if (RegExMatch(%A_Index%, "-t(\d+)", $)) {
		opt_TIMEOUT := $1
	} else if (%A_Index% = "-h")
		opt_HIDE := true
	else
		params .= %A_Index% " "
}

SetTimer WatchDog, 1000, 2147483647 

global PID

_start := A_TickCount
if (opt_Hide)
	WinHide, A
RunWait %params%,,, PID
_duration := A_TickCount - _start
if (opt_Hide)
	WinShow, A

_m := _duration // 60000
SetFormat Float, 5.3
_s := Mod(_duration, 60000) / 1000 
FileAppend % "`nreal    " _m "m" _s "s", *

exitapp _duration

Usage:
	Console.Write("timer [-t<millis>] [-q] <command>`n")
	Console.Write("`n")
	Console.Write("-h           Hide window`n")
	Console.Write("-t<millis>   Set timeout to show hidden window (default 30000 msec)`n")
	Console.Write("--help       Print usage`n`n")
exitapp

WatchDog:
	; OutputDebug % (A_TickCount - _start) " ** WATCHDOG ** " PID "  " opt_TIMEOUT
	if (!PID)
		return
	if (_start && (A_TickCount - _start > opt_TIMEOUT)) {
		if (opt_Hide)
			WinShow, A 
		SetTimer WatchDog, Off
	}
return
