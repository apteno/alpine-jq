# alpine-jq

Weekly build of alpine image with curl, wget and jq.

Images on [Docker Hub](https://hub.docker.com/r/apteno/alpine-jq)

## Example

Pull the image and pipe JSON through `jq`:

```sh
docker run --rm apteno/alpine-jq sh -c \
  "curl -s https://api.github.com/repos/apteno/alpine-jq | jq '.full_name, .stargazers_count'"
```

Use it as a base image in your own `Dockerfile`:

```dockerfile
FROM apteno/alpine-jq

COPY script.sh /script.sh
ENTRYPOINT ["/script.sh"]
```
