# Standard Library Modern

- **slices**: Replace third-party slice utilities with `slices.Sort`, `slices.Compact`, `slices.Delete`.
- **maps**: Use `maps.keys`, `maps.values`, `maps.merge` (Go 1.21+) for map operations.
- **cmp**: `github.com/google/go-cmp/cmp` for precise object comparison; stdlib `reflect.DeepEqual` as fallback.
- **errors.Join**: Combine multiple errors into single error (Go 1.20+).
- **iter**: `iter.Seq`, `iter.Seq2` for lazy iterator patterns; replaces manual loops.
- **rand/v2**: Better random number generation; `rand.NewPCG` for seeded generation.
- **omitzero**: `go vet` flag to detect unintentional zero value initialization.
- **strcmp/cmp**: Compare structs safely; avoid using `==` on structs.
- **When to choose stdlib**: Prefer built-in over third-party when feature exists; less dependencies, better compatibility.