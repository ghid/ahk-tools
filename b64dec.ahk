#NoEnv
SetBatchLines -1
ListLines Off
#include <logging>
#include <system>
#include <base64>
#include <ansi>

Main:
    B64_CP := System.EnvGet("B64_CP")
    if (System.vArgs.MaxIndex() < 1)
    {
        stdin := FileOpen("*", "r")
        st := Trim(stdin.Readline(), "`r`n")
        ; st := stdin.Read()
        cp := (B64_CP <> "" ? B64_CP : "cp1252")
    }
    else if (System.vArgs[1] = "-h" || System.vArgs[1] = "--help" || System.vArgs[1] = "/?")
    {
        Ansi.WriteLine("usage: b64dec <string> [encoding]")
        Ansi.WriteLine("   or: Command | b64dec")
        Ansi.WriteLine("   or: b64dec (to read vom StdIn)")
        Ansi.WriteLine("`nSet enviromnent variable B64_CP "
            . "to use a different encoding (Default: cp1252)")
        exitapp
    }
    else
    {
        st := System.vArgs[1]
        cp := (System.vArgs.MaxIndex() > 1 ? System.vArgs[2] : (B64_CP <> "" ? B64_CP : "cp1252"))
    }
    try
    {
        OutputDebug %A_ScriptName% cp=%cp% st="%st%"
        l_cp := Base64.Decode(st, 0, Base64.CRYPT_STRING_BASE64, st_cp)
        st := StrGet(&st_cp, l_cp, cp)
        OutputDebug %A_ScriptName% l_cp=%l_cp% st="%st%"
        Ansi.WriteLine(st)
    }
    catch err
    {
        Ansi.WriteLine(err.Message "(" err.Extra ")")
        exitapp 0
    }
exitapp 1
