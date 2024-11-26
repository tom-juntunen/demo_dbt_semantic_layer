import duckdb
import pandas as pd

con = duckdb.connect(database="duckdb/database.duckdb", read_only=False)

tables = ['fct_inventory', 'inventory_daily']

for table in tables:
    sql = f"SELECT * FROM {table}"
    df = pd.read_sql(sql, con=con)
    df.to_csv(f"{table}.csv", index=False)

con.close()
