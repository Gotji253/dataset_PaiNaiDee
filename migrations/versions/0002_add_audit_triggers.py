"""Add audit triggers for Place, Review, User, Trip tables

Revision ID: 0002
Revises: 0001
Create Date: YYYY-MM-DD HH:MM:SS.ffffff

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import os

# revision identifiers, used by Alembic.
revision: str = '0002'
down_revision: Union[str, None] = '0001'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

# Path to the SQL files for the trigger functions
# Assuming this migration script is in migrations/versions and SQL files are in triggers/
SQL_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'triggers')

trigger_definitions = {
    "Place": {
        "function_file": "log_place_changes.sql",
        "function_name": "log_place_changes",
        "trigger_name": "place_audit_trigger"
    },
    "Review": {
        "function_file": "log_review_changes.sql",
        "function_name": "log_review_changes",
        "trigger_name": "review_audit_trigger"
    },
    "User": {
        "function_file": "log_user_changes.sql",
        "function_name": "log_user_changes",
        "trigger_name": "user_audit_trigger"
    },
    "Trip": {
        "function_file": "log_trip_changes.sql",
        "function_name": "log_trip_changes",
        "trigger_name": "trip_audit_trigger"
    }
}

def upgrade() -> None:
    for table_name, definition in trigger_definitions.items():
        function_file_path = os.path.join(SQL_DIR, definition["function_file"])
        with open(function_file_path, 'r') as f:
            sql_function_definition = f.read()
        op.execute(sql_function_definition)

        op.execute(f"""
        CREATE TRIGGER {definition["trigger_name"]}
        AFTER INSERT OR UPDATE OR DELETE ON "{table_name}"
        FOR EACH ROW EXECUTE FUNCTION {definition["function_name"]}();
        """)

def downgrade() -> None:
    for table_name, definition in reversed(list(trigger_definitions.items())):
        op.execute(f"DROP TRIGGER IF EXISTS {definition['trigger_name']} ON \"{table_name}\";")
        # Optionally, drop the function if it's not shared or managed elsewhere.
        # For simplicity here, we might leave the function, or drop it if sure.
        # op.execute(f"DROP FUNCTION IF EXISTS {definition['function_name']}();")
    # It's generally safer to leave functions in downgrade unless they are strictly tied to this version
    # and not potentially used by other custom logic or future versions independently.
    # If functions are idempotent (CREATE OR REPLACE), re-running upgrade is fine.
    # For this case, since functions are in separate files and re-executed on upgrade,
    # we can consider dropping them in downgrade.
    for table_name, definition in reversed(list(trigger_definitions.items())):
         op.execute(f"DROP FUNCTION IF EXISTS {definition['function_name']}();")
