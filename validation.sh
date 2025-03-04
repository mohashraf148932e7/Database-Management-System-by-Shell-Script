#!/bin/bash

validate_primary_key() {
    local table=$1
    local pk_value=$2
    local pk_column=$(grep "PrimaryKey=" "$table.meta" | cut -d '=' -f2)

    if grep -q "^$pk_value," "$table"; then
        echo "Error: Primary Key '$pk_column' must be unique!"
        return 1
    fi
    return 0
}
