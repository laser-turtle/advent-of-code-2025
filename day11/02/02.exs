defmodule Problem10 do
  defp to_node_def(line) do
    [node, edges] = String.split(line, ":", trim: true)
    edges = String.split(edges, " ", trim: true)
    {node, MapSet.new(edges)}
  end

  defp to_graph(lines) do
    lines
    |> Enum.map(&to_node_def/1)
    |> Map.new()
  end

  defp dfs(graph, node, memo, fft, dac) do
    cond do
      node == "out" ->
        c = if fft and dac, do: 1, else: 0
        {c, memo}

      Map.has_key?(memo, {node, fft, dac}) ->
        {memo[{node, fft, dac}], memo}

      true ->
        fft = node == "fft" or fft
        dac = node == "dac" or dac

        edges = graph[node]

        {c, memo} =
          Enum.reduce(edges, {0, memo}, fn v, {count, memo} ->
            {c, memo} = dfs(graph, v, memo, fft, dac)
            memo = Map.put(memo, {v, fft, dac}, c)
            {c + count, memo}
          end)

        {c, memo}
    end
  end

  defp unique_paths(graph, memo \\ %{}) do
    {c, _} = dfs(graph, "svr", memo, false, false)
    c
  end

  def run() do
    [filename | _] = System.argv()

    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> to_graph()
    |> IO.inspect()
    |> unique_paths()
    |> IO.inspect()
  end
end

Problem10.run()
