#!/bin/sh

# set variables
directory="/root/config"

# create temporary alias
config () {
	/usr/bin/git --git-dir="$directory"/ --work-tree="/" "$@"
}

# import gpg key
# echo "------------------------ type the number of your identity -------------------------"
# gpg --search-keys $email

# trust key
# echo "-------------------- type 'trust', '5', 'y', 'primary', 'save' --------------------"
# gpg --edit-key $email

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
cargo install cargo-update rbw

# link rbw rbw-agent for doas config
ln -s /usr/local/lib/cargo/bin/rbw /usr/local/bin/
ln -s /usr/local/lib/cargo/bin/rbw-agent /usr/local/bin/

# rbw register
# rbw unlock

# set to track upstram
# config push --set-upstream https://github.com/lbia/config main

# java (for octave)
# ln -s /usr/lib/jvm/openjdk11/lib/server/libjvm.so /usr/lib/jvm/openjdk11/lib/
# ln -s /usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server/libjvm.so /usr/lib/jvm/java-1.8-openjdk/jre/lib
