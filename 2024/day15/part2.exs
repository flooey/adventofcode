defmodule State do
  defstruct wall: [], box: [], robot: nil
end

defmodule Day15 do
  def next({x, y}, dir) do
    case dir do
      :up -> {x, y - 1}
      :down -> {x, y + 1}
      :left -> {x - 1, y}
      :right -> {x + 1, y}
    end
  end

  def other({x, y} = pos, state) do
    case state[pos] do
      :boxl -> {x + 1, y}
      :boxr -> {x - 1, y}
    end
  end

  def move(state, pos, dir) do
    cond do
      not Map.has_key?(state, pos) ->
        {:ok, state}

      state[pos] == :wall ->
        {:error, nil}

      dir == :left or dir == :right ->
        newpos = next(pos, dir)

        case move(state, newpos, dir) do
          {:error, _} -> {:error, nil}
          {:ok, newstate} -> {:ok, newstate |> Map.delete(pos) |> Map.put(newpos, state[pos])}
        end

      true ->
        other = other(pos, state)
        newpos = next(pos, dir)

        case move(state, newpos, dir) do
          {:error, _} ->
            {:error, nil}

          {:ok, newstate} ->
            case move(newstate |> Map.delete(pos) |> Map.put(newpos, state[pos]), other, dir) do
              {:error, _} -> {:error, nil}
              {:ok, newnewstate} -> {:ok, newnewstate}
            end
        end
    end
  end

  def allmoves([], state, _) do
    state
    |> Enum.filter(fn {_, type} -> type == :boxl end)
    |> Enum.map(fn {{x, y}, _} -> x + 100 * y end)
    |> Enum.sum()
  end

  def allmoves([move | moves], state, robot) do
    case move(state, next(robot, move), move) do
      {:ok, newstate} -> allmoves(moves, newstate, next(robot, move))
      {:error, _} -> allmoves(moves, state, robot)
    end
  end
end

items =
  IO.stream()
  |> Stream.take_while(&(&1 != "\n"))
  |> Enum.with_index()
  |> Enum.flat_map(fn {row, y} ->
    String.trim(row)
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.flat_map(fn {c, x} ->
      case c do
        "#" -> [{x * 2, y, :wall}, {x * 2 + 1, y, :wall}]
        "O" -> [{x * 2, y, :boxl}, {x * 2 + 1, y, :boxr}]
        "@" -> [{x * 2, y, :robot}]
        "." -> []
      end
    end)
  end)
  |> Enum.group_by(fn {_, _, type} -> type end)

robot = items[:robot] |> List.first() |> then(fn {x, y, :robot} -> {x, y} end)

state =
  (items[:wall] ++ items[:boxl] ++ items[:boxr])
  |> Enum.map(fn {x, y, type} -> {{x, y}, type} end)
  |> Map.new()

moves =
  IO.stream()
  |> Enum.flat_map(fn l ->
    l
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(fn x ->
      case x do
        "^" -> :up
        "v" -> :down
        ">" -> :right
        "<" -> :left
      end
    end)
  end)

IO.puts(Day15.allmoves(moves, state, robot))
