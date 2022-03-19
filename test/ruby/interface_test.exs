defmodule Ruby.InterfaceTest do
  @moduledoc """
  false
  """
  use ChallengeGov.DataCase, async: true
  alias Ruby.Interface, as: Ruby

  describe "Ruby.Interface" do
    test "converts fundamental types" do
      assert Ruby.call("param_decoder", "for_testing", [1]) == "1"
      assert Ruby.call("param_decoder", "for_testing", [3.141592653]) == "3.141592653"
      assert Ruby.call("param_decoder", "for_testing", ["Nice Job"]) == "\"Nice Job\""
      assert Ruby.call("param_decoder", "for_testing", [5.0e5]) == "500000.0"
    end

    test "converts array of fundamental types" do
      assert Ruby.call("param_decoder", "for_testing", [[1, 3.14, "Nice Job"]]) ==
               "[1, 3.14, \"Nice Job\"]"
    end

    test "converts Keyword list to Ruby Hash" do
      assert Ruby.call("param_decoder", "for_testing", [
               [
                 rabbits: "eat lettuce",
                 who: "cares",
                 times_i_care: 0,
                 rent: 599.99
               ]
             ]) == "{:rabbits=>\"eat lettuce\", :who=>\"cares\", :times_i_care=>0, :rent=>599.99}"
    end

    test "converts complex nested things" do
      assert Ruby.call("param_decoder", "for_testing", [
               [
                 good: [another: "tuple", fine: [1, 2, 3]],
                 cool: 3,
                 sad: "dog"
               ]
             ]) == "{:good=>{:another=>\"tuple\", :fine=>[1, 2, 3]}, :cool=>3, :sad=>\"dog\"}"

      assert Ruby.call("param_decoder", "for_testing", [
               [
                 value: [key: 1, thing: 2],
                 starter: [[baker: "mayfield", pop: 5], 2, 3]
               ]
             ]) ==
               "{:value=>{:key=>1, :thing=>2}, :starter=>[{:baker=>\"mayfield\", :pop=>5}, 2, 3]}"
    end
  end
end
