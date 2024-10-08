defmodule ChallengeGov.AxeAccessibilityTest do
  use ExUnit.Case

  # Admin Accessibility test use case
  @tag :super_admin_active
  test "check accessibility violations with axe-core mode super_admin_active" do
   {_, exit_code} =  System.cmd("node", ["./accesibility_test/axe_test.js","super_admin_active"])

    assert exit_code == 0, "Accessibility violations found on mode super_admin_active! See accesibility_test/logs for more details."
  end

  # Solver Accessibility test use case
  @tag :solver_active
  test "check accessibility violations with axe-core mode solver_active" do
   {_, exit_code} =  System.cmd("node", ["./accesibility_test/axe_test.js", "solver_active"])

    assert exit_code == 0, "Accessibility violations found on mode solver_active! See accesibility_test/logs for more details."
  end
end
