# H1 Overview

This repo contains a docker build script and three docker files that will contain the puppet agent, pdk and one of the cli tools for the cloud providor

# H1 Requirements

1. *nix OS
2. docker installed
3. access to the internet

# H2 supported

1. aws
2. azure
3. gcp

# H1 Usage

# H3 Build image
```
docker build -f Dockerfile_aws -t onzyone/puppet-dev-aws .
```

# H3 Run an image

```
docker run -i -v <local dir to mount>:<inside the docker containor> -t onzyone/puppet-dev-<cloud providor> /bin/bash
```

