"""Add utility functions for trips and places

Revision ID: 0003
Revises: 0002
Create Date: YYYY-MM-DD HH:MM:SS.ffffff

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import os

# revision identifiers, used by Alembic.
revision: str = '0003'
down_revision: Union[str, None] = '0002'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

SQL_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'functions')

function_files = [
    "get_upcoming_trips.sql",
    "recommend_places.sql",
    "recommend_places_personalized.sql" # The renamed original file
]

# Function names for easier dropping in downgrade. Assumes no overloading with different params for now.
# If functions are overloaded, specific signatures would be needed for DROP FUNCTION.
function_signatures = {
    "get_upcoming_trips": "get_upcoming_trips(INT, INT)",
    "get_popular_places": "get_popular_places(INT)",
    "recommend_places_personalized": "recommend_places(INT, INT)" # Original name from the file was recommend_places
}


def upgrade() -> None:
    for func_file in function_files:
        function_file_path = os.path.join(SQL_DIR, func_file)
        if os.path.exists(function_file_path):
            with open(function_file_path, 'r') as f:
                sql_function_definition = f.read()
            op.execute(sql_function_definition)
        else:
            print(f"Warning: SQL function file {function_file_path} not found. Skipping.")


def downgrade() -> None:
    # Drop functions in reverse order of creation if dependencies exist, though not critical here.
    for func_name_key in reversed(list(function_signatures.keys())):
        # The actual function name in recommend_places_personalized.sql is recommend_places.
        # So we need to use the correct signature from the SQL file.
        # The key "recommend_places_personalized" maps to the function signature "recommend_places(INT, INT)"

        # A more robust way to get the function name for dropping:
        # For 'recommend_places_personalized.sql', the function is 'recommend_places(user_id_param INT, recommendation_limit INT DEFAULT 5)'
        # For 'get_upcoming_trips.sql', it's 'get_upcoming_trips(p_user_id INT, p_future_days INT)'
        # For 'recommend_places.sql', it's 'get_popular_places(p_limit INT)'

        # Correct signatures for dropping:
        if func_name_key == "get_upcoming_trips":
            op.execute("DROP FUNCTION IF EXISTS get_upcoming_trips(INT, INT);")
        elif func_name_key == "get_popular_places":
            op.execute("DROP FUNCTION IF EXISTS get_popular_places(INT);")
        elif func_name_key == "recommend_places_personalized": # This refers to function named 'recommend_places' in the SQL file
            op.execute("DROP FUNCTION IF EXISTS recommend_places(INT, INT);")
