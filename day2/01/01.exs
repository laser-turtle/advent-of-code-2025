defmodule Problem2 do
  defp split(str) do
    len = String.length(str)

    if Integer.mod(len, 2) == 1 do
      {0, 1}
    else
      len2 = div(len, 2)
      left = String.slice(str, 0, len2)

      start = if Integer.mod(len, 2) == 1, do: len2 + 1, else: len2
      right = String.slice(str, start, len2)

      {left, right}
    end
  end

  defp matches(num) do
    {left, right} = split(num)
    left == right
  end

  defp check_number(number) do
    [from, to] = String.split(number, "-")

    from = String.to_integer(from)
    to = String.to_integer(to)

    Enum.reduce(from..to, 0, fn i, acc ->
      if matches(Integer.to_string(i)) do
        acc + i
      else
        acc
      end
    end)
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
