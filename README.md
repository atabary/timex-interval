# Timex Interval

[![hex.pm version](https://img.shields.io/hexpm/v/timex_interval.svg)](https://hex.pm/packages/timex_interval) [![travis.ci build status](http://img.shields.io/travis/atabary/timex-interval/master.svg)](https://travis-ci.org/atabary/timex-interval)

Timex Interval is an extension of [Timex](https://github.com/bitwalker/timex) that deals with date/time intervals.

Intervals are enumerable, making them useful to iterate over time intervals, for instance every day between two dates.


## Constructors

The `DateTimeInterval` module provides a helper function to make new intervals.

Valid keywords:

  - `from`: the date the interval starts at (defaults to `Date.now()`)
  - `until`: either the date the interval ends at, or a time shift that will be applied to the "from" date (defaults to `[days: 7]`)
  - `left_open`: whether the interval is left open, defaults to #{@default_left_open}
  - `right_open`: whether the interval is right open, defaults to #{@default_right_open}
  - `step`: the iteration step for enumerations, defaults to `[days: 1]`

Time shifts should be keyword lists valid for use with `Timex.Date.shift`.

```elixir
use Timex
alias TimexInterval.DateTimeInterval, as: Interval

Interval.new(from: Date.from({2014, 9, 22}), until: Date.from({2014, 9, 29}))
|> Interval.format!("%Y-%m-%d")
#=> "[2014-09-22, 2014-09-29)"

Interval.new(from: Date.from({2014, 9, 22}), until: [months: 5])
|> Interval.format!("%Y-%m-%d")
#=> "[2014-09-22, 2015-02-22)"

Interval.new(from: Date.from({{2014, 9, 22}, {15, 30, 0}}), until: [mins: 20], right_open: false)
|> Interval.format!("%H:%M")
#=> "[15:30, 15:50]"

```

Note that by default intervals are right open.


## Iterators

`DateTimeInterval` implements the `Enumerable` protocol.

```elixir
use Timex
alias TimexInterval.DateTimeInterval, as: Interval

Interval.new(from: Date.from({2014, 9, 22}), until: [days: 3])
|> Enum.map(fn(dt) -> DateFormat.format!(dt, "%Y-%m-%d", :strftime) end)
#=> ["2014-09-22", "2014-09-23", "2014-09-24"]
```

You can easily specify whether to exclude the first and last dates:

```elixir
Interval.new(from: Date.from({2014, 9, 22}), until: [days: 3], right_open: false)
|> Enum.map(fn(dt) -> DateFormat.format!(dt, "%Y-%m-%d", :strftime) end)
#=> ["2014-09-22", "2014-09-23", "2014-09-24", "2014-09-25"]
```

You can of course iterate over anything else, for instance by chunks of 10 minutes:

```elixir
Interval.new(from: Date.from({{2014, 9, 22}, {15, 0, 0}}), until: [hours: 1])
|> Interval.with_step(mins: 10)
|> Enum.map(fn(dt) -> DateFormat.format!(dt, "%H:%M", :strftime) end)
#=> ["15:00", "15:10", "15:20", "15:30", "15:40", "15:50"]
```
