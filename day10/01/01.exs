defmodule Machine do
  import Bitwise

  @line_regex ~r/\[(?<lights>[.#]+)\]\s*(?<buttons>(?:\([0-9,]+\)\s*)+)\s*\{(?<joltage>[0-9,]+)\}/

  @enforce_keys [:target_lights, :buttons, :joltage]
  defstruct [:target_lights, :buttons, :joltage]

  def new(lights, buttons, joltage) do
    %Machine{
      target_lights: lights,
      buttons: buttons,
      joltage: joltage
    }
  end

  defp l_to_num("."), do: false
  defp l_to_num("#"), do: true

  defp lights_to_num(lights) do
    lights
    |> String.graphemes()
    |> Enum.map(&l_to_num/1)
    |> Enum.with_index()
    |> Enum.filter(fn {v, _} -> v end)
    |> Enum.map(fn {_, idx} -> idx end)
    |> list_to_num(0)
  end

  defp button_to_num(button_str) do
    button_str
    |> String.trim()
    |> String.trim_leading("(")
    |> String.trim_trailing(")")
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> list_to_num(0)
  end

  defp list_to_num([], acc), do: acc

  defp list_to_num([hd | rest], acc) do
    list_to_num(rest, acc + 2 ** hd)
  end

  defp parse_buttons(buttons) do
    buttons
    |> String.split(" ", trim: true)
    |> Enum.map(&button_to_num/1)
  end

  def parse(line) do
    groups = Regex.named_captures(@line_regex, line)

    lights = lights_to_num(groups["lights"])
    buttons = parse_buttons(groups["buttons"])
    joltage = groups["joltage"]

    new(lights, buttons, joltage)
  end

  defp find_sequence_internal(target, current, path, _)
       when target == current,
       do: path

  defp find_sequence_internal(_, _, _, []), do: nil

  defp find_sequence_internal(target, current, path, [hd | rest]) do
    IO.inspect("TARGET #{target} CURRENT #{current}")

    path1 = find_sequence_internal(target, current, path, rest)
    current = bxor(current, hd)
    path2 = find_sequence_internal(target, current, [hd | path], rest)

    case {path1, path2} do
      {nil, nil} ->
        nil

      {left, nil} ->
        left

      {nil, right} ->
        right

      {l, r} ->
        if length(l) < length(r) do
          l
        else
          r
        end
    end
  end

  def find_sequence(
        %Machine{
          target_lights: lights,
          buttons: buttons
        } = _
      ) do
    find_sequence_internal(lights, 0, [], buttons)
  end
end

defmodule Problem10 do
  def run() do
    [filename | _] = System.argv()

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&Machine.parse/1)
    |> Enum.map(&Machine.find_sequence/1)
    |> IO.inspect(charlists: :as_lists)
    |> Enum.map(&length/1)
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()
  end
end

Problem10.run()
