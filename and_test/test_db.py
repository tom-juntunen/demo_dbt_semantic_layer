import duckdb
con = duckdb.connect(database = "duckdb/database.duckdb", read_only = False)


title = """
4a. What is the quantity, and location/bin/status combos of item 355576 on date 2022-11-21?
"""
sql = """
    with daily_inventory AS (
        select 
            "Date",
            "Item ID",
            "Quantity",
            "Value",
            "Location",
            "Bin",
            "Status",
            MAX("Date") OVER (
                PARTITION BY "Item ID", "Location", "Bin", "Status"
            ) AS max_transaction_date
        from inventory_daily
            where "Item ID" = 355576
            and "Date" <= '2022-11-21'
    )
    select  
        "Date",
        "Item ID",
        SUM("Quantity") AS "Quantity",
        SUM("Value") AS "Value",
        "Location",
        "Bin",
        "Status"
    from daily_inventory
    where "Date" = max_transaction_date
    group by "Date", "Item ID", "Location", "Bin", "Status"
    order by "Date" DESC
"""
res = con.sql(sql)
print(title)
print(res)



title = """
4b. What is the total value of item 209372 on date 2022-06-05?
"""
sql = """
    with daily_inventory AS (
        select 
            "Date",
            "Item ID",
            "Quantity",
            "Value",
            "Location",
            "Bin",
            "Status",
            MAX("Date") OVER (
                PARTITION BY "Item ID"
                ORDER BY "Date" DESC
            ) AS max_transaction_date
        from inventory_daily
            where "Item ID" = 209372
                and "Date" <= '2022-06-05'
            order by "Date" DESC
    )
    select SUM("Value") AS "Value" 
    from daily_inventory
    where "Date" = max_transaction_date
"""
res = con.sql(sql)
print(title)
print(res)


title = """
4c. What is the total value of inventory in Location 
c7a95e433e878be525d03a08d6ab666b on 2022-01-01?
"""
sql = """
    with daily_inventory AS (
        select 
            "Date",
            "Item ID",
            "Value",
            MAX("Date") OVER (
                PARTITION BY "Item ID"
                ORDER BY "Date" DESC
            ) AS max_transaction_date
        from inventory_daily
            where "Location" = 'c7a95e433e878be525d03a08d6ab666b'
                and "Date" <= '2022-01-01'
            order by "Date" DESC
    )
    select SUM("Value") AS "Value" from daily_inventory
    where "Date" = max_transaction_date
"""

res = con.sql(sql)
print(title)
print(res)

# 2021-06-03 this item 12299 was in location c7a95e
# now im going to search for all transactions for item 12299
