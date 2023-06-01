FROM ubuntu:20.04

ARG RACKET_VERSION=8.1
ARG ROSETTE_VERSION=9f6322c9da5761da63126c7ef936bd77c210aeec
ARG Z3_VERSION=4.8.9
ARG BOOLECTOR_VERSION=3.2.1
ARG UNICORN_VERSION=1.0.2-rc3

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    bc \
    bison \
    build-essential \
    clang \
    clang-format \
    cmake \
    curl \
    flex \
    gawk \
    gcc \
    gcc-riscv64-linux-gnu \
    git \
    gperf \
    llvm \
    make \
    patchutils \
    pkg-config \
    python3 \
    python3-pip \
    texinfo \
    vim \
    wget \
    zlib1g-dev \
    libzmq5 \
    device-tree-compiler \
 && rm -rf /var/lib/apt/lists/*



# Install Racket
RUN wget "https://mirror.racket-lang.org/installers/${RACKET_VERSION}/racket-${RACKET_VERSION}-x86_64-linux-cs.sh" && \
    chmod +x ./racket-${RACKET_VERSION}-x86_64-linux-cs.sh && \
    echo 'yes\n1' | ./racket-${RACKET_VERSION}-x86_64-linux-cs.sh && \
	rm -f racket-${RACKET_VERSION}-x86_64-linux-cs.sh

# Install Unicorn
RUN git clone 'https://github.com/unicorn-engine/unicorn.git' && \
    cd unicorn && git checkout ${UNICORN_VERSION} && \
    env UNICORN_ARCHS="x86,arm,aarch64" ./make.sh && \
    env UNICORN_ARCHS="x86,arm,aarch64" ./make.sh install 

# Install Boolector twice with CaDiCal and Lingeling backends
RUN git clone 'https://github.com/boolector/boolector.git' && \
    cd boolector && git checkout ${BOOLECTOR_VERSION} && \
    ./contrib/setup-cadical.sh && \
    ./contrib/setup-btor2tools.sh && \
    ./configure.sh --prefix /opt/boolector/${BOOLECTOR_VERSION}-cadical && cd build && make -j $(nproc) && make install && \
    cd .. && git clean -xffd \
    ./contrib/setup-lingeling.sh && \
    ./contrib/setup-btor2tools.sh && \
    ./configure.sh --prefix /opt/boolector/${BOOLECTOR_VERSION}-lingeling && cd build && make -j $(nproc) && make install && \
    cd ../.. && rm -rfv ./boolector

# Install Spike
RUN git clone 'https://github.com/riscv/riscv-isa-sim.git' && \
    cd riscv-isa-sim && \
    mkdir build && cd build && \
    ../configure --prefix=/opt/riscv --with-fesvr=/opt/riscv && \
    make -j4 && make install && \
    ln -s /opt/riscv/bin/spike /usr/bin/spike


# Install Z3
RUN git clone 'https://github.com/Z3Prover/z3.git' && \
    cd z3 && git checkout z3-${Z3_VERSION} && \
    python3 scripts/mk_make.py --prefix /opt/z3/${Z3_VERSION} && \
    cd build && \
    make -j $(nproc) && make install && \
    cd .. && rm -rfv z3

# Install Rosette
RUN git clone 'https://github.com/emina/rosette.git' && \
    cd rosette && git checkout ${ROSETTE_VERSION} && \
    raco pkg install --auto -i --no-setup && raco setup -Dl rosette
    

RUN pip3 install notebook
RUN yes | raco pkg install iracket

RUN yes | raco iracket install 

RUN sed -i 's/"--",/"--","-t",/g' /root/.local/share/jupyter/kernels/racket/kernel.json



RUN pip install parcon

ADD . /serval

WORKDIR /serval
RUN yes | raco pkg install
