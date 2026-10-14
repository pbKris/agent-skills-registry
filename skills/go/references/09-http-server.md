# HTTP Server

- **ServeMux**: Register routes with `http.NewServeMux`; keep paths consistent and grouped.
- **Timeouts**: Use `http.Server.ReadTimeout`, `WriteTimeout`, `IdleTimeout` for request lifecycle control.
- **Graceful shutdown**: `http.Server.Shutdown(context)` to finish in-flight requests on exit.
- **Middleware pattern**: Function `next http.Handler` chain; log, recovery, auth, tracing individually.
- **Request ID**: Generate UUID per request; pass via context `context.WithValue`.
- **CORS**: Add headers manually or via middleware; restrict origins/methods for security.
- **Response encoding**: Write JSON with `json.NewEncoder`; set `Content-Type: application/json`.
- **Rate limiting**: Use token bucket or sliding window; `golang.org/x/time/rate` for per-IP limiting.
- **TLS configuration**: `http.ListenAndServeTLS` with proper cert/key management; force HTTPS.