defmodule Problem6 do
  defp transpose(list) do
    list
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)
  end

  defp as_numbers(list), do: Enum.map(list, &String.to_integer/1)
  defp apply(["+" | rest]), do: Enum.sum(as_numbers(rest))
  defp apply(["*" | rest]), do: Enum.product(as_numbers(rest))

  def run() do
    [filename | _] = System.argv()

    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> String.split(s, " ", trim: true) end)
    |> transpose()
    |> Enum.map(&apply/1)
    |> Enum.sum()
    |> IO.inspect()
  end
end

Problem6.run()
