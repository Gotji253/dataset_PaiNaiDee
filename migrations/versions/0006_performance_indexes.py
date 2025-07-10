"""performance_indexes

Revision ID: 0006_performance_indexes
Revises: 0005_schema_normalization_updates
Create Date: 2024-03-15 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0006_performance_indexes'
down_revision = '0005_schema_normalization_updates'
branch_labels = None
depends_on = None


def upgrade():
    # Indexes for Place table
    op.create_index('idx_place_popularity_score_sa', 'Place', ['popularity_score'], unique=False)
    op.create_index('idx_place_average_rating_sa', 'Place', ['average_rating'], unique=False)

    # Index for User table
    op.create_index('idx_user_is_verified_sa', 'User', ['is_verified'], unique=False)

    # Index for Trip table
    op.create_index('idx_trip_is_public_sa', 'Trip', ['is_public'], unique=False)

    # Index for Review table
    op.create_index('idx_review_rating_sa', 'Review', ['rating'], unique=False)


def downgrade():
    # Drop indexes in reverse order of creation
    op.drop_index('idx_review_rating_sa', table_name='Review')
    op.drop_index('idx_trip_is_public_sa', table_name='Trip')
    op.drop_index('idx_user_is_verified_sa', table_name='User')
    op.drop_index('idx_place_average_rating_sa', table_name='Place')
    op.drop_index('idx_place_popularity_score_sa', table_name='Place')
