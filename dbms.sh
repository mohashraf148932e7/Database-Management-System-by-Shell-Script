#!/bin/bash

DB_PATH="./databases"
mkdir -p "$DB_PATH"

show_main_menu() {
    echo "\nMain Menu:"
    echo "1) Create Database"
    echo "2) List Databases"
    echo "3) Connect to Database"
    echo "4) Drop Database"
    echo "5) Exit"
}

create_database() {
    read -p "Enter database name: " dbname
    mkdir -p "$DB_PATH/$dbname" && echo "Database created."
}

list_databases() {
    echo "\nAvailable Databases:" && ls "$DB_PATH"
}

connect_database() {
    read -p "Enter database name to connect: " dbname
    if [[ -d "$DB_PATH/$dbname" ]]; then
        cd "$DB_PATH/$dbname" || exit
        echo "Connected to $dbname"
        table_menu
    else
        echo "Database does not exist."
    fi
}

drop_database() {
    read -p "Enter database name to drop: " dbname
    rm -rf "$DB_PATH/$dbname" && echo "Database deleted."
}

show_table_menu() {
    echo "\nTable Menu:"
    echo "1) Create Table"
    echo "2) List Tables"
    echo "3) Drop Table"
    echo "4) Insert into Table"
    echo "5) Select from Table"
    echo "6) Delete from Table"
    echo "7) Update Table"
    echo "8) Back to Main Menu"
}

create_table() {
    read -p "Enter table name: " table
    read -p "Enter column names separated by space: " columns
    read -p "Enter data types (int, str) in same order: " datatypes
    read -p "Enter primary key column name: " pk
    echo "$columns" > "$table.meta"
    echo "$datatypes" >> "$table.meta"
    echo "$pk" >> "$table.meta"
    touch "$table"
    echo "Table $table created."
}

list_tables() {
    echo "\nTables:" && ls *.meta 2>/dev/null | sed 's/.meta//'
}

drop_table() {
    read -p "Enter table name to drop: " table
    rm -f "$table" "$table.meta" && echo "Table deleted."
}

insert_into_table() {
    read -p "Enter table name: " table
    if [[ ! -f "$table.meta" ]]; then echo "Table not found."; return; fi
    columns=($(head -1 "$table.meta"))
    datatypes=($(sed -n 2p "$table.meta"))
    pk=$(sed -n 3p "$table.meta")
    
    values=()
    for i in "${!columns[@]}"; do
        read -p "Enter ${columns[i]} (${datatypes[i]}): " val
        if [[ "${datatypes[i]}" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
            echo "Invalid input for ${columns[i]}. Expected integer."
            return
        fi
        if [[ "${columns[i]}" == "$pk" && $(cut -d, -f$((i+1)) "$table" | grep -w "$val") ]]; then
            echo "Primary key must be unique."
            return
        fi
        values+=("$val")
    done
    echo "${values[*]}" | tr ' ' ',' >> "$table"
    echo "Row inserted."
}

select_from_table() {
    read -p "Enter table name: " table
    column -t -s, "$table"
}

delete_from_table() {
    read -p "Enter table name: " table
    read -p "Enter condition (column=value): " condition
    col_name=$(echo "$condition" | cut -d= -f1)
    val=$(echo "$condition" | cut -d= -f2)
    col_index=$(head -1 "$table.meta" | tr ' ' '\n' | grep -n -w "$col_name" | cut -d: -f1)
    if [[ -z "$col_index" ]]; then echo "Invalid column."; return; fi
    grep -v "^.*,$val,.*$" "$table" > "$table.tmp" && mv "$table.tmp" "$table"
    echo "Rows deleted."
}

update_table() {
    read -p "Enter table name: " table
    read -p "Enter condition (column=value): " condition
    read -p "Enter update (column=new_value): " update
    col_name=$(echo "$condition" | cut -d= -f1)
    val=$(echo "$condition" | cut -d= -f2)
    update_col=$(echo "$update" | cut -d= -f1)
    new_val=$(echo "$update" | cut -d= -f2)
    col_index=$(head -1 "$table.meta" | tr ' ' '\n' | grep -n -w "$col_name" | cut -d: -f1)
    upd_index=$(head -1 "$table.meta" | tr ' ' '\n' | grep -n -w "$update_col" | cut -d: -f1)
    if [[ -z "$col_index" || -z "$upd_index" ]]; then echo "Invalid column."; return; fi
    awk -v col="$col_index" -v val="$val" -v upd_col="$upd_index" -v new_val="$new_val" -F, 'BEGIN {OFS=","} {if ($col==val) $upd_col=new_val; print}' "$table" > "$table.tmp" && mv "$table.tmp" "$table"
    echo "Row updated."
}

table_menu() {
    while true; do
        show_table_menu
        read -p "Choose an option: " choice
        case $choice in
            1) create_table;;
            2) list_tables;;
            3) drop_table;;
            4) insert_into_table;;
            5) select_from_table;;
            6) delete_from_table;;
            7) update_table;;
            8) cd - > /dev/null; break;;
            *) echo "Invalid option.";;
        esac
    done
}

while true; do
    show_main_menu
    read -p "Choose an option: " choice
    case $choice in
        1) create_database;;
        2) list_databases;;
        3) connect_database;;
        4) drop_database;;
        5) exit;;
        *) echo "Invalid option.";;
    esac
done
