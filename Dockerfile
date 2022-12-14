FROM nikolaik/python-nodejs:python3.10-nodejs18

# Needed otherwise subdirectory error on make
WORKDIR usr/app

RUN dpkg --add-architecture i386 && apt update
#RUN apt install qemu
# https://askubuntu.com/questions/378558/unable-to-locate-package-while-trying-to-install-packages-with-apt
RUN apt update
RUN apt-get install qemu

RUN dpkg --add-architecture i386 && apt update
RUN apt install -y \
          wine \
          wine32 \
          wine64 \
          libwine \
          libwine:i386 \
          fonts-wine
RUN apt update

# https://www.mono-project.com/download/stable/#download-lin-debian
# To remove https://stackoverflow.com/questions/54658346/electron-wininstaller
RUN apt install -y apt-transport-https dirmngr gnupg ca-certificates
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt update
RUN apt install -y mono-devel

RUN node --version
RUN npm --version
# Ensuring we have node-gyp as it's required for make
RUN npm install --global node-gyp
RUN node-gyp --version

# https://stackoverflow.com/questions/54082459/fatal-error-bits-libc-header-start-h-no-such-file-or-directory-while-compili
# Result of looking at error logs on make node-gyp error
RUN apt-get install -y gcc-multilib g++-multilib

RUN apt update
RUN apt install -y git
RUN git --version

RUN apt install -y lldb
# lldb better option over gdb, ptrace not supported for qemu images
# lldb is a trace logging solution for debugging, built for llvm.
# error: https://stackoverflow.com/questions/42029834/gdb-in-docker-container-returns-ptrace-operation-not-permitted
# --cap-add=SYS_PTRACE only works on run not build.

# https://stackoverflow.com/questions/35774714/how-to-cache-the-run-npm-install-instruction-when-docker-build-a-dockerfile
COPY package.json /usr/app/package.json
RUN npm install --platform=win32
# Copies into WORKDIR
COPY . /usr/app

# Ensuring wine64 is used as wine32 is default
# "make:windows": "electron-forge make --platform=win32 --arch=x64"
ENTRYPOINT DEBUG="electron-windows-installer*,electron-forge:*" QEMU_STRACE=1 WINEARCH=win64 WINEPREFIX=~/.wine64 npm run make:windows
