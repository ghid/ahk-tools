#NoEnv
SetBatchLines -1
ListLines Off
#include <logging>
#include <system>
#include <base64>
#include <ansi>

if (System.vArgs.MaxIndex() < 1) {
	Ansi.WriteLine("Usage: b64dec <text> [encoding]")
	exitapp 1
}
st := System.vArgs[1]
cp := "cp1252"
if (System.vArgs.MaxIndex() > 1)
	cp := System.vArgs[2]
l_cp := Base64.Decode(st, 0, Base64.CRYPT_STRING_BASE64, st_cp)
Ansi.WriteLine(StrGet(&st_cp, l_cp, cp))

exitapp 0
