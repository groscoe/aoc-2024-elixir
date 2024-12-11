defmodule Day4 do
  @spec part1() :: integer
  def part1() do
    lines = File.read("day4-input.txt")
      |> elem(1)
      |> String.split()
      |> Enum.map(&to_charlist(&1))

    columns = transpose(lines)
    diagonals = diagonals(lines)

    Enum.concat([lines, columns, diagonals])
    # NOTE: the look-ahead and look-behind clauses allow for overlapping matches.
    |> Enum.map(&count_xmas(0, 0, &1))
    |> Enum.sum()
  end

  @spec part2() :: integer
  def part2() do
    File.read("day4-input.txt")
      |> elem(1)
      |> String.split()
      |> Enum.map(&to_charlist(&1))
      |> count_x_mas()
  end

  # part 1

  @spec diagonals(list_of_lists :: list()) :: list()
  def diagonals(list_of_lists) do
    Enum.reduce(
      Enum.with_index(list_of_lists),
      {%{}, %{}},
      fn {row, row_index}, {left_to_right, right_to_left} ->
        Enum.with_index(row)
        |> Enum.reduce(
          {left_to_right, right_to_left},
          # Go through the elements, grouping them by row_index + column_index (i.e., right to left diagonals) and row_index - column_index (i.e., left to right diagonals).
          fn {element, column_index}, {left_to_right, right_to_left} ->
            sum = row_index + column_index
            difference = row_index - column_index
            updated_right_to_left = Map.update(right_to_left, sum, [element], fn diag -> [element | diag] end)
            updated_left_to_right = Map.update(left_to_right, difference, [element], fn diag -> [element | diag] end)
            {updated_left_to_right, updated_right_to_left}
          end
        )
      end
    )
    |> then(fn {ltr, rtl} -> Map.values(ltr) ++ Map.values(rtl) end)
  end

  @spec transpose(m :: list()) :: list()
  def transpose(m) do
    # Since Enum.zip_with/2 is variadic, zipping all rows is the same as transposing.
    # NOTE: Enum.zip/2 could work, but it returns tuples instead of lists.
    Enum.zip_with(m, &Function.identity/1)
  end

  # NOTE: direct_count and reverse_count are tallied separately just for
  # debugging purposes.
  @spec count_xmas(direct_count :: integer, reverse_count :: integer, xs :: charlist()) :: integer
  def count_xmas(direct_count, reverse_count, xs) do
    case xs do
      # When we find a full match, we re-append the last character to
      # account for overlapping matches (e.g. "XMASAMX".
      [?X, ?M, ?A, ?S | rest] -> count_xmas(direct_count + 1, reverse_count, [?S | rest])
      [?S, ?A, ?M, ?X | rest] -> count_xmas(direct_count, reverse_count + 1, [?X | rest])
      [_ | rest] -> count_xmas(direct_count, reverse_count, rest)
      [] -> direct_count + reverse_count
    end
  end

  # part 2

  # We're now counting X-MAS, not XMAS
  @spec count_x_mas(list_of_lists :: list()) :: integer
  def count_x_mas([r1, r2, r3 | other_rows]) do
    # slide a 3-row window through the input, accumulating matches.
    count_in_three_rows(0, [r1, r2, r3]) + count_x_mas([r2, r3 | other_rows])
  end

  def count_x_mas(_), do: 0

  @spec count_in_three_rows(acc :: integer, three_rows :: list()) :: integer
  def count_in_three_rows(acc, three_rows) do
    # go through each column looking for matches
    case three_rows do
      [ [a, b, c | xs],
        [_, e, f | ys],
        [g, h, i | zs]
      ] when ([a, e, i] == ~c"MAS" or [a, e, i] == ~c"SAM")
      and ([g, e, c] == ~c"MAS" or [g, e, c] == ~c"SAM") ->
        count_in_three_rows(acc + 1, [[b, c | xs], [e, f | ys], [h, i | zs]])

      [ [_ | xs],
        [_ | ys],
        [_ | zs]
      ] -> count_in_three_rows(acc, [xs, ys, zs])

      _ -> acc
    end
  end
end
