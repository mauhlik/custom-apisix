# custom-apisix

This image extends Apache APISIX 3.19.0 (Debian) with the GeoIP system
libraries and tools.

Build it locally with:

```sh
docker build -t custom-apisix:3.19.0 .
```

To publish to Docker Hub, create the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`
repository secrets. Push a version tag such as `v3.19.0` to publish
`<DOCKERHUB_USERNAME>/custom-apisix:3.19.0`.
