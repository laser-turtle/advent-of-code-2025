defmodule Problem2 do
  defp chunk(str, size) do
    str
    |> String.graphemes()
    |> Enum.chunk_every(size)
    |> Enum.map(&Enum.join/1)
  end

  defp all_same?(list), do: length(Enum.uniq(list)) <= 1

  defp check(str, size) do
    str
    |> chunk(size)
    |> all_same?()
  end

  defp matches?(str) do
    len2 = String.length(str) |> div(2)

    Enum.any?(Range.new(len2, 1, -1), &check(str, &1))
  end

  defp check_number(number) do
    [from, to] = String.split(number, "-")

    from = String.to_integer(from)
    to = String.to_integer(to)

    from..to
    |> Enum.filter(&matches?(Integer.to_string(&1)))
    |> Enum.sum()
  end

  defp read() do
    [filename | _] = System.argv()

    IO.inspect(filename)

    ranges =
      File.read!(filename)
      |> String.replace("\n", "")
      |> String.split(",")
      |> Enum.to_list()
      |> Enum.map(&check_number/1)
      |> Enum.reduce(0, &+/2)

    IO.inspect(ranges)
  end

  def run() do
    read()
  end
end

Problem2.run()
