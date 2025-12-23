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

  defp dfs(start, last, graph, memo) do
    cond do
      start == last ->
        {1, memo}

      Map.has_key?(memo, start) ->
        {memo[start], memo}

      true ->
        edges = graph[start]

        Enum.reduce(edges, {0, memo}, fn v, {count, memo} ->
          {c, memo} = dfs(v, last, graph, memo)
          memo = Map.put(memo, v, c)
          {count + c, memo}
        end)
    end
  end

  defp unique_paths(graph, memo \\ %{}) do
    {count, _} = dfs("you", "out", graph, memo)
    count
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
