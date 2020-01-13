#NoEnv
#NoTrayIcon

stHaystack = %1%
stNeedle = %2%
stReplacement = %3%
stReplacement := RegExReplace(stReplacement, "``s", " ")
nLimit = %4%
nStart = %5%
stRegExOpts = %6%
stRegExOpts .= ")"
if (nLimit = "")
	nLimit := -1
if (nStart = "")
	nStart := 1
OutputDebug stHaystack = /%stHaystack%/`; stNeedle = /%stNeedle%/`; stReplacement = /%stReplacement%/`; nLimit = %nLimit%`; nStart = %nStart%`; stReExOpts = %stRegExOpts%

res := RegExReplace(stHaystack, stRegExOpts stNeedle, stReplacement, n, nLimit, nStart)
OutputDebug n=%n%
OutputDebug res=%res%
FileAppend %res%, *

exitapp
