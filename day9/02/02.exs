defmodule Problem9 do
  defp to_coord(s) do
    s
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp area({x1, y1}, {x2, y2}) do
    x_l = min(x1, x2)
    x_r = max(x1, x2) + 1
    y_t = min(y1, y2)
    y_b = max(y1, y2) + 1

    (y_b - y_t) * (x_r - x_l)
  end

  defp find_area(coords) do
    Enum.reduce(coords, 0, fn c1, max ->
      Enum.reduce(coords, max, fn c2, max ->
        a = area(c1, c2)
        if a > max, do: a, else: max
      end)
    end)
  end

  def run() do
    [filename | _] = System.argv()

    coords =
      filename
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&to_coord/1)
      |> Enum.sort()

    c1 = List.first(coords)
    c2 = List.last(coords)

    IO.inspect(c1)
    IO.inspect(c2)
    IO.inspect(area(c1, c2))
  end
end

Problem9.run()
