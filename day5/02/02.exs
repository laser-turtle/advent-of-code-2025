defmodule Problem5 do
  defp convert_ranges(ranges) do
    ranges
    |> Enum.map(fn s -> String.split(s, "-") end)
    |> Enum.map(fn [a, b] -> String.to_integer(a)..String.to_integer(b) end)
    |> Enum.sort()
    |> IO.inspect()
  end

  defp merge_ranges(ranges) do
    Enum.chunk_while(
      ranges,
      Enum.at(ranges, 0),
      fn elem, acc ->
        IO.puts("ELEM #{inspect(elem)} ACC #{inspect(acc)}")

        if Range.disjoint?(elem, acc) do
          {:cont, acc, elem}
        else
          {:cont, min(acc.first, elem.first)..max(acc.last, elem.last)}
        end
      end,
      fn acc -> {:cont, acc, acc} end
    )
  end

  defp count_nums_in_ranges(ranges) do
    ranges
    |> Enum.map(fn r -> r.last - r.first + 1 end)
    |> Enum.sum()
  end

  defp count_ranges(ranges) do
    ranges
    |> convert_ranges()
    |> merge_ranges()
    |> IO.inspect()
    |> count_nums_in_ranges()
  end

  def run() do
    [filename | _] = System.argv()

    {ranges, _} =
      File.stream!(filename, [:utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Enum.split_while(fn x -> x != "" end)

    IO.inspect(ranges)
    IO.inspect(count_ranges(ranges))
  end
end

Problem5.run()
