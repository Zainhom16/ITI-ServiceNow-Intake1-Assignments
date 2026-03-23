CREATE TABLE role (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL CHECK (role_name IN ('admin','customer'))
);

CREATE TABLE user_account (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(50) NOT NULL,
    role_id INT REFERENCES role(role_id) ON DELETE SET NULL
);

CREATE TABLE hotel (
    hotel_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    rating DECIMAL(2,1) CHECK (rating >= 0.0 AND rating <= 5.0),
    description TEXT
);

CREATE TABLE room ( 
	room_id SERIAL PRIMARY KEY,
	type TEXT,
	price DECIMAL(2,1) CHECK (price >= 0.0),
	availability Boolean,
);

CREATE TABLE room (
    room_id SERIAL PRIMARY KEY,
    room_type VARCHAR(50),
    price DECIMAL(10,2) CHECK (price >= 0.0),
    availability BOOLEAN DEFAULT TRUE,
    hotel_id INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE airline (
    airline_id SERIAL PRIMARY KEY,
    airline_name VARCHAR(100) NOT NULL
);

CREATE TABLE flight (
    flight_id SERIAL PRIMARY KEY,
    departure_city VARCHAR(100) NOT NULL,
    arrival_city VARCHAR(100) NOT NULL,
    departure_date DATE NOT NULL,
    arrival_date DATE NOT NULL,
    price DECIMAL(10,2) CHECK (price >= 0.0),
    available_seats INT CHECK (available_seats >= 0),
    airline_id INT REFERENCES airline(airline_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE reservation_hotel (
    reservation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES user_account(user_id) ON DELETE CASCADE,
    hotel_id INT NOT NULL REFERENCES hotel(hotel_id) ON DELETE CASCADE,
    reservation_date DATE,
    status VARCHAR(20) CHECK (status IN ('Pending','Confirmed','Cancelled'))
);

CREATE TABLE booking_flight (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES user_account(user_id) ON DELETE CASCADE,
    flight_id INT NOT NULL REFERENCES flight(flight_id) ON DELETE CASCADE,
    booking_date DATE,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending','Confirmed','Cancelled'))
);

CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES user_account(user_id) ON DELETE CASCADE,
    review_type VARCHAR(10) NOT NULL CHECK (review_type IN ('hotel','flight')),
    hotel_id INT REFERENCES hotel(hotel_id),
    flight_id INT REFERENCES flight(flight_id),
    rating INT CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    review_date DATE
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES user_account(user_id) ON DELETE CASCADE,
    reservation_id INT REFERENCES reservation_hotel(reservation_id) ON DELETE CASCADE,
    booking_id INT REFERENCES booking_flight(booking_id) ON DELETE CASCADE,
    amount DECIMAL(10,2) CHECK (amount >= 0.0),
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('Cash', 'Card')),
    payment_date DATE NOT NULL,
    CHECK (reservation_id IS NOT NULL OR booking_id IS NOT NULL)
);

INSERT INTO role (role_name) VALUES
('admin'),
('customer');

INSERT INTO user_account (name, email, phone, password, role_id) VALUES
('Ahmed Hassan', 'ahmed.hassan@example.com', '01012345678', 'pass123', 2),
('Mona Ali', 'mona.ali@example.com', '01198765432', 'pass456', 2),
('Omar Mostafa', 'omar.mostafa@example.com', '01234567890', 'pass789', 1);

INSERT INTO hotel (name, location, rating, description) VALUES
('Cairo Grand Hotel', 'Cairo', 4.5, 'Luxury hotel in downtown Cairo'),
('Alexandria Beach Resort', 'Alexandria', 4.0, 'Beachfront hotel with sea view'),
('Luxor Nile Hotel', 'Luxor', 4.2, 'Hotel near the Nile with excellent services');

INSERT INTO room (room_type, price, availability, hotel_id) VALUES
('Single', 1200.00, TRUE, 1),
('Double', 2000.00, TRUE, 1),
('Suite', 3500.00, TRUE, 2),
('Standard', 1500.00, TRUE, 3);

INSERT INTO airline (airline_name) VALUES
('EgyptAir'),
('Nile Air'),
('Air Cairo');

INSERT INTO flight (departure_city, arrival_city, departure_date, arrival_date, price, available_seats, airline_id) VALUES
('Cairo', 'Alexandria', '2026-04-01', '2026-04-01', 1500.00, 50, 1),
('Cairo', 'Luxor', '2026-04-05', '2026-04-05', 2500.00, 30, 2),
('Alexandria', 'Cairo', '2026-04-10', '2026-04-10', 1400.00, 60, 3);

INSERT INTO reservation_hotel (user_id, hotel_id, reservation_date, status) VALUES
(1, 1, '2026-04-01', 'Confirmed'),
(2, 2, '2026-04-05', 'Pending');

INSERT INTO booking_flight (user_id, flight_id, booking_date, status) VALUES
(1, 1, '2026-03-20', 'Confirmed'),
(2, 3, '2026-03-22', 'Pending'),
(3, 1, '2026-03-23', 'Confirmed'),
(1, 1, '2026-03-24', 'Confirmed'),
(2, 1, '2026-03-25', 'Pending'),
(3, 1, '2026-03-26', 'Confirmed'),
(1, 1, '2026-03-27', 'Confirmed');

INSERT INTO review (user_id, review_type, hotel_id, flight_id, rating, comment, review_date) VALUES
(1, 'hotel', 1, NULL, 5, 'Excellent stay, very comfortable!', '2026-04-02'),
(2, 'flight', NULL, 3, 4, 'Good flight, on time.', '2026-04-11');

INSERT INTO payment (user_id, reservation_id, booking_id, amount, payment_method, payment_date) VALUES
(1, 1, NULL, 1200.00, 'Card', '2026-03-25'),
(2, NULL, 2, 1400.00, 'Cash', '2026-03-26');

-- 1. List all hotel bookings for each user
SELECT 
    u.name AS user_name,
    h.name AS hotel_name,
    rh.reservation_date
FROM user_account u
JOIN reservation_hotel rh USING (user_id)
JOIN hotel h USING (hotel_id);

-- 2. Total revenue from each user
SELECT u.name AS user_name,p.payment_method, sum(p.amount) AS user_spent
FROM user_account u
JOIN  payment p USING (user_id)
GROUP BY u.name, p.payment_method

-- 3. Hotels with average rating >= 3.5.
SELECT h.name AS hotel_name , rating
FROM hotel h
WHERE rating >= 3.5

-- 4. Users who have never made a booking for flights
WITH users_made_flights AS (
    SELECT DISTINCT u.name, u.user_id
    FROM user_account u
    JOIN booking_flight bf USING(user_id)
)

SELECT u.name, u.user_id
FROM user_account u
EXCEPT
SELECT name, user_id
FROM users_made_flights;

-- 5. Top 3 most booked hotels (by number of reservations).
SELECT *
FROM (
    SELECT 
        h.name,
        COUNT(*) AS total_reservations,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM hotel h
    JOIN reservation_hotel rh USING (hotel_id)
    GROUP BY h.hotel_id, h.name
) AS temp
WHERE temp.rank <= 3;

-- 6. Upcoming flights in the next 3 weeks and listing users who booked them.
SELECT 
    u.name AS user_name,
    f.departure_city,
    f.arrival_city,
    f.departure_date
FROM user_account u
JOIN booking_flight bf USING (user_id)
JOIN flight f USING (flight_id)
WHERE f.departure_date BETWEEN CURRENT_DATE AND CURRENT_DATE + 21;

-- 7. Users who booked both a hotel and a flight for the same trip (same date range)
SELECT 
    u.name AS user_name,
    h.name AS hotel_name,
    f.departure_city,
    f.arrival_city,
    f.departure_date
FROM user_account u
JOIN reservation_hotel rh USING (user_id)
JOIN hotel h USING (hotel_id)
JOIN booking_flight bf USING (user_id)
JOIN flight f USING (flight_id)
WHERE rh.reservation_date = f.departure_date;

-- 8. Top 3 busiest routes
SELECT departure_city, arrival_city, COUNT(*) AS total_bookings
FROM flight f
JOIN booking_flight bf USING (flight_id)
GROUP BY departure_city, arrival_city
ORDER BY total_bookings DESC
LIMIT 3;

-- 9. Available rooms in a hotel today
SELECT 
    r.room_id,
    r.room_type,
    h.name AS hotel_name
FROM room r
JOIN hotel h USING (hotel_id)
WHERE r.hotel_id NOT IN (
    SELECT hotel_id
    FROM reservation_hotel
    WHERE reservation_date = CURRENT_DATE 
);

-- 10. Airline has the highest number of bookings?
SELECT 
    airline_name, 
    COUNT(*) AS number_of_booking
FROM airline 
JOIN flight USING (airline_id)
JOIN booking_flight USING (flight_id)
GROUP BY airline_name
ORDER BY number_of_booking DESC
LIMIT 1;

-- 11. Hotel Name Contains Cairo
SELECT 
    name,
    location,
    rating,
    CASE 
        WHEN rating >= 4.5 THEN 'Excellent'
        WHEN rating >= 3 THEN 'Good'
        ELSE 'Poor'
    END AS rating_category
FROM hotel
WHERE name ILIKE '%cairo%';

-- 12. Hotels in Cairo + Room Prices
SELECT 
    h.name AS hotel_name,
    r.room_type,
    r.price,
    CASE 
        WHEN r.price > 3000 THEN 'Luxury'
        WHEN r.price >= 1500 THEN 'Standard'
        ELSE 'Budget'
    END AS room_class
FROM hotel h
JOIN room r USING (hotel_id)
WHERE h.location ILIKE '%cairo%';