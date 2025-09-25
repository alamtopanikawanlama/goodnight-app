# Good Night App

A Rails API for tracking sleep and viewing sleep summaries with social features.

## Features

- **User Management:** Register, update, delete users; view user profiles; list followers and following.
- **Sleep Tracking:** Clock in/out sleep sessions; view current sleep session; delete sleep records.
- **Sleep Analytics:** Daily summaries and statistics for each user.
- **Social Features:** Follow/unfollow users; view followers/following; see friends' sleep records.
- **Follows Management:** Create, view, and delete follow relationships.
- **Pagination:** Efficient data handling for large datasets.
- **API Documentation:** Swagger UI available

## Quick Start

### Using Docker (Recommended)
```sh
docker-compose up --build
```

### Using Rails Directly
```sh
bundle install
rails db:create db:migrate
rails s
```

## API Overview

### Authentication
All endpoints not use authentication

### Core Endpoints

#### Users
- `POST /api/v1/users` — Create user
- `GET /api/v1/users` — List users
- `GET /api/v1/users/:id` — Show user
- `PATCH /api/v1/users/:id` — Update user
- `DELETE /api/v1/users/:id` — Delete user
- `POST /api/v1/users/:id/follow` — Follow a user
- `DELETE /api/v1/users/:id/unfollow` — Unfollow a user
- `GET /api/v1/users/:id/followers` — List followers
- `GET /api/v1/users/:id/following` — List following

#### Sleep Records (nested under user)
- `GET /api/v1/users/:user_id/sleep_records` — List sleep records
- `GET /api/v1/users/:user_id/sleep_records/:id` — Show sleep record
- `DELETE /api/v1/users/:user_id/sleep_records/:id` — Delete sleep record
- `POST /api/v1/users/:user_id/sleep_records/clock_in` — Start sleep session
- `POST /api/v1/users/:user_id/sleep_records/clock_out` — End sleep session
- `GET /api/v1/users/:user_id/sleep_records/current` — View current sleep session
- `GET /api/v1/users/:user_id/sleep_records/friends` — View friends' sleep records

#### Follows
- `GET /api/v1/follows` — List all follows
- `GET /api/v1/follows/:id` — Show follow relationship
- `POST /api/v1/follows` — Create follow relationship
- `DELETE /api/v1/follows/:id` — Delete follow relationship

## Data Models

- **User:** Basic user information
- **SleepRecord:** Individual sleep sessions
- **Follow:** User following relationships

## Testing

```sh
bundle exec rspec
```

## Technologies

- Rails 8.0.2.1 API
- PostgreSQL
- RSpec
- Docker

## API Documentation

Swagger UI
