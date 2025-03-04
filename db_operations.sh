#!/bin/bash

DB_PATH="./databases"

create_database() {
    read -p "Enter database name: " dbname
    if [ -d "$DB_PATH/$dbname" ]; then
        echo "Database already exists!"
    else
        mkdir -p "$DB_PATH/$dbname"
        echo "Database '$dbname' created!"
    fi
}

list_databases() {
    echo "Available Databases:"
    ls "$DB_PATH"
}

connect_database() {
    read -p "Enter database name to connect: " dbname
    if [ -d "$DB_PATH/$dbname" ]; then
        echo "Connected to '$dbname'"
        cd "$DB_PATH/$dbname" || exit
        database_menu
    else
        echo "Database not found!"
    fi
}

drop_database() {
    read -p "Enter database name to delete: " dbname
    if [ -d "$DB_PATH/$dbname" ]; then
        rm -rf "$DB_PATH/$dbname"
        echo "Database '$dbname' deleted!"
    else
        echo "Database not found!"
    fi
}

database_menu() {
    while true; do
        echo "===== Database Menu ====="
        echo "1) Create Table"
        echo "2) List Tables"
        echo "3) Drop Table"
        echo "4) Insert into Table"
        echo "5) Select from Table"
        echo "6) Delete from Table"
        echo "7) Update Table"
        echo "8) Back to Main Menu"
        read -p "Choose an option: " db_choice

        case $db_choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) cd ../../ && break ;;
            *) echo "Invalid option!" ;;
        esac
    done
}
