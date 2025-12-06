defmodule Problem1 do
  def one_iteration("L" <> rest, {current, count}) do
    num = String.to_integer(rest)
    current = Integer.mod(current - num, 100)

    count =
      if current == 0 do
        count + 1
      else
        count
      end

    IO.inspect("L #{num} #{current} #{count}")
    {current, count}
  end

  def one_iteration("R" <> rest, {current, count}) do
    num = String.to_integer(rest)
    current = Integer.mod(current + num, 100)

    count =
      if current == 0 do
        count + 1
      else
        count
      end

    IO.inspect("R #{num} #{current} #{count}")
    {current, count}
  end

  def run() do
    filename = Enum.at(System.argv(), 0)

    result =
      File.stream!(filename, [:read, :utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Enum.reduce({50, 0}, &one_iteration/2)
      |> elem(1)

    IO.inspect(result)
  end
end

Problem1.run()
