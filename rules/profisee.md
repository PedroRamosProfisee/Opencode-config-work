# Profisee Platform Development Rules

## Code Standards
- Follow clean code principles: SRP, DRY, KISS, meaningful names
- Use PascalCase for public members, _camelCase for private fields, I-prefix for interfaces
- Prefer async/await with Async suffix on method names
- Use constructor injection for all dependencies
- Register new services in Program.cs with correct lifetime (Singleton/Scoped/Transient)

## Design Patterns
- Use Strategy Pattern for multiple interchangeable behaviors
- Use Factory Pattern for complex object creation
- Program to interfaces, not implementations

## Clean Architecture
- Dependencies point inward — domain/business logic never references infrastructure or UI
- Classes that change together belong together (CCP); don't force unused dependencies (CRP)
- Depend in the direction of stability — concrete depends on abstract

## Defensive Programming
- Guard clauses at method entry — fail fast with ArgumentNullException, ArgumentException
- Minimize variable scope; keep cyclomatic complexity low
- Replace deep if/else or switch chains with data structures when >3 branches
- Extract methods when >20 lines

## Microservice Boundaries
- Search for existing implementations before creating new classes
- Check *.Common, *.Shared, and *.Infrastructure projects for reusable utilities
- Stay within the current microservice's boundary
- Do not duplicate code that could be consolidated

## Testing
- Use MSTest with Arrange-Act-Assert pattern
- Name tests: MethodName_Scenario_ExpectedBehavior
- Use Moq for mocking dependencies
- Test behavior, not implementation details

## Before Making Changes
1. Read and understand relevant files first
2. Search for existing patterns in the codebase
3. Check how similar functionality is already implemented
4. Verify changes compile with dotnet build
