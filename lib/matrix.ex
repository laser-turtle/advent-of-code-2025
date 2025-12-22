defmodule Matrix do
  @enforce_keys [:map, :dim_x, :dim_y]
  defstruct [:map, :dim_x, :dim_y, show_quotes: true]

  @behaviour Access

  def new(input, opts \\ []) do
    [row | _] = input
    dim_x = length(row)
    dim_y = length(input)

    map =
      for {r, y} <- Enum.with_index(input), {elem, x} <- Enum.with_index(r), into: %{} do
        {{x, y}, elem}
      end

    %Matrix{
      map: map,
      dim_x: dim_x,
      dim_y: dim_y,
      show_quotes: Keyword.get(opts, :show_quotes, true)
    }
  end

  def get(%Matrix{map: map}, {x, y}, default \\ nil) do
    Map.get(map, {x, y}, default)
  end

  def put(%Matrix{map: map} = matrix, {x, y}, value) do
    %{matrix | map: Map.put(map, {x, y}, value)}
  end

  def update!(%Matrix{map: map} = matrix, {x, y}, fun) do
    %{matrix | map: Map.update!(map, {x, y}, fun)}
  end

  def update(%Matrix{map: map} = matrix, {x, y}, default, fun) do
    %{matrix | map: Map.update(map, {x, y}, default, fun)}
  end

  def delete(%Matrix{map: map} = matrix, {x, y}) do
    %{matrix | map: Map.delete(map, {x, y})}
  end

  def has_key?(%Matrix{map: map}, {x, y}) do
    Map.has_key?(map, {x, y})
  end

  def values(%Matrix{map: map}) do
    Map.values(map)
  end

  def keys(%Matrix{map: map}) do
    Map.keys(map)
  end

  def map(%Matrix{map: map} = matrix, fun) do
    %{matrix | map: Map.new(map, fn {k, v} -> {k, fun.(v)} end)}
  end

  def get_row(%Matrix{map: map, dim_x: dim_x}, y) do
    for x <- 0..(dim_x - 1) do
      Map.get(map, {x, y})
    end
  end

  def get_col(%Matrix{map: map, dim_y: dim_y}, x) do
    for y <- 0..(dim_y - 1) do
      Map.get(map, {x, y})
    end
  end

  def get_region(%Matrix{map: map}, {x1, y1}, {x2, y2}) do
    new_dim_x = x2 - x1 + 1
    new_dim_y = y2 - y1 + 1

    new_map =
      for y <- y1..y2, x <- x1..x2, into: %{} do
        # Map old coordinates to new coordinates (starting from 0,0)
        new_x = x - x1
        new_y = y - y1
        value = Map.get(map, {x, y})
        {{new_x, new_y}, value}
      end

    %Matrix{map: new_map, dim_x: new_dim_x, dim_y: new_dim_y}
  end

  def get_region_as_list(%Matrix{map: map}, {x1, y1}, {x2, y2}) do
    for y <- y1..y2 do
      for x <- x1..x2 do
        Map.get(map, {x, y})
      end
    end
  end

  def put_row(%Matrix{map: map, dim_x: dim_x} = matrix, y, values) when length(values) == dim_x do
    new_map =
      Enum.with_index(values)
      |> Enum.reduce(map, fn {value, x}, acc ->
        Map.put(acc, {x, y}, value)
      end)

    %{matrix | map: new_map}
  end

  def put_col(%Matrix{map: map, dim_y: dim_y} = matrix, x, values) when length(values) == dim_y do
    new_map =
      Enum.with_index(values)
      |> Enum.reduce(map, fn {value, y}, acc ->
        Map.put(acc, {x, y}, value)
      end)

    %{matrix | map: new_map}
  end

  # Put a source matrix into this matrix at the specified starting position
  # The source matrix's {0, 0} will be placed at {start_x, start_y}
  def put_region(
        %Matrix{map: map, dim_x: dim_x, dim_y: dim_y} = target,
        {start_x, start_y},
        %Matrix{} = source
      ) do
    new_map =
      for y <- 0..(source.dim_y - 1), x <- 0..(source.dim_x - 1), reduce: map do
        acc_map ->
          target_x = start_x + x
          target_y = start_y + y

          # Only update if within bounds
          if target_x >= 0 and target_x < dim_x and target_y >= 0 and target_y < dim_y do
            source_value = Map.get(source.map, {x, y})
            Map.put(acc_map, {target_x, target_y}, source_value)
          else
            acc_map
          end
      end

    %{target | map: new_map}
  end

  # Put a 2D list into the matrix at the specified starting position
  def put_region(
        %Matrix{map: map, dim_x: dim_x, dim_y: dim_y} = target,
        {start_x, start_y},
        list_2d
      )
      when is_list(list_2d) do
    new_map =
      for {row, y} <- Enum.with_index(list_2d),
          {value, x} <- Enum.with_index(row),
          reduce: map do
        acc_map ->
          target_x = start_x + x
          target_y = start_y + y

          # Only update if within bounds
          if target_x >= 0 and target_x < dim_x and target_y >= 0 and target_y < dim_y do
            Map.put(acc_map, {target_x, target_y}, value)
          else
            acc_map
          end
      end

    %{target | map: new_map}
  end

  def reduce(%Matrix{dim_x: dim_x, dim_y: dim_y} = matrix, fun) do
    for y <- 0..(dim_y - 1), x <- 0..(dim_x - 1), reduce: matrix do
      acc_matrix -> fun.({x, y}, acc_matrix)
    end
  end

  def reduce(%Matrix{dim_x: dim_x, dim_y: dim_y} = matrix, acc, fun) do
    for y <- 0..(dim_y - 1), x <- 0..(dim_x - 1), reduce: acc do
      current_acc -> fun.({x, y}, matrix, current_acc)
    end
  end

  def map_with_index(%Matrix{map: map, dim_x: dim_x, dim_y: dim_y} = matrix, fun) do
    new_map =
      for y <- 0..(dim_y - 1), x <- 0..(dim_x - 1), into: %{} do
        current_value = Map.get(map, {x, y})
        {{x, y}, fun.({x, y}, current_value)}
      end

    %{matrix | map: new_map}
  end

  def reduce_with_acc(%Matrix{dim_x: dim_x, dim_y: dim_y} = matrix, acc, fun) do
    for y <- 0..(dim_y - 1), x <- 0..(dim_x - 1), reduce: {matrix, acc} do
      {current_matrix, current_acc} -> fun.({x, y}, current_matrix, current_acc)
    end
  end

  def map_reduce(%Matrix{dim_x: dim_x, dim_y: dim_y} = matrix, acc, fun) do
    reduce_with_acc(matrix, acc, fun)
  end

  def transform(%Matrix{} = matrix, fun) do
    map_with_index(matrix, fun)
  end

  def fill(%Matrix{map: map} = matrix, value) do
    new_map = Map.new(map, fn {k, _v} -> {k, value} end)
    %{matrix | map: new_map}
  end

  def fill_region(%Matrix{} = matrix, {x1, y1}, {x2, y2}, value) do
    new_map =
      for y <- y1..y2, x <- x1..x2, reduce: matrix.map do
        acc_map -> Map.put(acc_map, {x, y}, value)
      end

    %{matrix | map: new_map}
  end

  def put_many(%Matrix{map: map} = matrix, updates) when is_list(updates) do
    new_map =
      Enum.reduce(updates, map, fn {{x, y}, value}, acc ->
        Map.put(acc, {x, y}, value)
      end)

    %{matrix | map: new_map}
  end

  def each_with_index(%Matrix{dim_x: dim_x, dim_y: dim_y} = matrix, fun) do
    for y <- 0..(dim_y - 1), x <- 0..(dim_x - 1) do
      value = Map.get(matrix.map, {x, y})
      fun.({x, y}, value)
    end

    matrix
  end

  def reduce_rows(%Matrix{dim_x: dim_x, dim_y: dim_y} = matrix, acc, fun) do
    for y <- 0..(dim_y - 1), reduce: acc do
      row_acc ->
        row = for x <- 0..(dim_x - 1), do: Map.get(matrix.map, {x, y})
        fun.(y, row, row_acc)
    end
  end

  def reduce_cols(%Matrix{dim_x: dim_x, dim_y: dim_y} = matrix, acc, fun) do
    for x <- 0..(dim_x - 1), reduce: acc do
      col_acc ->
        col = for y <- 0..(dim_y - 1), do: Map.get(matrix.map, {x, y})
        fun.(x, col, col_acc)
    end
  end

  @impl Access
  def fetch(%Matrix{map: map}, {x, y} = key) when is_integer(x) and is_integer(y) do
    Map.fetch(map, key)
  end

  @impl Access
  def get_and_update(%Matrix{map: map} = matrix, {x, y} = key, function)
      when is_integer(x) and is_integer(y) do
    {get_value, new_map} = Map.get_and_update(map, key, function)
    {get_value, %{matrix | map: new_map}}
  end

  @impl Access
  def pop(%Matrix{map: map} = matrix, {x, y} = key)
      when is_integer(x) and is_integer(y) do
    {value, new_map} = Map.pop(map, key)
    {value, %{matrix | map: new_map}}
  end

  defimpl Inspect, for: Matrix do
    def inspect(%Matrix{map: map, dim_x: dim_x, dim_y: dim_y, show_quotes: show_quotes}, _opts) do
      # Function to format elements based on show_quotes
      format_elem = fn elem ->
        if show_quotes do
          Kernel.inspect(elem)
        else
          try do
            to_string(elem)
          rescue
            Protocol.UndefinedError -> Kernel.inspect(elem)
          end
        end
      end

      # Calculate the maximum width needed for each column
      column_widths =
        for x <- 0..(dim_x - 1) do
          for y <- 0..(dim_y - 1) do
            elem = Map.get(map, {x, y}, "")
            elem |> format_elem.() |> String.length()
          end
          |> Enum.max()
        end

      # Build each row with proper padding
      rows =
        for y <- 0..(dim_y - 1) do
          row_items =
            for x <- 0..(dim_x - 1) do
              elem = Map.get(map, {x, y}, "")
              elem_str = format_elem.(elem)
              width = Enum.at(column_widths, x)
              String.pad_trailing(elem_str, width)
            end

          joiner = if show_quotes, do: " ", else: ""
          "  " <> Enum.join(row_items, joiner)
        end

      # Combine everything
      header = "%Matrix{#{dim_x}x#{dim_y},"
      body = Enum.join(rows, "\n")
      footer = "}"

      [header, body, footer] |> Enum.join("\n")
    end
  end
end
