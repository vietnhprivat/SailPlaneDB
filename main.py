from pathlib import Path

from db import DatabaseClientFactory

SCHEMA_FILE = Path(__file__).parent / "schema.sql"


def create_tables(factory: DatabaseClientFactory) -> None:
    sql = SCHEMA_FILE.read_text()
    statements: list[str] = []
    
    for sql_statement in sql.split(";"):
        sql_statement = sql_statement.strip()
        if sql_statement:
            statements.append(sql_statement)

    with factory.connection() as connection:
        with connection.cursor() as cursor:
            for statement in statements:
                cursor.execute(statement)

    print(f"Created {len(statements)} tables successfully.")


if __name__ == "__main__":
    factory = DatabaseClientFactory()
    create_tables(factory)
