defmodule Day10 do

  def part1 do
    map = read_map()
    zeroes = map |> Enum.filter(fn {_, x} -> x == 0 end) |> Enum.map(&elem(&1, 0))
    zeroes
    |> Enum.map(&get_nines(&1, map) |> MapSet.new() |> MapSet.size())
    |> Enum.sum()
  end

  def read_map() do
    File.read!("day10-input.txt")
    |> String.split()
    |> Enum.map(
      fn line ->
        line
        |> String.graphemes
        |> Enum.map(&String.to_integer(&1))
        |> Enum.with_index
      end
    )
    |> Enum.with_index
    |> Enum.reduce(
      Map.new(),
      fn {row, r}, coords ->
        Enum.reduce(
          row,
          coords,
          fn {x, c}, m -> Map.put(m, {r, c}, x) end
        )
      end
    )
  end

  def get_nines({r, c}, map) do
      x = Map.fetch!(map, {r, c})
      if x == 9 do
        [{r, c}]
      else
        [
          {r-1,c},
          {r,c+1},
          {r+1,c},
          {r,c-1}
        ]
        |> Enum.filter(&(Map.get(map, &1) == x + 1))
        |> Enum.flat_map(&get_nines(&1, map))
    end
  end

  def part2 do
    map = read_map()
    zeroes = map |> Enum.filter(fn {_, x} -> x == 0 end) |> Enum.map(&elem(&1, 0))
    zeroes
    |> Enum.map(&get_nines(&1, map) |> length)
    |> Enum.sum()
  end
end
