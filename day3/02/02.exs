defmodule Problem3 do
  @target_length 12

  defp max_substring(str) do
    str
    |> String.graphemes()
    |> Stream.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.max_by(fn {digit, _index} -> digit end)
  end

  defp find_max(bank) do
    len = String.length(bank)

    Enum.reduce(@target_length..1//-1, {0, 0}, fn offset, {total, last} ->
      rem = len - last - offset + 1

      s = String.slice(bank, last, rem)

      {value, idx} = max_substring(s)

      value = value * Integer.pow(10, offset - 1)

      {total + value, last + idx + 1}
    end)
    |> elem(0)
  end

  def run() do
    [filename | _] = System.argv()

    total =
      File.stream!(filename, [:utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Stream.map(&find_max/1)
      |> Enum.sum()

    IO.inspect("TOTAL #{total}")
  end
end

Problem3.run()
