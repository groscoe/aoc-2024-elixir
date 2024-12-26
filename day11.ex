defmodule Day11 do
  def part1 do
    File.read!("day11-input.txt")
    |> String.split()
    |> Enum.map(&String.to_integer(&1))
    |> blink(25)
  end

  def blink(stones, num_blinks) do
    Enum.reduce(
      stones,
      {0, Map.new()},
      fn stone, {cur, memo} ->
        {tot, new_memo} = blink_single(stone, 0, num_blinks, memo)
        {cur + tot, new_memo}
      end
    ) |> elem(0)
  end

  def blink_single(_, cur_blink, max_blinks, memo) when cur_blink == max_blinks, do: {1, memo}

  def blink_single(stone, cur_blink, max_blinks, memo) do
    case Map.get(memo, {stone, max_blinks - cur_blink}) do
      nil ->
        s = stone |> to_string()
        next_stones = cond do
          stone == 0 -> [1]
          rem(s |> byte_size(), 2) == 0 ->
            len = byte_size(s)
            mid = div(len, 2)
            left = binary_part(s, 0, mid)
            right = binary_part(s, div(len, 2), mid)
            [String.to_integer(left), String.to_integer(right)]
          true -> [stone * 2024]
        end
        {nums, new_memo} = Enum.map_reduce(
          next_stones,
          memo,
          fn x, acc -> blink_single(x, cur_blink + 1, max_blinks, acc) end
        )
        total = Enum.sum(nums)
        {total, Map.put(new_memo, {stone, max_blinks - cur_blink}, total)}

      n when is_integer(n) -> {n, memo}
    end
  end

  def part2 do
    File.read!("day11-input.txt")
    |> String.split()
    |> Enum.map(&String.to_integer(&1))
    |> blink(75)
  end

end
