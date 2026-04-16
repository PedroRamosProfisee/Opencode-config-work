# Profisee Learned Patterns

> Loaded only in Profisee workspace sessions. Split from learned-patterns.md on 2026-04-10.

## Codebase Patterns

- Gateway REST API uses three service base classes: `ServiceBase`, `ServiceWithTokenBase`, and `WcfServiceBase<I>` — all services return `ActionResult` directly, keeping controllers thin
- All controllers inherit `BaseController : ControllerBase` with attributes `[Route("v{version:apiVersion}/[controller]")]`, `[ApiVersion("1.0")]`, `[ApiController]`, `[Authorize]`, `[Produces("application/json")]`
- Fluent access token relay: controllers call `service.WithAccessToken(this.AccessToken).MethodName(...)` via `IAccessTokenService<T>` recursive generic interface
- NServiceBus with SQL Server transport connects all services; message handlers live in each service's Infrastructure layer
- Testing uses MSTest with Arrange-Act-Assert, Moq for mocking, naming convention `MethodName_Scenario_ExpectedBehavior`

## Architecture

- Profisee is a monolith-to-microservices transition: Platform is the backbone monolith (CoreWCF on .NET 8), with 17+ independently deployed microservices
- Strategy/Factory patterns preferred, always use DI, search codebase first, stay within microservice boundaries

## Common Errors

- **Culture/locale SQL injection bug**: numeric values interpolated into SQL strings break on non-US locales — fix: always use `SqlParameter` or `CultureInfo.InvariantCulture`
