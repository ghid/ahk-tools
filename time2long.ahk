#NoEnv
SetBatchLines -1

#Include <logging>
#Include <ansi>
#Include <optparser>
#Include <calendar>
#Include <system>

Main:
	op := new OptParser(["time2long [adjustments] [timestamp]", "time2long -r <long-time>"], OptParser.PARSER_ALLOW_DASHED_ARGS)
	op.Add(new OptParser.Group("Adjustments:"))
	op.Add(new OptParser.Boolean("h", "help", _h, "This help", OptParser.OPT_HIDDEN))
	op.Add(new OptParser.String("y", "", _adj_years, "adujst-years", "Adjust time +/- years", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("m", "", _adj_month, "adujst-month", "Adjust time +/- month", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("d", "", _adj_days, "adujst-days", "Adjust time +/- days", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("H", "", _adj_hours, "adujst-hours", "Adjust time +/- hours", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("M", "", _adj_minutes, "adujst-minutes", "Adjust time +/- minutes", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.String("S", "", _adj_seconds, "adujst-seconds", "Adjust time +/- seconds", OptParser.OPT_OPTARG,, 0))
	op.Add(new OptParser.Boolean("r", "", _r, "Reverse operation: convert long-time to timestamp"))
	
	try {
		args := op.Parse(system.vArgs)

		if (_h) {
			Ansi.WriteLine(op.Usage())
			exitapp
		} else if (args.MaxIndex() > 1)
			throw Exception("Too many arguments")
		else if (_r && args.MaxIndex() < 1)
			throw Exception("Missing argument")

		if (!_r) {
			ts := new Calendar(args[1])
			ts.Adjust(_adj_years+0, _adj_month+0, _adj_days+0, _adj_hours+0, _adj_minutes+0, _adj_seconds+0) 
			Ansi.WriteLine(ts.FormatTime("dd.MM.yyyy HH.mm.ss") ": " ts.Long())
		} else {
			ts := new Calendar().Long(args[1])
			Ansi.WriteLine(args[1] ": " ts.FormatTime("dd.MM.yyyy HH.mm.ss"))
		}
	} catch _ex {
		Ansi.WriteLine(_ex.Message)
		Ansi.WriteLine(op.Usage())	
	}
exitapp
