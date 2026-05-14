# ACME Status Dashboard

Small Flask status dashboard for Acme Internal Tools Ltd. The app can run locally, in Docker, or behind host Nginx using the included install script.

## Endpoints

- `GET /` - browser dashboard
- `GET /api/v1/status` - public status JSON
- `GET /api/v1/secret` - protected endpoint, requires `X-API-Key`
- `/api/status` and `/api/secret` redirect to the v1 endpoints

## Requirements

- Python 3.12
- Poetry
- Docker and Nginx for VM deployment

## Configuration

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `API_KEY` | Yes | None | API key required by `/api/v1/secret` |
| `PORT` | No | `5000` | Flask app port |
| `VERSION` | No | `1.0.0` locally, `latest` in `install.sh` | Version returned by the status API |

## Run Locally

```bash
poetry install --only main
API_KEY=change-me poetry run python app.py
```

## Run With Docker

```bash
docker build -t status-dashboard .
docker run --rm \
  --name status-dashboard \
  -e API_KEY=change-me \
  -e VERSION=0.1.0 \
  -p 127.0.0.1:5000:5000 \
  status-dashboard
```

Open `http://localhost:5000/`.

## Deploy

`install.sh` builds the image, starts the container, installs the Nginx config, validates Nginx, and reloads it.

```bash
sudo API_KEY=change-me ./install.sh
```

You can also put `API_KEY`, `PORT`, and `VERSION` in a `.env` file before running the script. After install, open `http://<vm-ip>/`.

## API Examples

```bash
curl -s http://localhost:5000/api/v1/status | jq .
curl -L -s http://localhost:5000/api/status | jq .
curl -s \
  -H "X-API-Key: change-me" \
  http://localhost:5000/api/v1/secret | jq .
```

## Troubleshooting

- Use `curl -L` for `/api/status` or `/api/secret` because they are redirects.
- If startup fails with `API_KEY environment variable is required`, set `API_KEY` in the environment or `.env`.
