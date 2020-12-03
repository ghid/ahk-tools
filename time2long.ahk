; ahk: con
#NoEnv
SetBatchLines -1

#Include <cui-libs>
#Include <calendar>

Main:
	; ahklint-ignore-begin: W004
    opts := { h: false
            , q: false
            , r: false
            , adjust: { years: 0
                      , month: 0
                      , days: 0
                      , hours: 0
                      , minutes: 0
                      , seconds: 0 } }
	; ahklint-ignore-end

	op := new OptParser(["time2long [-q] [adjustments] [timestamp]"
			, "time2long -r [-q] [adjustments] <long-time>"]
			, OptParser.PARSER_ALLOW_DASHED_ARGS)
	op.add(new OptParser.Boolean("h", "help"
			, opts, "h"
			, "This help", OptParser.OPT_HIDDEN))
	op.add(new OptParser.Boolean("q", "quiet"
			, opts, "q"
			, "Run quiet and return result as exit code"))
	op.add(new OptParser.Boolean("r", ""
			, opts, "r"
			, "Reverse operation: convert long-time to timestamp"))
	op.add(new OptParser.Group("`nAdjustments:"))
	op.add(new OptParser.String("y", ""
			, opts.adjust, "years", "adujst-years"
			, "Adjust time +/- years", OptParser.OPT_ARG,, 0))
	op.add(new OptParser.String("m", ""
			, opts.adjust, "month", "adujst-month"
			, "Adjust time +/- month", OptParser.OPT_ARG,, 0))
	op.add(new OptParser.String("d", ""
			, opts.adjust, "days", "adujst-days"
			, "Adjust time +/- days", OptParser.OPT_ARGREQ,, 0))
	op.add(new OptParser.String("H", ""
			, opts.adjust, "hours", "adujst-hours"
			, "Adjust time +/- hours", OptParser.OPT_ARG,, 0))
	op.add(new OptParser.String("M", ""
			, opts.adjust, "minutes", "adujst-minutes"
			, "Adjust time +/- minutes", OptParser.OPT_ARG,, 0))
	op.add(new OptParser.String("S", ""
			, opts.adjust, "seconds", "adujst-seconds"
			, "Adjust time +/- seconds", OptParser.OPT_ARG,, 0))
	op.add(new OptParser.Group("`nThe 'timestamp' may start with 'Today' "
			. "(or 'T') to set today's date as the date"))
	
	try {
		args := op.parse(A_Args)

		if (opts.h) {
			Ansi.writeLine(op.usage())
			exitapp
		} else if (args.maxIndex() > 1) {
			throw Exception("Too many arguments")
        }else if (opts.r && args.maxIndex() < 1) {
			throw Exception("Missing argument")
        }

		if (!opts.r) {
            if (RegExMatch(args[1], "i)^T(oday)?(.*)$", $)) {
                args[1] := A_YYYY A_MM A_DD $2
            }
			ts := new Calendar(args[1])
			ts.adjust(opts.adjust.years+0
					, opts.adjust.month+0
					, opts.adjust.days+0
					, opts.adjust.hours+0
					, opts.adjust.minutes+0
					, opts.adjust.seconds+0)
			if (opts.q) {
				res := ts.asLong()
            } else {
				Ansi.writeLine(ts.formatTime("dd.MM.yyyy HH.mm.ss")
						. ": " ts.asLong())
            }
		} else {
			ts := new Calendar().setAsLong(args[1])
			ts.adjust(opts.adjust.years+0
					, opts.adjust.month+0
					, opts.adjust.days+0
					, opts.adjust.hours+0
					, opts.adjust.minutes+0
					, opts.adjust.seconds+0)
			if (opts.q) {
				res := ts.get()
            } else {
				Ansi.writeLine(ts.asLong() ": "
						. ts.formatTime("dd.MM.yyyy HH.mm.ss"))
            }
		}
	} catch _ex {
		Ansi.writeLine(_ex.Message)
		Ansi.writeLine(op.usage())	
	}

exitapp res
