#NoEnv
#NoTrayIcon
#Persistent
SetBatchLines -1

#Include <logging>
#Include <ansi>
#Include *i %A_ScriptDir%\timer.versioninfo

opt_TIMEOUT := 30000
opt_HIDE := false

params := ""
expect_timer_args := true
loop %0%
{
	if (SubStr(%A_Index%, 1, 1) <> "-")
		expect_timer_args := false
	if (expect_timer_args) {
		if (%A_Index% = "--help")
			goto Usage
		if (%A_Index% = "--version")
			goto About
		if (RegExMatch(%A_Index%, "-t(\d+)", $)) {
			opt_TIMEOUT := $1
			continue
		} else if (%A_Index% = "-h") {
			opt_HIDE := true
			continue
		}
	}
	params .= %A_Index% " "
}

SetTimer WatchDog, 1000, 2147483647 

global PID

_start := A_TickCount
if (opt_Hide)
	WinHide, A
RunWait %params%,,UseErrorLevel, PID
RC := ErrorLevel
if (RC)
	Ansi.WriteLine("exit    " RC)
_duration := A_TickCount - _start
if (opt_Hide)
	WinShow, A

_m := _duration // 60000
SetFormat Float, 5.3
_s := Mod(_duration, 60000) / 1000 
Ansi.WriteLine("real    " _m "m" _s "s")

exitapp _duration

Usage:
	Ansi.WriteLine("timer [-t<millis>] [-h] <command>")
	Ansi.WriteLine()
	Ansi.WriteLine("-h           Hide window")
	Ansi.WriteLine("-t<millis>   Set timeout to show hidden window (default 30000 msec)")
	Ansi.WriteLine("--help       Print usage")
	Ansi.WriteLine()
exitapp

About:
	Ansi.WriteLine(G_VERSION_INFO.NAME "/" G_VERSION_INFO.ARCH "-b" G_VERSION_INFO.BUILD)
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
; vim: ts=4:sts=4:sw=4:tw=0:noet
