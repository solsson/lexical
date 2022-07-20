#!/usr/bin/env bash

echo "Running prod-build"
npm run build-vercel

echo "Building runtime image"
IMAGE=lexical-local
# https://github.com/Yolean/envoystatic/blob/main/tests/html01/Dockerfile
(cd build/;
cat << EOF | docker build -t $IMAGE -f - .
FROM yolean/envoystatic:tooling

COPY . /workspace

RUN [ "/usr/local/bin/envoystatic", \
  "route", \
  "--in=/workspace", \
  "--out=/tmp/docroot", \
  "--rdsyaml=/tmp/route.yaml" ]

FROM yolean/envoystatic:envoy

COPY --from=0 /tmp/route.yaml /etc/envoy/rds/
COPY --from=0 /tmp/docroot /var/docroot
EOF
)

echo "Done. Now run: docker run --rm -p 8080:8080 $IMAGE"
