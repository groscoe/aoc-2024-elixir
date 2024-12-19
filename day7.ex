defmodule Day7 do
  def part1() do
    File.stream!("day7-input.txt")
    |> Enum.map(&parse_line(&1))
    |> Enum.filter(
      fn [[target], [first_op | ops]] -> find_operators(false, target, first_op, ops) end
    )
    |> Enum.map(fn [[target] | _] -> target end)
    |> Enum.sum()
  end

  def parse_line(line) do
    # e.g. "190: 10 19" -> [[190], [10, 19]]
    line
    |> String.split(":")
    |> Enum.map(&String.trim(&1) |> String.split())
    |> Enum.map(&Enum.map(&1, fn i -> String.to_integer(i) end))
  end

  def find_operators(allow_concat \\ false, target, acc, operands)
  def find_operators(_, target, acc, []), do: target == acc
  def find_operators(allow_concat, target, acc, [ operand | rest ]) do
    if acc > target do
      false
    else
      ( find_operators(allow_concat, target, acc + operand, rest) or
        find_operators(allow_concat, target, acc * operand, rest) or
        (allow_concat and find_operators(allow_concat, target, concat(acc, operand), rest))
      )
    end
  end

  def concat(a, b) do
    Integer.digits(a) ++ Integer.digits(b)
    |> Integer.undigits()
  end

  def part2() do
    File.stream!("day7-input.txt")
    |> Enum.map(&parse_line(&1))
    |> Enum.filter(
      fn [[target], [first_op | ops]] -> find_operators(true, target, first_op, ops) end
    )
    |> Enum.map(fn [[target] | _] -> target end)
    |> Enum.sum()
  end
end
