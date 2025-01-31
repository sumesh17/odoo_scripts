#!/bin/bash
#########################################################################
# Script for installing or updating WKHTMLTOPDF with Patched Qt on Ubuntu 24.04 LTS

# Enable debugging options
set -e  # Exit immediately if any command fails
set -x  # Print each command as it is executed (for debugging)
PS4='+ $(basename $0):${LINENO}:${FUNCNAME[0]}: '  # Show line numbers in debug output

#########################################################################

echo "Starting WKHTMLTOPDF Installation/Update with Patched Qt..."

# Desired version of WKHTMLTOPDF with Patched Qt (change this to the version you want)
DESIRED_VERSION="0.12.6"  # Update this if a new version with patched Qt is available
PATCHED_QT_VERSION="0.12.6-1"  # Version with Patched Qt

# Check if wkhtmltopdf is already installed
if command -v wkhtmltopdf &> /dev/null; then
    # If installed, check the current version
    INSTALLED_VERSION=$(wkhtmltopdf --version | awk '{print $2}')
    echo "Current installed version: $INSTALLED_VERSION"

    if [[ "$INSTALLED_VERSION" == "$DESIRED_VERSION" ]]; then
        echo "The installed version is already the desired version ($DESIRED_VERSION) with patched Qt. No need to update."
        exit 0
    elif [[ "$INSTALLED_VERSION" < "$DESIRED_VERSION" ]]; then
        echo "Installed version is older than the desired version. Proceeding with update..."
    else
        echo "The installed version is newer than the desired version ($DESIRED_VERSION). No action taken."
        exit 0
    fi
else
    echo "WKHTMLTOPDF is not installed. Proceeding with installation..."
fi

# Set the download URLs based on Ubuntu version and Patched Qt version
if [[ $(lsb_release -r -s) == "24.04" ]]; then
    WKHTMLTOX_X64="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/$PATCHED_QT_VERSION/wkhtmltox_$PATCHED_QT_VERSION-1.$(lsb_release -c -s)_amd64.deb"
    WKHTMLTOX_X32="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/$PATCHED_QT_VERSION/wkhtmltox_$PATCHED_QT_VERSION-1.$(lsb_release -c -s)_i386.deb"
else
    # For older versions of Ubuntu (not patched Qt)
    WKHTMLTOX_X64="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -c -s)_amd64.deb"
    WKHTMLTOX_X32="https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.$(lsb_release -c -s)_i386.deb"
fi

echo -e "\n---- Updating Server ----"
# universe package is for Ubuntu 18.x
sudo add-apt-repository universe
# libpng12-0 dependency for wkhtmltopdf for older Ubuntu versions
sudo add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ xenial main"
sudo apt-get update
sudo apt-get upgrade -y

echo -e "\n---- Installing or Updating WKHTMLTOPDF with Patched Qt ----"
if [ "`getconf LONG_BIT`" == "64" ]; then
  _url=$WKHTMLTOX_X64
else
  _url=$WKHTMLTOX_X32
fi

# Download and install the new version (patched Qt)
echo "Downloading WKHTMLTOPDF from: $_url"
sudo wget $_url

# Install WKHTMLTOPDF for Ubuntu 24.04 LTS or older
if [[ $(lsb_release -r -s) == "24.04" ]]; then
    # Ubuntu 24.04 LTS: Install using the package manager
    echo "Installing WKHTMLTOPDF on Ubuntu 24.04 LTS..."
    sudo apt install wkhtmltopdf -y
else
    # For older versions of Ubuntu, use gdebi to install .deb
    echo "Installing WKHTMLTOPDF for older versions using gdebi..."
    sudo gdebi --n `basename $_url`
fi

# Create symbolic links for the commands
echo "Creating symbolic links..."
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin

echo -e "\n---- WKHTMLTOPDF Installation/Update with Patched Qt Complete ----"
