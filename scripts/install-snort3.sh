#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Snort 3 Installation Script (Ubuntu 24.04 LTS - Noble)
# - Installs required dependencies
# - Builds and installs LibDAQ
# - Builds and installs Snort 3 from source
#
# Tested target environment:
# - Ubuntu 24.04.x (VM used in course labs)
#
# Notes:
# - Compilation is done in ~/build to avoid issues with VirtualBox shared folders.
# - If you have limited RAM/CPU, reduce the -j value (e.g., -j1).
# ==============================================================================

# ----- Configuration -----
PREFIX="/usr/local"
BUILD_DIR="${HOME}/build"
JOBS="1"   # set to 1 if your VM is low on RAM (2GB) or compilation fails

# ----- Helpers -----
log() { echo -e "\n[+] $*\n"; }

# ----- Sanity checks -----
if [[ $EUID -eq 0 ]]; then
  echo "Please run as a normal user (not root). The script uses sudo when needed."
  exit 1
fi

command -v sudo >/dev/null || { echo "sudo not found. Install sudo first."; exit 1; }

log "Updating package lists"
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt update

log "Installing build tools and Snort dependencies"
# Core build tools + common libs
sudo apt install -y \
  build-essential cmake pkg-config git \
  autoconf automake libtool \
  bison flex \
  zlib1g-dev liblzma-dev \
  libpcap-dev \
  libpcre3-dev \
  libdumbnet-dev \
  libssl-dev \
  libnghttp2-dev \
  libluajit-5.1-dev \
  libhwloc-dev \
  uuid-dev \
  libunwind-dev \
  libatomic1 \
  wget curl ca-certificates

# Optional but recommended: Hyperscan (fast pattern matching)
# If it fails, Snort can still be compiled (we just skip it).
log "Trying to install Hyperscan (optional, recommended)"
if ! sudo apt install -y libhyperscan-dev; then
  echo "[!] Hyperscan not available from apt or failed to install. Continuing without it."
fi

log "Creating build directory: ${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"

# ==============================================================================
# 1) Build & install LibDAQ
# ==============================================================================
log "Cloning LibDAQ"
cd "${BUILD_DIR}"
if [[ -d "libdaq" ]]; then
  log "libdaq already exists, pulling latest changes"
  cd libdaq
  git pull
else
  git clone https://github.com/snort3/libdaq.git
  cd libdaq
fi

log "Building and installing LibDAQ"
./bootstrap
./configure --prefix="${PREFIX}"
make -j"${JOBS}"
sudo make install
sudo ldconfig

log "LibDAQ installed. Checking ldconfig for DAQ libraries"
ldconfig -p | grep -i daq || echo "[!] DAQ libraries not found in ldconfig output (might still be ok)."

# ==============================================================================
# 2) Build & install Snort 3
# ==============================================================================
log "Cloning Snort 3"
cd "${BUILD_DIR}"
if [[ -d "snort3" ]]; then
  log "snort3 already exists, pulling latest changes"
  cd snort3
  git pull
else
  git clone https://github.com/snort3/snort3.git
  cd snort3
fi

log "Configuring Snort 3 (cmake)"
./configure_cmake.sh --prefix="${PREFIX}"

log "Building Snort 3"
cd build
make -j"${JOBS}"

log "Installing Snort 3"
sudo make install
sudo ldconfig

# ==============================================================================
# 3) Verification
# ==============================================================================
log "Verifying Snort installation"
if command -v snort >/dev/null; then
  snort -V
else
  echo "[!] 'snort' not found in PATH. Try: ${PREFIX}/bin/snort -V"
  "${PREFIX}/bin/snort" -V || true
fi

log "Done. Snort 3 should now be installed under ${PREFIX}"
echo "Next suggested steps:"
echo " - Create a minimal snort.lua + local.rules in your repo"
echo " - Run Snort on a small PCAP to validate the pipeline"
