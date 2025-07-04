from sqlalchemy import create_engine, Column, Integer, String, Text, Boolean, DateTime, Date, Time, ForeignKey, UniqueConstraint, Index, DECIMAL, Table, CheckConstraint
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.sql import func
import datetime

Base = declarative_base()

# Association Table for Place and Category (Many-to-Many)
place_category_table = Table('PlaceCategory', Base.metadata,
    Column('place_id', Integer, ForeignKey('Place.place_id', ondelete="CASCADE"), primary_key=True),
    Column('category_id', Integer, ForeignKey('Category.category_id', ondelete="CASCADE"), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)
Index('idx_placecategory_place_id_sa', place_category_table.c.place_id)
Index('idx_placecategory_category_id_sa', place_category_table.c.category_id)


# Association Table for Place and Tag (Many-to-Many)
place_tag_table = Table('PlaceTag', Base.metadata,
    Column('place_id', Integer, ForeignKey('Place.place_id', ondelete="CASCADE"), primary_key=True),
    Column('tag_id', Integer, ForeignKey('Tag.tag_id', ondelete="CASCADE"), primary_key=True),
    Column('created_at', DateTime(timezone=True), server_default=func.now())
)
Index('idx_placetag_place_id_sa', place_tag_table.c.place_id)
Index('idx_placetag_tag_id_sa', place_tag_table.c.tag_id)


class User(Base):
    __tablename__ = "User"

    user_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    first_name = Column(String(50))
    last_name = Column(String(50))
    profile_picture_url = Column(String(255))
    bio = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    is_verified = Column(Boolean, default=False)
    social_provider = Column(String(50))
    social_id = Column(String(100))

    __table_args__ = (
        UniqueConstraint('social_provider', 'social_id', name='unique_social_login'),
        Index('idx_user_email_sa', 'email'),
        Index('idx_user_username_sa', 'username'),
    )

    # Relationships
    trips = relationship("Trip", back_populates="user", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="user", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="user", cascade="all, delete-orphan")
    images_uploaded = relationship("Image", foreign_keys="Image.uploaded_by_user_id", back_populates="uploader", cascade="all, delete-orphan") # Corrected cascade
    places_created = relationship("Place", foreign_keys="Place.created_by_user_id", back_populates="creator")
    favorite_places_association = relationship("Favorite", back_populates="user", cascade="all, delete-orphan") # Renamed for clarity
    login_logs = relationship("UserLoginLog", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")

    # Helper for M2M with Place through Favorite
    @property
    def favorite_places(self):
        return [fav.place for fav in self.favorite_places_association]

class Category(Base):
    __tablename__ = "Category"

    category_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        Index('idx_category_name_sa', 'name'),
    )

    # Relationship (Many-to-Many with Place)
    places = relationship("Place", secondary=place_category_table, back_populates="categories")

class Tag(Base):
    __tablename__ = "Tag"

    tag_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), unique=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        Index('idx_tag_name_sa', 'name'),
    )
    # Relationship (Many-to-Many with Place)
    places = relationship("Place", secondary=place_tag_table, back_populates="tags")


