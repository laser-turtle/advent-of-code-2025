defmodule Circuits do
  @enforce_keys [:circuits, :next, :directs]
  defstruct [:circuits, :next, :directs]

  def new(base_coords) do
    map =
      for {value, index} <- Enum.with_index(base_coords), into: %{} do
        {value, index}
      end

    %Circuits{
      circuits: map,
      next: Enum.count(base_coords),
      directs: MapSet.new()
    }
  end

  def connected?(%Circuits{circuits: map}, value1, value2) do
    v1 = map[value1]
    v2 = map[value2]
    v1 != nil and v2 != nil and v1 == v2
  end

  def directly_connected?(%Circuits{directs: directs}, c1, c2) do
    [c1, c2] = Enum.sort([c1, c2])
    MapSet.member?(directs, {c1, c2})
  end

  def any_missing?(%Circuits{circuits: map}, list),
    do: not Enum.all?(list, &Map.has_key?(map, &1))

  defp add_direct(%Circuits{directs: directs} = circuits, c1, c2) do
    [c1, c2] = Enum.sort([c1, c2])
    %{circuits | directs: MapSet.put(directs, {c1, c2})}
  end

  def add_connection(
        %Circuits{circuits: map, next: next} = circuits,
        value1,
        value2
      ) do
    v1 = map[value1]
    v2 = map[value2]

    case {v1, v2} do
      {nil, nil} ->
        map = Map.put(map, value1, next)
        map = Map.put(map, value2, next)
        %{circuits | circuits: map, next: next + 1}

      {c, nil} ->
        map = Map.put(map, value2, c)
        %{circuits | circuits: map}

      {nil, c} ->
        map = Map.put(map, value1, c)
        %{circuits | circuits: map}

      {c1, c2} when c1 == c2 ->
        circuits

      {c1, c2} when c1 != c2 ->
        keys = get_coords_for_circuit(circuits, c2)
        assign_circuit(circuits, keys, c1)
    end
    |> add_direct(value1, value2)
  end

  def assign_circuit(%Circuits{circuits: map} = circuit, coords, new_circuit) do
    map =
      coords
      |> Enum.reduce(map, fn c, m -> Map.replace(m, c, new_circuit) end)

    %Circuits{circuit | circuits: map}
  end

  def get_coords_for_circuit(%Circuits{circuits: map}, circuit_num) do
    map
    |> Map.keys()
    |> Enum.filter(fn c -> map[c] == circuit_num end)
  end

  def direct_connection_count(%Circuits{directs: directs}), do: MapSet.size(directs)

  def count(%Circuits{circuits: map}) do
    map
    |> Map.values()
    |> MapSet.new()
    |> MapSet.size()
  end

  def get_circuits(%Circuits{circuits: map}) do
    map
    |> Map.to_list()
    |> Enum.group_by(fn {_, value} -> value end, fn {key, _} -> key end)
  end
end

defmodule Problem8 do
  # Need to track circuits
  # Need to track unconnected boxes
  # When merging two boxes need to merge circuits
  #
  def to_coord(s) when is_binary(s) do
    s
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp distance({x1, y1, z1}, {x2, y2, z2}) do
    (x2 - x1) ** 2 + (y2 - y1) ** 2 + (z2 - z1) ** 2
  end

  defp find_closest(%MapSet{} = coords, %Circuits{} = circuits) do
    coords
    |> Enum.reduce(nil, fn value1, closest ->
      Enum.reduce(coords, closest, fn value2, closest ->
        cond do
          value1 == value2 ->
            closest

          # If already connected, skip
          Circuits.directly_connected?(circuits, value1, value2) ->
            closest

          true ->
            dist = distance(value1, value2)

            case closest do
              nil -> {value1, value2, dist}
              {_, _, c_dist} when dist < c_dist -> {value1, value2, dist}
              _ -> closest
            end
        end
      end)
    end)
  end

  defp merge_circuits(circuits, %MapSet{} = coords) do
    case find_closest(coords, circuits) do
      {c1, c2, _} ->
        IO.inspect("#{inspect(c1)} #{inspect(c2)}")

        circuits =
          circuits
          |> Circuits.add_connection(c1, c2)

        size = map_size(Circuits.get_circuits(circuits))
        IO.inspect("Size #{size}")

        if size == 1 do
          {{x1, _, _}, {x2, _, _}} = {c1, c2}
          x1 * x2
        else
          merge_circuits(circuits, coords)
        end

      nil ->
        circuits
    end
  end

  def run() do
    [filename | _] = System.argv()

    coords =
      filename
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&to_coord/1)
      |> IO.inspect()
      |> MapSet.new()

    circuits =
      merge_circuits(Circuits.new(coords), coords)
      |> IO.inspect(limit: :infinity)
  end
end

Problem8.run()
