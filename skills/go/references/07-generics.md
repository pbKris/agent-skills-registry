# Generics

- **Generic types**: Define with `type Repository[T any]` for type-safe containers and functions.
- **Type constraints**: Use `comparable` for map keys; define custom constraints for behavior.
- **Ordered constraint**: `golang.org/x/exp/constraints.Ordered` for sortable types.
- **Factory patterns**: `func NewRepository[T any]() *Repository[T]` for generic construction.
- **Methods on generics**: Define methods on generic types; receiver is type-safe.
- **Constraint satisfaction**: Ensure generic types meet required interface at compile time.
- **When to use**: Infrastructure (repositories, caches), algorithms; avoid over-engineering business types.
- **Migration**: Start with `any`; refactor to tighter constraints when type is known.