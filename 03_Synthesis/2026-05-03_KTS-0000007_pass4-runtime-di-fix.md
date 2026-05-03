# KTS-0000007 Pass 4: Runtime DI Fix (RestClient)

## Revisions Applied

* **RestClient.Builder DI Failure**: Selected **Option A**. The `RestClientConfig` now builds the `RestClient` inline using the static factory method `RestClient.builder()`, removing the dependency injection requirement for the builder itself.
* **Rationale**: For the current scope of the BFF, there is exactly one outbound client configuration. Exposing a global `RestClient.Builder` bean (Option B) is a premature abstraction that pollutes the application context. If future sagas require multiple tailored clients, we can elevate the builder to a bean then.

## Doctrine Note: Compile-Time vs. Runtime Validation
The distinction between compilation and context initialization is a hard boundary in Spring Boot. The compiler (`javac`) only validates type safety, syntax, and symbol resolution. It confirms that the type `RestClient.Builder` exists on the classpath. It does *not* validate the Spring Inversion of Control (IoC) graph. The IoC graph is assembled at runtime, which is when Spring attempts to wire the requested bean and fails.

## Junior Developer Perspective: The "Green Checkmark" Fallacy
A common hurdle for junior engineers moving into enterprise Spring Boot is the "green checkmark" fallacy—assuming that because the IDE shows no errors and `mvn compile` succeeds, the application is ready to run. This leads to profound confusion when the application immediately crashes on startup with a `NoSuchBeanDefinitionException`. 

The teaching moment here is understanding the difference between the **language layer** (Java) and the **container layer** (Spring). The language says the method signature is valid; the container says the components needed to execute that signature do not exist. Teaching developers to trace ApplicationContext startup failures is as critical as teaching them to read compiler output.

## Confirmation of Unchanged Artifacts
No other files were modified in this pass.