#!/bin/bash

create_table() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name" ]; then
        echo "Table already exists!"
    else
        read -p "Enter columns (comma-separated): " columns
        read -p "Enter primary key column: " primary_key
        echo "$columns" > "$table_name.meta"
        echo "PrimaryKey=$primary_key" >> "$table_name.meta"
        touch "$table_name"
        echo "Table '$table_name' created!"
    fi
}

list_tables() {
    echo "Available Tables:"
    ls | grep -v ".meta"
}

drop_table() {
    read -p "Enter table name to delete: " table_name
    if [ -f "$table_name" ]; then
        rm "$table_name" "$table_name.meta"
        echo "Table '$table_name' deleted!"
    else
        echo "Table not found!"
    fi
}
