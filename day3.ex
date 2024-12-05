defmodule Day3 do
  @spec part1() :: number
  def part1() do
    File.read!("day3-input.txt")
    |> get_muls()
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
    |> IO.puts()
  end

  @spec get_muls(memory :: String.t()) :: list
  def get_muls(memory) do
    Regex.scan(~r/mul\((\d+),(\d+)\)/, memory)
    |> Enum.map(fn captures -> Enum.drop(captures, 1) |> Enum.map(&String.to_integer(&1)) end)
  end

  @spec part2() :: number
  def part2() do
    File.read!("day3-input.txt")
    |> parse_and_run_instructions()
    |> IO.puts()
  end

  @spec parse_and_run_instructions(memory :: String.t()) :: number
  def parse_and_run_instructions(memory) do
    Regex.scan(~r/(do)\(\)|(don't)\(\)|mul\((\d+),(\d+)\)/, memory)
    |> Enum.reduce(
      {0, true},
      fn instruction, {acc, enabled?} -> case instruction do
        [_, "do"] -> {acc, true}
        [_, _, "don't"] -> {acc, false}
        [_, _, _, a, b] when enabled? -> {acc + String.to_integer(a) * String.to_integer(b), enabled?}
        _ -> {acc, enabled?}
      end
      end
    ) |> elem(0)
  end
end
