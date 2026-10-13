# Maven snippets (Spring Boot)

Copy these into your `pom.xml` under `<build><plugins>`. They make `mvn verify` (which the Stop hook
and CI both run) fail when coverage drops, when SpotBugs/FindSecBugs finds a bug, or (optionally) when
the mutation score is too low.

Versions shown were current in 2025. **Check the latest version** of each plugin on Maven Central
(search.maven.org) before you paste, and keep them in `<properties>` so they are easy to update.

```xml
<properties>
  <jacoco.version>0.8.12</jacoco.version>
  <spotbugs-maven-plugin.version>4.8.6.6</spotbugs-maven-plugin.version>
  <findsecbugs.version>1.13.0</findsecbugs.version>
  <pitest-maven.version>1.17.0</pitest-maven.version>
  <pitest-junit5-plugin.version>1.2.1</pitest-junit5-plugin.version>
  <dependency-check-maven.version>10.0.4</dependency-check-maven.version>
</properties>
```

## 1. JaCoCo: coverage report and a coverage floor

JaCoCo checks the whole module, not just new lines. Set the minimum to roughly your current value and
raise it over time (never lower it to get a change through). For "80% on new lines", use SonarQube's
quality gate or the optional diff-cover step in `quality-gates.yml`, which reads JaCoCo's XML report.

```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>${jacoco.version}</version>
  <executions>
    <execution>
      <id>prepare-agent</id>
      <goals><goal>prepare-agent</goal></goals>
    </execution>
    <execution>
      <id>report</id>
      <phase>verify</phase>
      <goals><goal>report</goal></goals>
    </execution>
    <execution>
      <id>check</id>
      <phase>verify</phase>
      <goals><goal>check</goal></goals>
      <configuration>
        <haltOnFailure>true</haltOnFailure>
        <rules>
          <rule>
            <element>BUNDLE</element>
            <limits>
              <limit>
                <counter>LINE</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.70</minimum>
              </limit>
              <limit>
                <counter>BRANCH</counter>
                <value>COVEREDRATIO</value>
                <minimum>0.60</minimum>
              </limit>
            </limits>
          </rule>
        </rules>
        <excludes>
          <!-- generated or trivial code only; every exclusion needs a reason -->
          <exclude>**/*Application.class</exclude>
          <exclude>**/config/**</exclude>
          <exclude>**/dto/**</exclude>
        </excludes>
      </configuration>
    </execution>
  </executions>
</plugin>
```

If you also run integration tests with Failsafe, add a `prepare-agent-integration` execution and a
`merge` / `report-aggregate` setup; see the JaCoCo Maven docs.

## 2. SpotBugs with Find Security Bugs

Finds null-pointer bugs, resource leaks, bad equals/hashCode, and (with FindSecBugs) injection, weak
crypto, path traversal and other OWASP-style issues in compiled bytecode. Runs in `verify`.

```xml
<plugin>
  <groupId>com.github.spotbugs</groupId>
  <artifactId>spotbugs-maven-plugin</artifactId>
  <version>${spotbugs-maven-plugin.version}</version>
  <configuration>
    <effort>Max</effort>
    <!-- Start at High to keep false positives low (the Tricorder rule: under 10% ignored findings);
         move to Medium once the codebase is clean. -->
    <threshold>High</threshold>
    <failOnError>true</failOnError>
    <xmlOutput>true</xmlOutput>
    <!-- Suppressions file (create it as below, or delete this line); each entry says why and until when. -->
    <excludeFilterFile>spotbugs-exclude.xml</excludeFilterFile>
    <plugins>
      <plugin>
        <groupId>com.h3xstream.findsecbugs</groupId>
        <artifactId>findsecbugs-plugin</artifactId>
        <version>${findsecbugs.version}</version>
      </plugin>
    </plugins>
  </configuration>
  <executions>
    <execution>
      <id>spotbugs-check</id>
      <phase>verify</phase>
      <goals><goal>check</goal></goals>
    </execution>
  </executions>
</plugin>
```

