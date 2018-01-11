; ahk: console

#include <logging>
#include <ansi>

Main:
exitapp exec()

exec() {
	count := 0

	curr := ""

	matrix := {}

	; loop, Read, %temp%\minus-user.txt
	loop, Read, H:\TEMP\files
	{
		; RegExMatch(A_LoopReadLine, "i)ou=\s*(\d+?)\s*,", $)
		RegExMatch(A_LoopReadLine, "(^.*$)", $)
		if (curr = "")
			prev := $1
		curr := $1
		if (curr == prev) {
			count++
			; OutputDebug %curr% %prev%
		} else {
			; OutputDebug ----------------------------
			; OutputDebug %curr% %prev% %count%
			if (count > 10)
				Ansi.WriteLine(prev ": " count)
				
			if (matrix[count] = "")
				matrix[count] := 1
			else
				matrix[count] += 1
			count := 1
		}
		prev := curr
	}
	if (matrix[count] = "")
		matrix[count] := 1
	else
		matrix[count] += 1

	for i, c in matrix {
		; FileAppend %i%`,%c%`n, h:\temp\matrix.txt
		; Ansi.WriteLine(i "," c)
	}
}

