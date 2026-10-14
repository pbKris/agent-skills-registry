# Index - spf13/go/SKILL.md (1142 lines)

| # | Concern | Keywords Trigger | Source File | Anchor / Line | When to Use |
|---|---------|------------------|-------------|---------------|-------------|
| 1 | Core Principles | clear clever, zero value, return early, happy path | vendor/spf13/go/SKILL.md | ## Core Principles L28-L88 | writing function, review readability |
| 2 | Package Organization | flat, internal/, domain, utils, helpers, clean architecture, service repository | references/02-package-organization.md | all | design package, project layout, anti Java-in-Go |
| 3 | Interface Design | interface discovered, accept interfaces return structs, consumer defines | references/03-interface-design.md | all | design API, library |
| 4 | Concurrency | worker pool, errgroup, sync.WaitGroup.Go, share memory communicating, goroutine stops | references/04-concurrency.md | all | writing concurrent code |
| 5 | Error Handling | errors values, wrap context, fmt.Errorf %w | references/05-error-handling.md | all | all error handling |
| 6 | Testing | table-driven, t.Helper, fakes stubs, testdata, afero, cmp, synctest | references/06-testing.md | all | TDD, writing test |
| 7 | Generics | generic, Repository[T], comparable, Ordered | references/07-generics.md | all | design generic |
| 8 | Stdlib Modern | slices, maps, cmp, errors.Join, iter, rand/v2, omitzero | vendor/spf13/go/SKILL.md | L637-L814 | choose stdlib vs third-party |
| 9 | HTTP Server | ServeMux, timeouts, graceful shutdown, middleware | references/09-http-server.md | all | build HTTP service |
| 10 | Syntax Modern | range int, any vs interface{}, go:build, tool directive | vendor/spf13/go/SKILL.md | L997-L1055 | modernize Go 1.22+ |