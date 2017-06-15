if [ $(id -u) = "0" ]; then
    echo "ERROR: Running $0 as root is not supported (and is a bad idea, anyway)"
    exit 1
fi

lower() {
    tr '[:upper:]' '[:lower:']
}

pip_installed() {
    "${1:?}" --disable-pip-version-check freeze --all | lower | LC_ALL=C sort
}

pip_reqs() {
    # Extract package==version from pip requirement files, ignoring blank and comment lines.
    awk '
      /^#/ {next}
      /^[[:blank:]]*$/ {next}
      {print $1}
    ' "${1:?}" | lower | LC_ALL=C sort
}

pip_compare() {
    local pip="${1:?}"
    local req="${2:?}"
    pip_installed "$pip" > env/first.txt
    pip_reqs "$req" > env/second.txt
    LC_ALL=C comm --check-order -13 env/first.txt env/second.txt
    rm env/first.txt env/second.txt
}

pip_install() {
    local pip="${1:?}"
    local req="${2:?}"
    "$pip" --disable-pip-version-check install --user --require-hashes -r "$req"
}
