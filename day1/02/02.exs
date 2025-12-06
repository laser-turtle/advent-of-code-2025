defmodule Problem1 do
  def compute(_, current, count, 0), do: {current, count}

  def compute(dir, current, count, times) do
    current = Integer.mod(current + dir, 100)
    count = if current == 0, do: count + 1, else: count

    compute(
      dir,
      current,
      count,
      times - 1
    )
  end

  def one_iteration("L" <> rest, {current, count}),
    do: compute(-1, current, count, String.to_integer(rest))

  def one_iteration("R" <> rest, {current, count}),
    do: compute(1, current, count, String.to_integer(rest))

  def run() do
    [filename | _] = System.argv()

    result =
      File.stream!(filename, [:read, :utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Enum.reduce({50, 0}, &one_iteration/2)
      |> elem(1)

    IO.inspect(result)
  end
end

Problem1.run()
