# Dockerfile

## Build
```
docker build --platform linux/amd64,linux/arm64 -t pyjamabrah/sandbox .
```

## Run
```
docker run -it --rm pyjamabrah/sandbox:latest
```

## Test Locally

Create a container named `lab` and map the container `workspace` to `~/Downloads/workspace` on local machine.
```bash
docker run -it -v ~/Downloads/workspace:/home/pyjamabrah/workspace --name lab pyjamabrah/sandbox
```

Starting Docker
```bash
docker start lab
```

Attach to the container
```bash
docker attach lab
```
