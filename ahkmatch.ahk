#NoEnv
#NoTrayIcon

stHaystack = %1%
stNeedle = %2%
nGroup = %3%
stRegExOpts = %4%
stRegExOpts .= "O)"
OutputDebug stHaystack = %stHaystack%`; stNeedle = %stNeedle%`; nGroup = %nGroup%`; stReExOpts = %stRegExOpts%

res := RegExMatch(stHaystack, stRegExOpts stNeedle, $)
if (nGroup) {
	OutputDebug % "$.Value(" nGroup ")=" $.Value(nGroup)
	FileAppend % $.Value(nGroup), *
} else {
	OutputDebug % "$=" $.Value(0)
	FileAppend % $.Value(0), *
}

OutputDebug res=%res%
exitapp (res)
