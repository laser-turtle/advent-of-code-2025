defmodule Problem3 do
  defp max_substring(str) do
    IO.inspect("Searching #{str}")

    str
    |> String.graphemes()
    |> Stream.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce(fn {elem, elem_idx}, {max, max_idx} ->
      if elem > max do
        {elem, elem_idx}
      else
        {max, max_idx}
      end
    end)
  end

  defp find_max(bank) do
    IO.inspect("Bank #{bank}")

    # Left max
    {left, lidx} =
      bank
      |> String.slice(0..-2//1)
      |> max_substring()

    {right, _} =
      bank
      |> String.slice((lidx + 1)..-1//1)
      |> max_substring()

    left * 10 + right
  end

  def run() do
    [filename | _] = System.argv()

    total =
      File.stream!(filename, [:read, :utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&find_max/1)
      |> Enum.to_list()
      |> Enum.sum()

    IO.inspect("TOTAL #{total}")
  end
end

Problem3.run()
