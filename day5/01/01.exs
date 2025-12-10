defmodule Problem5 do
  defp convert_ranges(ranges) do
    ranges
    |> Enum.map(fn s -> String.split(s, "-") end)
    |> Enum.map(fn [a, b] -> String.to_integer(a)..String.to_integer(b) end)
    |> IO.inspect()
  end

  defp is_fresh(ingredient, ranges) do
    Enum.any?(ranges, fn r -> ingredient in r end)
  end

  defp count_fresh_ingredients(ranges, ingredients) do
    ranges = convert_ranges(ranges)
    ingredients = Enum.map(ingredients, &String.to_integer/1)

    ingredients
    |> Enum.filter(&is_fresh(&1, ranges))
    |> IO.inspect()
    |> Enum.count()
  end

  def run() do
    [filename | _] = System.argv()

    {ranges, [_ | ingredients]} =
      File.stream!(filename, [:utf8], :line)
      |> Stream.map(&String.trim/1)
      |> Enum.split_while(fn x -> x != "" end)

    IO.inspect(ranges)
    IO.inspect(ingredients)
    IO.inspect("COUNT #{count_fresh_ingredients(ranges, ingredients)}")
  end
end

Problem5.run()
