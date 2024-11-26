WITH costed_transactions AS (
    SELECT * FROM {{ ref('fct_inventory') }}
),

aggregated_transactions AS (
    SELECT
        transaction_surrogate_id,
        transaction_time AS "Timestamp",
        transaction_date AS "Date",
        transaction_id AS "Transaction ID",
        transaction_line_id AS "Transaction Line ID",
        transaction_type AS "Transaction Type",
        type_based_document_number AS "Type Based Document Number",
        type_based_document_status AS "Type Based Document Status",
        item_id AS "Item ID",
        item_name AS "Item",
        bin_name AS "Bin",
        inventory_status_name AS "Status",
        location_name AS "Location",
        cost AS "Cost",
        SUM(quantity) OVER (
            PARTITION BY location_id, bin_id, inventory_status_id, item_id 
            ORDER BY transaction_date ASC
        ) AS "Quantity",
        SUM(value) OVER (
            PARTITION BY location_id, bin_id, inventory_status_id, item_id 
            ORDER BY transaction_date ASC
        ) AS "Value"

    FROM costed_transactions
)

    SELECT * FROM aggregated_transactions