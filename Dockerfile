# ---- 1. Base image ----
FROM ubuntu:22.04

# ---- 2. Install sudo (and any other packages you need) ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo git cmake ninja-build ccache dfu-util device-tree-compiler python3 python3-pip python3-setuptools python3-wheel python3-venv python3-requests python3-pyelftools wget file qemu-system-arm tree zsh gcc flex bison make ca-certificates curl gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu libc6-dev-arm64-cross qemu-system-aarch64 qemu-user qemu-user-static bc libssl-dev libncurses-dev libncurses5-dev libncursesw5-dev bzip2 vim nano cpio xz-utils gcc-riscv64-unknown-elf qemu-system-misc gdb-multiarch \
    gcc-aarch64-linux-gnu \
    binutils-common \
    build-essential \
    git-core \
    ssh \
    less \
    python3-dev \
    python3-pip \
    binutils \
    fdisk \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    libssl-dev \
    libc6-dev \
    rustc \
    libncurses5-dev \
    crossbuild-essential-arm64 xxd \
    strace man openssh-server && \
    rm -rf /var/lib/apt/lists/*

# RUN yes | unminimize

# ---- 2b. PocketBeagle 2 (AM6254) cross-build support ----
# Added for the pocketBeagle2 project (a-class = A53 Linux, m-class = M4F
# firmware). The aarch64 and arm-none-eabi compilers, dtc, gdb-multiarch,
# python3-pyelftools, flex/bison/bc, cpio and xz are already installed above;
# this fills the remaining gaps.
#
#   gcc-arm-linux-gnueabihf   U-Boot's first stage (tiboot3.bin, R5 SPL) is armhf
#   libgnutls28-dev uuid-dev  U-Boot host tools
#   swig libelf-dev           binman / kernel build
#   python3-yaml              binman reads its board config as YAML
#   python3-jsonschema        binman validates that YAML against a schema
#   yamllint                  also required by binman's ti-board-config entry
#   fakeroot                  initramfs device nodes without CAP_MKNOD
#   kmod rsync lz4 zstd       module deps, build helpers, kernel compression
#   u-boot-tools              mkimage
#   gdisk dosfstools mtools   build an SD image without root or loop devices
#     parted e2fsprogs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc-arm-linux-gnueabihf \
        libgnutls28-dev uuid-dev swig libelf-dev \
        python3-yaml python3-jsonschema yamllint \
        fakeroot kmod rsync lz4 zstd \
        u-boot-tools \
        gdisk dosfstools mtools parted e2fsprogs && \
    rm -rf /var/lib/apt/lists/*

# Sources bind-mounted from a host (especially macOS) can appear to have a
# foreign owner to git, which makes every git command fail with
# 'detected dubious ownership'. Harmless and generally useful.
RUN git config --system --add safe.directory '*'

# ---- 3. Create the non‑root user & add to the sudo group ----
RUN groupadd -r pyjamacafe && \
    useradd -m -r -g pyjamacafe -s /bin/bash pyjamacafe && \
    usermod -aG sudo pyjamacafe

RUN echo "pyjamacafe:pj" | chpasswd && \
    echo "root:pj" | chpasswd

# ---- 4. Allow 'pyjamacafe' NOPASSWD sudo (optional but handy for CI) ----
RUN echo "pyjamacafe ALL=(ALL) ALL" > /etc/sudoers.d/pyjamacafe && \
    chmod 0440 /etc/sudoers.d/pyjamacafe

RUN mkdir /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "UsePAM yes" >> /etc/ssh/sshd_config && \
    ssh-keygen -A

RUN echo 'echo -e "\\e[1;33m===== Welcome to Pyjamacafe Sandbox =====\\e[0m"' >> /home/pyjamacafe/.bashrc && \
    echo 'echo -e "\\e[1;32mUser:\\e[0m pyjamacafe"' >> /home/pyjamacafe/.bashrc && \
    echo 'echo -e "\\e[1;32mPassword:\\e[0m pj"' >> /home/pyjamacafe/.bashrc && \
    echo 'echo -e "\\e[1;32mRoot:\\e[0m root (same password: pj)\\e[0m"' >> /home/pyjamacafe/.bashrc && \
    echo 'echo -e "\\e[1;32mHostname:\\e[0m $(hostname)"' >> /home/pyjamacafe/.bashrc && \
    echo 'echo -e "\\e[1;32mIP‑address:\\e[0m $(hostname -I)"' >> /home/pyjamacafe/.bashrc && \
    echo 'echo -e "\\e[1;33m=========================================\\e[0m\\n"' >> /home/pyjamacafe/.bashrc
RUN echo "PS1='\[\e[32m\]\u\[\e[00m\]:\[\e[33m\]\w\[\e[00m\]\\n$ '" >> /home/pyjamacafe/.bashrc

RUN pip3 install pygments

# ---- 5. Working directory ----
WORKDIR /home/pyjamacafe

# ---- 6. Switch to the non‑root user ----
USER pyjamacafe

# terminal colors with xterm
ENV TERM=xterm

# ---- 7. Install GDB Dashboard ----------
RUN wget -P ~ https://git.io/.gdbinit

# ---- 8. Install rustup ----------
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="~/.cargo/bin:${PATH}"

# ---- 9. Default command (replace if you need something else) ----
CMD ["bash"]
