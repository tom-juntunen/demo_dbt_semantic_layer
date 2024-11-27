WITH transactions AS (
    SELECT DISTINCT
        transaction_date AS transaction_time,
        CAST(transaction_date AS DATE) AS transaction_date,
        transaction_id,
        transaction_line_id,
        transaction_type,
        type_based_document_number,
        type_based_document_status,
        item_id,
        bin_id,
        inventory_status_id,
        location_id,
        quantity
    FROM {{ ref('transaction_line') }}
),

items AS (
    SELECT DISTINCT * FROM {{ ref('item') }}
),

bins AS (
    SELECT DISTINCT * FROM {{ ref('bin') }}
),

inventory_statuses AS (
    SELECT DISTINCT * FROM {{ ref('inventory_status') }}
),

locations AS (
    SELECT DISTINCT * FROM {{ ref('location') }}
),

costs AS (
    SELECT DISTINCT 
        date,
        location_id,
        item_id,
        cost
    FROM {{ ref('costs') }}
),

costed_transactions AS (

    SELECT 
        {{ 
            dbt_utils.generate_surrogate_key(
                [
                    'bin_id', 
                    'inventory_status_id',
                    't1.item_id',
                    't1.location_id',
                    'transaction_id',
                    'transaction_line_id',
                    'transaction_type',
                    'type_based_document_number',
                    'type_based_document_status',
                    'quantity'
                ]
            ) 
        }} AS transaction_surrogate_id,
        t1.transaction_time,
        t1.transaction_date,
        t1.transaction_id,
        t1.transaction_line_id,
        t1.transaction_type,
        t1.type_based_document_number,
        t1.type_based_document_status,
        t1.item_id,
        i.name AS item_name,
        t1.bin_id,
        b.name AS bin_name,
        t1.inventory_status_id,
        s.name AS inventory_status_name,
        t1.location_id,
        l.name AS location_name,
        quantity,
        CAST(c.cost AS DECIMAL(10,2)) AS cost,
        quantity * CAST(c.cost AS DECIMAL(10,2)) AS value

    FROM transactions t1
    LEFT JOIN items i ON t1.item_id = i.id
    LEFT JOIN bins b ON t1.bin_id = b.id
    LEFT JOIN inventory_statuses s ON t1.inventory_status_id = s.id
    LEFT JOIN locations l ON t1.location_id = l.id
    -- Find the most recent effective cost for each transaction using window function
    LEFT JOIN (
        SELECT 
            c1.item_id,
            c1.location_id,
            c1.cost,
            ROW_NUMBER() OVER (PARTITION BY c1.item_id, c1.location_id ORDER BY c1.date DESC) AS rn
        FROM costs c1
        WHERE c1.date <= (SELECT MAX(t2.transaction_date) 
                           FROM transactions t2 
                           WHERE t2.item_id = c1.item_id 
                             AND t2.location_id = c1.location_id)
    ) c ON t1.item_id = c.item_id AND t1.location_id = c.location_id AND c.rn = 1  -- Only the most recent cost
)

SELECT * FROM costed_transactions
