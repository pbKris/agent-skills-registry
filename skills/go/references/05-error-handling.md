# Error Handling

- **errors values**: Use `errors.New` for basic errors; `fmt.Errorf` with verbs for formatted errors.
- **Wrap context**: `fmt.Errorf(" %w", err)` to wrap and preserve original error chain.
- **errors.Is/errors.As**: Inspect and match error hierarchies programmatically.
- **fmt.Errorf %w**: Write errors that support `errors.Is` for wrapping.
- **error interfaces**: Functions return `error`; callers check `if err != nil`.
- **Early return**: Handle errors immediately; don't defer error checking.
- **error sentinels**: Use `var ErrX = errors.New("...")` for specific error checks with `errors.Is`.
- **errors.Join**: Combine multiple errors into one (Go 1.20+); useful for aggregate validation.
- **panic/recover**: Use only for unexpected bugs; not for expected control flow.