-- Users
-- Assuming user_id will be 1, 2, 3, 4, 5
INSERT INTO "User" (username, email, password_hash, first_name, last_name, profile_picture_url, bio, created_at, updated_at, is_verified) VALUES
('traveler1', 'traveler1@example.com', 'hashed_password_123', 'John', 'Doe', 'https://example.com/avatar1.png', 'Loves hiking and nature.', NOW(), NOW(), TRUE),
('explorer22', 'explorer22@example.com', 'hashed_password_123', 'Jane', 'Smith', 'https://example.com/avatar2.png', 'City explorer and foodie.', NOW(), NOW(), TRUE),
('adventure_lover', 'adventure@example.com', 'hashed_password_123', 'Mike', 'Johnson', 'https://example.com/avatar3.png', 'Seeking adrenaline rushes.', NOW(), NOW(), FALSE),
('foodie_gal', 'foodie@example.com', 'hashed_password_123', 'Sarah', 'Lee', 'https://example.com/avatar4.png', 'Always looking for the next best meal.', NOW(), NOW(), TRUE),
('history_buff', 'history@example.com', 'hashed_password_123', 'David', 'Kim', 'https://example.com/avatar5.png', 'Fascinated by history and culture.', NOW(), NOW(), FALSE);

-- Categories
-- Assuming category_id will be 1, 2, 3, 4, 5
INSERT INTO "Category" (name, description, created_at, updated_at) VALUES
('ธรรมชาติ', 'สถานที่ท่องเที่ยวทางธรรมชาติ เช่น ภูเขา ทะเล น้ำตก', NOW(), NOW()),
('ร้านอาหาร', 'ร้านอาหารหลากหลายประเภท', NOW(), NOW()),
('คาเฟ่', 'ร้านกาแฟและเบเกอรี่', NOW(), NOW()),
('ประวัติศาสตร์', 'สถานที่สำคัญทางประวัติศาสตร์และโบราณสถาน', NOW(), NOW()),
('ศิลปะ', 'พิพิธภัณฑ์ แกลเลอรี่ และสถานที่แสดงงานศิลปะ', NOW(), NOW());

-- Tags
-- Assuming tag_id will be 1, 2, 3, 4, 5
INSERT INTO "Tag" (name, created_at, updated_at) VALUES
('วิวสวย', NOW(), NOW()),
('โรแมนติก', NOW(), NOW()),
('ครอบครัว', NOW(), NOW()),
('ประหยัด', NOW(), NOW()),
('ห้ามพลาด', NOW(), NOW());


