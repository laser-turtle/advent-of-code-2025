Code.require_file("../../lib/matrix.ex", __DIR__)

defmodule Problem7 do
  defp propagate(%Matrix{dim_x: dim_x, dim_y: dim_y} = mat) do
    # Loop through, if S then we add a | below us
    # if ^ we check above and add bars to the left and right
    IO.inspect("#{dim_x} #{dim_y} #{length(Matrix.keys(mat))}")

    Matrix.reduce(mat, fn {x, y} = coord, acc ->
      v = Matrix.get(acc, coord)

      cond do
        v == "S" ->
          Matrix.put(acc, {x, y + 1}, "|")

        v == "^" && Matrix.get(acc, {x, y - 1}) == "|" ->
          Matrix.put_many(
            acc,
            [
              {{x - 1, y}, "|"},
              {{x + 1, y}, "|"}
            ]
          )

        v == "." && Matrix.get(acc, {x, y - 1}) == "|" ->
          Matrix.put(acc, coord, "|")

        true ->
          acc
      end
    end)
  end

  defp count_splits(%Matrix{} = mat) do
    Matrix.reduce(mat, 0, fn {x, y} = coord, mat, count ->
      v = Matrix.get(mat, coord)

      cond do
        v == "^" && Matrix.get(mat, {x, y - 1}) == "|" -> count + 1
        true -> count
      end
    end)
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
