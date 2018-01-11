#NoEnv
SetBatchLines -1
ListLines Off
#include <logging>
#include <system>
#include <base64>
#include <ansi>

B64_CP := System.EnvGet("B64_CP")
if (System.vArgs.MaxIndex() < 1) {
	stdin := FileOpen("*", "r")
	st := Trim(stdin.Readline(), "`r`n")
	cp := (B64_CP <> "" ? B64_CP : "cp1252")
} else {
	st := System.vArgs[1]
	cp := (System.vArgs.MaxIndex() > 1 ? System.vArgs[2] : (B64_CP <> "" ? B64_CP : "cp1252"))
}
OutputDebug %A_ScriptName% cp=%cp% st="%st%"
l_cp := Base64.Decode(st, 0, Base64.CRYPT_STRING_BASE64, st_cp)
st := StrGet(&st_cp, l_cp, cp)
OutputDebug %A_ScriptName% l_cp=%l_cp% st="%st%"
Ansi.WriteLine(st)

exitapp 1