Minimal `spotbugs-exclude.xml` at the module root (protected from agent edits by `protect-files.sh`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<FindBugsFilter>
  <!-- Example: generated MapStruct mappers. Reason: generated code. Review: 2026-12-31 -->
  <Match>
    <Class name="~.*MapperImpl" />
  </Match>
</FindBugsFilter>
```

## 3. PIT mutation testing (optional, recommended for core logic)

PIT changes your code in small ways (flips a condition, changes a return value) and checks that some
test fails. A surviving mutant means a behaviour no test checks. It is slow, so run it on changed code
in pull requests and on everything nightly. In CI it is switched on with `ENABLE_PIT=true`.

```xml
<plugin>
  <groupId>org.pitest</groupId>
  <artifactId>pitest-maven</artifactId>
  <version>${pitest-maven.version}</version>
  <dependencies>
    <dependency>
      <groupId>org.pitest</groupId>
      <artifactId>pitest-junit5-plugin</artifactId>
      <version>${pitest-junit5-plugin.version}</version>
    </dependency>
  </dependencies>
  <configuration>
    <targetClasses>
      <param>com.example.yourapp.*</param>
    </targetClasses>
    <excludedClasses>
      <param>com.example.yourapp.config.*</param>
      <param>com.example.yourapp.*Application</param>
    </excludedClasses>
    <!-- Start at 60-70 and ratchet up. Default 0 means "not enforced". -->
    <mutationThreshold>60</mutationThreshold>
    <timestampedReports>false</timestampedReports>
    <outputFormats>
      <param>HTML</param>
      <param>XML</param>
    </outputFormats>
    <!-- Reuse results between runs to make local and PR runs faster -->
    <withHistory>true</withHistory>
  </configuration>
</plugin>
```

Run: `./mvnw -B -ntp test-compile org.pitest:pitest-maven:mutationCoverage`.
For changed files only: `./mvnw -B -ntp test-compile org.pitest:pitest-maven:scmMutationCoverage`
(needs `<scm>` in the pom), or the Arcmutate extension for git-diff-based pull request analysis.

## 4. OWASP Dependency-Check (optional; CI's dependency-review covers pull requests)

Fails the build when a dependency has a known vulnerability with CVSS 7 or higher. The first run
downloads the NVD database and is slow; get a free NVD API key and pass it as an environment variable.

```xml
<plugin>
  <groupId>org.owasp</groupId>
  <artifactId>dependency-check-maven</artifactId>
  <version>${dependency-check-maven.version}</version>
  <configuration>
    <failBuildOnCVSS>7</failBuildOnCVSS>
    <nvdApiKeyEnvironmentVariable>NVD_API_KEY</nvdApiKeyEnvironmentVariable>
    <suppressionFiles>
      <suppressionFile>dependency-check-suppressions.xml</suppressionFile>
    </suppressionFiles>
  </configuration>
</plugin>
```

Run: `./mvnw -B -ntp org.owasp:dependency-check-maven:check` (nightly is usually enough).

## 5. Useful Spring Boot test settings

- Detect N+1 queries: enable Hibernate statistics in tests (`spring.jpa.properties.hibernate.generate_statistics=true`)
  and assert the statement count for important use cases, or use a statement-counting library such as
  datasource-proxy or Hypersistence Utils `SQLStatementCountValidator`.
- Expose latency percentiles for SLOs: `management.metrics.distribution.percentiles-histogram.http.server.requests=true`.
- Keep the build reproducible: commit the Maven wrapper (`mvnw`, `.mvn/wrapper/`) so the hook and CI use the same Maven.

## 6. PMD CPD: copy-paste detection (catches copied controllers and services)

`api-dup-check.py` catches the same API copied per region; CPD catches any copied block of code. Bind
`cpd-check` to `verify` so `mvn verify` fails when a new copy appears. Version from memory: check the
latest maven-pmd-plugin release.

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-pmd-plugin</artifactId>
  <version>3.26.0</version>
  <configuration>
    <!-- about 10-15 lines of Java; lower it to catch smaller copies -->
    <minimumTokens>100</minimumTokens>
    <failOnViolation>true</failOnViolation>
    <printFailingErrors>true</printFailingErrors>
    <includeTests>false</includeTests>
    <excludeRoots>
      <excludeRoot>target/generated-sources</excludeRoot>
    </excludeRoots>
  </configuration>
  <executions>
    <execution>
      <goals><goal>cpd-check</goal></goals>
    </execution>
  </executions>
</plugin>
```

For an existing codebase with copies already in it, run `mvn pmd:cpd` once, fix or list them, then
switch `failOnViolation` on so only new copies fail.

