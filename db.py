import os
from contextlib import contextmanager
from typing import Generator

import pymysql
import pymysql.cursors
from dotenv import load_dotenv

load_dotenv()


class DatabaseConfig:
    host: str
    port: int
    database: str
    user: str
    password: str

    def __init__(
        self,
        host: str | None = None,
        port: int | None = None,
        database: str | None = None,
        user: str | None = None,
        password: str | None = None,
    ) -> None:
        self.host = host or os.environ["DB_HOST"]
        self.port = int(port or os.environ.get("DB_PORT", 3306))
        self.database = database or os.environ["DB_NAME"]
        self.user = user or os.environ["DB_USER"]
        self.password = password or os.environ["DB_PASSWORD"]


class DatabaseClientFactory:
    """Factory for creating MariaDB connections via PyMySQL."""

    def __init__(self, config: DatabaseConfig | None = None) -> None:
        self._config = config or DatabaseConfig()

    def get_connection(self) -> pymysql.Connection:
        """Return a new raw connection. Caller is responsible for closing it."""
        return pymysql.connect(
            host=self._config.host,
            port=self._config.port,
            database=self._config.database,
            user=self._config.user,
            password=self._config.password,
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False,
        )

    @contextmanager
    def connection(self) -> Generator[pymysql.Connection, None, None]:
        """Context manager that yields a connection and commits on success, rolls back on error."""
        conn = self.get_connection()
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()

    @contextmanager
    def cursor(self) -> Generator[pymysql.cursors.DictCursor, None, None]:
        """Context manager that yields a cursor directly."""
        with self.connection() as conn:
            with conn.cursor() as cur:
                yield cur
