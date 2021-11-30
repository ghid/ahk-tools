; ahk: console
#NoEnv
#NoTrayIcon

#Include <string>
#Include <console>
#Include <crypto>

_flag = %1%
_fileName = %2%

FileEncoding cp850
if (_flag = "-") {
	_size := Console.read(_content, 256)
	VarSetCapacity(_content, -1)
	_size := StrLen(_content) - 2
} else if (_flag = "-f") {
	if (!FileExist(_fileName)) {
		Console.write("byte2ascii: Unable to open " _fileName ".`n")
		exitapp 2
	} else {
		file := FileOpen(_fileName, "r")
		FileGetSize _size, %_fileName%
		_content := file.read(_size)
		file.close()
	}
} else {
    _content = %1%
}

loop parse, _content, %A_Space%
{
    if (A_LoopField != 0) {
        Console.write(Chr(A_LoopField))
    }
}
Console.write("`n")

exitapp 0
