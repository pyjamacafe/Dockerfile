# Dockerfile

## Build
```
docker build --platform linux/amd64,linux/arm64 -t pyjamacafe/sandbox .
```

## Run
```
docker run -it --rm pyjamacafe/sandbox:latest
```

## Test Locally

Create a container named `lab` and map the container `workspace` to `~/Downloads/workspace` on local machine.
```bash
docker run -it -v ~/Downloads/workspace:/home/pyjamacafe/workspace --name lab pyjamacafe/sandbox
```

Starting Docker
```bash
docker start lab
```

Attach to the container
```bash
docker attach lab
```
