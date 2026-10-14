# Syntax Modern

- **range int**: Prefer `for i := range slice` over `for i := 0; i < len(slice); i++`.
- **any vs interface{}**: Use `any` for type flexibility; `interface{}` for backward compatibility or legacy APIs.
- **go:build directives**: Conditional compilation with `//go:build` tags; feature gating per platform/version.
- **tool directives**: `//go:tool` for custom build tool invocation; rare but possible.
- **Integer range**: `for _, v := range items` idiom; avoid `_ = len(items)` anti-pattern.
- **Type aliases**: `type Config struct { ... }` with methods on named types.
- **Composite literals**: `Config{Key: val}` initialization; avoid `Config{}` zero value usage without validation.
- **Named return values**: `func compute() (err error) { ... return }` for explicit error returns.
- **Select default**: `select { case msg := <-ch: ... default: ... }` for non-blocking channel ops.