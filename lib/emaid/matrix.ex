defmodule Emaid.Matrix do
  import Bitwise, only: [band: 2, bsl: 2, bsr: 2]

  @type matrix() :: {integer(), integer(), integer(), integer()}

  @spec mult(matrix(), matrix()) :: matrix()
  def mult({lm11, lm12, lm21, lm22}, {rm11, rm12, rm21, rm22}) do
    {
      lm11 * rm11 + lm12 * rm21,
      lm11 * rm12 + lm12 * rm22,
      lm21 * rm11 + lm22 * rm21,
      lm21 * rm12 + lm22 * rm22
    }
  end

  @spec decode(integer()) :: matrix()
  def decode(x),
    do: {
      band(x, 1),
      x |> bsr(1) |> band(1),
      x |> bsr(2) |> band(3),
      bsr(x, 4)
    }

  @spec encode(matrix()) :: integer()
  def encode({m11, m12, m21, m22}), do: m11 + bsl(m12, 1) + bsl(m21, 2) + bsl(m22, 4)
end
