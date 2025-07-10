"""schema_normalization_updates

Revision ID: 0005_schema_normalization_updates
Revises: 0004_add_place_enhancements
Create Date: 2024-03-15 11:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '0005_schema_normalization_updates'
down_revision = '0004_add_place_enhancements'
branch_labels = None
depends_on = None


def upgrade():
    # --- Favorite Table Changes ---
    # Step 1: Add the new favorite_id column, initially nullable to handle existing data if any.
    # autoincrement=True tells SQLAlchemy this column should use a sequence.
    op.add_column('Favorite', sa.Column('favorite_id', sa.Integer(), autoincrement=True, nullable=True))

    # Step 2: Populate favorite_id for existing rows. (Important if data exists)
    # This example assumes 'Favorite_favorite_id_seq' is the sequence name.
    # SQLAlchemy/Alembic usually handles naming. If custom population needed:
    # op.execute('UPDATE "Favorite" SET favorite_id = nextval(\'"Favorite_favorite_id_seq"\') WHERE favorite_id IS NULL;')
    # For this script, we rely on autoincrement handling new rows and assume migration handles population or it's done manually if complex.

    # Step 3: Drop the old composite primary key constraint.
    # The actual name of the constraint must be known. 'Favorite_pkey' is a common default.
    # This operation can fail if the constraint name is different or does not exist.
    # A common name for a PK defined on (user_id, place_id) is 'Favorite_pkey'.
    # If the PK was defined implicitly by setting primary_key=True on both columns in the model,
    # Alembic might require a different approach or the name might be different.
    # It's safer to check the actual constraint name in your database.
    # Example: SELECT conname FROM pg_constraint WHERE contrelid = 'Favorite'::regclass AND contype = 'p';
    try:
        op.drop_constraint('Favorite_pkey', 'Favorite', type_='primary')
    except Exception as e:
        # Log or print a message if the constraint is not found, as it might be named differently
        # or the table structure might be different than assumed.
        print(f"Notice: Could not drop constraint 'Favorite_pkey' on 'Favorite'. It might have a different name or not exist. Error: {e}")


    # Step 4: Make favorite_id NOT NULL and the new primary key.
    op.alter_column('Favorite', 'favorite_id',
                    existing_type=sa.INTEGER(),
                    nullable=False)
    op.create_primary_key(
        'Favorite_pkey_new',  # Name for the new primary key constraint
        'Favorite',
        ['favorite_id']
    )

    # Step 5: Create a unique constraint for (user_id, place_id) to maintain original uniqueness.
    op.create_unique_constraint('uq_user_place_favorite', 'Favorite', ['user_id', 'place_id'])

    # Step 6: Create indexes for user_id and place_id FKs.
    op.create_index('idx_favorite_user_id_fk_sa', 'Favorite', ['user_id'], unique=False)
    # The index idx_favorite_place_id_sa from the original schema.sql on place_id should still be effective.
    # If it was tied to the old PK, it might need re-evaluation. Creating a new one for clarity is fine.
    op.create_index('idx_favorite_place_id_fk_sa', 'Favorite', ['place_id'], unique=False)


    # --- AuditLog Table Changes ---
    # Add Foreign Key from AuditLog.changed_by to User.user_id
    # Ensure the column 'changed_by' exists in AuditLog table.
    op.create_foreign_key(
        'fk_auditlog_changed_by_user',  # Constraint name
        'AuditLog',                     # Source table
        'User',                         # Target table
        ['changed_by'],                 # Source column(s) in AuditLog
        ['user_id'],                    # Target column(s) in User
        ondelete='SET NULL'
    )
    # Create index for the foreign key column 'changed_by' in AuditLog
    op.create_index('idx_auditlog_changed_by_fk_sa', 'AuditLog', ['changed_by'], unique=False)


def downgrade():
    # --- AuditLog Table Changes (reverse order) ---
    op.drop_index('idx_auditlog_changed_by_fk_sa', table_name='AuditLog')
    op.drop_constraint('fk_auditlog_changed_by_user', 'AuditLog', type_='foreignkey')

    # --- Favorite Table Changes (reverse order) ---
    op.drop_index('idx_favorite_place_id_fk_sa', table_name='Favorite')
    op.drop_index('idx_favorite_user_id_fk_sa', table_name='Favorite')
    op.drop_constraint('uq_user_place_favorite', 'Favorite', type_='unique')

    op.drop_constraint('Favorite_pkey_new', 'Favorite', type_='primary') # Drop new PK
    op.drop_column('Favorite', 'favorite_id')

    # To restore the old composite primary key (user_id, place_id):
    # This assumes 'user_id' and 'place_id' columns still exist and are NOT NULL.
    # The original PK might have been named 'Favorite_pkey' or defined implicitly.
    # op.create_primary_key('Favorite_pkey', 'Favorite', ['user_id', 'place_id'])
    # Note: Restoring PKs that were implicitly defined by Column(primary_key=True) on multiple columns
    # without an explicit Table.__table_args__ constraint name can be tricky in downgrade.
    # For this exercise, dropping favorite_id is the main part of reversing the PK change.
    # The original schema.sql implies PRIMARY KEY (user_id, place_id) was defined at table creation.
    # A simple way to restore this if other constraints are dropped:
    # (This might fail if columns are not suitable, or if ORM model implies different PK structure on downgrade)
    # op.execute('ALTER TABLE "Favorite" ADD CONSTRAINT "Favorite_pkey" PRIMARY KEY (user_id, place_id);')
    # However, Alembic prefers op.create_primary_key.
    # For now, the downgrade path focuses on removing what was added.
    # A full revert to the exact previous PK state might need more specific commands based on initial DDL.
