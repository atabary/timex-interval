defmodule TimexInterval.DateTimeIntervalTest do
  use ExUnit.Case, async: true
  use Timex
  alias TimexInterval.DateTimeInterval, as: I

  test :new do

    temp = I.new(from: Date.from({2014, 9, 22}), until: Date.from({2014, 9, 29})) |> I.format!("%Y-%m-%d")
    assert temp == "[2014-09-22, 2014-09-29)"

    temp = I.new(from: Date.from({2014, 9, 22}), until: [days: 7])
        |> I.format!("%Y-%m-%d")
    assert temp == "[2014-09-22, 2014-09-29)"

    temp = I.new(from: Date.from({2014, 9, 22}), until: [days: 7], left_open: true, right_open: false)
        |> I.format!("%Y-%m-%d")
    assert temp == "(2014-09-22, 2014-09-29]"

    temp = I.new(from: Date.from({{2014, 9, 22}, {15, 30, 0}}), until: [mins: 20], right_open: false)
        |> I.format!("%H:%M")
    assert temp == "[15:30, 15:50]"
  end

  test :enum do
    temp = I.new(from: Date.from({2014, 9, 22}), until: [days: 3])
        |> Enum.map(&DateFormat.format!(&1, "%Y-%m-%d", :strftime))
    assert temp == ["2014-09-22", "2014-09-23", "2014-09-24"]

    temp = I.new(from: Date.from({2014, 9, 22}), until: [days: 3], right_open: false)
        |> Enum.map(&DateFormat.format!(&1, "%Y-%m-%d", :strftime))
    assert temp == ["2014-09-22", "2014-09-23", "2014-09-24", "2014-09-25"]

    temp = I.new(from: Date.from({{2014, 9, 22}, {15, 0, 0}}), until: [hours: 1])
        |> I.with_step(mins: 10)
        |> Enum.map(&DateFormat.format!(&1, "%H:%M", :strftime))
    assert temp == ["15:00", "15:10", "15:20", "15:30", "15:40", "15:50"]
  end

  test :duration do
    temp = I.new(from: Date.from({2014, 9, 22}), until: [months: 5])
        |> I.duration(:months)
    assert temp == 5

    temp = I.new(from: Date.from({{2014, 9, 22}, {15, 30, 0}}), until: [mins: 20])
        |> I.duration(:timestamp)
    assert temp == {0, 0, 1200}
  end
end
