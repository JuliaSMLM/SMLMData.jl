# CLAUDE.md

Guidance for Claude Code in this repository.

## What this package is

SMLMData (0.7.2 and later) is a container with no code of its own. `src/SMLMData.jl` loads
SMLMCore (types, coordinates, filters, operations) and SMLMio (SMITE files) and exports the 32
names SMLMData 0.7.1 exported, each the owning package's own object. The only function defined
here is `api_overview()` (unexported), which returns `api_overview.md` followed by
`SMLMCore.api_overview()`.

- A bug or feature in any exported name belongs to SMLMCore or SMLMio, through that package's
  session and release. Nothing here wraps, copies or patches their code.
- Never add or drop an export: the export list is 0.7.1's, checked by `test/test_container.jl`.
- SMLMCore and SMLMio name SMLMData as a weak dependency with compat `>= 0.7.2`, so they cannot be
  installed beside SMLMData 0.7.1 or earlier, which defined its own copies of the types.

## Commands

```bash
julia --project=. -e 'using Pkg; Pkg.test()'                  # Core group
GROUP=QA julia --project=. -e 'using Pkg; Pkg.test()'          # Aqua, ExplicitImports, docstrings
julia --project=docs docs/make.jl                              # docs (docs/Project.toml has [sources])
```

## Tests

- `test/test_container.jl`: the export list equals 0.7.1's; each name is SMLMCore's or SMLMio's
  object; a method added through SMLMData lands on the owner's function; `api_overview`; and SMLDs
  that SMLMData 0.7.1 writes with JLD2 at test time, in a temporary environment of its own (it needs
  the registry), load as the same types with equal values.
- The other `test/test_*.jl` files are SMLMData 0.7.1's suite, run through the container. Where
  SMLMCore 0.1.0 or SMLMio 0.1.0 fixed a bug, the assertion expects the fixed behavior and says so.
- No data file is tracked: tests build their inputs at test time.
- `test/runtests.jl` and `test/qa/qa.jl` are the lab templates; never edit them.

## Rules

- Lengths are in µm. Julia floor 1.10, as SMLMCore's.
- Versions follow the lab's 0.Y.Z rule: main carries the next version with `-DEV`.
