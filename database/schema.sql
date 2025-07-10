-- SQL DDL for PaiNaiDee Project (PostgreSQL)
-- Generated from Alembic migration 0001_initial_schema.py
-- This schema is based on database/models.py

-- Drop tables if they exist (in an order that respects FK constraints)
DROP TABLE IF EXISTS "Image" CASCADE;
DROP TABLE IF EXISTS "Review" CASCADE;
DROP TABLE IF EXISTS "PlaceTag" CASCADE;
DROP TABLE IF EXISTS "PlaceCategory" CASCADE;
DROP TABLE IF EXISTS "Itinerary" CASCADE;
DROP TABLE IF EXISTS "Favorite" CASCADE;
DROP TABLE IF EXISTS "Booking" CASCADE;
DROP TABLE IF EXISTS "Notification" CASCADE;
DROP TABLE IF EXISTS "UserLoginLog" CASCADE;
DROP TABLE IF EXISTS "Trip" CASCADE;
DROP TABLE IF EXISTS "Place" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE; -- User table might be referenced by Place, so drop Place first
DROP TABLE IF EXISTS "Tag" CASCADE;
DROP TABLE IF EXISTS "Category" CASCADE;
DROP TABLE IF EXISTS "AuditLog" CASCADE; -- AuditLog might be last if no FKs point to it