-- Places
-- Assuming User IDs are 1-5 (SERIAL)
-- Assuming Place IDs will be 1-10 (SERIAL)
INSERT INTO "Place" (name, description, address, latitude, longitude, contact_email, contact_phone, website, created_by_user_id, created_at, updated_at) VALUES
('อุทยานแห่งชาติดอยอินทนนท์', 'ยอดเขาที่สูงที่สุดในประเทศไทย มีธรรมชาติที่สวยงามและอากาศเย็นสบายตลอดทั้งปี', 'อำเภอจอมทอง จังหวัดเชียงใหม่', 18.5899, 98.4868, 'doiinthanon@example.com', '053286729', 'https://doiinthanon.com', 1, NOW(), NOW()),
('ร้านอาหารครัวคุณต๋อย', 'ร้านอาหารไทยรสชาติต้นตำรับ บรรยากาศดี', '123 ถนนสุขุมวิท กรุงเทพมหานคร', 13.7563, 100.5018, 'kruakhuntoy@example.com', '022345678', 'https://kruakhuntoy.com', 2, NOW(), NOW()),
('คาเฟ่บ้านต้นไม้', 'คาเฟ่บรรยากาศร่มรื่นในสวนสวย มีเครื่องดื่มและเบเกอรี่อร่อย', '45/6 ถนนนิมมานเหมินท์ เชียงใหม่', 18.7883, 98.9853, 'treehousecafe@example.com', '0987654321', 'https://treehousecnx.com', 3, NOW(), NOW()),
('อุทยานประวัติศาสตร์สุโขทัย', 'อดีตราชธานีแห่งแรกของไทย มีโบราณสถานที่สวยงามและทรงคุณค่า', 'เมืองเก่า อำเภอเมืองสุโขทัย จังหวัดสุโขทัย', 17.0172, 99.7033, 'sukhothaihist@example.com', '055697310', 'https://sukhothaihistoricalpark.com', 5, NOW(), NOW()),
('หอศิลปวัฒนธรรมแห่งกรุงเทพมหานคร (BACC)', 'ศูนย์รวมงานศิลปะร่วมสมัยหลากหลายแขนงใจกลางกรุง', '939 ถนนพระรามที่ ๑ แขวงวังใหม่ เขตปทุมวัน กรุงเทพมหานคร', 13.7469, 100.5302, 'info@bacc.or.th', '022146630', 'http://www.bacc.or.th', 4, NOW(), NOW()),
('เกาะพีพี', 'หมู่เกาะที่มีชื่อเสียงระดับโลก น้ำทะเลใส หาดทรายสวยงาม', 'ตำบลอ่าวนาง อำเภอเมืองกระบี่ จังหวัดกระบี่', 7.7405, 98.7784, 'phiphiinfo@example.com', NULL, 'https://tourismthailand.org/phiphi', 1, NOW(), NOW()),
('ร้านอาหารบ้านไอซ์', 'ร้านอาหารใต้รสเด็ด จัดจ้าน ถึงเครื่อง', '115 ซอยทองหล่อ 5 กรุงเทพมหานคร', 13.7289, 100.5372, 'baanice@example.com', '023918020', 'https://baanice.com', 2, NOW(), NOW()),
('วัดพระแก้ว (วัดพระศรีรัตนศาสดาราม)', 'วัดคู่บ้านคู่เมืองของประเทศไทย ประดิษฐานพระแก้วมรกต', 'ถนนหน้าพระลาน แขวงพระบรมมหาราชวัง เขตพระนคร กรุงเทพมหานคร', 13.7515, 100.4926, NULL, '026235500', 'https://www.royalgrandpalace.th/th/discover/wat-phra-kaeo', 5, NOW(), NOW()),
('ตลาดน้ำดำเนินสะดวก', 'ตลาดน้ำเก่าแก่ที่มีชื่อเสียงของไทย มีของกินของขายมากมาย', 'อำเภอดำเนินสะดวก จังหวัดราชบุรี', 13.5191, 99.9587, NULL, NULL, NULL, 3, NOW(), NOW()),
('พิพิธภัณฑ์บ้านจิม ทอมป์สัน', 'เรือนไทยโบราณที่จัดแสดงคอลเลคชั่นผ้าไหมและของเก่าแก่', '6 ซอยเกษมสันต์ 2 ถนนพระราม 1 กรุงเทพมหานคร', 13.7480, 100.5287, 'info@jimthompsonhouse.com', '022167368', 'https://www.jimthompsonhouse.com', 4, NOW(), NOW());

-- PlaceCategory Junction Table Data
-- Assuming Place IDs 1-10 and Category IDs 1-5
INSERT INTO "PlaceCategory" (place_id, category_id, created_at) VALUES
(1, 1, NOW()), -- ดอยอินทนนท์ -> ธรรมชาติ
(2, 2, NOW()), -- ครัวคุณต๋อย -> ร้านอาหาร
(3, 3, NOW()), -- คาเฟ่บ้านต้นไม้ -> คาเฟ่
(4, 4, NOW()), -- อุทยานประวัติศาสตร์สุโขทัย -> ประวัติศาสตร์
(5, 5, NOW()), -- BACC -> ศิลปะ
(6, 1, NOW()), -- เกาะพีพี -> ธรรมชาติ
(7, 2, NOW()), -- ร้านอาหารบ้านไอซ์ -> ร้านอาหาร
(8, 4, NOW()), -- วัดพระแก้ว -> ประวัติศาสตร์
(9, 2, NOW()), -- ตลาดน้ำดำเนินสะดวก -> ร้านอาหาร (could also be 'ช้อปปิ้ง' or 'วัฒนธรรม' if categories existed)
(10, 5, NOW()); -- จิม ทอมป์สัน -> ศิลปะ (also ประวัติศาสตร์)

