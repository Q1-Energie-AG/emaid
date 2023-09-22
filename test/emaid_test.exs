defmodule EmaidTest do
  use ExUnit.Case
  doctest Emaid

  test "calculate correct checksum" do
    tests = %{
      "NN*123*ABCDEFGHI" => "T",
      "FRXYZ123456789" => "2",
      "IT-A1B-2C3E4F5G6" => "4",
      "ESZU8WOX834H1D" => "R",
      "PT73902837ABCZ" => "Z",
      "DE83DUIEN83QGZ" => "D",
      "DE83DUIEN83ZGQ" => "M",
      "DE8AA001234567" => "0"
    }

    for {contract_id, expected_checksum} <- tests do
      assert {:ok, expected_checksum} == Emaid.calculate_checksum(contract_id)
      assert Emaid.valid?(contract_id <> expected_checksum)

      format =
        cond do
          String.contains?(contract_id, "-") -> :dash
          String.contains?(contract_id, "*") -> :star
          true -> :plain
        end

      assert Emaid.new(contract_id, format) == contract_id <> expected_checksum
    end
  end
end
