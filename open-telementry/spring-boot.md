# Install an required opentelementry java agent file

```
curl -L -o opentelemetry-javaagent.jar \
https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar
```

# Add to your current folder 

```
java -javaagent:opentelemetry-javaagent.jar \
-Dotel.service.name=order-service \
-jar target/order-service-0.0.1-SNAPSHOT.jar
```