class Place(Base):
    __tablename__ = "Place"

    place_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    address = Column(String(255))
    latitude = Column(DECIMAL(10, 8))
    longitude = Column(DECIMAL(11, 8))
    # category_id removed
    contact_email = Column(String(100))
    contact_phone = Column(String(20))
    website = Column(String(255))
    average_rating = Column(DECIMAL(3, 2), default=0.00, nullable=False) # Updated by trigger
    created_by_user_id = Column(Integer, ForeignKey("User.user_id", ondelete="SET NULL"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    # tags (Text column) removed

    __table_args__ = (
        Index('idx_place_name_sa', 'name'),
        Index('idx_place_created_by_user_id_sa', 'created_by_user_id'),
        Index('idx_place_latitude_sa', 'latitude'),
        Index('idx_place_longitude_sa', 'longitude'),
    )

    # Relationships
    creator = relationship("User", foreign_keys=[created_by_user_id], back_populates="places_created")
    reviews = relationship("Review", back_populates="place", cascade="all, delete-orphan")
    images = relationship("Image", foreign_keys="Image.place_id", back_populates="place", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="place", cascade="all, delete-orphan")
    itinerary_items = relationship("Itinerary", back_populates="place", cascade="all, delete-orphan")
    favorited_by_users_association = relationship("Favorite", back_populates="place", cascade="all, delete-orphan") # Renamed for clarity

    # Many-to-Many relationships
    categories = relationship("Category", secondary=place_category_table, back_populates="places")
    tags = relationship("Tag", secondary=place_tag_table, back_populates="places")

    @property
    def favorited_by_users(self):
        return [fav.user for fav in self.favorited_by_users_association]

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

    __table_args__ = (
        Index('idx_trip_user_id_sa', 'user_id'),
        Index('idx_trip_start_date_sa', 'start_date'),
        Index('idx_trip_end_date_sa', 'end_date'),
    )

    # Relationships
    user = relationship("User", back_populates="trips")
    itinerary_items = relationship("Itinerary", back_populates="trip", cascade="all, delete-orphan")
    bookings = relationship("Booking", back_populates="trip")

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
        CheckConstraint('rating >= 1 AND rating <= 5', name='check_rating_range'),
        Index('idx_review_user_id_sa', 'user_id'),
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

    __table_args__ = (
        Index('idx_image_uploaded_by_user_id_sa', 'uploaded_by_user_id'),
        Index('idx_image_place_id_sa', 'place_id'),
        Index('idx_image_review_id_sa', 'review_id'),
    )

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

    __table_args__ = (
        CheckConstraint("number_of_people > 0", name="check_booking_number_of_people"),
        CheckConstraint("status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED')", name="check_booking_status"),
        Index('idx_booking_user_id_sa', 'user_id'),
        Index('idx_booking_place_id_sa', 'place_id'),
        Index('idx_booking_trip_id_sa', 'trip_id'),
        Index('idx_booking_booking_date_sa', 'booking_date'),
        Index('idx_booking_status_sa', 'status'),
    )

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
        Index('idx_itinerary_place_id_sa', 'place_id'),
    )

    # Relationships
    trip = relationship("Trip", back_populates="itinerary_items")
    place = relationship("Place", back_populates="itinerary_items")

class Favorite(Base):
    __tablename__ = "Favorite"

    user_id = Column(Integer, ForeignKey("User.user_id", ondelete="CASCADE"), primary_key=True)
    place_id = Column(Integer, ForeignKey("Place.place_id", ondelete="CASCADE"), primary_key=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        Index('idx_favorite_place_id_sa', 'place_id'), # Index for querying by place_id
    )

    # Relationships
    user = relationship("User", back_populates="favorite_places_association")
    place = relationship("Place", back_populates="favorited_by_users_association")

class UserLoginLog(Base):
    __tablename__ = "UserLoginLog"

    log_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("User.user_id", ondelete="CASCADE"), nullable=False)
    login_timestamp = Column(DateTime(timezone=True), server_default=func.now())
    ip_address = Column(String(45))
    user_agent = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now()) # Redundant with login_timestamp but kept for consistency

    __table_args__ = (
        Index('idx_userloginlog_user_id_sa', 'user_id'),
        Index('idx_userloginlog_login_timestamp_sa', 'login_timestamp'),
    )

    # Relationship
    user = relationship("User", back_populates="login_logs")

class Notification(Base):
    __tablename__ = "Notification"

    notification_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("User.user_id", ondelete="CASCADE"), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(50))
    related_entity_type = Column(String(50))
    related_entity_id = Column(Integer)
    is_read = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        Index('idx_notification_user_id_sa', 'user_id'),
        Index('idx_notification_is_read_sa', 'is_read'),
        Index('idx_notification_created_at_sa', 'created_at'),
        Index('idx_notification_related_entity_sa', 'related_entity_type', 'related_entity_id'),
    )

    # Relationship
    user = relationship("User", back_populates="notifications")

# Note: For SQLAlchemy's onupdate=func.now() to work for existing records' updates,
# the database trigger for `updated_at` is more reliable for direct DB modifications.
# SQLAlchemy's onupdate is triggered when the session flushes changes made through the ORM.
# The DDL triggers ensure `updated_at` is handled at the DB level for any modification type.
