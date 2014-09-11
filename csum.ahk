#NoEnv
#NoTrayIcon

#Include <logging>
#Include <string>
#Include <console>
#Include <crypto>

if 0 = 1
	_fileName = %1%
else
	exitapp 1
	
FileEncoding cp850

if (_fileName = "-") {
	_size := Console.Read(_input, 256)
	VarSetCapacity(_input, -1)
	_size := StrLen(_input) - 2
	
	VarSetCapacity(_content, _size + 1, 0)
	StrPut(_input, &_content, _size, "cp0")
} else {
	if (!FileExist(_fileName)) {
		Console.Write("csum: Unable to open " _fileName ".`n")
		exitapp 2
	} else {
		file := FileOpen(_fileName, "r")
		FileGetSize _size, %_fileName%
		_size := file.RawRead(_content, _size)
		file.Close()
	}
}
	
Console.Write(Crypto.MD5.Encode(_content, _size) "  " _fileName "`n")

exitapp 0

