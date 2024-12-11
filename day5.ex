defmodule Day5 do
  def part1() do
    File.read!("day5-input.txt")
    |> String.trim()
    |> String.split("\n\n", parts: 2)
    |> (fn [rule_block, update_block] -> parse_instructions(rule_block, update_block) end).()
    |> (fn {rule_map, updates} -> Enum.filter(updates, &update_is_ordered(rule_map, &1)) end).()
    |> Enum.map(&(get_second_half(&1) |> hd() |> String.to_integer()))
    |> Enum.sum()
  end

  def part2() do
    File.read!("day5-input.txt")
    |> String.trim()
    |> String.split("\n\n", parts: 2)
    |> (fn [rule_block, update_block] -> parse_instructions(rule_block, update_block) end).()
    |> (fn {rule_map, updates} ->
      Enum.filter(updates, &(not update_is_ordered(rule_map, &1)))
      |> Enum.map(&(order_update(rule_map, &1) |> get_second_half() |> hd() |> String.to_integer()))
      |> Enum.sum()
    end).()
  end

  def parse_instructions(rule_block, update_block) do
    rule_map = Enum.reduce(
      String.split(rule_block, "\n"),
      %{},
      fn rule, map ->
        case String.split(rule, "|") do
          [precedes, succeeds] -> Map.update(
              map,
              precedes,
              MapSet.new([succeeds]),
              &MapSet.put(&1, succeeds)
          )
        end
      end
    )

    updates =
      String.split(update_block, "\n")
      |> Enum.map(&String.split(&1, ","))

    {rule_map, updates}
  end

  def update_is_ordered(rule_map, update) do
    case update do
      [] -> true
      [x | xs] ->
        Enum.all?(xs, &(precedes?(rule_map, x, &1)))
        and update_is_ordered(rule_map, xs)
    end
  end

  def precedes?(rule_map, x, y) do
    # Actually checks if x _may_ precede y.
    not Map.has_key?(rule_map, y) or not MapSet.member?(Map.get(rule_map, y), x)
  end

  def get_second_half(xs), do: get_second_half(xs, xs)
  def get_second_half(xs, ys) do
    case { xs, ys } do
      { [_, _ | left_rest], [_ | right_rest] } -> get_second_half(left_rest, right_rest)
      { _, second_half } -> second_half
    end
  end

  # ordering an update is simple (if we accept some inefficiency): order the
  # tail recursively and then insert the head in its proper place.
  def order_update(_rule_map, []), do: []
  def order_update(rule_map, [x | xs]), do: order_update(rule_map, xs) |> insert(rule_map, x)

  # Insert x into xs according to rule_map, assuming xs is already sorted.
  def insert([], _rule_map, x), do: [x]
  def insert([y | ys], rule_map, x) do
    if precedes?(rule_map, x, y) do
      [x, y | ys]
    else
      [y | insert(ys, rule_map, x)]
    end
  end
end
