defmodule Block do
  defstruct [:id, :type, :size]
end

defmodule THZ do
  defstruct ll: nil, lx: nil, lr: nil, rl: nil, rx: nil, rr: nil

  @spec new(xs :: list()) :: THZ
  def new([lx, y | ys]) do
    {lr, r} = halve([y | ys])
    [rx | rl] = Enum.reverse(r)
    %THZ{
      ll: [],
      lx: lx,
      lr: lr,
      rl: rl,
      rx: rx,
      rr: []
    }
  end

  def new(_) do
    raise "list must have at least two elements"
  end

  @spec to_list(z :: THZ) :: list()
  def to_list(z) do
    [
      Enum.reverse(z.ll),
      [z.lx | z.lr],
      Enum.reverse(z.rl),
      [z.rx | z.rr]
    ] |> Enum.concat()
  end

  # Movements

  def movell(%THZ{ll: [x | xs]} = z), do: %{z | ll: xs, lx: x, lr: [z.lx | z.lr]}
  def movell(z), do: z

  def movelr(%THZ{lr: [x | xs]} = z), do: %{z | ll: [z.lx | z.ll], lx: x, lr: xs}
  def movelr(%THZ{rl: []} = z), do: z
  def movelr(z) do
    [lx | lr] = Enum.reverse(z.rl)
    %{z | lr: lr, rl: [], lx: lx, ll: [z.lx | z.ll]}
  end

  def moverl(%THZ{rl: [x | xs]} = z), do: %{z | rl: xs, rx: x, rr: [z.rx | z.rr]}
  def moverl(%THZ{lr: []} = z), do: z
  def moverl(z) do
    [rx | rl] = Enum.reverse(z.lr)
    %{z | lr: [], rl: rl, rx: rx, rr: [z.rx | z.rr]}
  end

  def moverr(%THZ{rr: [x | xs]} = z), do: %{z | rl: [z.rx | z.rl], rx: x, rr: xs}
  def moverr(z), do: z

  # Utils

  def halve(xs), do: halve(xs, xs)
  def halve([x|xs], [_, _ | ys]) do
    {l, r} = halve(xs, ys)
    {[x | l], r}
  end
  def halve(l, _), do: {[], l}
end

defmodule Day9 do
  def part1() do
    File.read!("day9-input.txt")
    |> String.graphemes()
    |> Enum.map(&String.to_integer(&1))
    |> Enum.with_index()
    |> read_blocks()
    |> defrag()
    |> Enum.flat_map(&List.duplicate(&1.id, &1.size))
    |> Enum.with_index()
    |> Enum.filter(fn {id, _} -> not is_nil(id) end)
    |> Enum.map(fn {id, i} -> id * i end)
    |> Enum.sum()
  end

  def read_blocks(blocks, file_index \\ 0)
  def read_blocks([], _), do: []
  def read_blocks([{size, position} | rest], file_index) do
    cond do
      size == 0 -> read_blocks(rest, file_index)

      rem(position, 2) == 0 ->
        [
          %Block{
            id: file_index,
            type: :file,
            size: size,
          }
          | read_blocks(rest, file_index + 1)
        ]

      true ->
        [
          %Block{
            id: nil,
            type: :space,
            size: size,
          }
          | read_blocks(rest, file_index)
        ]
    end
  end

  def show_blocks(blocks, quote \\ false)
  def show_blocks(blocks, quote) do
    blocks
    |> Enum.flat_map(
      fn block ->
        List.duplicate(block.id || ".", block.size)
        |> (&if quote do ["\"" | &1] ++ ["\""] else &1 end).()
      end
    )
    |> Enum.join()
  end

  def defrag(blocks), do: defrag(blocks, Enum.reverse(blocks), 0, length(blocks) - 1)

  def defrag(forward, reversed, forward_index, reversed_index) do
    cond do
      # stop once we've crossed over the indices.
      forward_index >= reversed_index -> [ reversed |> hd ]

      # or if we've gone through all of the blocks
      Enum.empty?(forward) -> []

      # otherwise, inspect the current indices
      true -> case {forward, reversed} do
        # If we already have a file in a slot, move forward.
        {[%Block{type: :file} = f | rest], _} ->
          [ f | defrag(rest, reversed, forward_index + 1, reversed_index) ]

        # If there's no file at the end, look further backwards.
        {_, [%Block{type: :space} | rest]} ->
          defrag(forward, rest, forward_index, reversed_index - 1)

        # Otherwise, fill in the current space as best as possible with the file.
        {[space | rest], [file | rest_reversed]} ->
          cond do
            # If there's not enough space, move over only a part of the file and
            # move forward.
            space.size < file.size ->
              new_file_block = %{file | size: space.size }
              remaining_file_block = %{file | size: file.size - space.size}
              [
                new_file_block
                | defrag(
                  rest,
                  [ remaining_file_block | rest_reversed ],
                  forward_index + 1,
                  reversed_index
                )
              ]

            # If there's excess space, move over the entire file and move backwards.
            space.size > file.size ->
              new_space_block = %{space | size: space.size - file.size}
              [
                file
                | defrag(
                  [new_space_block | rest],
                  rest_reversed,
                  forward_index,
                  reversed_index - 1
                )
              ]

            # Otherwise, just move over the entire file and keep going forward.
            true ->
            [
              file
              | defrag(
                rest,
                rest_reversed,
                forward_index + 1, reversed_index - 1
              )
            ]
          end
      end
    end
  end

  def part2() do
    File.read!("day9-input.txt")
    |> String.graphemes()
    |> Enum.map(&String.to_integer(&1))
    |> Enum.with_index()
    |> read_blocks()
    |> Enum.reverse()
    |> defrag2()
    |> Enum.reverse()
    |> Enum.flat_map(&List.duplicate(&1.id, &1.size))
    |> Enum.with_index()
    |> Enum.filter(fn {id, _} -> not is_nil(id) end)
    |> Enum.map(fn {id, i} -> id * i end)
    |> Enum.sum()
  end

  def defrag2([]), do: []
  def defrag2([%Block{type: :space} = x | xs]), do: [x | defrag2(xs)]
  def defrag2([x | xs]) do
    {y, ys} = rotate(x, Enum.reverse(xs))
    [y | defrag2(Enum.reverse(ys))]
  end

  def rotate(x, []), do: {x, []}
  def rotate(x, [%Block{type: :file} = y | ys]) do
    {z, zs} = rotate(x, ys)
    {z, [y | zs]}
  end
  def rotate(x, [y | ys]) do
    cond do
      x.size == y.size -> {y, [x | ys]}
      x.size < y.size -> {%{y | size: x.size}, [x, %{y | size: y.size - x.size} | ys]}
      true ->
        {z, zs} = rotate(x, ys)
        {z, [y | zs]}
    end
  end
end

