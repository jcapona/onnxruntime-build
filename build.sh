#!/bin/bash

# Install dependencies
apt update
apt install -y \
  build-essential \
  curl \
  git \
  libcurl4-openssl-dev \
  libssl-dev \
  python3 \
  python3-flatbuffers \
  python3-numpy \
  python3-packaging \
  python3-pip \
  wget

# Update pypy and install python dependencies
rm -r /usr/lib/python3.11/EXTERNALLY-MANAGED || true
cd /tmp
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py
pip3 install --upgrade setuptools
pip3 install --upgrade wheel

# Install cmake from bookworm-backports, as the version in the main repository is too old
echo "deb http://deb.debian.org/debian bookworm-backports main" >> /etc/apt/sources.list
apt update
apt install -t bookworm-backports -y cmake

# Clone onnxruntime repo and build
cd /tmp
git clone --recursive https://github.com/Microsoft/onnxruntime.git
cd /tmp/onnxruntime
./build.sh \
  --config MinSizeRel \
  --update \
  --build \
  --build_shared_lib \
  --build_wheel \
  --parallel \
  --compile_no_warning_as_error \
  --enable_pybind \
  --allow_running_as_root

# Move artifacts to /src
mkdir -p /build
cp -r /tmp/onnxruntime/build/Linux/MinSizeRel/*.so /build
cp -r /tmp/onnxruntime/build/Linux/MinSizeRel/dist/*.whl /build
ls -l /build
