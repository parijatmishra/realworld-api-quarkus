-- Create a database and role for use with `mvn quarkus:dev`
-- - db name, role name and password must match src/main/resources/application.properties (`dev.quarkus.*`)
CREATE DATABASE realworldapiservice_dev;
CREATE ROLE dev LOGIN PASSWORD 'devpassword';
GRANT CONNECT, CREATE ON DATABASE realworldapiservice_dev TO dev;
-- Create a database and role for use with `mvn test`
-- - db name, role name and password must match src/test/resources/application.properties (`test.quarkus.*`)
CREATE DATABASE realworldapiservice_unit;
CREATE ROLE unit LOGIN PASSWORD 'unitpassword';
GRANT CONNECT, CREATE ON DATABASE realworldapiservice_unit TO unit;
