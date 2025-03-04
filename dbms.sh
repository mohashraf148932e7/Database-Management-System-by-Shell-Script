#!/bin/bash

source db_operations.sh
source table_operations.sh
source data_operations.sh
source validation.sh

while true; do
    echo "Main menu"
    echo "1) Create db"
    echo "2) List db"
    echo "3) Connect to db"
    echo "4) Drop db"
    echo "5) Exit"
    read -p "Choose an option: " choice

    case $choice in
        1) create_database ;;
        2) list_databases ;;
        3) connect_database ;;
        4) drop_database ;;
        5) exit ;;
        *) echo "Invalid option!" ;;
    esac
done
