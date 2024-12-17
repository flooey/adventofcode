defmodule Day17 do
  def combo_op(op, a, b, c) do
    case op do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> a
      5 -> b
      6 -> c
    end
  end

  def run(a, b, c, program, ip, output) do
    if ip >= tuple_size(program) do
      output
    else
      opcode = elem(program, ip)
      operand = elem(program, ip + 1)

      case opcode do
        0 ->
          run(
            div(a, floor(:math.pow(2, combo_op(operand, a, b, c)))),
            b,
            c,
            program,
            ip + 2,
            output
          )

        1 ->
          run(a, Bitwise.bxor(b, operand), c, program, ip + 2, output)

        2 ->
          run(a, rem(combo_op(operand, a, b, c), 8), c, program, ip + 2, output)

        3 ->
          if a == 0 do
            run(a, b, c, program, ip + 2, output)
          else
            run(a, b, c, program, operand, output)
          end

        4 ->
          run(a, Bitwise.bxor(b, c), c, program, ip + 2, output)

        5 ->
          run(a, b, c, program, ip + 2, [rem(combo_op(operand, a, b, c), 8) | output])

        6 ->
          run(
            a,
            div(a, floor(:math.pow(2, combo_op(operand, a, b, c)))),
            c,
            program,
            ip + 2,
            output
          )

        7 ->
          run(
            a,
            b,
            div(a, floor(:math.pow(2, combo_op(operand, a, b, c)))),
            program,
            ip + 2,
            output
          )
      end
    end
  end

  def matches(output, program) do
    Enum.zip(Tuple.to_list(output) |> Enum.reverse(), Tuple.to_list(program) |> Enum.reverse())
    |> Enum.all?(fn {x, y} -> x == y end)
  end

  def find(a, program) do
    output = run(a, 0, 0, program, 0, []) |> Enum.reverse() |> List.to_tuple()

    cond do
      output == program ->
        {:ok, a}

      matches(output, program) ->
        case find(a * 8, program) do
          {:ok, result} -> {:ok, result}
          {:error, _} -> find(a + 1, program)
        end

      rem(a, 8) == 7 ->
        {:error, nil}

      true ->
        find(a + 1, program)
    end
  end
end

_a =
  IO.read(:line)
  |> String.split(":")
  |> List.last()
  |> String.trim()
  |> String.to_integer()

_b =
  IO.read(:line)
  |> String.split(":")
  |> List.last()
  |> String.trim()
  |> String.to_integer()

_c =
  IO.read(:line)
  |> String.split(":")
  |> List.last()
  |> String.trim()
  |> String.to_integer()

IO.read(:line)

program =
  IO.read(:line)
  |> String.split(":")
  |> List.last()
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)
  |> List.to_tuple()

IO.puts(elem(Day17.find(0, program), 1))
