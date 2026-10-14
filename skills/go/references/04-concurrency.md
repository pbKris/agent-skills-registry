# Concurrency

- **Share memory by communicating**: Use channels instead of shared memory for goroutine safety.
- **Worker pattern**: Fixed number of goroutines processing from a shared channel.
- **errgroup**: Use `golang.org/x/sync/errgroup` for N goroutines with automatic error collection and WaitGroup replacement.
- **sync.WaitGroup**: Wait for collection of goroutines to complete; signal completion via `wg.Done()`.
- **Context cancellation**: Use `context.WithCancel/WithTimeout/WithDeadline` to stop goroutines gracefully.
- **Goroutine leaks**: Always ensure launched goroutines complete or are cancelled; use `defer wg.Done()`.
- **Channel direction**: Specify `<-chan` or `chan<-` to clarify intent and prevent misuse.
- **Singleflight**: Dedup in-flight requests with `golang.org/x/sync/singleflight` to avoid redundant work.