#!/bin/bash

# Author: Sumesh T
# Purpose: Automate Git installation, Python 3.10 setup, virtual environment creation, Odoo 16 setup, and aliases creation

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

echo ""
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
sudo apt-get install -y libpq-dev

echo ""
echo "====================== CHECKING AND INSTALLING PIP ======================"
echo ""

# Check if pip3 is installed
if ! command -v pip3 &>/dev/null; then
    echo "pip3 is not installed. Installing pip3..."
    sudo apt install -y python3-pip
    if [ $? -eq 0 ]; then
        echo "pip3 has been installed successfully!"
    else
        echo "Error: Failed to install pip3. Please check your system settings."
        exit 1
    fi
else
    echo "pip3 is already installed!"
fi

if [ $? -eq 0 ]; then
    echo "System dependency 'libpq-dev' has been installed successfully!"
else
    echo "Error: Failed to install 'libpq-dev'. Please check your system settings."
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

# Create a virtual environment named venv16
venv_dir="/opt/venv16"
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
odoo_dir="$HOME/workspace"
if [ -d "$odoo_dir" ]; then
    echo "Directory '$odoo_dir' already exists."
else
    mkdir -p "$odoo_dir" && echo "Directory '$odoo_dir' created successfully!" || { echo "Error: Failed to create directory '$odoo_dir'."; exit 1; }
fi
cd "$odoo_dir" || { echo "Error: Failed to navigate to directory '$odoo_dir'."; exit 1; }

echo ""
echo "====================== GIT CLONE START ================================"
echo ""

# Clone Odoo 16 repository
if [ ! -d "odoo_16" ]; then
   git clone https://github.com/odoo/odoo.git --branch=16.0 --depth=1 odoo_16
    if [ $? -eq 0 ]; then
        echo "Odoo 16 repository has been cloned successfully!"
    else
        echo "Error: Failed to clone the Odoo 16 repository."
        exit 1
    fi
else
    echo "Odoo 16 repository already exists."
fi

echo ""
echo "====================== PYTHON PACKAGE INSTALLATION ======================"
echo ""

# Navigate to the Odoo 16 directory
cd odoo_16 || { echo "Error: Failed to navigate to 'odoo_16' directory."; exit 1; }

# Install required Python packages inside the virtual environment
echo "Installing required Python packages..."
pip install --no-cache-dir Babel==2.9.1 \
    psycopg2==2.9.5 \
    chardet==4.0.0 \
    cryptography==3.4.8 \
    decorator==4.4.2 \
    docutils==0.16 \
    ebaysdk==2.1.5 \
    freezegun==0.3.15 \
    gevent==22.10.2 \
    greenlet==2.0.2 \
    idna==2.10 \
    Jinja2==3.1.2 \
    libsass==0.20.1 \
    lxml==4.9.2 \
    MarkupSafe==2.1.2 \
    num2words==0.5.9 \
    ofxparse==0.21 \
    passlib==1.7.4 \
    Pillow==9.4.0 \
    polib==1.1.0 \
    psutil==5.9.4 \
    pydot==1.4.2 \
    pyopenssl==20.0.1 \
    PyPDF2==2.12.1 \
    pyserial==3.5 \
    python-dateutil==2.8.1 \
    python-ldap==3.4.0 \
    python-stdnum==1.16 \
    pyusb==1.2.1 \
    qrcode==6.1 \
    reportlab==3.6.12 \
    requests==2.25.1 \
    urllib3==1.26.5 \
    vobject==0.9.6.1 \
    Werkzeug==2.0.2 \
    xlrd==1.2.0 \
    XlsxWriter==1.1.2 \
    xlwt==1.3.* \
    zeep==4.0.0 \
    setuptools \
    lxml_html_clean

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

if ! grep -q "alias v16=" "$bashrc"; then
    echo "# Aliases for virtual environment 16 and directories" >> "$bashrc"
    echo "alias v16=\"source $venv_dir/bin/activate\"" >> "$bashrc"
    echo "alias d=\"deactivate\"" >> "$bashrc"
    echo "alias 16=\"source $venv_dir/bin/activate && cd $odoo_dir/odoo_16\"" >> "$bashrc"
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
echo -e "Odoo 16 folder: $odoo_dir/odoo_16"
echo ""
echo -e "${YELLOW}Use these shortcuts:${RESET}"
echo -e "${GREEN}1. Activate virtual environment: v16${RESET}"
echo -e "${GREEN}2. Deactivate virtual environment: d${RESET}"
echo -e "${GREEN}3. Activate venv and navigate to Odoo folder: 16${RESET}"

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
