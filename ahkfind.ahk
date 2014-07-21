#NoEnv
#NoTrayIcon

stExpr = %1%
stFileName = %2%
OutputDebug stExpr = %stExpr%`; stFileName = %stFileName%

FileRead bContent, %stFileName%

exitapp (RegExMatch(bContent, stExpr) > 0)