#!/bin/sh

# config
# config_dir="/root/config"

# create temporary alias
# rcon () {
#     /usr/bin/git --git-dir="$config_dir"/ --work-tree="/" "$@"
# }

# set to track upstram
# done later
# rcon push --set-upstream https://github.com/lbia/config main

# rustup cargo env
export RUSTUP_HOME="/usr/local/lib/rustup"
export CARGO_HOME="/usr/local/lib/cargo"

# go path
export GOPATH="/usr/local/lib/go"

# add npm go and cargo to path in order to install packages in the right places
export PATH="/usr/local/lib/npm/bin:${GOPATH}/bin:${CARGO_HOME}/bin:${PATH}"

# install rust
rustup-init
rustup default stable

# cargo packages already installed globally
# --all-features activate all available features
# --locked require Cargo.lock is up to date
# --frozen require Cargo.lock and cache are up to date
# cargo install --all-features --locked --frozen
cargo install cargo-update

# java (for octave)
# ln -s /usr/lib/jvm/openjdk11/lib/server/libjvm.so /usr/lib/jvm/openjdk11/lib/
# ln -s /usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server/libjvm.so /usr/lib/jvm/java-1.8-openjdk/jre/lib
