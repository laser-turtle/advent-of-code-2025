defmodule Problem4 do
  defp to_map(lines) do
    map =
      Enum.reduce(lines, %{}, fn {content, y}, map ->
        content = String.graphemes(content)

        content
        |> Enum.with_index()
        |> Enum.reduce(map, fn {char, x}, map ->
          Map.put(map, {x, y}, char)
        end)
      end)

    map
  end

  defp neighbors(map, x, y) do
    if map[{x, y}] != "@" do
      map[{x, y}]
    else
      neighbors = [
        map[{x - 1, y}],
        map[{x + 1, y}],
        map[{x - 1, y - 1}],
        map[{x + 1, y - 1}],
        map[{x - 1, y + 1}],
        map[{x + 1, y + 1}],
        map[{x, y - 1}],
        map[{x, y + 1}]
      ]

      count =
        neighbors
        |> Enum.map(&(&1 == "@"))
        |> Enum.filter(&(&1 == true))
        |> Enum.count()

      if count < 4 do
        "x"
      else
        map[{x, y}]
      end
    end
  end

  defp count_positions(map) do
    list =
      for {{x, y}, _} <- map, into: %{} do
        {{x, y}, neighbors(map, x, y)}
      end

    keys = Enum.sort_by(Map.keys(list), fn {x, y} -> {y, x} end)

    for {x, y} <- keys do
      IO.write(list[{x, y}])

      if x == 9 do
        IO.puts("")
      end
    end

    list
  end

  defp count_x(map) do
    map
    |> Map.values()
    |> Enum.filter(&(&1 == "x"))
    |> Enum.count()
  end

  defp remove_while(map, acc) do
    map = count_positions(map)
    count = count_x(map)

    if count != acc do
      remove_while(map, count)
    else
      acc
    end
  end

  def run() do
    [filename | _] = System.argv()

    result =
      File.stream!(filename, [:utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.to_list()
      |> to_map()
      |> remove_while(0)

    IO.inspect("RESULT #{result}")
  end
end

Problem4.run()
