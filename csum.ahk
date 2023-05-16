;@Ahk2Exe-ConsoleApp

#NoEnv
#NoTrayIcon

#Include <cui-libs>
#Include <crypto>
; #Include c:\work\ahk\ahk-libs\modules\testcase\LoggingHelper.ahk

if 0 = 1
	_fileName = %1%
else
	exitapp 1
	
; FileEncoding cp850

if (_fileName = "-") {
    Ansi.stdOut.read(0)
    _input := Ansi.stdIn.readLine()
    Ansi.stdOut.read(0)
	_size := StrLen(_input)

	VarSetCapacity(_content, _size + 1, 0)
	StrPut(_input, &_content, _size, "cp0")
} else {
	if (!FileExist(_fileName)) {
		Ansi.write("csum: Unable to open " _fileName ".`n")
		exitapp 2
	} else {
		file := FileOpen(_fileName, "r")
		FileGetSize _size, %_fileName%
		_size := file.rawRead(_content, _size)
		file.close()
	}
}
	
; print(LoggingHelper.hexDump(&_content, 0, _size))    
Ansi.write(Crypto.MD5.encode(_content, _size) "  " _fileName "`n")

exitapp 0
