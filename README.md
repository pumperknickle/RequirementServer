# Requirements Server

Requirements Server is the backend API for requirement versions and tags. It will be used in the Requirements Clarification Process and holds training data for RQT language models and tagging models.

## Usage

```bash
# Build images:
docker-compose build

# Run app
docker-compose up app
# Run database
docker-compose up db
# Run migrations:
docker-compose up migrate

# Stop all:
docker-compose down
# Stop & wipe database
docker-compose down -v
```
