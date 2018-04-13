Main:
	rc := 0
	stdin := FileOpen("*", "r")
	try {
		Clipboard := stdin.Read()
	} catch {
		rc := A_LastError
	} finally {
		stdin.Close()
	}
exitapp rc
