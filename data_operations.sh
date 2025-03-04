#!/bin/bash

insert_into_table() {
    read -p "Enter table name: " table_name
    if [ ! -f "$table_name" ]; then
        echo "Table not found!"
        return
    fi

    columns=$(head -n 1 "$table_name.meta" | tr ',' ' ')
    pk=$(grep "PrimaryKey=" "$table_name.meta" | cut -d '=' -f2)

    declare -A record
    for col in $columns; do
        read -p "Enter value for $col: " value
        record[$col]=$value
    done

    if grep -q "^${record[$pk]}," "$table_name"; then
        echo "Error: Primary Key must be unique!"
        return
    fi

    echo "${record[@]}" | tr ' ' ',' >> "$table_name"
    echo "Record inserted successfully!"
}

select_from_table() {
    read -p "Enter table name: " table_name
    if [ ! -f "$table_name" ]; then
        echo "Table not found!"
        return
    fi
    column -t -s ',' "$table_name"
}

delete_from_table() {
    read -p "Enter table name: " table_name
    read -p "Enter column name to filter: " col_name
    read -p "Enter value to match: " value

    sed -i "/$value/d" "$table_name"
    echo "Rows deleted where $col_name = $value"
}

update_table() {
    read -p "Enter table name: " table_name
    read -p "Enter column to filter: " col_name
    read -p "Enter value to match: " value
    read -p "Enter column to update: " update_col
    read -p "Enter new value: " new_value

    awk -F, -v col="$col_name" -v val="$value" -v update="$update_col" -v new_val="$new_value" '
    NR==1 {
        for (i=1; i<=NF; i++) {
            if ($i == col) col_num = i;
            if ($i == update) update_num = i;
        }
        print;
    }
    NR>1 {
        if ($col_num == val) $update_num = new_val;
        print;
    }' OFS=',' "$table_name" > tmpfile && mv tmpfile "$table_name"

    echo "Record updated!"
}
