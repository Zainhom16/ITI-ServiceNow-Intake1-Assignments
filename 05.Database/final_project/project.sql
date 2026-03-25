-- =====================================================
-- ============= 1. TABLES CREATION ===================
-- =====================================================
CREATE TABLE role (
    role_id   SERIAL PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL CHECK (role_name IN ('admin', 'customer'))
);

CREATE TABLE user_account (
    user_id  SERIAL PRIMARY KEY,
    name     VARCHAR(100) NOT NULL,
    email    VARCHAR(100) UNIQUE NOT NULL,
    phone    VARCHAR(20),
    password VARCHAR(50)  NOT NULL,
    role_id  INT REFERENCES role(role_id) ON DELETE SET NULL
);

CREATE TABLE hotel (
    hotel_id    SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    location    VARCHAR(100),
    rating      DECIMAL(2,1) CHECK (rating >= 0.0 AND rating <= 5.0),
    description TEXT
);

CREATE TABLE room (
    room_id      SERIAL PRIMARY KEY,
    room_type    VARCHAR(50),
    price        DECIMAL(10,2) CHECK (price >= 0.0),
    availability BOOLEAN DEFAULT TRUE,
    hotel_id     INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE airline (
    airline_id   SERIAL PRIMARY KEY,
    airline_name VARCHAR(100) NOT NULL
);

CREATE TABLE flight (
    flight_id       SERIAL PRIMARY KEY,
    departure_city  VARCHAR(100) NOT NULL,
    arrival_city    VARCHAR(100) NOT NULL,
    departure_date  DATE NOT NULL,
    arrival_date    DATE NOT NULL,
    price           DECIMAL(10,2) CHECK (price >= 0.0),
    available_seats INT CHECK (available_seats >= 0),
    airline_id      INT REFERENCES airline(airline_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE reservation_room (
    reservation_id SERIAL PRIMARY KEY,
    user_id        INT  REFERENCES user_account(user_id) ON DELETE CASCADE,
    room_id        INT  REFERENCES room(room_id) ON DELETE CASCADE,
    check_in       DATE NOT NULL,
    check_out      DATE NOT NULL,
    status         VARCHAR(20) CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')) DEFAULT 'Pending'
);

CREATE TABLE booking_flight (
    booking_id   SERIAL PRIMARY KEY,
    user_id      INT NOT NULL REFERENCES user_account(user_id) ON DELETE CASCADE,
    flight_id    INT NOT NULL REFERENCES flight(flight_id)     ON DELETE CASCADE,
    booking_date DATE,
    status       VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Confirmed', 'Cancelled'))
);

CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    user_id   INT REFERENCES user_account(user_id) ON DELETE CASCADE,
    hotel_id  INT REFERENCES hotel(hotel_id)  ON DELETE CASCADE,
    flight_id INT REFERENCES flight(flight_id) ON DELETE CASCADE,
    type      VARCHAR(10) CHECK (type IN ('hotel', 'flight')),
    rating    INT CHECK (rating BETWEEN 1 AND 5),
    comment   TEXT,
    CHECK (
        (hotel_id IS NOT NULL AND flight_id IS NULL AND type = 'hotel')
        OR
        (hotel_id IS NULL AND flight_id IS NOT NULL AND type = 'flight')
    )
);

CREATE TABLE payment (
    payment_id     SERIAL PRIMARY KEY,
    user_id        INT REFERENCES user_account(user_id)          ON DELETE CASCADE,
    reservation_id INT REFERENCES reservation_room(reservation_id) ON DELETE CASCADE,
    booking_id     INT REFERENCES booking_flight(booking_id)      ON DELETE CASCADE,
    amount         DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(20) CHECK (payment_method IN ('Card', 'Cash')),
    payment_date   DATE DEFAULT CURRENT_DATE,
    CHECK (
        (reservation_id IS NOT NULL AND booking_id IS NULL)
        OR
        (reservation_id IS NULL     AND booking_id IS NOT NULL)
    )
);

-- =====================================================
-- ============= 2. INSERTING DATA =====================
-- =====================================================

-- ROLES
INSERT INTO role (role_name) VALUES
('admin'),
('customer');

-- USERS
INSERT INTO user_account (name, email, phone, password, role_id) VALUES
('Ahmed Hassan', 'ahmed.hassan@example.com', '01012345678', 'pass123', 2),
('Mona Ali',     'mona.ali@example.com',     '01198765432', 'pass456', 2),
('Omar Mostafa', 'omar.mostafa@example.com', '01234567890', 'pass789', 1);

-- HOTELS
INSERT INTO hotel (name, location, rating, description) VALUES
('Cairo Grand Hotel',        'Cairo',      4.5, 'Luxury hotel in downtown Cairo'),
('Alexandria Beach Resort',  'Alexandria', 4.0, 'Beachfront hotel with sea view'),
('Luxor Nile Hotel',         'Luxor',      4.2, 'Hotel near the Nile with excellent services');

-- ROOMS
INSERT INTO room (room_type, price, availability, hotel_id) VALUES
('Single',   1200.00, TRUE, 1),
('Double',   2000.00, TRUE, 1),
('Suite',    3500.00, TRUE, 2),
('Standard', 1500.00, TRUE, 3);

-- AIRLINES
INSERT INTO airline (airline_name) VALUES
('EgyptAir'),
('Nile Air'),
('Air Cairo');

-- FLIGHTS
INSERT INTO flight (departure_city, arrival_city, departure_date, arrival_date, price, available_seats, airline_id) VALUES
('Cairo',       'Alexandria', '2026-04-01', '2026-04-01', 1500.00, 50, 1),
('Cairo',       'Luxor',      '2026-04-05', '2026-04-05', 2500.00, 30, 2),
('Alexandria',  'Cairo',      '2026-04-10', '2026-04-10', 1400.00, 60, 3);

-- RESERVATIONS
INSERT INTO reservation_room (user_id, room_id, check_in, check_out, status) VALUES
(1, 1, '2026-04-01', '2026-04-04', 'Confirmed'),
(2, 3, '2026-04-05', '2026-04-08', 'Confirmed'),
(3, 4, '2026-04-10', '2026-04-13', 'Confirmed'),
(1, 2, '2026-04-15', '2026-04-17', 'Pending'),
(2, 1, '2026-04-18', '2026-04-20', 'Cancelled'),
(3, 2, '2026-04-20', '2026-04-23', 'Pending'),
(1, 3, '2026-04-25', '2026-04-28', 'Confirmed');

-- BOOKINGS
INSERT INTO booking_flight (user_id, flight_id, booking_date, status) VALUES
(1, 1, '2026-03-20', 'Confirmed'),  
(2, 2, '2026-03-21', 'Confirmed'),   
(3, 3, '2026-03-22', 'Confirmed'),   
(1, 3, '2026-03-23', 'Pending'),     
(2, 3, '2026-03-24', 'Cancelled'),   
(3, 2, '2026-03-25', 'Pending'),   
(2, 1, '2026-03-26', 'Confirmed');  

-- REVIEWS
INSERT INTO review (user_id, hotel_id, flight_id, type, rating, comment) VALUES
(1, 1,    NULL, 'hotel',  5, 'Excellent stay, very comfortable!'),
(2, NULL, 3,    'flight', 4, 'Good flight, on time.'),
(3, 3,    NULL, 'hotel',  4, 'Great view of the Nile, very relaxing.'),
(1, NULL, 1,    'flight', 5, 'Smooth flight, excellent service.');

-- PAYMENTS
INSERT INTO payment (user_id, reservation_id, booking_id, amount, payment_method, payment_date) VALUES
(1, 1,    NULL, 1200.00, 'Card', '2026-03-25'), 
(2, 2,    NULL, 3500.00, 'Cash', '2026-03-26'),   
(3, 3,    NULL, 1500.00, 'Card', '2026-03-27'),  
(1, NULL, 1,    1500.00, 'Card', '2026-03-28'),
(2, NULL, 2,    2500.00, 'Cash', '2026-03-29'),
(3, NULL, 3,    1400.00, 'Card', '2026-03-30');

-- =====================================================
-- ============= 3. QUERIES ============================
-- =====================================================

-- 1. List all hotel bookings for each user
SELECT
    u.name  AS user_name,
    h.name  AS hotel_name,
    rr.check_in,
    rr.check_out
FROM user_account u
JOIN reservation_room rr USING (user_id)
JOIN room             r  USING (room_id)
JOIN hotel            h  USING (hotel_id);

-- 2. Total revenue from each user, broken down by payment method
SELECT
    u.name            AS user_name,
    p.payment_method,
    SUM(p.amount)     AS user_spent
FROM user_account u
JOIN payment p USING (user_id)
GROUP BY u.name, p.payment_method
ORDER BY user_spent DESC;

-- 3. Hotels with average rating >= 3.5
SELECT name AS hotel_name, rating
FROM hotel
WHERE rating >= 3.5;

-- 4. Users who have never booked a flight
SELECT u.name, u.user_id
FROM user_account u
WHERE u.user_id NOT IN (
    SELECT DISTINCT user_id
    FROM booking_flight
);

-- 5. Top 3 most booked hotels (by number of reservations)
SELECT *
FROM (
    SELECT
        h.name,
        COUNT(*)  AS total_reservations,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM hotel h
    JOIN room             r  USING (hotel_id)
    JOIN reservation_room rr USING (room_id)
    GROUP BY h.hotel_id, h.name
) t
WHERE rank <= 3;

-- 6. Upcoming flights in the next 3 weeks and users who booked them
SELECT
    u.name AS user_name,
    f.departure_city,
    f.arrival_city,
    f.departure_date,
    bf.booking_date,
    bf.status,
    bf.booking_id
FROM user_account   u
JOIN booking_flight bf USING (user_id)
JOIN flight         f  USING (flight_id)
WHERE f.departure_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '21 days'
ORDER BY f.departure_date, u.name;

-- 7. Users who booked both a hotel and a flight with the same departure/check-in date
SELECT
    u.name,
    h.name AS hotel_name,
    f.departure_city,
    f.arrival_city
FROM user_account   u
JOIN reservation_room rr USING (user_id)
JOIN room              r  USING (room_id)
JOIN hotel             h  USING (hotel_id)
JOIN booking_flight   bf  USING (user_id)
JOIN flight            f  USING (flight_id)
WHERE rr.check_in = f.departure_date;

-- 8. Top 3 busiest routes
SELECT
    departure_city,
    arrival_city,
    COUNT(*) AS total_bookings
FROM flight        f
JOIN booking_flight bf USING (flight_id)
GROUP BY departure_city, arrival_city
ORDER BY total_bookings DESC
LIMIT 3;

-- 9. Available rooms today
SELECT
    r.room_id,
    r.room_type,
    h.name AS hotel_name
FROM room  r
JOIN hotel h USING (hotel_id)
WHERE r.room_id NOT IN (
    SELECT room_id
    FROM reservation_room
    WHERE status != 'Cancelled'
      AND check_in  <= CURRENT_DATE
      AND check_out >= CURRENT_DATE
);

-- 10. Airline with the highest number of bookings
SELECT
    airline_name,
    COUNT(*) AS number_of_bookings
FROM airline
JOIN flight         USING (airline_id)
JOIN booking_flight USING (flight_id)
GROUP BY airline_name
ORDER BY number_of_bookings DESC
LIMIT 1;

-- 11. Hotels whose name contains "Cairo" with rating category
SELECT
    name,
    location,
    rating,
    CASE
        WHEN rating >= 4.5 THEN 'Excellent'
        WHEN rating >= 3.0 THEN 'Good'
        ELSE 'Poor'
    END AS rating_category
FROM hotel
WHERE name ILIKE '%cairo%';

-- 12. Hotels in Cairo with room prices and room class
SELECT
    h.name        AS hotel_name,
    r.room_type,
    r.price,
    CASE
        WHEN r.price > 3000  THEN 'Luxury'
        WHEN r.price >= 1500 THEN 'Standard'
        ELSE 'Budget'
    END AS room_class
FROM hotel h
JOIN room r USING (hotel_id)
WHERE h.location ILIKE '%cairo%';

-- 13. Hotels have the highest cancellation rates
SELECT
    h.name  AS hotel_name,
    COUNT(*) AS total_reservations,
    COUNT(*) FILTER (WHERE rr.status = 'Cancelled') AS cancelled,
    COUNT(*) FILTER (WHERE rr.status = 'Confirmed') AS confirmed,
    ROUND(100.0 * COUNT(*) FILTER (WHERE rr.status = 'Cancelled')
          / COUNT(*), 2)  AS cancellation_rate_pct
FROM hotel h
JOIN room  r  USING (hotel_id)
JOIN reservation_room rr USING (room_id)
GROUP BY h.hotel_id, h.name
ORDER BY cancellation_rate_pct DESC;

-- 14. Cheapest available flight between two cities
SELECT
    f.flight_id,
    a.airline_name,
    f.departure_date,
    f.available_seats,
    f.price
FROM flight   f
JOIN airline  a USING (airline_id)
WHERE f.departure_city  = 'Cairo'
  AND f.arrival_city    = 'Alexandria'
  AND f.departure_date  >= CURRENT_DATE
  AND f.available_seats  > 0
ORDER BY f.price ASC, f.departure_date ASC;