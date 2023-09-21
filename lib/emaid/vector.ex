defmodule Emaid.Vector do
  @moduledoc false

  @type vector :: {integer(), integer()}

  @spec mult(vector(), Matrix.matrix()) :: vector()
  def mult({v1, v2}, {m11, m12, m21, m22}) do
    {v1 * m11 + v2 * m21, v1 * m12 + v2 * m22}
  end

  @spec add(vector(), vector()) :: vector()
  def add({lv1, lv2}, {rv1, rv2}), do: {lv1 + rv1, lv2 + rv2}
end
