-- Users
INSERT INTO "User" (username, email, password_hash, full_name, avatar_url, created_at) VALUES
('traveler1', 'traveler1@example.com', 'hashed_password_123', 'John Doe', 'https://example.com/avatar1.png', NOW()),
('explorer22', 'explorer22@example.com', 'hashed_password_123', 'Jane Smith', 'https://example.com/avatar2.png', NOW()),
('adventure_lover', 'adventure@example.com', 'hashed_password_123', 'Mike Johnson', 'https://example.com/avatar3.png', NOW()),
('foodie_gal', 'foodie@example.com', 'hashed_password_123', 'Sarah Lee', 'https://example.com/avatar4.png', NOW()),
('history_buff', 'history@example.com', 'hashed_password_123', 'David Kim', 'https://example.com/avatar5.png', NOW());

-- Categories
INSERT INTO "Category" (name, description, created_at) VALUES
('ธรรมชาติ', 'สถานที่ท่องเที่ยวทางธรรมชาติ เช่น ภูเขา ทะเล น้ำตก', NOW()),
('ร้านอาหาร', 'ร้านอาหารหลากหลายประเภท', NOW()),
('คาเฟ่', 'ร้านกาแฟและเบเกอรี่', NOW()),
('ประวัติศาสตร์', 'สถานที่สำคัญทางประวัติศาสตร์และโบราณสถาน', NOW()),
('ศิลปะ', 'พิพิธภัณฑ์ แกลเลอรี่ และสถานที่แสดงงานศิลปะ', NOW());

-- Places
-- Assuming User IDs are 1-5 and Category IDs are 1-5 from the above inserts
INSERT INTO "Place" (name, description, location, latitude, longitude, category_id, created_by, created_at) VALUES
('อุทยานแห่งชาติดอยอินทนนท์', 'ยอดเขาที่สูงที่สุดในประเทศไทย มีธรรมชาติที่สวยงามและอากาศเย็นสบายตลอดทั้งปี', 'อำเภอจอมทอง จังหวัดเชียงใหม่', 18.5899, 98.4868, 1, 1, NOW()),
('ร้านอาหารครัวคุณต๋อย', 'ร้านอาหารไทยรสชาติต้นตำรับ บรรยากาศดี', 'กรุงเทพมหานคร', 13.7563, 100.5018, 2, 2, NOW()),
('คาเฟ่บ้านต้นไม้', 'คาเฟ่บรรยากาศร่มรื่นในสวนสวย มีเครื่องดื่มและเบเกอรี่อร่อย', 'จังหวัดเชียงใหม่', 18.7883, 98.9853, 3, 3, NOW()),
('อุทยานประวัติศาสตร์สุโขทัย', 'อดีตราชธานีแห่งแรกของไทย มีโบราณสถานที่สวยงามและทรงคุณค่า', 'จังหวัดสุโขทัย', 17.0172, 99.7033, 4, 5, NOW()),
('หอศิลปวัฒนธรรมแห่งกรุงเทพมหานคร (BACC)', 'ศูนย์รวมงานศิลปะร่วมสมัยหลากหลายแขนงใจกลางกรุง', 'กรุงเทพมหานคร', 13.7469, 100.5302, 5, 4, NOW()),
('เกาะพีพี', 'หมู่เกาะที่มีชื่อเสียงระดับโลก น้ำทะเลใส หาดทรายสวยงาม', 'จังหวัดกระบี่', 7.7405, 98.7784, 1, 1, NOW()),
('ร้านอาหารบ้านไอซ์', 'ร้านอาหารใต้รสเด็ด จัดจ้าน ถึงเครื่อง', 'กรุงเทพมหานคร', 13.7289, 100.5372, 2, 2, NOW()),
('วัดพระแก้ว', 'วัดคู่บ้านคู่เมืองของประเทศไทย ประดิษฐานพระแก้วมรกต', 'กรุงเทพมหานคร', 13.7515, 100.4926, 4, 5, NOW()),
('ตลาดน้ำดำเนินสะดวก', 'ตลาดน้ำเก่าแก่ที่มีชื่อเสียงของไทย มีของกินของขายมากมาย', 'จังหวัดราชบุรี', 13.5191, 99.9587, 2, 3, NOW()),
('พิพิธภัณฑ์บ้านจิม ทอมป์สัน', 'เรือนไทยโบราณที่จัดแสดงคอลเลคชั่นผ้าไหมและของเก่าแก่', 'กรุงเทพมหานคร', 13.7480, 100.5287, 5, 4, NOW());

