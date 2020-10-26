#!/bin/ash
# This script installs Klipper on a Raspberry Pi machine running the
# Alpine distribution.

PYTHONDIR="${HOME}/klippy-env"

# Step 2: Create python virtual environment
create_virtualenv()
{
    report_status "Updating python virtual environment..."

    # Create virtualenv if it doesn't already exist
    [ ! -d ${PYTHONDIR} ] && virtualenv -p python2 ${PYTHONDIR}

    # Install/update dependencies
    ${PYTHONDIR}/bin/pip install -r ${SRCDIR}/scripts/klippy-requirements.txt
}

# Step 3: Install startup script
install_script()
{
    report_status "Installing system start script..."
    sudo cp "${SRCDIR}/scripts/klipper-start.sh" /etc/init.d/klipper
    #sudo update-rc.d klipper defaults
}

# Step 4: Install startup script config
install_config()
{
    DEFAULTS_FILE=/etc/default/klipper
    [ -f $DEFAULTS_FILE ] && return

    report_status "Installing system start configuration..."
    sudo /bin/sh -c "cat > $DEFAULTS_FILE" <<EOF
# Configuration for /etc/init.d/klipper
KLIPPY_USER=$USER
KLIPPY_EXEC=${PYTHONDIR}/bin/python
KLIPPY_ARGS="${SRCDIR}/klippy/klippy.py ${HOME}/printer.cfg -l /tmp/klippy.log"
EOF
}

# Step 5: Start host software
start_software()
{
    report_status "Launching Klipper host software..."
    sudo /etc/init.d/klipper restart
}

# Helper functions
report_status()
{
    echo -e "\n\n###### $1"
}

verify_ready()
{
    if [ "$EUID" -eq 0 ]; then
        echo "This script must not run as root"
        exit -1
    fi
}

# Force script to exit if an error occurs
set -e

# Find SRCDIR from the pathname of this script
#SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
# this script is intended to be ran from Docker build, so we can hardcode it
SRCDIR="/3d_print/klipper"

# Run installation steps defined above
verify_ready
create_virtualenv
install_script
install_config
start_software