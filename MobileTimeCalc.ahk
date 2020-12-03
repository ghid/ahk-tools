; ahk: con
#Include <cui-libs>
#Include <calendar>

if (A_Args.maxIndex() == "" || A_Args[1] = "-h" || A_Args[1] = "--help") {
	; ahklint-ignore-begin: W002
	Ansi.writeLine("Usage: MobileTimeCalc <arbeits_beginn-arbeits_ende> [<unterbrechungs_begin-unterbrechungs_ende> ...]`n`n"
			. "- Jeden Beginn-Ende-Intervall in der Form HHMM-HHMM (Stunde und Minute von-bis) angeben`n"
			. "- Pausendauer in Minuten kann über die Umgebungsvariable MTC_MINS_PAUSE geändert werden (Default 60)`n"
			. "- Soll-Arbeitszeit in Dezimalstunden kann über die Umgebungsvariable MTC_WORK_TIME geändert werden (Default: 7.5, 6.0)")
	; ahklint-ignore-end
	exitapp
}

try {
	work := StrSplit(A_Args[1], "-")
	start := new Calendar().setAsTime(work[1])
	end := new Calendar().setAsTime(work[2])

	breaks := []
	loop % A_Args.count() - 1 {
		breaks.push(A_Args[A_Index + 1])
	}

	duration := start.compare(end, Calendar.Units.MINUTES)

	brk_dur := 0
	brk_text := ""
	loop % breaks.count() {
		brk := StrSplit(breaks[A_Index], "-")
		brk_st := new Calendar().setAsTime(brk[1])
		brk_end := new Calendar().setAsTime(brk[2])
		brk_dur += brk_st.compare(brk_end, Calendar.Units.MINUTES)
		brk_text .= (brk_text = "" ? "" : ", ")
				. brk_st.formatTime("HH:mm") "-" brk_end.formatTime("HH:mm")
	}

	EnvGet WorkTime, MTC_WORK_TIME
	if (WorkTime = "") {
		WorkTime := [7.75, 6.50]
	} else {
		WorkTime := StrSplit(WorkTime, ",", " `t")
	}
	EnvGet MinsPause, MTC_MINS_PAUSE
	if (MinsPause = "") {
		MinsPause := 60
	}

	SetFormat Float, 0.2
	Ansi.writeLine("Kommt: " start.formatTime("HH:mm"))
	Ansi.writeLine("Geht:  " end.formatTime("HH:mm"))
	; Ansi.WriteLine("Abwsd: " (brk_dur / 60.0))
	Ansi.writeLine("Abwsd: %s ~ %s".Printf(dec_time(brk_dur / 60.0), brk_text))
	e_end := start.clone()
	e_end := e_end.adjust(0, 0, 0, 0, duration - brk_dur)

	Ansi.writeLine("EGeht: " e_end.formatTime("HH:mm"))
	e_anwsd := (start.compare(e_end, Calendar.Units.MINUTES) - MinsPause) / 60.0
	Ansi.writeLine("`nPause: " MinsPause)
	Ansi.writeLine("EAnwh: " e_anwsd)
	e_anwsd += 0.0
	soll_1 := e_anwsd - WorkTime[1]
	soll_2 := e_anwsd - WorkTime[2]
	soll_1_ok := "[" (soll_1 >= 0 ? 32 : 31) "m"
	soll_2_ok := "[" (soll_2 >= 0 ? 32 : 31) "m"
	Ansi.writeLine("Delta: Mo-Do(%.1f)=%s%.2f [0mFr(%.1f)=%s%.2f [0m"
			.Printf(WorkTime[1], soll_1_ok, soll_1
			, WorkTime[2], soll_2_ok, soll_2))
} catch _ex {
	Ansi.writeLine("Fehler: " _ex.Message)
}

exitapp

dec_time(t, ff=0.6) {
	t_ff := A_FormatFloat
	SetFormat Float, %ff%
	h := Floor(t)
	m := Round((t - h) * 60, 0)
	SetFormat Float, %t_ff%

	return h "h " m "m"
}
; 7.75 & 6.50
