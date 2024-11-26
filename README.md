# Analytics Engineer Case Study
Author: Tom Juntunen

#### View my final answers in `deliverable.txt`

#### The data stack used for this case study is as follows:
- duckdb (in-memory OLAP warehouse)
- dbt-core

#### Follow these instructions to run the project:

Pre-requisites:
- Create a Python venv and activate it:
```python -m venv venv``` then ```venv\Scripts\activate``` on Windows or ```venv/bin/activate``` on Linux/Mac.
- Install requirements using pip.
```pip install -r requirements.txt```

1. Add the following to ~/.dbt/profiles.yml
```
and_test:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'duckdb/database.duckdb'
```

2. Open a terminal and navigate to the dbt project named **"and_test"**:
```cd and_test```

3. Test your connection:
```dbt debug```

4. Install dbt dependencies: 
```dbt deps```

4. Load the seed data from csv files:
```dbt seed```

5. Run the dbt project to build the models:
```dbt run```

6. Run the database queries to view the results:
```python test_db.py``` 

![alt text](image.png)