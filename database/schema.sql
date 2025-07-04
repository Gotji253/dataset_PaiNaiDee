-- SQL DDL for PaiNaiDee Project (PostgreSQL)

-- Drop tables if they exist (optional, for development)
DROP TABLE IF EXISTS "Favorite" CASCADE;
DROP TABLE IF EXISTS "Itinerary" CASCADE;
DROP TABLE IF EXISTS "Booking" CASCADE;
DROP TABLE IF EXISTS "Image" CASCADE;
DROP TABLE IF EXISTS "Review" CASCADE;
DROP TABLE IF EXISTS "Trip" CASCADE;
DROP TABLE IF EXISTS "Place" CASCADE;
DROP TABLE IF EXISTS "Category" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;


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

-- Category Table
CREATE TABLE "Category" (
    "category_id" SERIAL PRIMARY KEY,
    "name" VARCHAR(100) UNIQUE NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Place Table
CREATE TABLE "Place" (
    "place_id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "address" VARCHAR(255),
    "latitude" DECIMAL(10, 8),
    "longitude" DECIMAL(11, 8),
    "category_id" INT,
    "contact_email" VARCHAR(100),
    "contact_phone" VARCHAR(20),
    "website" VARCHAR(255),
    "average_rating" DECIMAL(3, 2) DEFAULT 0.00,
    "created_by_user_id" INT,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "tags" TEXT, -- Can be comma-separated or JSON/JSONB for better querying
    FOREIGN KEY ("category_id") REFERENCES "Category"("category_id") ON DELETE SET NULL,
    FOREIGN KEY ("created_by_user_id") REFERENCES "User"("user_id") ON DELETE SET NULL
);

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
    UNIQUE ("user_id", "place_id") -- One user can review a place only once
);

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

-- Booking Table
CREATE TABLE "Booking" (
    "booking_id" SERIAL PRIMARY KEY,
    "user_id" INT NOT NULL,
    "place_id" INT NOT NULL,
    "trip_id" INT,
    "booking_date" TIMESTAMP WITH TIME ZONE NOT NULL,
    "number_of_people" INT NOT NULL DEFAULT 1,
    "status" VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, CONFIRMED, CANCELLED
    "notes" TEXT,
    "total_price" DECIMAL(10, 2),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE,
    FOREIGN KEY ("trip_id") REFERENCES "Trip"("trip_id") ON DELETE SET NULL
);

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
    CONSTRAINT "unique_event_in_trip_day_order" UNIQUE ("trip_id", "day_number", "order_in_day")
);

-- Favorite Table (Composite Primary Key)
CREATE TABLE "Favorite" (
    "user_id" INT NOT NULL,
    "place_id" INT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("user_id", "place_id"),
    FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE CASCADE,
    FOREIGN KEY ("place_id") REFERENCES "Place"("place_id") ON DELETE CASCADE
);

-- Triggers for updated_at columns (PostgreSQL specific)
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to tables with updated_at
CREATE TRIGGER set_timestamp_user
BEFORE UPDATE ON "User"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_category
BEFORE UPDATE ON "Category"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_place
BEFORE UPDATE ON "Place"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_trip
BEFORE UPDATE ON "Trip"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_review
BEFORE UPDATE ON "Review"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_booking
BEFORE UPDATE ON "Booking"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_itinerary
BEFORE UPDATE ON "Itinerary"
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- Indexes for performance (examples)
CREATE INDEX idx_place_name ON "Place" ("name");
CREATE INDEX idx_place_category_id ON "Place" ("category_id");
CREATE INDEX idx_place_tags ON "Place" USING GIN (to_tsvector('english', "tags")); -- For FTS on tags
CREATE INDEX idx_review_place_id ON "Review" ("place_id");
CREATE INDEX idx_itinerary_trip_id ON "Itinerary" ("trip_id");
CREATE INDEX idx_user_email ON "User" ("email");

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

CREATE TRIGGER review_changed_update_place_rating
AFTER INSERT OR UPDATE OF rating OR DELETE ON "Review" -- Trigger on rating update too
FOR EACH ROW
EXECUTE FUNCTION update_place_average_rating();
