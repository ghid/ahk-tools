; ahk: console
#NoEnv
#NoTrayIcon
if (!A_IsCompiled) {
	#Warn All, StdOut
}
#SingleInstance Off
SetBatchLines -1

#Include <ansi>
#Include <console>
#Include <object>
#Include <structure>
#Include <testcase>

#Include <modules\structure\CONSOLE_SCREEN_BUFFER_INFO>
#Include <modules\structure\COORD>
#Include <modules\structure\SMALL_RECT>

Main:
	infoAboutMonitors := retrieveInfoAboutAvailableMonitors()
	Ansi.write(fred(infoAboutMonitors))
exitapp

retrieveInfoAboutAvailableMonitors() {
	result := {primary: 0, monitors: []}
	SysGet numOfMonitors, MonitorCount
	loop %numOfMonitors% {
		SysGet, workArea, MonitorWorkArea, %A_Index%
		monitor := {left: workAreaLeft, top: workAreaTop
				, right: workAreaRight, bottom: workAreaBottom}
		result.monitors.push(monitor)
	}
	SysGet primaryMonitor, MonitorPrimary
	result.primary := primaryMonitor
	return result
}

fred(infoAboutMonitors) {
	result := infoAboutMonitors.primary
	for _, monitor in infoAboutMonitors.monitors {
		result .= "[" monitor.left ":" monitor.top ":"
				. monitor.right ":" monitor.bottom "]"
	}
	return result
}
