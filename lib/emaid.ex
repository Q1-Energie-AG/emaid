defmodule Emaid do
  @moduledoc """
  Documentation for `Emaid`.
  """

  import Bitwise

  alias Emaid.{Matrix, Vector}

  @type emaid_format :: :plain | :star | :dash

  @encoding %{
              ?0 => 0,
              ?1 => 16,
              ?2 => 32,
              ?3 => 4,
              ?4 => 20,
              ?5 => 36,
              ?6 => 8,
              ?7 => 24,
              ?8 => 40,
              ?9 => 2,
              ?A => 18,
              ?B => 34,
              ?C => 6,
              ?D => 22,
              ?E => 38,
              ?F => 10,
              ?G => 26,
              ?H => 42,
              ?I => 1,
              ?J => 17,
              ?K => 33,
              ?L => 5,
              ?M => 21,
              ?N => 37,
              ?O => 9,
              ?P => 25,
              ?Q => 41,
              ?R => 3,
              ?S => 19,
              ?T => 35,
              ?U => 7,
              ?V => 23,
              ?W => 39,
              ?X => 11,
              ?Y => 27,
              ?Z => 43
            }
            |> Map.new(fn {k, v} -> {k, Matrix.decode(v)} end)

  @decoding Map.new(@encoding, fn {k, v} -> {v, k} end)

  @p1 {0, 1, 1, 1}
  @p2 {0, 1, 1, 2}

  @p1s Stream.iterate(@p1, fn x -> Matrix.mult(x, @p1) end) |> Enum.take(14)
  @p1_encoding Map.new(@encoding, fn {k, {m11, m12, _m21, _m22}} -> {k, {m11, m12}} end)
  @p2s Stream.iterate(@p2, fn x -> Matrix.mult(x, @p2) end) |> Enum.take(14)
  @p2_encoding Map.new(@encoding, fn {k, {_m11, _m12, m21, m22}} -> {k, {m21, m22}} end)

  @neg_p2_minus_15 {0, 2, 2, 1}

  @spec calculate_checksum(binary() | charlist()) :: {:ok, binary()} | {:error, binary()}
  def calculate_checksum(contract_id) when is_binary(contract_id),
    do: contract_id |> normalize_emaid() |> to_charlist() |> calculate_checksum()

  def calculate_checksum(contract_id)
      when is_list(contract_id) and length(contract_id) != 14,
      do: {:error, "invalid contract_id length"}

  def calculate_checksum(contract_id) when is_list(contract_id) do
    {{v11, v12}, v2} =
      [contract_id, @p1s, @p2s]
      |> Enum.zip_reduce({{0, 0}, {0, 0}}, fn [char, p1, p2], {p1_acc, p2_acc} ->
        {
          # P1 vector
          @p1_encoding[char]
          |> Vector.mult(p1)
          |> Vector.add(p1_acc),
          # P2 vector
          @p2_encoding[char]
          |> Vector.mult(p2)
          |> Vector.add(p2_acc)
        }
      end)

    {v21, v22} = Vector.mult(v2, @neg_p2_minus_15)

    # Calculate Matrix 15
    m15 = {band(v11, 1), band(v12, 1), rem(v21, 3), rem(v22, 3)}

    # Decode Matrix and convert it to string
    case @decoding[m15] do
      nil -> raise "invalid checksum calculation"
      value -> {:ok, to_string([value])}
    end
  end

  @spec new(binary(), emaid_format()) :: binary()
  def new(contract_id, format \\ :plain)

  def new(contract_id, format) do
    contract_id = normalize_emaid(contract_id)

    case calculate_checksum(contract_id) do
      {:ok, checksum} ->
        format(contract_id <> checksum, format)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def valid?(emaid) do
    {contract_id, checksum} =
      emaid
      |> normalize_emaid()
      |> String.split_at(14)

    case calculate_checksum(contract_id) do
      {:ok, calculated} ->
        checksum == calculated

      {:error, _reason} ->
        false
    end
  end

  defp format(emaid, :plain), do: emaid

  defp format(emaid, spacer) when spacer in [:star, :dash] do
    {c, rest} = emaid |> String.split_at(2)
    {pid, rest} = rest |> String.split_at(3)

    s =
      case spacer do
        :star -> "*"
        :dash -> "-"
      end

    "#{c}#{s}#{pid}#{s}#{rest}"
  end

  defp normalize_emaid(emaid) do
    emaid
    |> String.replace(["*", "-"], "")
  end
end
