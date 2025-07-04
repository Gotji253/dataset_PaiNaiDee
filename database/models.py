from sqlalchemy import create_engine, Column, Integer, String, Text, Boolean, DateTime, Date, Time, ForeignKey, UniqueConstraint, Index, DECIMAL
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.sql import func
import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "User" # Use quoted name to match PostgreSQL DDL

    user_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    first_name = Column(String(50))
    last_name = Column(String(50))
    profile_picture_url = Column(String(255))
    bio = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now()) # Relies on DB trigger or SQLAlchemy event for onupdate
    is_verified = Column(Boolean, default=False)
    social_provider = Column(String(50))
    social_id = Column(String(100))

    __table_args__ = (
        UniqueConstraint('social_provider', 'social_id', name='unique_social_login'),
        Index('idx_user_email_sa', 'email'), # Index for email, added _sa to avoid clash if DDL index name is same
    )

    # Relationships
    trips = relationship("Trip", back_populates="user", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="user", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="user", cascade="all, delete-orphan")
    images_uploaded = relationship("Image", foreign_keys="Image.uploaded_by_user_id", back_populates="uploader", cascade="delete, delete-orphan") # cascade adjusted
    places_created = relationship("Place", foreign_keys="Place.created_by_user_id", back_populates="creator") # Default cascade is save-update, merge
    favorite_places = relationship("Favorite", back_populates="user", cascade="all, delete-orphan")

class Category(Base):
    __tablename__ = "Category"

    category_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationship
    places = relationship("Place", back_populates="category")

class Place(Base):
    __tablename__ = "Place"

    place_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    address = Column(String(255))
    latitude = Column(DECIMAL(10, 8))
    longitude = Column(DECIMAL(11, 8))
    category_id = Column(Integer, ForeignKey("Category.category_id", ondelete="SET NULL"))
    contact_email = Column(String(100))
    contact_phone = Column(String(20))
    website = Column(String(255))
    average_rating = Column(DECIMAL(3, 2), default=0.00, nullable=False) # Should be updated by trigger
    created_by_user_id = Column(Integer, ForeignKey("User.user_id", ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    tags = Column(Text)

    __table_args__ = (
        Index('idx_place_name_sa', 'name'),
        Index('idx_place_category_id_sa', 'category_id'),
    )

    # Relationships
    category = relationship("Category", back_populates="places")
    creator = relationship("User", foreign_keys=[created_by_user_id], back_populates="places_created")
    reviews = relationship("Review", back_populates="place", cascade="all, delete-orphan")
    images = relationship("Image", foreign_keys="Image.place_id", back_populates="place", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="place", cascade="all, delete-orphan")
    itinerary_items = relationship("Itinerary", back_populates="place", cascade="all, delete-orphan") # Default cascade might be fine, but being explicit.
    favorited_by_users = relationship("Favorite", back_populates="place", cascade="all, delete-orphan")


class Trip(Base):
    __tablename__ = "Trip"

    trip_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("User.user_id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    start_date = Column(Date)
    end_date = Column(Date)
    is_public = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="trips")
    itinerary_items = relationship("Itinerary", back_populates="trip", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="trip") # A trip can have bookings, cascade might need to be SET NULL or handled if Trip is deleted

class Review(Base):
    __tablename__ = "Review"

    review_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("User.user_id", ondelete="CASCADE"), nullable=False)
    place_id = Column(Integer, ForeignKey("Place.place_id", ondelete="CASCADE"), nullable=False)
    rating = Column(Integer, nullable=False)
    comment = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        UniqueConstraint('user_id', 'place_id', name='uq_user_place_review'),
        Index('idx_review_place_id_sa', 'place_id'),
    )

    # Relationships
    user = relationship("User", back_populates="reviews")
    place = relationship("Place", back_populates="reviews")
    images = relationship("Image", foreign_keys="Image.review_id", back_populates="review", cascade="all, delete-orphan")

class Image(Base):
    __tablename__ = "Image"

    image_id = Column(Integer, primary_key=True, autoincrement=True)
    image_url = Column(String(255), nullable=False)
    caption = Column(String(255))
    uploaded_by_user_id = Column(Integer, ForeignKey("User.user_id", ondelete="SET NULL"))
    place_id = Column(Integer, ForeignKey("Place.place_id", ondelete="SET NULL"))
    review_id = Column(Integer, ForeignKey("Review.review_id", ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    uploader = relationship("User", foreign_keys=[uploaded_by_user_id], back_populates="images_uploaded")
    place = relationship("Place", foreign_keys=[place_id], back_populates="images")
    review = relationship("Review", foreign_keys=[review_id], back_populates="images")


class Booking(Base):
    __tablename__ = "Booking"

    booking_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("User.user_id", ondelete="CASCADE"), nullable=False)
    place_id = Column(Integer, ForeignKey("Place.place_id", ondelete="CASCADE"), nullable=False)
    trip_id = Column(Integer, ForeignKey("Trip.trip_id", ondelete="SET NULL"))
    booking_date = Column(DateTime(timezone=True), nullable=False)
    number_of_people = Column(Integer, nullable=False, default=1)
    status = Column(String(20), nullable=False, default='PENDING')
    notes = Column(Text)
    total_price = Column(DECIMAL(10, 2))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="bookings")
    place = relationship("Place", back_populates="bookings")
    trip = relationship("Trip", back_populates="bookings")

class Itinerary(Base):
    __tablename__ = "Itinerary"

    itinerary_item_id = Column(Integer, primary_key=True, autoincrement=True)
    trip_id = Column(Integer, ForeignKey("Trip.trip_id", ondelete="CASCADE"), nullable=False)
    place_id = Column(Integer, ForeignKey("Place.place_id", ondelete="CASCADE"), nullable=False)
    day_number = Column(Integer, nullable=False)
    start_time = Column(Time)
    end_time = Column(Time)
    notes = Column(Text)
    order_in_day = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        UniqueConstraint('trip_id', 'day_number', 'order_in_day', name='uq_trip_day_order'),
        Index('idx_itinerary_trip_id_sa', 'trip_id'),
    )

    # Relationships
    trip = relationship("Trip", back_populates="itinerary_items")
    place = relationship("Place", back_populates="itinerary_items")

class Favorite(Base):
    __tablename__ = "Favorite"

    user_id = Column(Integer, ForeignKey("User.user_id", ondelete="CASCADE"), primary_key=True)
    place_id = Column(Integer, ForeignKey("Place.place_id", ondelete="CASCADE"), primary_key=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="favorite_places")
    place = relationship("Place", back_populates="favorited_by_users")

# Note: For SQLAlchemy's onupdate=func.now() to work for existing records' updates,
# the database trigger for `updated_at` is more reliable, or use SQLAlchemy event listeners.
# The `server_default` is for insert, `onupdate` for update operations initiated via SQLAlchemy.
# The DDL triggers ensure `updated_at` is handled at the DB level for any modification.
