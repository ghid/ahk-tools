#NoEnv
#NoTrayIcon

if %0% = 0
	msecs := 1000
else
	msecs = %1%

OutputDebug Sleep %msecs% milliseconds
Sleep %msecs%
