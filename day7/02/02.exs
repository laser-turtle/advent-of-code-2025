Code.require_file("../../lib/matrix.ex", __DIR__)

defmodule Problem7 do
  def cast(cell) when is_binary(cell) do
    case Integer.parse(cell) do
      {i, ""} -> i
      _ -> 0
    end
  end

  def cast(cell) when is_integer(cell), do: cell

  defp propagate(%Matrix{dim_x: dim_x, dim_y: dim_y} = mat) do
    # Loop through, if S then we add a | below us
    # if ^ we check above and add bars to the left and right
    IO.inspect("#{dim_x} #{dim_y} #{length(Matrix.keys(mat))}")

    Matrix.reduce(mat, fn {x, y} = coord, acc ->
      v = acc[coord]

      cond do
        v == "S" ->
          Matrix.put(acc, {x, y + 1}, 1)

        v == "^" && is_integer(acc[{x, y - 1}]) ->
          l = acc[{x - 1, y}]
          r = acc[{x + 1, y}]
          a = acc[{x, y - 1}]

          Matrix.put_many(
            acc,
            [
              {{x - 1, y}, a + cast(l)},
              {{x + 1, y}, a + cast(r)}
            ]
          )

        v == "." && is_integer(acc[{x, y - 1}]) ->
          Matrix.put(acc, coord, acc[{x, y - 1}])

        is_integer(v) && is_integer(acc[{x, y - 1}]) ->
          a = acc[{x, y - 1}]
          c = acc[coord]
          Matrix.put(acc, coord, a + c)

        true ->
          acc
      end
    end)
  end

  defp count_splits(%Matrix{dim_y: dim_y} = mat) do
    mat
    |> Matrix.get_row(dim_y - 1)
    |> Enum.filter(&is_integer/1)
    |> Enum.sum()
  end

  def run() do
    [filename | _] = System.argv()

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Matrix.new(show_quotes: false)
    |> IO.inspect()
    |> propagate()
    |> IO.inspect()
    |> count_splits()
    |> IO.inspect()
  end
end

Problem7.run()