-- PlaceTag Junction Table Data
-- Assuming Place IDs 1-10 and Tag IDs 1-5
INSERT INTO "PlaceTag" (place_id, tag_id, created_at) VALUES
(1, 1, NOW()), -- ดอยอินทนนท์ -> วิวสวย
(1, 3, NOW()), -- ดอยอินทนนท์ -> ครอบครัว
(2, 5, NOW()), -- ครัวคุณต๋อย -> ห้ามพลาด
(3, 2, NOW()), -- คาเฟ่บ้านต้นไม้ -> โรแมนติก
(4, 5, NOW()), -- อุทยานประวัติศาสตร์สุโขทัย -> ห้ามพลาด
(6, 1, NOW()), -- เกาะพีพี -> วิวสวย
(6, 2, NOW()), -- เกาะพีพี -> โรแมนติก
(7, 5, NOW()), -- ร้านอาหารบ้านไอซ์ -> ห้ามพลาด
(8, 5, NOW()), -- วัดพระแก้ว -> ห้ามพลาด
(9, 3, NOW()), -- ตลาดน้ำดำเนินสะดวก -> ครอบครัว
(10, 4, NOW()); -- จิม ทอมป์สัน -> ประหยัด (entry fee might be considered so)

-- Reviews
-- Assuming User IDs 1-5 and Place IDs 1-10 (SERIAL)
INSERT INTO "Review" (user_id, place_id, rating, comment, created_at, updated_at) VALUES
(1, 1, 5, 'สวยงามมาก อากาศดีสุดๆ ประทับใจมากครับ', NOW(), NOW()),
(2, 2, 4, 'อาหารอร่อย บริการดี แต่คนเยอะไปหน่อย', NOW(), NOW()),
(3, 3, 5, 'ร้านน่ารักมาก กาแฟอร่อย เค้กก็ดีงาม', NOW(), NOW()),
(4, 5, 4, 'มีงานศิลปะน่าสนใจเยอะดี เดินเพลินๆ', NOW(), NOW()),
(5, 4, 5, 'ยิ่งใหญ่ อลังการ คุ้มค่ากับการมาเยือน', NOW(), NOW()),
(1, 6, 5, 'น้ำใสมากกกก สวยเหมือนสวรรค์เลย', NOW(), NOW()),
(2, 7, 4, 'อาหารใต้รสจัดจ้าน เผ็ดแต่อร่อย', NOW(), NOW()),
(3, 9, 3, 'ของกินเยอะดี แต่คนเยอะและร้อนไปหน่อย', NOW(), NOW()),
(4, 10, 4, 'ได้ความรู้เกี่ยวกับผ้าไหมไทยเยอะเลย', NOW(), NOW()),
(5, 8, 5, 'สวยงามมาก เป็นวัดที่ต้องมาสักครั้งในชีวิต', NOW(), NOW());

