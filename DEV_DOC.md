# Developer Documentation

This document explains the internal mechanics, script flows, and security measures applied across the service layers.

## Core Component Configurations

### 1. Networking & Reverse Proxy
- All network interaction occurs over an isolated, custom Docker bridge network.
- NGINX functions as the absolute gateway. Direct port forwarding to the WordPress or MariaDB containers from the external host is intentionally omitted.
- NGINX routes incoming dynamic queries to the WordPress container over port `9000` utilizing the FastCGI protocol.

### 2. Storage & Persistence
Data persistency bypasses container lifecycles via historical volume binding mapping host system directories directly to service runtime hubs:
- **WordPress Root**: `/home/cwong/data/wordpress` mounts to `/var/www/html`
- **MariaDB Database**: `/home/cwong/data/mariadb` mounts to `/var/lib/mysql`

## Security Mechanics: Docker Secrets Implementation

To mitigate credential leaks, the platform relies on native Docker Secrets file-mounting over basic `.env` parsing for system passwords.

### Configuration Extraction Flow
At startup, runtime scripts execute an internal shell utility function (`get_secret`) to safely acquire internal configuration parameters:

```bash
get_secret() {
    local env_var_name=$1
    local secret_file_path=$2
    
    if [ -f "$secret_file_path" ]; then
        cat "$secret_file_path"
    else
        echo "${!env_var_name}"
    fi
}
