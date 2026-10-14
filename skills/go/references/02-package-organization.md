# Package Organization

- **Flat is better than nested**: Prefer flat directory structures over deep nesting.
- **Package naming**: Use lowercase, single-word names; no underscores or mixedCase.
- **Internal packages**: Place private code under `internal/`; inaccessible from outside the module.
- **Domain-driven**: Group by business domain (e.g., `user`, `order`, `auth`) not by layer.
- **Utility packages**: Common helpers in `utils` or `pkg` at root level.
- **Service/repository pattern**: Separate business logic (service) from data access (repository).
- **Avoid circular dependencies**: Plan import graph carefully; use interfaces to break cycles.
- **go.mod version**: Keep Go 1.21+ compatible; use go.work for monorepos.