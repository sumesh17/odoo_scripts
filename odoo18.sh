#!/bin/bash

# Author: Sumesh T
# Purpose: Automate Python 3.10 setup, virtual environment creation, Odoo 18 setup, and necessary package installation

echo "====================== GIT INSTALLATION START ============================"
echo ""

# Install Git
sudo apt install -y git
if [ $? -eq 0 ]; then
    echo "Git has been installed successfully!"
else
    echo "Error: Failed to install Git. Please check your system settings."
    exit 1
fi

echo "====================== SYSTEM UPDATE & UPGRADE START ===================="
echo ""

# Update and Upgrade
sudo apt update -y && sudo apt upgrade -y
if [ $? -eq 0 ]; then
    echo "System has been updated and upgraded successfully!"
else
    echo "Error: Failed to update or upgrade the system."
    exit 1
fi

echo ""
echo "====================== INSTALLING SYSTEM DEPENDENCIES =================="
echo ""

# Install essential development libraries
sudo apt-get install -y libpq-dev python3.10 python3.10-venv python3.10-dev
if [ $? -eq 0 ]; then
    echo "System dependencies have been installed successfully!"
else
    echo "Error: Failed to install dependencies. Please check your system settings."
    exit 1
fi

echo ""
echo "====================== CHECKING AND INSTALLING PYTHON 3.10 =============="
echo ""

# Check if Python 3.10 is installed
if python3.10 --version &>/dev/null; then
    echo "Python 3.10 is already installed!"
else
    echo "Python 3.10 is not installed. Installing Python 3.10..."
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update -y
    sudo apt install -y python3.10 python3.10-venv python3.10-dev
    if [ $? -eq 0 ]; then
        echo "Python 3.10 has been installed successfully!"
    else
        echo "Error: Failed to install Python 3.10. Please check your system settings."
        exit 1
    fi
fi

echo ""
echo "====================== CREATING VIRTUAL ENVIRONMENT ====================="
echo ""

# Create a virtual environment named venv18
venv_dir="/opt/venv18"
if [ ! -d "$venv_dir" ]; then
    sudo python3.10 -m venv "$venv_dir"
    sudo chown -R $USER:$USER "$venv_dir"
    if [ $? -eq 0 ]; then
        echo "Virtual environment '$venv_dir' has been created successfully!"
    else
        echo "Error: Failed to create virtual environment."
        exit 1
    fi
else
    echo "Virtual environment '$venv_dir' already exists."
fi

# Activate the virtual environment
source "$venv_dir/bin/activate"
if [ $? -eq 0 ]; then
    echo "Virtual environment '$venv_dir' has been activated!"
else
    echo "Error: Failed to activate virtual environment."
    exit 1
fi

echo ""
echo "====================== DIRECTORY SETUP START ============================"
echo ""

# Directory setup
odoo_dir="$HOME/workspace/odoo-18"
if [ -d "$odoo_dir" ]; then
    echo "Directory '$odoo_dir' already exists."
else
    mkdir -p "$odoo_dir" && echo "Directory '$odoo_dir' created successfully!" || { echo "Error: Failed to create directory '$odoo_dir'."; exit 1; }
fi
cd "$odoo_dir" || { echo "Error: Failed to navigate to directory '$odoo_dir'."; exit 1; }

echo ""
echo "====================== GIT CLONE START ================================"
echo ""

# Clone Odoo 18 repository
if [ ! -d "odoo_18" ]; then
    git clone https://github.com/odoo/odoo.git --branch=18.0 --depth=1 odoo_18
    if [ $? -eq 0 ]; then
        echo "Odoo 18 repository has been cloned successfully!"
    else
        echo "Error: Failed to clone the Odoo 18 repository."
        exit 1
    fi
else
    echo "Odoo 18 repository already exists."
fi

echo ""
echo "====================== PYTHON PACKAGE INSTALLATION ======================"
echo ""

# Navigate to the Odoo 18 directory
cd odoo_18 || { echo "Error: Failed to navigate to 'odoo_18' directory."; exit 1; }

# Install required Python packages inside the virtual environment
echo "Installing required Python packages..."
pip install --no-cache-dir \
    asn1crypto==1.4.0 \
    Babel==2.9.1 \
    psycopg2==2.9.2 \
    rjsmin==1.1.0 \
    pyopenssl==21.0.0 \
    qrcode==7.3.1 \
    cbor2==5.4.2 \
    chardet==4.0.0 \
    cryptography==3.4.8 \
    decorator==4.4.2 \
    docutils==0.17 \
    freezegun==1.1.0 \
    geoip2==2.9.0 \
    gevent==22.10.2 \
    greenlet==2.0.2 \
    idna==2.10 \
    Jinja2==3.1.2 \
    libsass==0.20.1 \
    lxml==4.9.2 \
    MarkupSafe==2.1.2 \
    num2words==0.5.9 \
    passlib==1.7.4 \
    Pillow==9.4.0 \
    polib==1.1.0 \
    psutil==5.9.4 \
    PyPDF2==2.12.1 \
    python-dateutil==2.8.1 \
    python-stdnum==1.17 \
    reportlab==3.6.12 \
    requests==2.25.1 \
    Werkzeug==2.0.2 \
    XlsxWriter==1.1.2 \
    openpyxl==3.1.4 \
    pandas==1.3.4 \
    xlwt==1.3.0 \
    numpy==1.26.1 \
    zeep==4.0.0

if [ $? -eq 0 ]; then
    echo "Required Python packages have been installed successfully!"
else
    echo "Error: Failed to install some Python packages."
    deactivate
    exit 1
fi

echo ""
echo "====================== CREATING ALIASES ================================"
echo ""

# Add aliases to .bashrc
bashrc="$HOME/.bashrc"

if ! grep -q "alias v18=" "$bashrc"; then
    echo "# Aliases for virtual environment 18 and directories" >> "$bashrc"
    echo "alias v18=\"source $venv_dir/bin/activate\"" >> "$bashrc"
    echo "alias d=\"deactivate\"" >> "$bashrc"
    echo "alias 18=\"source $venv_dir/bin/activate && cd $odoo_dir\"" >> "$bashrc"
    echo "Aliases added successfully!"
else
    echo "Aliases already exist in '$bashrc'."
fi

# Source .bashrc to make aliases immediately available
source "$bashrc"

echo ""
echo "====================== SHORTCUTS AND FILE PATHS ========================="
echo ""

# Color for shortcuts
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "Setup completed! Here are your shortcuts and file paths:"
echo ""
echo -e "Virtual environment: $venv_dir"
echo -e "Odoo 18 folder: $odoo_dir"
echo ""
echo -e "${YELLOW}Use these shortcuts:${RESET}"
echo -e "${GREEN}1. Activate virtual environment: v18${RESET}"
echo -e "${GREEN}2. Deactivate virtual environment: d${RESET}"
echo -e "${GREEN}3. Activate venv and navigate to Odoo folder: 18${RESET}"

echo ""
echo "NOTE: The shortcuts will work in a new terminal session. If you want to use them in this terminal, run:"
echo "  source ~/.bashrc"

echo ""
echo "====================== SCRIPT COMPLETED SUCCESSFULLY ===================="
echo ""

# Deactivate the virtual environment
deactivate

# LinkedIn and GitHub Information
echo ""
echo "====================== CONNECT WITH ME ================================"
echo ""
echo "For more updates and to stay connected, feel free to follow us on:"
echo "LinkedIn: https://www.linkedin.com/in/sumesh-t-0b5357191/"
echo "GitHub: https://github.com/sumesh17"
echo ""
echo "Stay tuned for the latest updates and innovations!"
