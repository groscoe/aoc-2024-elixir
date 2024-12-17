defmodule Day6 do
  @guard_glyphs MapSet.new(["v", "<", "^", ">"])

  def part1() do
    File.stream!("day6-input.txt")
    |> Enum.map(&(String.trim(&1) |> String.graphemes()))
    |> build_map()
    |> with_guard_coords()
    |> count_squares(%{})
  end

  def build_map(rows) do
    rows
    |> Enum.with_index()
    |> Enum.reduce(
      %{},
      fn {row, row_index}, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(
          acc,
          fn {x, col_index}, acc ->
            Map.put(acc, {row_index, col_index}, x)
          end
        )
      end
    )
  end

  def draw_map(map, visited_with_direction \\ MapSet.new()) do
    visited = visited_with_direction |> Enum.map(&elem(&1, 0)) |> MapSet.new()

    map
    |> group_keys(&elem(&1, 0))
    |> Enum.sort()
    |> Enum.map(
      fn {_, row} ->
        row
        |> Enum.sort()
        |> Enum.map(
          fn {coords, cell} ->
            if MapSet.member?(@guard_glyphs, cell) or not MapSet.member?(visited, coords) do
              cell
            else
              "X"
            end
          end
        )
        |> Enum.join()
      end
    )
    |> Enum.join("\n")
  end

  def group_keys(map, projection) do
    map
    |> Enum.reduce(
      %{},
      fn {key, value}, acc ->
        Map.update(acc, projection.(key), [{key, value}], &([{key, value} | &1]))
      end
    )
  end

  def with_guard_coords(map) do
    map
    |> Enum.find(fn {_, x} -> MapSet.member?(@guard_glyphs, x) end)
    |> (&({elem(&1, 0), map})).()
  end

  def count_squares({cur_pos, map}, visited_with_direction) do
    cur_direction = Map.fetch!(map, cur_pos)
    next_visited = case Map.fetch(visited_with_direction, cur_pos) do
      :error -> Map.put(visited_with_direction, cur_pos, MapSet.new())
      {:ok, previous_directions} ->
        if MapSet.member?(previous_directions, cur_direction) do
          nil # got in a loop (previously visited the same tile with the same direction)
        else
          Map.put(visited_with_direction, cur_pos, MapSet.put(previous_directions, cur_direction))
        end
    end

    if is_nil(next_visited) do
      nil
    else
      next_square = next_pos(cur_pos, map)

      case map |> Map.fetch(next_square) do
        :error -> map_size(next_visited) # went outside the map
        {:ok, c} ->
          case c do
            "#" -> turn_around(cur_pos, map) |> count_squares(next_visited)
            _ -> advance(cur_pos, map) |> count_squares(next_visited)
          end
      end
    end

  end

  def turn_around(cur_pos, map) do
    map
    |> Map.put(
      cur_pos,
      case map |> Map.fetch!(cur_pos) do
        "^" -> ">"
        ">" -> "v"
        "v" -> "<"
        "<" -> "^"
      end
    )
    |> (&{cur_pos, &1}).()
  end

  def next_pos({cur_y, cur_x} = cur_pos, map) do
    case map |> Map.fetch!(cur_pos) do
      "^" -> {cur_y - 1, cur_x    }
      ">" -> {cur_y    , cur_x + 1}
      "v" -> {cur_y + 1, cur_x    }
      "<" -> {cur_y    , cur_x - 1}
    end
  end

  def advance(cur_pos, map) do
    direction = map |> Map.fetch!(cur_pos)
    next_pos = next_pos(cur_pos, map)
    if map |> Map.has_key?(next_pos) do
      map
      |> Map.put(cur_pos, "X")
      |> Map.put(next_pos, direction)
      |> (&{next_pos, &1}).()
    else
      nil
    end
  end

  def part2() do
    File.stream!("day6-input.txt")
    |> Enum.map(&(String.trim(&1) |> String.graphemes()))
    |> build_map()
    |> with_guard_coords
    |> (&count_loops_with_obstacles(&1, &1, %{}, MapSet.new())).()
  end

  def count_loops_with_obstacles(
    {cur_pos, map},
    {original_guard_pos, original_map} = original_map_with_pos,
    visited_with_direction,
    loops
  ) do
    # same as `count_squares`, but, at each guard movement, we check if putting
    # an obstacle there would cause a loop.
    cur_direction = Map.fetch!(map, cur_pos)
    next_visited =
      if seen?(visited_with_direction, cur_pos, cur_direction) do
          nil # got in a loop (previously visited the same tile with the same direction)
      else
        Map.update(
          visited_with_direction,
          cur_pos,
          MapSet.new([cur_direction]),
          &MapSet.put(&1, cur_direction)
        )
      end

    if is_nil(next_visited) do
      MapSet.size(loops)
    else
      next_square = next_pos(cur_pos, map)

      case map |> Map.fetch(next_square) do
        :error -> MapSet.size(loops) # went outside the map
        {:ok, c} ->
          case c do
            "#" -> turn_around(cur_pos, map) |> count_loops_with_obstacles(original_map_with_pos, next_visited, loops)
            _ ->
              map_with_obstacle = {
                original_guard_pos,
                original_map |> Map.put(next_square, "#")
              }
              next_loops = if (
                next_square != original_guard_pos
                and not seen?(next_visited, next_square, cur_direction)
                and is_nil(count_squares(map_with_obstacle, %{}))
              ) do
                  MapSet.put(loops, next_square)
                else
                  loops
                end

              advance(cur_pos, map) |> count_loops_with_obstacles(original_map_with_pos, next_visited, next_loops)
          end
      end
    end
  end


  def seen?(visited, cur_pos, cur_direction) do
    case Map.fetch(visited, cur_pos) do
      :error -> false
      {:ok, directions} -> MapSet.member?(directions, cur_direction)
    end
  end
end
