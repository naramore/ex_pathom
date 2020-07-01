defmodule Digraph do
  @moduledoc """
  TENTATIVE, NAIVE, UNOPTIMIZED, INCOMPLETE
  """
  use Boundary, deps: [EQL], exports: []
  import Kernel, except: [update_in: 3]
  alias EQL.AST.{Join, Property, Root, Union, Union.Entry}
  require Logger

  defstruct graph: nil,
            vertices: [],
            edges: [],
            options: []

  @type t :: %__MODULE__{
          graph: :digraph.graph(),
          vertices: [vertex],
          edges: [edge],
          options: [:digraph.d_type()]
        }

  @type vertex :: {:digraph.vertex(), :digraph.label()}
  @type edge :: {:digraph.edge(), :digraph.vertex(), :digraph.vertex(), :digraph.label()}

  @spec from_digraph(:digraph.graph()) :: t
  def from_digraph(dg) do
    {options, _} = Keyword.split(:digraph.info(dg), [:cyclicity, :protection])

    %__MODULE__{
      graph: dg,
      vertices: Enum.map(:digraph.vertices(dg), &:digraph.vertex(dg, &1)),
      edges: Enum.map(:digraph.edges(dg), &:digraph.edge(dg, &1)),
      options: Keyword.values(options)
    }
  end

  def resolver(id, input, output \\ []) do
    %{
      id: id,
      input: input,
      output: output
    }
  end

  def graph([], dg), do: dg

  def graph([res | t], dg) do
    [i | _] =
      input =
      case res.input do
        [x] -> [x]
        x -> [x | x]
      end

    labels = output_info(res)
    output = Enum.map(labels, &Map.get(&1, :id))
    _ = Enum.each(input, &:digraph.add_vertex(dg, &1))
    _ = Enum.each(output, &:digraph.add_vertex(dg, &1))
    _ = Enum.each(labels, &:digraph.add_edge(dg, i, &1.id, %{&1 | id: res.id}))

    graph(t, dg)
  end

  def update_in(data, [], fun), do: fun.(data)

  def update_in(data, path, fun) do
    Kernel.update_in(data, path, fun)
  end

  def output_info(resolver) do
    resolver.output
    |> EQL.query_to_ast()
    |> elem(1)
    |> output_info(0, [], nil)
    |> Enum.map(fn
      {id, depth, path, union_key, leaf?} ->
        %{id: id, depth: depth, parent: Enum.reverse(path), union_key: union_key, leaf?: leaf?}
    end)
  end

  def output_info([], _, _, _), do: []
  def output_info([h | t], d, p, u), do: output_info(h, d, p, u) ++ output_info(t, d, p, u)
  def output_info(%Property{key: key}, d, p, u), do: [{key, d, p, u, true}]

  def output_info(%Join{key: key, children: cs}, d, p, u),
    do: [{key, d, p, u, false} | output_info(cs, d + 1, [key | p], nil)]

  def output_info(%Union{children: cs}, d, p, _), do: output_info(cs, d, p, nil)
  def output_info(%Entry{key: key, children: cs}, d, p, _), do: output_info(cs, d + 1, p, key)
  def output_info(%Root{children: cs}, _, _, _), do: output_info(cs, 0, [], nil)

  def flatten([]), do: []
  def flatten([{k, v} | t]), do: flatten([k, v | t])
  def flatten([h | t]), do: flatten(h) ++ flatten(t)
  def flatten(%{} = x), do: flatten(Enum.into(x, []))
  def flatten(x), do: [x]

  def top([]), do: []
  def top([{k, _} | t]), do: [k | top(t)]

  def top([%{} = h | t]) do
    [{k, _} | _] = Enum.into(h, [])
    [k | top(t)]
  end

  def top([h | t]), do: [h | top(t)]

  def oir(dg) do
    dg
    |> :digraph.edges()
    |> to_edges(dg)
    |> Enum.map(fn {_, i, o, %{id: r, parent: parent}} ->
      if parent == [], do: {o, i, r}
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.group_by(&elem(&1, 0), fn {_, i, r} -> {i, r} end)
    |> Enum.map(fn {o, irs} ->
      {o,
       Enum.group_by(irs, &elem(&1, 0), &elem(&1, 1))
       |> Enum.map(fn {i, rs} -> {i, MapSet.new(rs)} end)
       |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
  end

  def io(dg) do
    dg
    |> :digraph.edges()
    |> to_edges(dg)
    |> Enum.sort_by(fn {_, _, _, %{depth: d}} -> d end)
    |> Enum.reduce(%{}, fn {_, i, o, %{parent: p}}, io ->
      Digraph.update_in(io, [i | p], fn
        nil -> %{o => %{}}
        x -> Map.put(x, o, %{})
      end)
    end)
  end

  def idents(dg) do
    dg
    |> :digraph.edges()
    |> to_edges(dg)
    |> Enum.reject(&is_list(elem(&1, 1)))
    |> Enum.uniq_by(&Map.get(elem(&1, 3), :id))
    |> Enum.map(&elem(&1, 1))
  end

  def attributes(dg) do
    dg
    |> :digraph.vertices()
    |> Enum.map(fn v ->
      %{
        attribute: v,
        provides: provides(dg, v),
        output_in: output_in(dg, v),
        input_in: input_in(dg, v),
        reach_via: reach_via(dg, v),
        leaf_in: leaf_in(dg, v),
        branch_in: branch_in(dg, v)
      }
    end)
    |> Enum.map(
      &{&1.attribute,
       &1
       |> Enum.reject(fn
         {:attribute, _} -> false
         {_, v} -> empty?(v)
       end)
       |> Enum.into(%{})}
    )
    |> Enum.into(%{})
  end

  def provides(dg, v) do
    dg
    |> :digraph.out_edges(v)
    |> to_edges(dg)
    |> Enum.group_by(
      fn
        {_, _, o, %{parent: []}} -> o
        {_, _, o, %{parent: p}} -> p ++ [o]
      end,
      &get_in(&1, [Access.elem(3), :id])
    )
  end

  def output_in(dg, v), do: gather_ids(dg, v, &:digraph.in_edges/2)
  def input_in(dg, v), do: gather_ids(dg, v, &:digraph.out_edges/2)

  def gather_ids(dg, v, edge_fun) do
    dg
    |> edge_fun.(v)
    |> to_edges(dg)
    |> Enum.reduce(MapSet.new([]), fn {_, _, _, %{id: id}}, ins ->
      MapSet.put(ins, id)
    end)
  end

  def leaf_in(dg, v), do: gather_tree(dg, v, &Enum.filter/2)
  def branch_in(dg, v), do: gather_tree(dg, v, &Enum.reject/2)

  def gather_tree(dg, v, filter_fun) do
    dg
    |> :digraph.in_edges(v)
    |> to_edges(dg)
    |> filter_fun.(fn {_, _, _, %{leaf?: leaf?}} -> leaf? end)
    |> Enum.map(fn {_, _, _, %{id: id}} -> id end)
    |> Enum.into(MapSet.new([]))
  end

  def reach_via(dg, v) do
    dg
    |> :digraph.in_edges(v)
    |> to_edges(dg)
    |> Enum.reduce(%{}, fn {_, i, _, %{id: id, parent: p}}, acc ->
      Map.update(acc, [i | p], MapSet.new([id]), &MapSet.put(&1, id))
    end)
  end

  def to_edges(edge_ids, dg) do
    Enum.map(edge_ids, &:digraph.edge(dg, &1))
  end

  def empty?(nil), do: true

  def empty?(x) do
    if Enumerable.impl_for(x) do
      Enum.empty?(x)
    else
      false
    end
  end

  def resolvers(dg) do
    dg
    |> :digraph.edges()
    |> to_edges(dg)
    |> Enum.group_by(fn {_, _, _, %{id: id}} -> id end)
    |> Enum.map(fn {id, [{_, i, _, _} | _] = es} ->
      %{
        id: id,
        input: if(is_list(i), do: i, else: [i]),
        output:
          es
          |> Enum.sort_by(fn {_, _, _, %{depth: d}} -> d end)
          |> Enum.reduce([], fn {_, _, o, %{parent: p}}, acc ->
            put_in(acc, p ++ [o], [])
          end)
          |> format_output()
      }
    end)
  end

  def format_output([]), do: []
  def format_output([{k, []} | t]), do: [k | format_output(t)]
  def format_output([{k, v} | t]), do: [%{k => format_output(v)} | format_output(t)]
  def format_output([h | t]), do: [h | format_output(t)]

  def index(resolvers, dg) do
    dg = graph(resolvers, dg)

    %{
      resolvers: Enum.map(resolvers, &{&1.id, &1}) |> Enum.into(%{}),
      graph: dg,
      oir: oir(dg),
      io: io(dg),
      idents: idents(dg),
      attributes: attributes(dg)
    }
  end

  @type plan :: [[atom | {:and, [plan]}]]

  # credo:disable-for-next-line Credo.Check.Design.TagFIXME
  # FIXME: translate will only work with single output resolvers atm
  def translate(_index, []), do: []

  def translate(index, [h | t]) when is_list(h) do
    [translate(index, h) | translate(index, t)]
  end

  def translate(index, [{:and, ps, n} | t]) do
    %{input: ni, output: [no]} = Map.get(index.resolvers, n)
    [{:and, translate(index, ps), {ni, no}} | translate(index, t)]
  end

  def translate(index, [h | t]) do
    %{input: [i], output: [o]} = Map.get(index.resolvers, h)
    [{i, o} | translate(index, t)]
  end

  def new_acc() do
    %{plan: [], unreachable_attrs: MapSet.new([]), attr_trail: [], res_trail: [], count: 0}
  end

  def pipe_debug(result, msg) do
    _ = Logger.debug(msg)
    result
  end

  # credo:disable-for-next-line Credo.Check.Design.TagTODO
  # TODO: refactor + change acc & state -> struct(s)

  # credo:disable-for-next-line Credo.Check.Design.TagTODO
  # TODO: change logging -> tracing?
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def walk(graph, source_attrs, attr, acc) do
    _ = Logger.debug("enter walk: attr=#{attr}")

    :digraph.in_edges(graph, attr)
    |> Enum.map(&:digraph.edge(graph, &1))
    |> Enum.reduce(acc, fn
      {e, i, o, %{id: id}}, acc ->
        _ = Logger.debug("enter edge=#{inspect({e, i, o})}, path=#{inspect(acc.attr_trail)}")

        cond do
          i in acc.unreachable_attrs ->
            _ = Logger.debug("unreachable: attr=#{i}")
            acc

          i in acc.attr_trail ->
            _ = Logger.debug("cyclic: attr=#{i}")
            acc

          known?(i, source_attrs) ->
            _ = Logger.debug("known: attr=#{i}")
            %{acc | plan: [[id | acc.res_trail] | acc.plan], count: acc.count + 1}

          is_list(i) and length(i) > 1 ->
            _ = Logger.debug("and-branch: attr=#{inspect(i)}")

            state =
              Enum.reduce(i, %{acc: acc, plans: []}, fn i, s ->
                _ = Logger.debug("continue walk: attr=#{inspect(i)}")

                case walk(graph, source_attrs, i, %{
                       s.acc
                       | attr_trail: [attr | s.acc.attr_trail],
                         res_trail: [],
                         count: 0,
                         plan: []
                     }) do
                  %{count: 0} = acc ->
                    _ =
                      Logger.debug(
                        "unreachable and-branch: attr=#{i} | unreachable=#{
                          inspect(acc.unreachable_attrs)
                        }"
                      )

                    %{
                      s
                      | acc: %{s.acc | unreachable_attrs: MapSet.put(acc.unreachable_attrs, i)},
                        plans: [{i, []} | s.plans]
                    }

                  acc ->
                    _ = Logger.debug("reachable and-branch: attr=#{i}")

                    %{
                      s
                      | acc: %{s.acc | unreachable_attrs: acc.unreachable_attrs},
                        plans: [{i, acc.plan} | s.plans]
                    }
                end
              end)

            # credo:disable-for-next-line Credo.Check.Refactor.Nesting
            if Enum.all?(state.plans, fn {_, p} -> length(p) > 0 end) do
              _ = Logger.debug("reachable and: attr=#{inspect(i)}")
              and_plan = [{:and, Enum.map(state.plans, &elem(&1, 1)), id} | state.acc.res_trail]
              %{state.acc | plan: [and_plan | state.acc.plan], count: acc.count + 1}
            else
              _ = Logger.debug("unreachable and: attr=#{inspect(i)}")
              %{state.acc | unreachable_attrs: MapSet.put(state.acc.unreachable_attrs, i)}
            end

          true ->
            _ = Logger.debug("continue walk: attr=#{i}")

            case walk(graph, source_attrs, i, %{
                   acc
                   | attr_trail: [attr | acc.attr_trail],
                     res_trail: [id | acc.res_trail],
                     count: 0
                 }) do
              %{count: 0, unreachable_attrs: uattrs} ->
                _ = Logger.debug("unreachable walk: attr=#{i}")
                %{acc | unreachable_attrs: MapSet.put(uattrs, i)}

              %{plan: plan, unreachable_attrs: uattrs} ->
                _ = Logger.debug("reachable paths: attr=#{i}")
                %{acc | plan: plan, unreachable_attrs: uattrs, count: acc.count + 1}
            end
        end
        |> pipe_debug("leave edge=#{inspect({e, i, o})}")
    end)
    |> pipe_debug("leave walk: attr=#{attr}")
  end

  def create_vertex(graph, dest, source \\ nil)

  def create_vertex(graph, dest, nil) do
    _ = :digraph.add_vertex(graph, dest)
    graph
  end

  def create_vertex(graph, dest, source) do
    _ = create_vertex(graph, dest, nil)

    :digraph.out_neighbours(graph, source)
    |> Enum.map(&:digraph.vertex(graph, &1))
    |> case do
      [] ->
        :digraph.add_edge(graph, source, dest)

      [{next, :or}] ->
        :digraph.add_edge(graph, next, dest)

      [{next, _}] ->
        or_vertex = :digraph.add_vertex(graph)
        or_vertex = :digraph.add_vertex(graph, or_vertex, :or)
        [e] = :digraph.out_edges(graph, source)
        _ = :digraph.add_edge(graph, e, source, or_vertex, nil)
        _ = :digraph.add_edge(graph, or_vertex, next)
        :digraph.add_edge(graph, or_vertex, dest)

      _ ->
        nil
    end

    graph
  end

  def known?([], _known), do: true
  def known?(input, known) when is_list(input), do: Enum.all?(input, &(&1 in known))
  def known?(input, known), do: input in known
end

# DOT - https://graphviz.org/doc/info/lang.html
#   graph 	: 	[ strict ] (graph | digraph) [ ID ] '{' stmt_list '}'
#   stmt_list 	: 	[ stmt [ ';' ] stmt_list ]
#   stmt 	: 	node_stmt
#   	| 	edge_stmt
#   	| 	attr_stmt
#   	| 	ID '=' ID
#   	| 	subgraph
#   attr_stmt 	: 	(graph | node | edge) attr_list
#   attr_list 	: 	'[' [ a_list ] ']' [ attr_list ]
#   a_list 	: 	ID '=' ID [ (';' | ',') ] [ a_list ]
#   edge_stmt 	: 	(node_id | subgraph) edgeRHS [ attr_list ]
#   edgeRHS 	: 	edgeop (node_id | subgraph) [ edgeRHS ]
#   node_stmt 	: 	node_id [ attr_list ]
#   node_id 	: 	ID [ port ]
#   port 	: 	':' ID [ ':' compass_pt ]
#   	| 	':' compass_pt
#   subgraph 	: 	[ subgraph [ ID ] ] '{' stmt_list '}'
#   compass_pt 	: 	(n | ne | e | se | s | sw | w | nw | c | _)
defmodule Digraph.Viz do
  @moduledoc false
  # import Inspect.Algebra

  @type id :: any
  @type edge_op :: :-> | :--
  @type graph_type :: :graph | :digraph
  @type graph ::
          {:strict, graph_type, id, [statement]}
          | {graph_type, id, [statement]}
          | {:strict, graph_type, [statement]}
          | {graph_type, [statement]}
  @type statement ::
          node_statement
          | edge_statement
          | attribute_statement
          | attribute
          | subgraph
  @type attribute_statement :: {:node | :graph | :edge, [attribute]}
  @type attribute :: {id, id}
  @type edge_statement :: {node_id | subgraph, edge_rhs, [attribute]}
  @type edge_rhs ::
          {edge_op, node_id | subgraph}
          | {edge_op, node_id | subgraph, edge_rhs}
  @type node_statement :: {node_id, [attribute]}
  @type node_id :: id | {id, node_port}
  @type node_port :: id | compass_point | {id, compass_point}
  @type subgraph ::
          {:subgraph, id, [statement]}
          | {:subgraph, [statement]}
          | [statement]
  @type compass_point :: :n | :ne | :e | :se | :s | :sw | :w | :c | :_

  # def to_dot({:strict, type, id, statements}, opts) do
  #   space("strict #{type} #{id}", to_dot(statements, opts))
  # end
  # def to_dot(statements, opts) when is_list(statements) do
  #   container_doc("{", statements, "}", opts, &to_dot/2, break: :flex, separator: ";")
  # end
  # def to_dot({node_id, attributes}, opts) when is_list(attributes) do
  # end
  # def to_dot({node_id, edge_rhs, attributes}, opts) when is_list(attributes) do
  # end
  # def to_dot({type, attributes}, opts) when type in [:node, :graph, :edge] and is_list(attributes) do
  # end
  # def to_dot({:subgraph, statements}, opts) when is_list(statements) do
  #   to_dot(statements, opts)
  # end
end
