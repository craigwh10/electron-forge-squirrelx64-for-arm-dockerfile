# electron-forge-squirrelx64-for-arm-dockerfile
Dockerfile which generates an image for building electron forge apps for windows win32 X64 on ARM64 devices

Needed this as it's a pain to build windows applications on ARM chips.

Process takes around 15 minutes on my m1 pro 2021, approx 400 secs on npm i for win32, approx 500 secs for make, which isn't great but without some clever optimisations I'm not sure how to improve this much more.

## Possible improvements

- Caching node_modules after checking for possible cause-of-change in dependencies
- Version fixing for dependencies with security tests

## Leftover useful bits for reference

```
# https://stackoverflow.com/questions/36399848/install-node-in-dockerfile
#ENV NODE_VERSION=18.0.0
#RUN apt install -y curl
#RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
#ENV NVM_DIR=/root/.nvm
#RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
#RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
#RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
#ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
```

```
RUN apt install -y
# -y is necessary to automatically say yes to taking up space on build
```

- Version checks are necessary as a sanity check that the binaries are there.
- apt update prior to installs is necessary to ensure we aren't missing packages.

Logging build (adds logfile to image)
```
RUN QEMU_STRACE=1 WINEARCH=win64 WINEPREFIX=~/.wine64 npm run make:windows > build.log 2>&1
```
