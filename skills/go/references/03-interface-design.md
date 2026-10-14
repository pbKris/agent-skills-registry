# Interface Design

- **Interface discovery**: Let the consumer define what's needed; start with empty interface `interface{}` then narrow.
- **Accept interfaces, return structs**: Functions receive interfaces; return concrete types.
- **Smallest interface possible**: Only extract methods that are actually used (YAGNI).
- **Naming**: Interfaces end in -er (e.g., `Reader`, `Writer`, `Saver`).
- ** favor composition over inheritance**: Embed structs instead of inheriting from base types.
- **Strategic interface use**: Add interfaces when you need polymorphism, mocking, or abstraction boundaries.
- **`io.Reader`/`io.Writer`**: Standard library patterns for I/O abstraction.
- **Testability**: Design interfaces specifically to enable stubs and fakes in tests.