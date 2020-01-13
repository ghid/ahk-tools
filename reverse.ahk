#NoEnv
SetBatchLines -1
ListLines Off
#include <logging>
#include <system>
#include <ansi>
#include <string>

Main:
    if (System.vArgs.MaxIndex() < 1)
    {
        stdin := FileOpen("*", "r")
        st := stdin.Read()
    }
    else if (System.vArgs[1] = "-h" || System.vArgs[1] = "--help" || System.vArgs[1] = "/?")
    {
        Ansi.WriteLine("usage: reverse <string>")
        Ansi.WriteLine("   or: Command | reverse")
        Ansi.WriteLine("   or: reverse (to read vom StdIn)")
        exitapp
    }
    else
    {
        st := System.vArgs[1]
    }
    try
    {
        OutputDebug %A_ScriptName% st="%st%"
        l_cp := Base64.Decode(st, 0, Base64.CRYPT_STRING_BASE64, st_cp)
        r_st := ""
        loop % StrLen(st)
        {
            r_st := SubStr(st, A_Index, 1) r_st
        }
        OutputDebug %A_ScriptName% st="%r_st%"
        Ansi.WriteLine(r_st)
    }
    catch err
    {
        Ansi.WriteLine(err.Message "(" err.Extra ")")
        exitapp 0
    }
exitapp 1
