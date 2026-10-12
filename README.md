# custom-apisix

This image extends Apache APISIX 3.19.0 (Debian) with:

- MaxMind DB runtime tools (`libmaxminddb0`, `mmdb-bin`),
- a dynamically built GeoIP2 module compatible with the image OpenResty runtime.

The build validates module loading as the non-root `apisix` user. Legacy
`libgeoip` packages are not needed for `.mmdb` databases.

The GeoIP2 module is installed at:

- `/usr/local/openresty/nginx/modules/ngx_http_geoip2_module.so`

MMDB databases are intentionally **not** baked into the image. Mount them at
runtime (read-only) from infrastructure automation (for example Ansible-managed
host paths).

Build it locally with:

```sh
docker build -t custom-apisix:3.19.0 .
```

To publish to Docker Hub, create the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`
repository secrets. Push a version tag such as `v3.19.0` to publish
`<DOCKERHUB_USERNAME>/custom-apisix:3.19.0`.
