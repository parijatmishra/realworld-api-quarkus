# ![RealWorld Example App](quarkus-logo.png)
**This repository was forked from https://github.com/diegocamara/realworld-api-quarkus**

This application is an implementation of the [RealWorld](https://github.com/gothinkster/realworld) spec and API backend (it contains no front-end UI).

It was written with:

* Java 14 as the core language
* Apache Maven for builds
* [Quarkus](https://quarkus.io/) framework and its extensions, such as
    * [Flyway](https://quarkus.io/guides/flyway) for database migrations
    * [Hibernate](https://quarkus.io/guides/hibernate-orm) as the ORM
    * [RESTEasy](https://resteasy.github.io/) for JAX-RS, [Vertx Web](https://vertx.io/docs/vertx-web/java/) as the HTTP server
      with both provided via the Quarkus RESTEasy Jackson extension
* Auth0 java-jwt
* PostgreSQL

# Building and running

## Setting up PostgreSQL

Most Java projects that work with relational databases use an embedded database like H2 or Derby for unit-tests.
This way, unit-tests don't require an external resource to
run and are therefore "hermetic". They may also be less resource intensive and run faster.
However, the downside is that the code is being unit-tested against a different database that the one
it will run against in production, increasing the probability of bugs.
We eschew the use of an embedded database and use PostgreSQL throughout.

You can install and run a PostgreSQL server in a Docker container like this:

```
$ docker image pull postgresql # only need to do this once
$ docker run --name postgresql --env POSTGRES_PASSWORD=foobar --publish 5432:5432 -d postgres
```

The server starts with a root user named `postgres` with the password specified in `POSTGRES_PASSWORD`
environment variable. An initial database named `postgres` is also created. To find the IP address of
the server, run:

```
$ docker inspect postgres
...
        "IPAddress": "172.17.0.2",
...
```

You can use the `psql` command line tool and connect to the server like this:

```
$ docker run --rm -it postgres psql -h 172.17.0.2 -U postgres
Password for user postgres: ****** # same as the POSTGRES_PASSWORD above
psql (12.3 (Debian 12.3-1.pgdg100+1))
Type "help" for help.

postgres=# 
```

You will need to create at least two databases within the postgresql server, one for unit-tests
and another for running the application in `dev` profile. You will also need to create two different
PostgreSQL roles, one for unit tests, and another for running the application in `dev` profile.

**Database setup for running unit tests (`test` profile)**

The database name, username and password for unit tests are specified in the file
`src/test/resources/application.properties` as `%test.quarkus.datasource.*` properties.

Connect to the server using psql and run the following commands, changing the database name, username
or password if you changed the properties described above:

```
postgres=# CREATE DATABASE realworldapiservice_unit;
postgres=# CREATE ROLE unit LOGIN PASSWORD 'unitpassword';
postgres=# GRANT connect, create ON DATABASE realworldapiservice_unit TO unit;
```

**Database setup for running in development mode (`dev` profile)**

The database name, username and password for the dev profile are specified in the file
`src/main/resources/application.properties` as `%dev.quarkus.datasource.*` properties.

Connect to the server using psql and run the following commands, changing the database name, username
or password if you changed the properties described above:

```
postgres=# CREATE DATABASE realworldapiservice_dev;
postgres=# CREATE ROLE dev LOGIN PASSWORD 'devpassword';
postgres=# GRANT connect, create ON DATABASE realworldapiservice_dev TO dev;
```

**Database setup for running standalone jar or native executable (`prod` profile)**

When the application is run from the runner jar or native executable, it runs in the `prod` profile.
We deliberately do not provide default settings for this profile. Production database configuration should
be explicit, to prevent the application from connecting to an incorrect db instance by accident.

Create the production database as appropriate.

## Running

### Unit Tests (`test` profile)

Ensure the test database is setup as described above, and run:

```bash
./mvnw test
```

### Development mode (`dev` profile)

Ensure the dev database is setup as described above, and run


```bash
 ./mvnw compile quarkus:dev
 ```

The server should be running at http://localhost:8080

### Integration Tests

The application ships with a set of HTTP tests implemented as a [Postman](https://www.postman.com/) Collection.
The tests are kept in the file
[collections/Conduit.postman_collection.json](collections/Conduit.postman_collection.json).

They are run using
the [newman](https://learning.postman.com/docs/running-collections/using-newman-cli/command-line-integration-with-newman/)
program.

Run the server as above ("Running the application in `dev` profile"), and then run:

```bash
./collections/run-api-tests.sh
```

### Production Mode

To run the application in production mode you need to build either a standalone jar or a native executable.

#### Configuration for `prod` mode

The production database configuration must be set before you can run the app. You can specify it
using the following environment variables:

```
export QUARKUS_DATASOURCE_JDBC_URL=....
export QUARKUS_DATASOURCE_USERNAME=...
export QUARKUS_DATASOURCE_PASSWORD=...
``` 

An additional setting you may be interested in configuring is the HTTP port the application listens on:

```
export QUARKUS_HTTP_PORT=...
```

You may also be interested in configuring logging.
See [Quarkus - Logging](https://quarkus.io/guides/logging).

There are other ways of specifying these settings.
See [Quarkus - Configuring Your Application](https://quarkus.io/guides/config).


#### Building a "runner" standalone jar

```bash
./mvnw package
# standalone jar is in target/realworld-api-quarkus-runner.jar
# run it like so
java -jar target/realworld-api-quarkus-runner.jar
```

#### Building a native executable

GraalVM is necessary for building native executable, more information about
setting up GraalVM can be found in [Quarkus guides](https://quarkus.io/guides/).

```
./mvnw package -Pnative
# output is in target/realworld-api-quarkus-runner (no .jar extension)
# run it like so
./target/realworld-api-quarkus-runner
```


## Project structure:
```
application/            -> business logic implementation
+--data/                -> data aggregator classes
domain/                     -> core business package
+-- model/
|   +-- builder/
|   +-- constants/
|   +-- entity/             -> only persistent model classes
|   +-- exception/          -> domain exceptions
|   +-- repository/         -> persistent context abstractions
|   +-- provider/           -> providers abstraction (token, hash, slug)
+-- service                 -> domain bussiness abstraction
infrastructure/             -> technical details package
+-- provider/               -> providers implementaion
+-- repository/             -> repository implementation
+-- web/                    -> web layer package
    +-- config/             -> serializer/deserializer singleton options
    +-- exception/          -> web layer exceptions
    +-- mapper/             -> exception handler mapping
    +-- model/              -> request/response models for web layer
    |   +-- request/        -> request model objects
    |   +-- response/       -> response model objects
    +-- qualifiers/         -> qualifiers for dependency injection 
    +-- resources/          -> http routes and their handlers
    +-- security/           -> web layer security implementation
    |   +-- annotation/     -> name binding annotations
    |   +-- context/        -> security context options
    |   +-- filter/         -> filters implementation for check authentication/authorization rules
    |   +-- profile/        -> security profiles options
    +-- validation/         -> custom validations for request model
```