-- Trips
-- Assuming User IDs 1-5 (SERIAL)
-- Assuming Trip IDs will be 1-3 (SERIAL)
INSERT INTO "Trip" (user_id, name, description, start_date, end_date, is_public, created_at, updated_at) VALUES
(1, 'ทริปเชียงใหม่ 3 วัน 2 คืน', 'เที่ยวธรรมชาติและคาเฟ่สวยๆ ที่เชียงใหม่', '2024-08-15', '2024-08-17', TRUE, NOW(), NOW()),
(2, 'ตะลุยกินกรุงเทพฯ', 'รวมร้านเด็ด ร้านดังในกรุงเทพฯ ที่ต้องไปลอง', '2024-09-01', '2024-09-02', FALSE, NOW(), NOW()),
(3, 'เที่ยวสุโขทัยเมืองเก่า', 'ย้อนรอยประวัติศาสตร์ ณ อุทยานประวัติศาสตร์สุโขทัย', CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', TRUE, NOW(), NOW());

-- Itinerary
-- Assuming Trip IDs 1-3 and Place IDs 1-10 (SERIAL)
-- Trip 1 (เชียงใหม่)
INSERT INTO "Itinerary" (trip_id, place_id, day_number, start_time, end_time, notes, order_in_day, created_at, updated_at) VALUES
(1, 1, 1, '09:00:00', '16:00:00', 'ขึ้นดอยอินทนนท์ ชมวิว ถ่ายรูป', 1, NOW(), NOW()),
(1, 3, 2, '10:00:00', '12:00:00', 'แวะคาเฟ่ชิลๆ', 1, NOW(), NOW());

-- Trip 2 (กรุงเทพฯ)
INSERT INTO "Itinerary" (trip_id, place_id, day_number, start_time, end_time, notes, order_in_day, created_at, updated_at) VALUES
(2, 2, 1, '12:00:00', '14:00:00', 'กินข้าวเที่ยงร้านดัง', 1, NOW(), NOW()),
(2, 5, 1, '15:00:00', '17:00:00', 'เดินเล่นหอศิลป์', 2, NOW(), NOW()),
(2, 7, 2, '19:00:00', '21:00:00', 'จัดหนักอาหารใต้', 1, NOW(), NOW());

-- Trip 3 (สุโขทัย)
INSERT INTO "Itinerary" (trip_id, place_id, day_number, start_time, end_time, notes, order_in_day, created_at, updated_at) VALUES
(3, 4, 1, '09:00:00', '17:00:00', 'เที่ยวชมอุทยานประวัติศาสตร์ทั้งวัน', 1, NOW(), NOW());

-- Favorites
-- Assuming User IDs 1-5 and Place IDs 1-10 (SERIAL)
INSERT INTO "Favorite" (user_id, place_id, created_at) VALUES
(1, 1, NOW()),
(1, 6, NOW()),
(2, 2, NOW()),
(2, 7, NOW()),
(3, 3, NOW()),
(4, 5, NOW()),
(5, 4, NOW()),
(5, 8, NOW());

-- Bookings
-- Assuming User IDs 1-5 and Place IDs 1-10 (SERIAL)
-- Assuming Booking IDs will be 1-3 (SERIAL)
INSERT INTO "Booking" (user_id, place_id, trip_id, booking_date, number_of_people, status, notes, total_price, created_at, updated_at) VALUES
(1, 1, 1, '2024-08-15 14:00:00+07', 2, 'CONFIRMED', 'จองที่พักใกล้ดอยอินทนนท์สำหรับทริปเชียงใหม่', 2500.00, NOW(), NOW()),
(2, 2, 2, '2024-09-01 12:00:00+07', 4, 'PENDING', 'จองโต๊ะสำหรับ 4 ท่าน ร้านครัวคุณต๋อย', NULL, NOW(), NOW()),
(4, 10, NULL, '2024-07-30 10:00:00+07', 1, 'CONFIRMED', 'ซื้อตั๋วเข้าชมพิพิธภัณฑ์บ้านจิม ทอมป์สัน', 200.00, NOW(), NOW());

-- UserLoginLog
-- Assuming User IDs 1-2
INSERT INTO "UserLoginLog" (user_id, login_timestamp, ip_address, user_agent) VALUES
(1, NOW() - INTERVAL '1 day', '192.168.1.10', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'),
(2, NOW() - INTERVAL '2 hours', '10.0.0.5', 'TravelApp/1.2 (iPhone; iOS 14.5; Scale/3.00)');

-- Notification
-- Assuming User IDs 1,2
INSERT INTO "Notification" (user_id, message, type, related_entity_type, related_entity_id, is_read, created_at, updated_at) VALUES
(1, 'Your booking for ดอยอินทนนท์ is confirmed!', 'BOOKING_CONFIRMED', 'Booking', 1, FALSE, NOW(), NOW()),
(2, 'New review on ร้านอาหารครัวคุณต๋อย by traveler1.', 'NEW_REVIEW', 'Review', 1, TRUE, NOW() - INTERVAL '1 hour', NOW());


-- End of seed data
