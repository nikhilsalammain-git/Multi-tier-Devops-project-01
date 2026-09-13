# Flask and PostgreSQL Database Connection

## Overview

This application contains two Docker Compose services:

- `flask_app`: the Flask REST API and browser dashboard
- `flask_db`: the PostgreSQL database

The Flask application connects to PostgreSQL through Docker's internal network using the database service name `flask_db`.

```text
Client browser
     |
     | http://localhost:4000
     v
Flask application container
     |
     | SQLAlchemy connection through DB_URL
     v
PostgreSQL container
     |
     | database: postgres, port: 5432
     v
users table
```

## Docker Compose Configuration

The Flask service receives its database connection string through the `DB_URL` environment variable:

```yaml
environment:
  - DB_URL=postgresql://postgres:postgres@flask_db:5432/postgres
```

The connection string uses this format:

```text
postgresql://username:password@hostname:port/database
```

For this project:

| Component | Value |
|---|---|
| Database engine | PostgreSQL |
| Username | `postgres` |
| Password | `postgres` |
| Host | `flask_db` |
| Port | `5432` |
| Database | `postgres` |

The hostname is `flask_db` because that is the PostgreSQL service name in `docker-compose.yml`. Docker Compose automatically provides internal DNS, allowing the Flask container to resolve `flask_db` to the PostgreSQL container.

## PostgreSQL Service

The database service is defined as follows:

```yaml
flask_db:
  image: postgres:12
  environment:
    - POSTGRES_PASSWORD=postgres
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 2s
    timeout: 5s
    retries: 10
```

The official PostgreSQL image creates the default `postgres` database and user. The password is set using `POSTGRES_PASSWORD`.

The health check runs `pg_isready` to verify that PostgreSQL is accepting connections.

## Flask Configuration

The Flask application reads `DB_URL` from the container environment:

```python
from os import environ

app.config['SQLALCHEMY_DATABASE_URI'] = environ.get('DB_URL')
db = SQLAlchemy(app)
```

`flask_sqlalchemy` uses this URI to configure SQLAlchemy's PostgreSQL database engine.

The application does not connect to `localhost` or the host machine. Inside Docker, the correct database hostname is `flask_db`.

## Startup Order

The Flask service depends on PostgreSQL:

```yaml
depends_on:
  flask_db:
    condition: service_healthy
```

When `docker compose up` runs:

1. Docker starts the PostgreSQL container.
2. PostgreSQL initializes the database.
3. The health check runs `pg_isready`.
4. Once PostgreSQL is healthy, Docker starts the Flask container.
5. Flask reads `DB_URL` and initializes SQLAlchemy.
6. The application creates the `users` table if it does not already exist.

## Database Model

The `User` class represents the PostgreSQL `users` table:

```python
class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
```

The table contains:

| Column | Type | Rules |
|---|---|---|
| `id` | Integer | Primary key |
| `username` | String | Required and unique |
| `email` | String | Required and unique |

At startup, the following code creates the table when necessary:

```python
with app.app_context():
    db.create_all()
```

For a production application, database migrations using Alembic or Flask-Migrate are recommended instead of relying on `db.create_all()`.

## CRUD Database Operations

### Create

The `POST /users` route creates a new SQLAlchemy object:

```python
new_user = User(
    username=data['username'],
    email=data['email']
)
db.session.add(new_user)
db.session.commit()
```

`commit()` writes the new record to PostgreSQL.

### Read

The `GET /users` route queries all users:

```python
users = User.query.all()
```

The result is converted into JSON and returned to the client.

### Update

The `PUT /users/<id>` route changes an existing record and commits the transaction:

```python
user.username = data['username']
user.email = data['email']
db.session.commit()
```

### Delete

The `DELETE /users/<id>` route removes the selected record:

```python
db.session.delete(user)
db.session.commit()
```

## Running the Application

Start both containers:

```bash
docker compose up --build
```

The Flask application is available at:

```text
http://localhost:4000/
```

The API is available at:

```text
http://localhost:4000/users
```

Check the running containers:

```bash
docker compose ps
```

View Flask logs:

```bash
docker compose logs -f flask_app
```

View PostgreSQL logs:

```bash
docker compose logs -f flask_db
```

Stop the containers:

```bash
docker compose down
```

## Testing the Connection

Create a user:

```bash
curl -X POST http://localhost:4000/users \
  -H 'Content-Type: application/json' \
  -d '{"username":"ada","email":"ada@example.com"}'
```

Retrieve all users:

```bash
curl http://localhost:4000/users
```

Open a shell inside the PostgreSQL container:

```bash
docker compose exec flask_db psql -U postgres -d postgres
```

List tables inside PostgreSQL:

```sql
\dt
```

Query the users:

```sql
SELECT * FROM users;
```

## Data Persistence

The current Compose file does not define a named volume for PostgreSQL. The database container can therefore lose its data when it is removed.

For local persistence, add this to `docker-compose.yml`:

```yaml
services:
  flask_db:
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

For production, use Amazon RDS for PostgreSQL with automated backups, encryption, monitoring, and multi-Availability Zone deployment where required.

## Security Considerations

The current credentials are intended only for local development:

```text
username: postgres
password: postgres
```

For production:

- Do not commit database passwords to Git.
- Store credentials in AWS Secrets Manager, Parameter Store, or protected CI/CD secrets.
- Use a separate application database user instead of the PostgreSQL administrator.
- Restrict database access using security groups.
- Keep RDS private and do not expose port `5432` publicly.
- Enable encryption at rest and in transit.
- Configure automated backups and a retention period.
- Use database migrations for schema changes.

A production database URL might look like this:

```text
postgresql://app_user:<password>@<rds-endpoint>:5432/appdb
```

The RDS endpoint would be supplied to Flask through an environment variable or secret, replacing the local Docker hostname `flask_db`.
