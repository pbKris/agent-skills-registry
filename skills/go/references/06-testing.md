# Testing

- **Table-driven tests**: Write test cases as data tables; iterate over inputs and expected outputs.
- **t.Helper**: Mark helper functions in subtests so they appear in correct test location.
- **Fakes and stubs**: In-memory implementations of interfaces for test dependency replacement.
- **Test data**: Use `testdata/` directory for fixed test files (afero, os.ReadFile).
- **cmp for comparison**: `github.com/google/go-cmp/cmp` for deep value comparison in tests.
- **synctest**: `golang.org/x/sync/synctest` for deterministic concurrent test execution.
- **Benchmarking**: Write benchmarks with `BenchmarkXxx`; report ops/sec for performance.
- **Test coverage**: Run `go test -cover`; aim for meaningful coverage, not 100% mandate.
- **Subtests**: Use `t.Run` for grouped test cases with independent subtests.