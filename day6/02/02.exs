defmodule Problem6 do
  defp transpose(list) do
    list
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end

  defp apply({"+", rest}), do: Enum.sum(rest)
  defp apply({"*", rest}), do: Enum.product(rest)

  defp to_integer(""), do: 0
  defp to_integer(s), do: String.to_integer(s)

  defp trim([s]), do: String.trim(s)

  defp extend_operator([head | rest]) do
    head =
      head
      |> then(fn s -> Regex.scan(~r/\S\s+/, s) end)
      |> Enum.map(&trim/1)

    rest =
      rest
      |> Enum.reverse()
      |> transpose()
      |> Enum.map(&String.trim/1)
      |> Enum.map(&to_integer/1)
      |> Enum.chunk_by(&(&1 == 0))
      |> Enum.filter(&([0] != &1))

    Enum.zip([head, rest])
  end

  def run() do
    [filename | _] = System.argv()

    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> extend_operator()
    |> Enum.map(&apply/1)
    |> Enum.sum()
    |> IO.inspect()
  end
end

Problem6.run()
