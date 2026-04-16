# GrocerSnap-API Learned Patterns

> Loaded only in GrocerSnap-API workspace sessions.

## Architecture

- Ktor-based Kotlin backend using version catalog (`libs.versions.toml`)
- Routes: `src/main/kotlin/com/grocersnap/api/routes/`
- Adapters: `src/main/kotlin/com/grocersnap/api/adapter/` — scraping + flipp integration
- Services: `src/main/kotlin/com/grocersnap/api/service/`
- Caching: `src/main/kotlin/com/grocersnap/api/cache/` (in-memory + Redis)
- Config: `src/main/kotlin/com/grocersnap/api/config/`

## GrocerSnap vs GrocerSnap-API

- GrocerSnap = Android app (Compose + Hilt + Room + Firebase)
- GrocerSnap-API = Kotlin/Ktor backend (no Spring, no Micronaut — Ktor only)

## Adapter Patterns

- Each store has an `XAdapter : StorePriceAdapter` — implements `search(query): List<PriceResult>`
- Flipp adapter: parses Flipp circulars API → unified `StoreOffer` model
- All adapters are tested via `*AdapterTest` in `src/test/kotlin/`
- Rate limiting: `PriceCacheService` enforces 5 req/min per store

## API Conventions

- All routes return `ApplicationResponse` (typed response wrapper)
- Error handling: `tryCatch()` utility in `Routing.kt`
- Serialization: kotlinx.serialization (JSON, not Gson)
- HTTP client: Ktor Client with OkHttp engine

## Linting

- ktlint + detekt config at GrocerSnap root (shared with Android app)
- GrocerSnap-API uses same rules — run `./gradlew detekt` at GrocerSnap root
- No specific API lint rules beyond standard Kotlin style
