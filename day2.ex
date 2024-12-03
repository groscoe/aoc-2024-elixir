defmodule Day2 do
  @spec part1() :: non_neg_integer()
  def part1() do
    File.stream!("day2-input.txt")
    |> Enum.map(&String.trim(&1) |> parse_report())
    |> Enum.count(&report_is_safe?(&1, false))
  end

  def part2() do
    File.stream!("day2-input.txt")
    |> Enum.map(&String.trim(&1) |> parse_report())
    |> Enum.count(&report_is_safe?(&1, true))
  end

  @spec parse_report(str_level :: String.t()) :: list
  def parse_report(str_level) do
    str_level
    |> String.split()
    |> Enum.map(&Integer.parse(&1) |> elem(0))
  end

  @spec report_is_safe?(report :: list, dampen_problems? :: boolean) :: boolean
  def report_is_safe?(report, dampen_problems?) do
    # A report is safe if:
    #  1. All levels are either increasing or decreasing
    #  2. The difference between any two adjacent levels is between 1 and 3.
    safe? = Enum.zip_reduce(
      report,
      report |> Enum.drop(1),
      {true, nil},
      fn previous_level, current_level, {safe_so_far?, last_direction} ->
        {still_safe?, direction} = pair_is_safe(previous_level, current_level, last_direction)
        {safe_so_far? and still_safe?, direction}
      end
    ) |> elem(0)

    if safe? or not dampen_problems? do
      safe?
    else
      # FIXME: go through each pair, "dampening" problem levels if needed
      Enum.any?(
        Enum.with_index(report),
        fn {element, index} -> report_is_safe?(hole_at(report, index), false) end
      )
    end
  end

  def get_direction(previous_level, current_level) do
    cond do
      previous_level < current_level -> :increasing
      previous_level > current_level -> :decreasing
      true -> :unchanged
    end
  end

  def pair_is_safe(previous_level, current_level, last_direction) do
    current_direction = get_direction(previous_level, current_level)
    difference = abs(previous_level - current_level)
    same_direction = is_nil(last_direction) or current_direction == last_direction
    within_bounds = 1 <= difference and difference <= 3
    pair_is_safe? = same_direction and within_bounds and current_direction != :unchanged
    {pair_is_safe?, current_direction}
  end

  def hole_at(enum, hole_index) do
    enum
    |> Enum.with_index()
    |> Enum.filter(fn {_elem, index} -> index !== hole_index end)
    |> Enum.map(fn {elem, _index} -> elem end)
  end

end
