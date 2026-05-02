# Project Skeleton: riverhorse-gateway-spring

* Build Tool: Maven.
* Rationale: Maven's pom.xml and strict, declarative build lifecycle (clean, compile, test, package) map directly to the MSBuild / .csproj mental model. Gradle's Groovy/Kotlin DSL introduces a scriptable build paradigm that drifts further from the C# baseline.

Structure Map:
riverhorse-gateway-spring/
|-- pom.xml                      (Equivalent to .csproj)
|-- src/main/resources/
|   `-- application.yml          (Equivalent to appsettings.json)
`-- src/main/java/com/bluesand/riverhorse/gateway/
    |-- GatewayApplication.java  (Equivalent to Program.cs)
    |-- config/                  (Equivalent to /Extensions or /Configuration)
    |-- controllers/             (Equivalent to /Controllers)
    |-- filters/                 (Equivalent to /Middleware)
    `-- models/                  (Equivalent to /Models)