# This file contains the configuration for Credo and you are probably reading
# this after creating it with `mix credo.gen.config`.
#
# If you find anything wrong or unclear in this file, please report an
# issue on GitHub: https://github.com/rrrene/credo/issues
#
%{
  #
  # You can have as many configs as you like in the `configs:` field.
  configs: [
    %{
      #
      # Run any exec using `mix credo -C <name>`. If no exec name is given
      # "default" is used.
      #
      name: "default",
      #
      # These are the files included in the analysis:
      files: %{
        #
        # You can give explicit globs or simply directories.
        # In the latter case `**/*.{ex,exs}` will be used.
        #
        included: ["lib/", "src/", "test/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      #
      # If you create your own checks, you must specify the source files for
      # them here, so they can be loaded by Credo before running the analysis.
      #
      requires: [],
      #
      # If you want to enforce a style guide and need a more traditional linting
      # experience, you can change `strict` to `true` below:
      #
      strict: false,
      #
      # If you want to use uncolored output by default, you can change `color`
      # to `false` below:
      #
      color: true,
      #
      # You can customize the parameters of any check by adding a second element
      # to the tuple.
      #
      # To disable a check put `false` as second element:
      #
      #     {Credo.Check.Design.DuplicatedCode, false}
      #
      checks: [
        #
        ## Consistency Checks
        #
        {Credo.Check.Consistency.ExceptionNames, []},
        {Credo.Check.Consistency.LineEndings, []},
        {Credo.Check.Consistency.ParameterPatternMatching, []},
        {Credo.Check.Consistency.SpaceAroundOperators, []},
        {Credo.Check.Consistency.SpaceInParentheses, []},
        {Credo.Check.Consistency.TabsOrSpaces, []},

        #
        ## Design Checks
        #
        # You can customize the priority of any check
        # Priority values are: `low, normal, high, higher`
        #
        {Credo.Check.Design.AliasUsage,
         [priority: :low, if_nested_deeper_than: 2, if_called_more_often_than: 0]},
        # You can also customize the exit_status of each check.
        # If you don't want TODO comments to cause `mix credo` to fail, just
        # set this value to 0 (zero).
        #
        {Credo.Check.Design.TagTODO, [exit_status: 0]},
        {Credo.Check.Design.TagFIXME, []},

        #
        ## Readability Checks
        #
        {Credo.Check.Readability.AliasOrder, [exit_status: 0]},
        {Credo.Check.Readability.FunctionNames, [exit_status: 0]},
        {Credo.Check.Readability.LargeNumbers, [exit_status: 0]},
        {Credo.Check.Readability.MaxLineLength,
         [priority: :low, max_length: 120, exit_status: 0]},
        {Credo.Check.Readability.ModuleAttributeNames, [exit_status: 0]},
        {Credo.Check.Readability.ModuleDoc, [exit_status: 0]},
        {Credo.Check.Readability.ModuleNames, [exit_status: 0]},
        {Credo.Check.Readability.ParenthesesInCondition, [exit_status: 0]},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, [exit_status: 0]},
        {Credo.Check.Readability.PredicateFunctionNames, [exit_status: 0]},
        {Credo.Check.Readability.PreferImplicitTry, [exit_status: 0]},
        {Credo.Check.Readability.RedundantBlankLines, [max_blank_lines: 2, exit_status: 0]},
        {Credo.Check.Readability.Semicolons, [exit_status: 0]},
        {Credo.Check.Readability.SpaceAfterCommas, [exit_status: 0]},
        {Credo.Check.Readability.StringSigils, [exit_status: 0]},
        {Credo.Check.Readability.TrailingBlankLine, [exit_status: 0]},
        {Credo.Check.Readability.UnnecessaryAliasExpansion, [exit_status: 0]},
        {Credo.Check.Readability.TrailingWhiteSpace, [exit_status: 0]},
        {Credo.Check.Readability.VariableNames, [exit_status: 0]},

        #
        ## Refactoring Opportunities
        #
        {Credo.Check.Refactor.CondStatements, []},
        {Credo.Check.Refactor.CyclomaticComplexity, []},
        {Credo.Check.Refactor.FunctionArity, []},
        {Credo.Check.Refactor.LongQuoteBlocks, []},
        # Not an issue with Elixir 1.8+
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Refactor.MatchInCondition, []},
        {Credo.Check.Refactor.NegatedConditionsInUnless, []},
        {Credo.Check.Refactor.NegatedConditionsWithElse, []},
        {Credo.Check.Refactor.Nesting, []},
        {Credo.Check.Refactor.PipeChainStart,
         [
           excluded_argument_types: [:atom, :binary, :fn, :keyword, :number],
           excluded_functions: ["from"]
         ]},
        {Credo.Check.Refactor.UnlessWithElse, []},
        {Credo.Check.Refactor.WithClauses, []},

        #
        ## Warnings
        #
        {Credo.Check.Warning.ApplicationConfigInModuleAttribute, false},
        {Credo.Check.Warning.BoolOperationOnSameValues, []},
        {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
        {Credo.Check.Warning.IExPry, []},
        {Credo.Check.Warning.IoInspect, []},
        # Not an issue with Elixir 1.8+
        {Credo.Check.Warning.LazyLogging, []},
        {Credo.Check.Warning.OperationOnSameValues, []},
        {Credo.Check.Warning.OperationWithConstantResult, []},
        {Credo.Check.Warning.RaiseInsideRescue, []},
        {Credo.Check.Warning.UnusedEnumOperation, []},
        {Credo.Check.Warning.UnusedFileOperation, []},
        {Credo.Check.Warning.UnusedKeywordOperation, []},
        {Credo.Check.Warning.UnusedListOperation, []},
        {Credo.Check.Warning.UnusedPathOperation, []},
        {Credo.Check.Warning.UnusedRegexOperation, []},
        {Credo.Check.Warning.UnusedStringOperation, []},
        {Credo.Check.Warning.UnusedTupleOperation, []},
        # {Credo.Check.Warning.UnsafeExe, []},
        {Credo.Check.Warning.MapGetUnsafePass, []},
        # {Credo.Check.Warning.UnsafeToAtom, []},
        #
        # Controversial and experimental checks (opt-in, just replace `false` with `[]`)
        #
        {Credo.Check.Consistency.MultiAliasImportRequireUse, []},
        {Credo.Check.Consistency.UnusedVariableNames, false},
        # {Credo.Check.Design.DuplicatedCode, []},
        {Credo.Check.Readability.AliasAs, false},
        # {Credo.Check.Readability.BlockPipe, []},
        {Credo.Check.Readability.ImplTrue, []},
        {Credo.Check.Readability.MultiAlias, []},
        {Credo.Check.Readability.SeparateAliasRequire, []},
        {Credo.Check.Readability.SinglePipe, false},
        # {Credo.Check.Readability.Specs, []},
        {Credo.Check.Readability.StrictModuleLayout, []},
        {Credo.Check.Readability.WithCustomTaggedTuple, []},
        {Credo.Check.Refactor.ABCSize, false},
        {Credo.Check.Refactor.AppendSingleItem, []},
        {Credo.Check.Refactor.DoubleBooleanNegation, []},
        {Credo.Check.Refactor.ModuleDependencies, false},
        {Credo.Check.Refactor.NegatedIsNil, false},
        {Credo.Check.Refactor.VariableRebinding, false},

        #
        # CredoContrib checks
        #
        {CredoContrib.Check.EmptyDocString, []},
        {CredoContrib.Check.EmptyTestBlock, []},
        {CredoContrib.Check.FunctionBlockSyntax, false},
        {CredoContrib.Check.FunctionNameUnderscorePrefix, []},
        {CredoContrib.Check.ModuleAlias, []},
        {CredoContrib.Check.ModuleDirectivesOrder, []},
        {CredoContrib.Check.PublicPrivateFunctionName, []},
        {CredoContrib.Check.SingleFunctionPipe, false},

        #
        # CredoEnvVar checks
        #
        # {CredoEnvvar.Check.Warning.EnvironmentVariablesAtCompileTime, []},
        #
        # CredoNaming checks
        #
        {CredoNaming.Check.Warning.AvoidSpecificTermsInModuleNames, false},
        {CredoNaming.Check.Consistency.ModuleFilename,
         excluded_paths: ["config", "mix.exs", "test/support"]}

        #
        # Custom checks can be created using `mix credo.gen.check`.
        #
      ]
    }
  ]
}
