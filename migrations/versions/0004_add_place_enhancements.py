"""add_place_enhancements

Revision ID: 0004_add_place_enhancements
Revises: 0003_add_utility_functions
Create Date: 2024-03-15 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '0004_add_place_enhancements'
down_revision = '0003_add_utility_functions' # Ensure this matches the previous migration ID
branch_labels = None
depends_on = None


def upgrade():
    op.add_column('Place', sa.Column('cover_image_url', sa.String(length=255), nullable=True))
    op.add_column('Place', sa.Column('popularity_score', sa.Integer(), server_default=sa.text('0'), nullable=False))
    op.add_column('Place', sa.Column('opening_hours', postgresql.JSONB(astext_type=sa.Text()), nullable=True))


def downgrade():
    op.drop_column('Place', 'opening_hours')
    op.drop_column('Place', 'popularity_score')
    op.drop_column('Place', 'cover_image_url')
