#NoEnv
#NoTrayIcon

stExpr = %1%
stFileName = %2%
nGroup = %3%
nDistance = %4%
	
OutputDebug stExpr = %stExpr%`; stFileName = %stFileName%`; nGroup = %nGroup%`; nDistance = %nDistance%

FileRead bContent, %stFileName%

res := RegExMatch(bContent, stExpr, _)
if (nGroup = "")
	st := _
else
	st := _%nGroup%
OutputDebug % "res = " res "`; found: " st  
if (nDistance) {
	FileGetSize fsize, %stFileName%
	OutputDebug %stFileName% = %fsize% bytes
	if (res <= nDistance || fsize - Abs(fsize) <= nDistance)
		FileAppend %st%, *
	else
		res := 0
} else
	FileAppend %st%, *

exitapp res
