# Vehicle Admin Challenge

A Rails 8 API-only backend to manage vehicle maintenance workflows: report failures, auto-generate service orders, simulate workshop processing, and track history.

**Repository:** https://github.com/dzamoraf12/vehicleadminapi  
**API Docs (Apidog):** https://r7z8x0c376.apidog.io/

---

## Prerequisites

- Docker & Docker Compose  
- Ports **3000**, **5432**, **6379** available  

---

## Getting Started

```bash
git clone https://github.com/dzamoraf12/vehicleadminapi.git
cd vehicleadminapi
touch .env
```

---

## Environment Variables

Copy this variables into `.env` and fill in your values:

```dotenv
# -----------------------
# PostgreSQL
# -----------------------
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_USER=<your_db_user>
POSTGRES_PASSWORD=<your_db_password>
POSTGRES_DB=vehicles_dev

# -----------------------
# Redis & Sidekiq
# -----------------------
REDIS_URL=redis://redis:6379/0
SIDEKIQ_USERNAME=<sidekiq_user>      # optional for web UI
SIDEKIQ_PASSWORD=<sidekiq_pass>      # optional for web UI

# -----------------------
# Devise & JWT
# -----------------------
DEVISE_JWT_SECRET_KEY=<your_jwt_secret>

# -----------------------
# Seed Users
# -----------------------
API_ADMIN_USER_EMAIL=admin@vehicles.com
API_ADMIN_USER_PASS=password
API_TECHNICIAN_USER_EMAIL=technician@vehicles.com
API_TECHNICIAN_USER_PASS=password
API_DRIVER_USER_EMAIL=driver@vehicles.com
API_DRIVER_USER_PASS=password
```

---

## Docker Setup

Build and start all services in detached mode:

```bash
docker-compose up --build -d
```

Services launched:

- **backend** — Rails API on port 3000  
- **db** — PostgreSQL on port 5432  
- **redis** — Redis on port 6379  
- **sidekiq** — Background job processor  

---

## Database Setup & Seeding

Run migrations and seed data:

```bash
docker-compose exec backend rails db:create db:migrate db:seed
```

Seeds will create:

- Three users (admin, technician, driver)  
- Sample vehicles  
- Sample maintenance reports  
- Sample service orders  

---

## Running the Test Suite

Execute RSpec:

```bash
docker-compose exec backend rspec
```

You should see all specs passing (models, services, jobs, policies, requests).

---

## Code Style & Linting

Check Ruby style with RuboCop:

```bash
docker-compose exec backend rubocop
```

Auto-correct offenses:

```bash
docker-compose exec backend rubocop -A
```

---

## API Usage Examples

### Authenticate (Sign In)

```bash
curl -X POST http://localhost:3000/users/sign_in   -H "Content-Type: application/json"   -d '{"user":{"email":"admin@vehicles.com","password":"password"}}'
```

Response header includes:

```
Authorization: Bearer <your_jwt_token>
```

### List Vehicles

```bash
curl http://localhost:3000/vehicles   -H "Authorization: Bearer <your_jwt_token>"
```

### Create Maintenance Report

```bash
curl -X POST http://localhost:3000/maintenance_reports   -H "Authorization: Bearer <your_jwt_token>"   -H "Content-Type: application/json"   -d '{
        "maintenance_report": {
          "vehicle_id": 1,
          "description": "Brake pads worn out",
          "priority": "alta"
        }
      }'
```

Full endpoint list & examples: https://r7z8x0c376.apidog.io/

---

## Monitoring Sidekiq

Tail Sidekiq logs:

```bash
docker-compose logs -f sidekiq
```

If you enabled Sidekiq Web UI authentication, visit:

```
http://localhost:3000/sidekiq
```

---

## Contributing

1. Fork the repository  
2. Create a feature branch:  
   ```bash
   git checkout -b feature/my-feature
   ```  
3. Commit your changes:  
   ```bash
   git commit -m "Add my feature"
   ```  
4. Push to your fork:  
   ```bash
   git push origin feature/my-feature
   ```  
5. Open a Pull Request  

Ensure tests pass and RuboCop is clean before submitting.
