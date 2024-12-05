defmodule Day1 do

  @spec part1() :: number
  def part1() do
    File.stream!("day1-input.txt")
      # Split each line into pairs of integers
      |> Stream.map(
        fn line ->
          String.trim(line)
          |> String.split()
          |> Enum.map(&Integer.parse(&1) |> elem(0))
        end
      )
      # Unzip the pairs of integers into a pair of sorted columns of integers
      # NOTE: the resulting columns will be reversed, but as we'll sort them it
      # doesn't matter.
      |> unzip_and_reverse()
      |> Enum.map(&Enum.sort(&1))
      # Get the absolute difference between each pair
      |> Enum.zip_with(fn [l, r] -> abs(l - r) end)
      # Finally, sum the differences
      |> Enum.sum()
      |> IO.puts()
  end

  @spec part2() :: number
  def part2() do
    File.stream!("day1-input.txt")
      # Split each line into pairs of integers
      |> Stream.map(
        fn line ->
          String.trim(line)
          |> String.split()
          |> Enum.map(&Integer.parse(&1) |> elem(0))
        end
      )
      # Unzip the pairs of integers into a pair of sorted columns of integers
      |> unzip_and_reverse()
      |> similarity_score()
      |> IO.puts()
  end

  def similarity_score([left, right]) do
    frequencies = Enum.frequencies(right)
    Enum.map(left, &(&1 * Map.get(frequencies, &1, 0))) |> Enum.sum()
  end

  @spec unzip_and_reverse(pairs :: list()) :: list()
  def unzip_and_reverse(pairs), do:
    Enum.reduce(
      pairs,
      [[], []],
      fn [x, y], [left, right] -> [[x | left], [y | right]] end
    )
end
