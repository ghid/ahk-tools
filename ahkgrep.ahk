#NoEnv
#NoTrayIcon

stExpr = %1%
stFileName = %2%
nGroup = %3%
	
OutputDebug stExpr = %stExpr%`; stFileName = %stFileName%`; nGroup = %nGroup%

FileRead bContent, %stFileName%

res := RegExMatch(bContent, stExpr, _)
if (nGroup = "")
	st := _
else
	st := _%nGroup%
OutputDebug % "res = " res "`; found: " st  
FileAppend %st%, *

exitapp res