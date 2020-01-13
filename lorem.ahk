#NoEnv
SetBatchLines -1
ListLines Off
#include <logging>
#include <system>
#include <ansi>
#include <flimsydata\flimsydata>

Main:
    try
    {
        fd := new Flimsydata.Lorem(A_Now A_MSec)
        Ansi.Write(fd.getParagraph("PLorem", 1))
    }
    catch err
    {
        Ansi.WriteLine(err.Message "(" err.Extra ")")
        exitapp 0
    }
exitapp 1