-- Reviews
-- Assuming User IDs 1-5 and Place IDs 1-10
INSERT INTO "Review" (user_id, place_id, rating, comment, created_at) VALUES
(1, 1, 5, 'สวยงามมาก อากาศดีสุดๆ ประทับใจมากครับ', NOW()),
(2, 2, 4, 'อาหารอร่อย บริการดี แต่คนเยอะไปหน่อย', NOW()),
(3, 3, 5, 'ร้านน่ารักมาก กาแฟอร่อย เค้กก็ดีงาม', NOW()),
(4, 5, 4, 'มีงานศิลปะน่าสนใจเยอะดี เดินเพลินๆ', NOW()),
(5, 4, 5, 'ยิ่งใหญ่ อลังการ คุ้มค่ากับการมาเยือน', NOW()),
(1, 6, 5, 'น้ำใสมากกกก สวยเหมือนสวรรค์เลย', NOW()),
(2, 7, 4, 'อาหารใต้รสจัดจ้าน เผ็ดแต่อร่อย', NOW()),
(3, 9, 3, 'ของกินเยอะดี แต่คนเยอะและร้อนไปหน่อย', NOW()),
(4, 10, 4, 'ได้ความรู้เกี่ยวกับผ้าไหมไทยเยอะเลย', NOW()),
(5, 8, 5, 'สวยงามมาก เป็นวัดที่ต้องมาสักครั้งในชีวิต', NOW());

-- Trips
-- Assuming User IDs 1-5
INSERT INTO "Trip" (user_id, name, start_date, end_date, created_at) VALUES
(1, 'ทริปเชียงใหม่ 3 วัน 2 คืน', '2024-08-15', '2024-08-17', NOW()),
(2, 'ตะลุยกินกรุงเทพฯ', '2024-09-01', '2024-09-02', NOW()),
(3, 'เที่ยวสุโขทัยเมืองเก่า', CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', NOW());

-- Itinerary
-- Assuming Trip IDs 1-3 and Place IDs 1-10
-- Trip 1 (เชียงใหม่)
INSERT INTO "Itinerary" (trip_id, place_id, day_number, start_time, end_time, notes, created_at) VALUES
(1, 1, 1, '09:00:00', '16:00:00', 'ขึ้นดอยอินทนนท์ ชมวิว ถ่ายรูป', NOW()),
(1, 3, 2, '10:00:00', '12:00:00', 'แวะคาเฟ่ชิลๆ', NOW());

-- Trip 2 (กรุงเทพฯ)
INSERT INTO "Itinerary" (trip_id, place_id, day_number, start_time, end_time, notes, created_at) VALUES
(2, 2, 1, '12:00:00', '14:00:00', 'กินข้าวเที่ยงร้านดัง', NOW()),
(2, 5, 1, '15:00:00', '17:00:00', 'เดินเล่นหอศิลป์', NOW()),
(2, 7, 2, '19:00:00', '21:00:00', 'จัดหนักอาหารใต้', NOW());

-- Trip 3 (สุโขทัย)
INSERT INTO "Itinerary" (trip_id, place_id, day_number, start_time, end_time, notes, created_at) VALUES
(3, 4, 1, '09:00:00', '17:00:00', 'เที่ยวชมอุทยานประวัติศาสตร์ทั้งวัน', NOW());

-- Favorites
-- Assuming User IDs 1-5 and Place IDs 1-10
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
-- Assuming User IDs 1-5 and Place IDs 1-10
INSERT INTO "Booking" (user_id, place_id, booking_date, status, notes, created_at) VALUES
(1, 1, '2024-08-15', 'CONFIRMED', 'จองที่พักใกล้ดอยอินทนนท์', NOW()),
(2, 2, '2024-09-01', 'PENDING', 'จองโต๊ะสำหรับ 4 ท่าน', NOW()),
(4, 10, '2024-07-30', 'CONFIRMED', 'ซื้อตั๋วเข้าชมล่วงหน้า', NOW());

-- End of seed data
