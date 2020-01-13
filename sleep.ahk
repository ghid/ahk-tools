#NoEnv
#NoTrayIcon
Critical Off

if %0% = 0
	msecs := 1000
else
	msecs = %1%

; Sleep %msecs%
DllCall("Sleep", UInt, msecs)
OutputDebug Slept %msecs% milliseconds

return
