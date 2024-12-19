defmodule Day8 do

  def part1() do
    File.read!("day8-input.txt")
    |> get_antenna_positions()
    |> (
      fn {antenna_positions, max_x, max_y} ->
        Enum.reduce(
          antenna_positions,
          MapSet.new(),
          fn {_, antennae}, acc -> MapSet.union(
            acc,
            all_antinodes(antennae, max_x, max_y)
          )
          end
        )
        |> MapSet.size()
      end
    ).()
  end

  def get_antenna_positions(raw_input) do
    cells =
      raw_input
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.trim(&1))

    max_y = (cells |> length) - 1
    first_line = cells |> hd
    max_x = (first_line |> String.length()) - 1

    # Just for debugging purposes in case we mess up the input
    if Enum.any?(cells, &(String.length(&1) !== String.length(first_line))) do
      raise "Input error: lines have different lengths"
    end

    antenna_positions =
      cells
      |> Enum.with_index()
      |> Enum.map(
        fn {row, y} ->
          row
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.map(fn {cell, x} -> {x, y, cell} end)
          |> Enum.filter(fn {_, _, cell} -> cell =~ ~r/[a-zA-Z0-9]/ end)
        end
      )
      |> Enum.concat()
      |> Enum.group_by(&(elem(&1, 2)))

    {antenna_positions, max_x, max_y}
  end

  def all_antinodes([p1, p2 | rest], max_x, max_y) do
    antinodes(p1, p2, max_x, max_y)
    |> MapSet.new()
    |> MapSet.union(all_antinodes([p1 | rest], max_x, max_y))
    |> MapSet.union(all_antinodes([p2 | rest], max_x, max_y))
  end
  def all_antinodes(_, _, _), do: MapSet.new()

  def antinodes({x1, y1, _}, {x2, y2, _}, max_x, max_y) do
    # Note: assumes the points are ordered
    delta_x = x2 - x1
    delta_y = y2 - y1

    possible_antinodes = [
      # First possible antinode is before p1 on the line.
      {x1 - delta_x, y1 - delta_y},
      # The second possible antinode is after p2 on the line.
      {x2 + delta_x, y2 + delta_y},
    ]

    in_grid = fn {x, y} -> x >= 0 and y >= 0 and x <= max_x and y <= max_y end

    possible_antinodes |> Enum.filter(&in_grid.(&1))
  end

  def part2() do
    File.read!("day8-input.txt")
    |> get_antenna_positions()
    |> (
      fn {antenna_positions, max_x, max_y} ->
        Enum.reduce(
          antenna_positions,
          MapSet.new(),
          fn {_, antennae}, acc -> MapSet.union(
            acc,
            all_antinodes_with_resonance(acc, antennae, max_x, max_y)
          )
          end
        )
        |> MapSet.size()
      end
    ).()
  end

  def canonicalize_line({x1, y1, _}, {x2, y2, _}) do
    # Get the slope and integer offset of the line defined by two points. Used
    # so we don't repeat the work for lines we've already traversed.
    {dx, dy} = {x2 - x1, y2 - y1}
    factor = Integer.gcd(x2 - x1, y2 - y1)
    {dx2, dy2} = {div(dx, factor), div(dy, factor)}
    {dx3, dy3} = cond do
      dx2 < 0 -> {- dx2, -dy2}
      dx2 == 0 and dy2 < 0 -> {dx2, - dy2}
      true -> {dx2, dy2}
    end

    offset = dx3 * y1 - dy3 * x1

    {dx3, dy3, offset}
  end

  def all_antinodes_with_resonance(known_antinodes, [p1, p2 | rest], max_x, max_y) do
    # For every pair of points, enumerate all cells collinear to them.
    canonical = canonicalize_line(p1, p2)
    antinodes = if MapSet.member?(known_antinodes, canonical) do
      known_antinodes
    else
      MapSet.union(
        known_antinodes,
        antinodes_with_resonance(known_antinodes, canonical, max_x, max_y)
      )
    end

    antinodes = all_antinodes_with_resonance(antinodes, [p1 | rest], max_x, max_y)
    antinodes = all_antinodes_with_resonance(antinodes, [p2 | rest], max_x, max_y)

    antinodes
  end
  def all_antinodes_with_resonance(known_antinodes, _, _, _), do: known_antinodes

  def antinodes_with_resonance(antinodes, {dx, dy, offset}, max_x, max_y) do
    # i.e. enumerate all collinear positions on the grid
    new_antinodes =
      if dx == 0 do # vertical line
        x = div(-offset, dy)
        if 0 <= x and x < max_x do
          # we're only interest in points inside the grid.
          0 .. max_y
          |> Enum.map(&{x, &1})
          |> MapSet.new()
        else
          MapSet.new()
        end
      else # all other lines
        0 .. max_x
        |> Enum.filter(fn x -> rem(offset + dy*x, dx) == 0 end)
        |> Enum.map(
          fn x ->
            y = div(offset + dy*x, dx)
            {x, y}
          end
        )
        # we're only interest in points inside the grid.
        |> Enum.filter(fn {_, y} -> 0 <= y and y <= max_y end)
        |> MapSet.new()
      end

    MapSet.union(antinodes, new_antinodes)
  end
end