-- Functions and Triggers (should be created before tables that use them, or handled by Alembic's execution order)

-- Trigger for updated_at columns
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for updating Place.average_rating when Review changes
CREATE OR REPLACE FUNCTION update_place_average_rating()
RETURNS TRIGGER AS $$
DECLARE
    v_place_id INT;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        v_place_id := OLD.place_id;
    ELSE
        v_place_id := NEW.place_id;
    END IF;

    IF v_place_id IS NOT NULL THEN
        UPDATE "Place"
        SET "average_rating" = COALESCE(
            (SELECT AVG("rating") FROM "Review" WHERE "place_id" = v_place_id),
            0.00 -- Default to 0 if no reviews
        )
        WHERE "place_id" = v_place_id;
    END IF;

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- AuditLog related function
CREATE OR REPLACE FUNCTION log_booking_changes()
RETURNS TRIGGER AS $$
DECLARE
    v_old_data JSONB;
    v_new_data JSONB;
    v_record_pk TEXT;
    v_changed_by_user_id INTEGER;
BEGIN
    BEGIN
        v_changed_by_user_id := current_setting('app.current_user_id', TRUE)::INTEGER;
    EXCEPTION WHEN OTHERS THEN
        v_changed_by_user_id := NULL;
    END;

    IF (TG_OP = 'UPDATE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := to_jsonb(NEW);
        v_record_pk := OLD.booking_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            IF OLD.user_id IS NOT NULL THEN
                v_changed_by_user_id := OLD.user_id;
            END IF;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        v_old_data := to_jsonb(OLD);
        v_new_data := NULL;
        v_record_pk := OLD.booking_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            IF OLD.user_id IS NOT NULL THEN
                v_changed_by_user_id := OLD.user_id;
            END IF;
        END IF;
    ELSIF (TG_OP = 'INSERT') THEN
        v_old_data := NULL;
        v_new_data := to_jsonb(NEW);
        v_record_pk := NEW.booking_id::TEXT;
        IF v_changed_by_user_id IS NULL THEN
            IF NEW.user_id IS NOT NULL THEN
                v_changed_by_user_id := NEW.user_id;
            END IF;
        END IF;
    END IF;

    INSERT INTO "AuditLog" (table_name, record_pk, operation_type, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME::TEXT, v_record_pk, TG_OP, v_old_data, v_new_data, v_changed_by_user_id);

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Table Definitions

-- Category Table
CREATE TABLE "Category" (
    "category_id" SERIAL PRIMARY KEY,
    "name" VARCHAR(100) UNIQUE NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_category_name_sa ON "Category" ("name"); -- Matches Alembic generated index name

-- Tag Table
CREATE TABLE "Tag" (
    "tag_id" SERIAL PRIMARY KEY,
    "name" VARCHAR(100) UNIQUE NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_tag_name_sa ON "Tag" ("name"); -- Matches Alembic generated index name

-- User Table
CREATE TABLE "User" (
    "user_id" SERIAL PRIMARY KEY,
    "username" VARCHAR(50) UNIQUE NOT NULL,
    "email" VARCHAR(100) UNIQUE NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "first_name" VARCHAR(50),
    "last_name" VARCHAR(50),
    "profile_picture_url" VARCHAR(255),
    "bio" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "is_verified" BOOLEAN DEFAULT FALSE,
    "social_provider" VARCHAR(50),
    "social_id" VARCHAR(100),
    CONSTRAINT "unique_social_login" UNIQUE ("social_provider", "social_id")
);
CREATE INDEX IF NOT EXISTS idx_user_email_sa ON "User" ("email");
CREATE INDEX IF NOT EXISTS idx_user_username_sa ON "User" ("username");
CREATE INDEX IF NOT EXISTS idx_user_is_verified_sa ON "User" ("is_verified"); -- Added Index

-- Place Table
CREATE TABLE "Place" (
    "place_id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "address" VARCHAR(255),
    "latitude" DECIMAL(10, 8),
    "longitude" DECIMAL(11, 8),
    "contact_email" VARCHAR(100),
    "contact_phone" VARCHAR(20),
    "website" VARCHAR(255),
    "average_rating" DECIMAL(3, 2) DEFAULT 0.00 NOT NULL,
    "created_by_user_id" INT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- New columns added in 0004_add_place_enhancements
    "cover_image_url" VARCHAR(255),
    "popularity_score" INTEGER DEFAULT 0 NOT NULL,
    "opening_hours" JSONB,
    FOREIGN KEY ("created_by_user_id") REFERENCES "User"("user_id") ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_place_name_sa ON "Place" ("name");
CREATE INDEX IF NOT EXISTS idx_place_created_by_user_id_sa ON "Place" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS idx_place_latitude_sa ON "Place" ("latitude");
CREATE INDEX IF NOT EXISTS idx_place_longitude_sa ON "Place" ("longitude");
CREATE INDEX IF NOT EXISTS idx_place_popularity_score_sa ON "Place" ("popularity_score"); -- Added Index
CREATE INDEX IF NOT EXISTS idx_place_average_rating_sa ON "Place" ("average_rating"); -- Added Index

-- Trip Table
CREATE TABLE "Trip" (
    "trip_id" SERIAL PRIMARY KEY,
    "user_id" INT NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "start_date" DATE,
    "end_date" DATE,
    "is_public" BOOLEAN DEFAULT FALSE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_trip_user_id_sa ON "Trip" ("user_id");
CREATE INDEX IF NOT EXISTS idx_trip_start_date_sa ON "Trip" ("start_date");
CREATE INDEX IF NOT EXISTS idx_trip_end_date_sa ON "Trip" ("end_date");
CREATE INDEX IF NOT EXISTS idx_trip_is_public_sa ON "Trip" ("is_public"); -- Added Index

-- UserLoginLog Table
CREATE TABLE "UserLoginLog" (
    "log_id" SERIAL PRIMARY KEY,
    "user_id" INT NOT NULL,
    "login_timestamp" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "ip_address" VARCHAR(45),
    "user_agent" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, -- Kept for consistency as per model
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_userloginlog_user_id_sa ON "UserLoginLog" ("user_id");
CREATE INDEX IF NOT EXISTS idx_userloginlog_login_timestamp_sa ON "UserLoginLog" ("login_timestamp");

-- Notification Table
CREATE TABLE "Notification" (
    "notification_id" SERIAL PRIMARY KEY,
    "user_id" INT NOT NULL,
    "message" TEXT NOT NULL,
    "type" VARCHAR(50),
    "related_entity_type" VARCHAR(50),
    "related_entity_id" INT,
    "is_read" BOOLEAN DEFAULT FALSE NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_notification_user_id_sa ON "Notification" ("user_id");
CREATE INDEX IF NOT EXISTS idx_notification_is_read_sa ON "Notification" ("is_read");
CREATE INDEX IF NOT EXISTS idx_notification_created_at_sa ON "Notification" ("created_at");
CREATE INDEX IF NOT EXISTS idx_notification_related_entity_sa ON "Notification" ("related_entity_type", "related_entity_id");

-- Booking Table
CREATE TABLE "Booking" (
    "booking_id" SERIAL PRIMARY KEY,
    "user_id" INT NOT NULL,
    "place_id" INT NOT NULL,
    "trip_id" INT,
    "booking_date" TIMESTAMP WITH TIME ZONE NOT NULL,
    "number_of_people" INT DEFAULT 1 NOT NULL CHECK ("number_of_people" > 0),
    "status" VARCHAR(20) DEFAULT 'PENDING' NOT NULL CHECK ("status" IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED')),
    "notes" TEXT,
    "total_price" DECIMAL(10, 2),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE,
    FOREIGN KEY ("trip_id") REFERENCES "Trip"("trip_id") ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_booking_user_id_sa ON "Booking" ("user_id");
CREATE INDEX IF NOT EXISTS idx_booking_place_id_sa ON "Booking" ("place_id");
CREATE INDEX IF NOT EXISTS idx_booking_trip_id_sa ON "Booking" ("trip_id");
CREATE INDEX IF NOT EXISTS idx_booking_booking_date_sa ON "Booking" ("booking_date");
CREATE INDEX IF NOT EXISTS idx_booking_status_sa ON "Booking" ("status");

-- Itinerary Table
CREATE TABLE "Itinerary" (
    "itinerary_item_id" SERIAL PRIMARY KEY,
    "trip_id" INT NOT NULL,
    "place_id" INT NOT NULL,
    "day_number" INT NOT NULL,
    "start_time" TIME,
    "end_time" TIME,
    "notes" TEXT,
    "order_in_day" INT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("trip_id") REFERENCES "Trip"("trip_id") ON DELETE CASCADE,
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE,
    CONSTRAINT "uq_trip_day_order" UNIQUE ("trip_id", "day_number", "order_in_day")
);
CREATE INDEX IF NOT EXISTS idx_itinerary_trip_id_sa ON "Itinerary" ("trip_id");
CREATE INDEX IF NOT EXISTS idx_itinerary_place_id_sa ON "Itinerary" ("place_id");

-- Favorite Table
CREATE TABLE "Favorite" (
    "user_id" INT NOT NULL,
    "place_id" INT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "favorite_id" SERIAL PRIMARY KEY, -- Changed: favorite_id is now the PK
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE,
    CONSTRAINT "uq_user_place_favorite" UNIQUE ("user_id", "place_id") -- Added unique constraint
);
CREATE INDEX IF NOT EXISTS idx_favorite_user_id_fk_sa ON "Favorite" ("user_id"); -- Added index
CREATE INDEX IF NOT EXISTS idx_favorite_place_id_fk_sa ON "Favorite" ("place_id"); -- Potentially renamed or ensured index

-- PlaceCategory Junction Table
CREATE TABLE "PlaceCategory" (
    "place_id" INT NOT NULL,
    "category_id" INT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("place_id", "category_id"),
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE,
    FOREIGN KEY ("category_id") REFERENCES "Category"("category_id") ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_placecategory_place_id_sa ON "PlaceCategory" ("place_id");
CREATE INDEX IF NOT EXISTS idx_placecategory_category_id_sa ON "PlaceCategory" ("category_id");

-- PlaceTag Junction Table
CREATE TABLE "PlaceTag" (
    "place_id" INT NOT NULL,
    "tag_id" INT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("place_id", "tag_id"),
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE,
    FOREIGN KEY ("tag_id") REFERENCES "Tag"("tag_id") ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_placetag_place_id_sa ON "PlaceTag" ("place_id");
CREATE INDEX IF NOT EXISTS idx_placetag_tag_id_sa ON "PlaceTag" ("tag_id");

-- Review Table
CREATE TABLE "Review" (
    "review_id" SERIAL PRIMARY KEY,
    "user_id" INT NOT NULL,
    "place_id" INT NOT NULL,
    "rating" INT NOT NULL CHECK ("rating" >= 1 AND "rating" <= 5),
    "comment" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE,
    UNIQUE ("user_id", "place_id") -- Renamed from uq_user_place_review to match implicit constraint name
);
CREATE INDEX IF NOT EXISTS idx_review_user_id_sa ON "Review" ("user_id");
CREATE INDEX IF NOT EXISTS idx_review_place_id_sa ON "Review" ("place_id");
CREATE INDEX IF NOT EXISTS idx_review_rating_sa ON "Review" ("rating"); -- Added Index

-- Image Table
CREATE TABLE "Image" (
    "image_id" SERIAL PRIMARY KEY,
    "image_url" VARCHAR(255) NOT NULL,
    "caption" VARCHAR(255),
    "uploaded_by_user_id" INT,
    "place_id" INT,
    "review_id" INT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("uploaded_by_user_id") REFERENCES "User"("user_id") ON DELETE SET NULL,
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE SET NULL,
    FOREIGN KEY ("review_id") REFERENCES "Review"("review_id") ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_image_uploaded_by_user_id_sa ON "Image" ("uploaded_by_user_id");
CREATE INDEX IF NOT EXISTS idx_image_place_id_sa ON "Image" ("place_id");
CREATE INDEX IF NOT EXISTS idx_image_review_id_sa ON "Image" ("review_id");

-- AuditLog Table
CREATE TABLE "AuditLog" (
    log_id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_pk TEXT NOT NULL, -- Primary key of the audited record. For composite keys, consider a consistent string representation.
    operation_type VARCHAR(10) NOT NULL, -- เช่น INSERT, UPDATE, DELETE
    old_data JSONB, -- ข้อมูลเก่า (สำหรับ UPDATE, DELETE)
    new_data JSONB, -- ข้อมูลใหม่ (สำหรับ INSERT, UPDATE)
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    changed_by INTEGER, -- User ID who performed the change, if available.
    FOREIGN KEY ("changed_by") REFERENCES "User"("user_id") ON DELETE SET NULL -- Added FK Constraint
);
COMMENT ON COLUMN "AuditLog".record_pk IS 'Primary key of the audited record. For composite keys, consider a consistent string representation.';
COMMENT ON COLUMN "AuditLog".changed_by IS 'User ID who performed the change, if available. Now an FK to User.user_id.';

CREATE INDEX IF NOT EXISTS idx_auditlog_table_record_pk_sa ON "AuditLog" ("table_name", "record_pk"); -- Ensured index
CREATE INDEX IF NOT EXISTS idx_auditlog_changed_by_fk_sa ON "AuditLog" ("changed_by"); -- Added index for FK

-- Apply Triggers

-- set_timestamp triggers
CREATE TRIGGER set_timestamp_user BEFORE UPDATE ON "User" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_category BEFORE UPDATE ON "Category" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_tag BEFORE UPDATE ON "Tag" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_place BEFORE UPDATE ON "Place" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_trip BEFORE UPDATE ON "Trip" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_review BEFORE UPDATE ON "Review" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_booking BEFORE UPDATE ON "Booking" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_itinerary BEFORE UPDATE ON "Itinerary" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();
CREATE TRIGGER set_timestamp_notification BEFORE UPDATE ON "Notification" FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

-- review_changed_update_place_rating trigger
CREATE TRIGGER review_changed_update_place_rating AFTER INSERT OR UPDATE OF rating OR DELETE ON "Review" FOR EACH ROW EXECUTE FUNCTION update_place_average_rating();

-- booking_audit_trigger
CREATE TRIGGER booking_audit_trigger AFTER INSERT OR UPDATE OR DELETE ON "Booking" FOR EACH ROW EXECUTE FUNCTION log_booking_changes();

-- End of schema
