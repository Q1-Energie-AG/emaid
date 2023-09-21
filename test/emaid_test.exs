defmodule EmaidTest do
  use ExUnit.Case
  doctest Emaid

  test "calculate correct checksum" do
    tests = %{
      "NN123ABCDEFGHI" => "T",
      "FRXYZ123456789" => "2",
      "ITA1B2C3E4F5G6" => "4",
      "ESZU8WOX834H1D" => "R",
      "PT73902837ABCZ" => "Z",
      "DE83DUIEN83QGZ" => "D",
      "DE83DUIEN83ZGQ" => "M",
      "DE8AA001234567" => "0"
    }

    for {contract_id, expected_checksum} <- tests do
      assert {:ok, expected_checksum} == Emaid.calculate_checksum(contract_id)
      assert Emaid.valid?(contract_id <> expected_checksum)
    end
  end
end
