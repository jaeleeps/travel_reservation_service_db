DROP DATABASE IF EXISTS travel_reservation_service;
CREATE DATABASE IF NOT EXISTS travel_reservation_service;
USE travel_reservation_service;

------------------------------------------
--
-- Entities
--
------------------------------------------

CREATE TABLE accounts
(
    email      VARCHAR(50)  NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    password       VARCHAR(50)  NOT NULL,

    PRIMARY KEY (email)
);

-- Admin is a keyword in MySQL
CREATE TABLE admins
(
    email VARCHAR(50) NOT NULL,

    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES accounts (email)
);

CREATE TABLE clients
(
    email        VARCHAR(50)     NOT NULL,
    phone_number Char(12) UNIQUE NOT NULL CHECK (length(phone_number) = 12), -- Assuming format 123-456-7890

    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES accounts (email)
);

-- owner is a keyword in MySQL
CREATE TABLE owners
(
    email VARCHAR(50) NOT NULL,

    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES clients (email)
);

CREATE TABLE customer
(
    email    VARCHAR(50)        NOT NULL,
    ccnumber VARCHAR(19) UNIQUE NOT NULL CHECK (length(ccnumber) = 19), -- Assuming format "1234 1234 1234 1234"
    cvv      CHAR(3)            NOT NULL CHECK (length(cvv) = 3),
    exp_date DATE               NOT NULL,
    location VARCHAR(50)        NOT NULL,

    PRIMARY KEY (email),
    FOREIGN KEY (email) REFERENCES clients (email)
);

CREATE TABLE airline
(
    airline_name VARCHAR(50)   NOT NULL,                                     -- name is a keyword in MySQL
    rating       DECIMAL(2, 1) NOT NULL CHECK (rating >= 1 AND rating <= 5), -- Assuming 5 point rating scale

    PRIMARY KEY (airline_name)
);

CREATE TABLE airport
(
    airport_id   CHAR(3)            NOT NULL CHECK (length(airport_id) = 3),
    airport_name VARCHAR(50) UNIQUE NOT NULL,
    time_zone    CHAR(3)            NOT NULL CHECK (length(time_zone) = 3), -- Assuming 3 letter timezone abbreviation is used
    street       VARCHAR(50)        NOT NULL,
    city         VARCHAR(50)        NOT NULL,
    state        CHAR(2)            NOT NULL CHECK (length(state) = 2),
    zip          CHAR(5)            NOT NULL CHECK (length(zip) = 5),

    PRIMARY KEY (airport_id),
    UNIQUE KEY (street, city, state, zip)
);

------------------------------------------
--
-- Weak Entities
--
------------------------------------------

CREATE TABLE flight
(
    -- Comment length check until flight numbers are updated
    flight_num     CHAR(5)       NOT NULL,                   -- CHECK(length(flight_num) = 5),
    airline_name   VARCHAR(50)   NOT NULL,
    from_airport   CHAR(3)       NOT NULL,
    to_airport     CHAR(3)       NOT NULL,
    departure_time TIME          NOT NULL,
    arrival_time   TIME          NOT NULL,
    flight_date    DATE          NOT NULL,
    cost           DECIMAL(6, 2) NOT NULL CHECK (cost >= 0), -- Allow prices from $0.00 to $9999.99
    capacity       INT           NOT NULL CHECK (capacity > 0),

    PRIMARY KEY (flight_num, airline_name),
    FOREIGN KEY (airline_name) REFERENCES airline (airline_name),
    FOREIGN KEY (from_airport) REFERENCES airport (airport_id),
    FOREIGN KEY (to_airport) REFERENCES airport (airport_id),

    -- Destination airport must be different from origin airport
    CHECK (from_airport != to_airport)
    -- flight must arrive after it departs
    -- Commenting this for now. Since for short flights across time zones
    -- this may not always hold
    -- CHECK (departure_time < arrival_time)
);

CREATE TABLE property
(
    property_name VARCHAR(50)   NOT NULL,
    owner_email   VARCHAR(50)   NOT NULL,
    descr         VARCHAR(500)  NOT NULL,                   -- description is a keyword in MySQL
    capacity      INT           NOT NULL CHECK (capacity > 0),
    cost          DECIMAL(6, 2) NOT NULL CHECK (cost >= 0), -- Allow prices from $0.00 to $9999.99
    street        VARCHAR(50)   NOT NULL,
    city          VARCHAR(50)   NOT NULL,
    state         CHAR(2)       NOT NULL CHECK (length(state) = 2),
    zip           CHAR(5)       NOT NULL CHECK (length(zip) = 5),

    PRIMARY KEY (property_name, owner_email),
    FOREIGN KEY (owner_email) REFERENCES owners (email),
    UNIQUE KEY (street, city, state, zip)
);

------------------------------------------
--
-- Multivalued Attributes
--
------------------------------------------

CREATE TABLE amenity
(
    property_name  VARCHAR(50) NOT NULL,
    property_owner VARCHAR(50) NOT NULL,
    amenity_name   VARCHAR(50) NOT NULL,

    PRIMARY KEY (property_name, property_owner, amenity_name),
    FOREIGN KEY (property_name, property_owner) REFERENCES property (property_name, owner_email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE attraction
(
    airport         CHAR(3)     NOT NULL,
    attraction_name VARCHAR(50) NOT NULL,

    PRIMARY KEY (airport, attraction_name),
    FOREIGN KEY (airport) REFERENCES airport (airport_id)
);

------------------------------------------
--
-- M-N Relationships
--
------------------------------------------

CREATE TABLE review
(
    property_name VARCHAR(50) NOT NULL,
    owner_email   VARCHAR(50) NOT NULL,
    customer      VARCHAR(50) NOT NULL,
    content       VARCHAR(500),                                           -- Assuming a customer could provide just a rating
    score         INT         NOT NULL CHECK (score >= 1 AND score <= 5), -- Assuming 5 point rating scale

    PRIMARY KEY (property_name, owner_email, customer),
    FOREIGN KEY (property_name, owner_email) REFERENCES property (property_name, owner_email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (customer) REFERENCES customer (email)
);

CREATE TABLE reserve
(
    property_name VARCHAR(50) NOT NULL,
    owner_email   VARCHAR(50) NOT NULL,
    customer      VARCHAR(50) NOT NULL,
    start_date    DATE        NOT NULL,
    end_date      DATE        NOT NULL,
    num_guests    INT         NOT NULL CHECK (num_guests > 0),
    was_cancelled BOOLEAN     NOT NULL,

    PRIMARY KEY (property_name, owner_email, customer),
    FOREIGN KEY (property_name, owner_email) REFERENCES property (property_name, owner_email),
    FOREIGN KEY (customer) REFERENCES customer (email),

    -- End date must be after start date
    CHECK (end_date >= start_date)
);

CREATE TABLE is_close_to
(
    property_name VARCHAR(50) NOT NULL,
    owner_email   VARCHAR(50) NOT NULL,
    airport       CHAR(3)     NOT NULL,
    distance      INT         NOT NULL CHECK (distance >= 0), -- Assuming all distances rounded to nearest mile

    PRIMARY KEY (property_name, owner_email, airport),
    FOREIGN KEY (property_name, owner_email) REFERENCES property (property_name, owner_email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (airport) REFERENCES airport (airport_id)
);

CREATE TABLE book
(
    customer      VARCHAR(50) NOT NULL,
    flight_num    CHAR(5)     NOT NULL,
    airline_name  VARCHAR(50) NOT NULL,
    Num_Seats     INT         NOT NULL CHECK (Num_Seats > 0),
    was_cancelled BOOLEAN     NOT NULL,

    PRIMARY KEY (customer, flight_num, airline_name),
    FOREIGN KEY (customer) REFERENCES customer (email),
    FOREIGN KEY (flight_num, airline_name) REFERENCES flight (flight_num, airline_name)
);

CREATE TABLE owners_rate_customers
(
    owner_email VARCHAR(50) NOT NULL,
    customer    VARCHAR(50) NOT NULL,
    score       INT         NOT NULL CHECK (score >= 1 AND score <= 5), -- Assuming 5 point rating scale

    PRIMARY KEY (owner_email, customer),
    FOREIGN KEY (owner_email) REFERENCES owners (email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (customer) REFERENCES customer (email)
);

CREATE TABLE customers_rate_owners
(
    customer    VARCHAR(50) NOT NULL,
    owner_email VARCHAR(50) NOT NULL,
    score       INT         NOT NULL CHECK (score >= 1 AND score <= 5), -- Assuming 5 point rating scale

    PRIMARY KEY (customer, owner_email),
    FOREIGN KEY (customer) REFERENCES customer (email),
    FOREIGN KEY (owner_email) REFERENCES owners (email) ON UPDATE CASCADE ON DELETE CASCADE
);

------------------------------------------
--
-- Insert statements
--
------------------------------------------

INSERT INTO accounts (email, first_name, last_name, password)
VALUES ('mmoss1@travelagency.com', 'Mark', 'Moss', 'password1'),
       ('asmith@travelagency.com', 'Aviva', 'Smith', 'password2'),
       ('mscott22@gmail.com', 'Michael', 'Scott', 'password3'),
       ('arthurread@gmail.com', 'Arthur', 'Read', 'password4'),
       ('jwayne@gmail.com', 'John', 'Wayne', 'password5'),
       ('gburdell3@gmail.com', 'George', 'Burdell', 'password6'),
       ('mj23@gmail.com', 'Michael', 'Jordan', 'password7'),
       ('lebron6@gmail.com', 'Lebron', 'James', 'password8'),
       ('msmith5@gmail.com', 'Michael', 'Smith', 'password9'),
       ('ellie2@gmail.com', 'Ellie', 'Johnson', 'password10'),
       ('scooper3@gmail.com', 'Sheldon', 'Cooper', 'password11'),
       ('mgeller5@gmail.com', 'Monica', 'Geller', 'password12'),
       ('cbing10@gmail.com', 'Chandler', 'Bing', 'password13'),
       ('hwmit@gmail.com', 'Howard', 'Wolowitz', 'password14'),
       ('swilson@gmail.com', 'Samantha', 'Wilson', 'password16'),
       ('aray@tiktok.com', 'Addison', 'Ray', 'password17'),
       ('cdemilio@tiktok.com', 'Charlie', 'Demilio', 'password18'),
       ('bshelton@gmail.com', 'Blake', 'Shelton', 'password19'),
       ('lbryan@gmail.com', 'Luke', 'Bryan', 'password20'),
       ('tswift@gmail.com', 'Taylor', 'Swift', 'password21'),
       ('jseinfeld@gmail.com', 'Jerry', 'Seinfeld', 'password22'),
       ('maddiesmith@gmail.com', 'Madison', 'Smith', 'password23'),
       ('johnthomas@gmail.com', 'John', 'Thomas', 'password24'),
       ('boblee15@gmail.com', 'Bob', 'Lee', 'password25');

INSERT INTO admins (email)
VALUES ('mmoss1@travelagency.com'),
       ('asmith@travelagency.com');

INSERT INTO clients (email, phone_number)
VALUES ('mscott22@gmail.com', '555-123-4567'),
       ('arthurread@gmail.com', '555-234-5678'),
       ('jwayne@gmail.com', '555-345-6789'),
       ('gburdell3@gmail.com', '555-456-7890'),
       ('mj23@gmail.com', '555-567-8901'),
       ('lebron6@gmail.com', '555-678-9012'),
       ('msmith5@gmail.com', '555-789-0123'),
       ('ellie2@gmail.com', '555-890-1234'),
       ('scooper3@gmail.com', '678-123-4567'),
       ('mgeller5@gmail.com', '678-234-5678'),
       ('cbing10@gmail.com', '678-345-6789'),
       ('hwmit@gmail.com', '678-456-7890'),
       ('swilson@gmail.com', '770-123-4567'),
       ('aray@tiktok.com', '770-234-5678'),
       ('cdemilio@tiktok.com', '770-345-6789'),
       ('bshelton@gmail.com', '770-456-7890'),
       ('lbryan@gmail.com', '770-567-8901'),
       ('tswift@gmail.com', '770-678-9012'),
       ('jseinfeld@gmail.com', '770-789-0123'),
       ('maddiesmith@gmail.com', '770-890-1234'),
       ('johnthomas@gmail.com', '404-770-5555'),
       ('boblee15@gmail.com', '404-678-5555');

INSERT INTO owners (email)
VALUES ('mscott22@gmail.com'),
       ('arthurread@gmail.com'),
       ('jwayne@gmail.com'),
       ('gburdell3@gmail.com'),
       ('mj23@gmail.com'),
       ('lebron6@gmail.com'),
       ('msmith5@gmail.com'),
       ('ellie2@gmail.com'),
       ('scooper3@gmail.com'),
       ('mgeller5@gmail.com'),
       ('cbing10@gmail.com'),
       ('hwmit@gmail.com');

INSERT INTO customer (email, CCNumber, cvv, exp_date, location)
VALUES ('scooper3@gmail.com', '6518 5559 7446 1663', '551', '2024-2-01', ''),
       ('mgeller5@gmail.com', '2328 5670 4310 1965', '644', '2024-3-01', ''),
       ('cbing10@gmail.com', '8387 9523 9827 9291', '201', '2023-2-01', ''),
       ('hwmit@gmail.com', '6558 8596 9852 5299', '102', '2023-4-01', ''),
       ('swilson@gmail.com', '9383 3212 4198 1836', '455', '2022-8-01', ''),
       ('aray@tiktok.com', '3110 2669 7949 5605', '744', '2022-8-01', ''),
       ('cdemilio@tiktok.com', '2272 3555 4078 4744', '606', '2025-2-01', ''),
       ('bshelton@gmail.com', '9276 7639 7883 4273', '862', '2023-9-01', ''),
       ('lbryan@gmail.com', '4652 3726 8864 3798', '258', '2023-5-01', ''),
       ('tswift@gmail.com', '5478 8420 4436 7471', '857', '2024-12-01', ''),
       ('jseinfeld@gmail.com', '3616 8977 1296 3372', '295', '2022-6-01', ''),
       ('maddiesmith@gmail.com', '9954 5698 6355 6952', '794', '2022-7-01', ''),
       ('johnthomas@gmail.com', '7580 3274 3724 5356', '269', '2025-10-01', ''),
       ('boblee15@gmail.com', '7907 3513 7161 4248', '858', '2025-11-01', '');

INSERT INTO airline (airline_name, rating)
VALUES ('Delta airlines', 4.7),
       ('Southwest airlines', 4.4),
       ('American airlines', 4.6),
       ('United airlines', 4.2),
       ('JetBlue Airways', 3.6),
       ('Spirit airlines', 3.3),
       ('WestJet', 3.9),
       ('Interjet', 3.7);

INSERT INTO airport (airport_id, airport_name, time_zone, street, city, state, zip)
VALUES ('ATL', 'Atlanta Hartsfield Jackson airport', 'EST', '6000 N Terminal Pkwy', 'Atlanta', 'GA', '30320'),
       ('JFK', 'John F Kennedy International airport', 'EST', '455 airport Ave', 'Queens', 'NY', '11430'),
       ('LGA', 'Laguardia airport', 'EST', '790 airport St', 'Queens', 'NY', '11371'),
       ('LAX', 'Lost Angeles International airport', 'PST', '1 World Way', 'Los Angeles', 'CA', '90045'),
       ('SJC', 'Norman Y. Mineta San Jose International airport', 'PST', '1702 airport Blvd', 'San Jose', 'CA',
        '95110'),
       ('ORD', 'O\'Hare International airport', 'CST', '10000 W O\'Hare Ave', 'Chicago', 'IL', '60666'),
       ('MIA', 'Miami International airport', 'EST', '2100 NW 42nd Ave', 'Miami', 'FL', '33126'),
       ('DFW', 'Dallas International airport', 'CST', '2400 Aviation DR', 'Dallas', 'TX', '75261');

INSERT INTO flight (flight_num, airline_name, from_airport, to_airport, departure_time, arrival_time, flight_date, cost,
                    capacity)
VALUES ('1', 'Delta airlines', 'ATL', 'JFK', '100000', '120000', '2021-10-18', 400, 150),
       ('2', 'Southwest airlines', 'ORD', 'MIA', '103000', '143000', '2021-10-18', 350, 125),
       ('3', 'American airlines', 'MIA', 'DFW', '130000', '160000', '2021-10-18', 350, 125),
       ('4', 'United airlines', 'ATL', 'LGA', '163000', '183000', '2021-10-18', 400, 100),
       ('5', 'JetBlue Airways', 'LGA', 'ATL', '110000', '130000', '2021-10-19', 400, 130),
       ('6', 'Spirit airlines', 'SJC', 'ATL', '123000', '213000', '2021-10-19', 650, 140),
       ('7', 'WestJet', 'LGA', 'SJC', '130000', '160000', '2021-10-19', 700, 100),
       ('8', 'Interjet', 'MIA', 'ORD', '193000', '213000', '2021-10-19', 350, 125),
       ('9', 'Delta airlines', 'JFK', 'ATL', '80000', '100000', '2021-10-20', 375, 150),
       ('10', 'Delta airlines', 'LAX', 'ATL', '91500', '181500', '2021-10-20', 700, 110),
       ('11', 'Southwest airlines', 'LAX', 'ORD', '120700', '190700', '2021-10-20', 600, 95),
       ('12', 'United airlines', 'MIA', 'ATL', '153500', '173500', '2021-10-20', 275, 115);

INSERT INTO property (property_name, owner_email, descr, capacity, cost, street, city, state, zip)
VALUES ('Atlanta Great property', 'scooper3@gmail.com', 'This is right in the middle of Atlanta near many attractions!',
        4, 600, '2nd St', 'ATL', 'GA', '30008'),
       ('House near Georgia Tech', 'gburdell3@gmail.com', 'Super close to bobby dodde stadium!', 3, 275, 'North Ave',
        'ATL', 'GA', '30008'),
       ('New York city property', 'cbing10@gmail.com', 'A view of the whole city. Great property!', 2, 750,
        '123 Main St', 'NYC', 'NY', '10008'),
       ('Statue of Libery property', 'mgeller5@gmail.com', 'You can see the statue of liberty from the porch', 5, 1000,
        '1st St', 'NYC', 'NY', '10009'),
       ('Los Angeles property', 'arthurread@gmail.com', '', 3, 700, '10th St', 'LA', 'CA', '90008'),
       ('LA Kings House', 'arthurread@gmail.com', 'This house is super close to the LA kinds stadium!', 4, 750,
        'Kings St', 'La', 'CA', '90011'),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'Huge house that can sleep 12 people. Totally worth it!',
        12, 900, 'Golden Bridge Pkwt', 'San Jose', 'CA', '90001'),
       ('LA Lakers property', 'lebron6@gmail.com',
        'This house is right near the LA lakers stadium. You might even meet Lebron James!', 4, 850, 'Lebron Ave', 'LA',
        'CA', '90011'),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'This is a great property!', 3, 775, 'Blackhawks St', 'Chicago',
        'IL', '60176'),
       ('Chicago Romantic Getaway', 'mj23@gmail.com', 'This is a great property!', 2, 1050, '23rd Main St', 'Chicago',
        'IL', '60176'),
       ('Beautiful Beach property', 'msmith5@gmail.com', 'You can walk out of the house and be on the beach!', 2, 975,
        '456 Beach Ave', 'Miami', 'FL', '33101'),
       ('Family Beach House', 'ellie2@gmail.com', 'You can literally walk onto the beach and see it from the patio!', 6,
        850, '1132 Beach Ave', 'Miami', 'FL', '33101'),
       ('Texas Roadhouse', 'mscott22@gmail.com', 'This property is right in the center of Dallas, Texas!', 3, 450,
        '17th street', 'Dallas', 'TX', '75043'),
       ('Texas Longhorns House', 'mscott22@gmail.com', 'You can walk to the longhorns stadium from here!', 10, 600,
        '1125 Longhorns Way', 'Dallas', 'TX', '75001');

INSERT INTO amenity (property_name, property_owner, amenity_name)
VALUES ('Atlanta Great property', 'scooper3@gmail.com', 'A/C & Heating'),
       ('Atlanta Great property', 'scooper3@gmail.com', 'Pets allowed'),
       ('Atlanta Great property', 'scooper3@gmail.com', 'Wifi & TV'),
       ('Atlanta Great property', 'scooper3@gmail.com', 'Washer and Dryer'),
       ('House near Georgia Tech', 'gburdell3@gmail.com', 'Wifi & TV'),
       ('House near Georgia Tech', 'gburdell3@gmail.com', 'Washer and Dryer'),
       ('House near Georgia Tech', 'gburdell3@gmail.com', 'Full Kitchen'),
       ('New York city property', 'cbing10@gmail.com', 'A/C & Heating'),
       ('New York city property', 'cbing10@gmail.com', 'Wifi & TV'),
       ('Statue of Libery property', 'mgeller5@gmail.com', 'A/C & Heating'),
       ('Statue of Libery property', 'mgeller5@gmail.com', 'Wifi & TV'),
       ('Los Angeles property', 'arthurread@gmail.com', 'A/C & Heating'),
       ('Los Angeles property', 'arthurread@gmail.com', 'Pets allowed'),
       ('Los Angeles property', 'arthurread@gmail.com', 'Wifi & TV'),
       ('LA Kings House', 'arthurread@gmail.com', 'A/C & Heating'),
       ('LA Kings House', 'arthurread@gmail.com', 'Wifi & TV'),
       ('LA Kings House', 'arthurread@gmail.com', 'Washer and Dryer'),
       ('LA Kings House', 'arthurread@gmail.com', 'Full Kitchen'),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'A/C & Heating'),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'Pets allowed'),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'Wifi & TV'),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'Washer and Dryer'),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'Full Kitchen'),
       ('LA Lakers property', 'lebron6@gmail.com', 'A/C & Heating'),
       ('LA Lakers property', 'lebron6@gmail.com', 'Wifi & TV'),
       ('LA Lakers property', 'lebron6@gmail.com', 'Washer and Dryer'),
       ('LA Lakers property', 'lebron6@gmail.com', 'Full Kitchen'),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'A/C & Heating'),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'Wifi & TV'),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'Washer and Dryer'),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'Full Kitchen'),
       ('Chicago Romantic Getaway', 'mj23@gmail.com', 'A/C & Heating'),
       ('Chicago Romantic Getaway', 'mj23@gmail.com', 'Wifi & TV'),
       ('Beautiful Beach property', 'msmith5@gmail.com', 'A/C & Heating'),
       ('Beautiful Beach property', 'msmith5@gmail.com', 'Wifi & TV'),
       ('Beautiful Beach property', 'msmith5@gmail.com', 'Washer and Dryer'),
       ('Family Beach House', 'ellie2@gmail.com', 'A/C & Heating'),
       ('Family Beach House', 'ellie2@gmail.com', 'Pets allowed'),
       ('Family Beach House', 'ellie2@gmail.com', 'Wifi & TV'),
       ('Family Beach House', 'ellie2@gmail.com', 'Washer and Dryer'),
       ('Family Beach House', 'ellie2@gmail.com', 'Full Kitchen'),
       ('Texas Roadhouse', 'mscott22@gmail.com', 'A/C & Heating'),
       ('Texas Roadhouse', 'mscott22@gmail.com', 'Pets allowed'),
       ('Texas Roadhouse', 'mscott22@gmail.com', 'Wifi & TV'),
       ('Texas Roadhouse', 'mscott22@gmail.com', 'Washer and Dryer'),
       ('Texas Longhorns House', 'mscott22@gmail.com', 'A/C & Heating'),
       ('Texas Longhorns House', 'mscott22@gmail.com', 'Pets allowed'),
       ('Texas Longhorns House', 'mscott22@gmail.com', 'Wifi & TV'),
       ('Texas Longhorns House', 'mscott22@gmail.com', 'Washer and Dryer'),
       ('Texas Longhorns House', 'mscott22@gmail.com', 'Full Kitchen');

INSERT INTO attraction (airport, attraction_name)
VALUES ('ATL', 'The Coke Factory'),
       ('ATL', 'The Georgia Aquarium'),
       ('JFK', 'The Statue of Liberty'),
       ('JFK', 'The Empire state Building'),
       ('LGA', 'The Statue of Liberty'),
       ('LGA', 'The Empire state Building'),
       ('LAX', 'Lost Angeles Lakers Stadium'),
       ('LAX', 'Los Angeles Kings Stadium'),
       ('SJC', 'Winchester Mystery House'),
       ('SJC', 'San Jose Earthquakes Soccer Team'),
       ('ORD', 'Chicago Blackhawks Stadium'),
       ('ORD', 'Chicago Bulls Stadium'),
       ('MIA', 'Crandon Park Beach'),
       ('MIA', 'Miami Heat Basketball Stadium'),
       ('DFW', 'Texas Longhorns Stadium'),
       ('DFW', 'The Original Texas Roadhouse');

INSERT INTO review (property_name, owner_email, customer, content, score)
VALUES ('House near Georgia Tech', 'gburdell3@gmail.com', 'swilson@gmail.com',
        'This was so much fun. I went and saw the coke factory, the falcons play, GT play, and the Georgia aquarium. Great time! Would highly recommend!',
        5),
       ('New York city property', 'cbing10@gmail.com', 'aray@tiktok.com',
        'This was the best 5 days ever! I saw so much of NYC!', 5),
       ('Statue of Libery property', 'mgeller5@gmail.com', 'bshelton@gmail.com',
        'This was truly an excellent experience. I really could see the Statue of Liberty from the property!', 4),
       ('Los Angeles property', 'arthurread@gmail.com', 'lbryan@gmail.com', 'I had an excellent time!', 4),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com',
        'We had a great time, but the house wasn\'t fully cleaned when we arrived', 3),
       ('LA Lakers property', 'lebron6@gmail.com', 'jseinfeld@gmail.com',
        'I was disappointed that I did not meet lebron james', 2),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'maddiesmith@gmail.com',
        'This was awesome! I met one player on the chicago blackhawks!', 5),
       ('New York city property', 'cbing10@gmail.com', 'cdemilio@tiktok.com',
        'It was decent, but could have been better', 4);

INSERT INTO reserve (property_name, owner_email, customer, start_date, end_date, num_guests, was_cancelled)
VALUES ('House near Georgia Tech', 'gburdell3@gmail.com', 'swilson@gmail.com', '2021-10-19', '2021-10-25', 3, 0),
       ('New York city property', 'cbing10@gmail.com', 'aray@tiktok.com', '2021-10-18', '2021-10-23', 2, 0),
       ('New York city property', 'cbing10@gmail.com', 'cdemilio@tiktok.com', '2021-10-24', '2021-10-30', 2, 0),
       ('Statue of Libery property', 'mgeller5@gmail.com', 'bshelton@gmail.com', '2021-10-18', '2021-10-22', 4, 0),
       ('Los Angeles property', 'arthurread@gmail.com', 'lbryan@gmail.com', '2021-10-19', '2021-10-25', 2, 0),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com', '2021-10-19', '2021-10-22', 10, 0),
       ('LA Lakers property', 'lebron6@gmail.com', 'jseinfeld@gmail.com', '2021-10-19', '2021-10-24', 4, 0),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'maddiesmith@gmail.com', '2021-10-19', '2021-10-23', 2, 0),
       ('Chicago Romantic Getaway', 'mj23@gmail.com', 'aray@tiktok.com', '2021-11-1', '2021-11-7', 2, 1),
       ('Beautiful Beach property', 'msmith5@gmail.com', 'cbing10@gmail.com', '2021-10-18', '2021-10-25', 2, 0),
       ('Family Beach House', 'ellie2@gmail.com', 'hwmit@gmail.com', '2021-10-18', '2021-10-28', 5, 1),
       ('New York city property', 'cbing10@gmail.com', 'mgeller5@gmail.com', '2021-11-02', '2021-11-06', 3, 1);

INSERT INTO is_close_to (property_name, owner_email, airport, distance)
VALUES ('Atlanta Great property', 'scooper3@gmail.com', 'ATL', 12),
       ('House near Georgia Tech', 'gburdell3@gmail.com', 'ATL', 7),
       ('New York city property', 'cbing10@gmail.com', 'JFK', 10),
       ('Statue of Libery property', 'mgeller5@gmail.com', 'JFK', 8),
       ('New York city property', 'cbing10@gmail.com', 'LGA', 25),
       ('Statue of Libery property', 'mgeller5@gmail.com', 'LGA', 19),
       ('Los Angeles property', 'arthurread@gmail.com', 'LAX', 9),
       ('LA Kings House', 'arthurread@gmail.com', 'LAX', 12),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'SJC', 8),
       ('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'LAX', 30),
       ('LA Lakers property', 'lebron6@gmail.com', 'LAX', 6),
       ('Chicago Blackhawks House', 'hwmit@gmail.com', 'ORD', 11),
       ('Chicago Romantic Getaway', 'mj23@gmail.com', 'ORD', 13),
       ('Beautiful Beach property', 'msmith5@gmail.com', 'MIA', 21),
       ('Family Beach House', 'ellie2@gmail.com', 'MIA', 19),
       ('Texas Roadhouse', 'mscott22@gmail.com', 'DFW', 8),
       ('Texas Longhorns House', 'mscott22@gmail.com', 'DFW', 17);

INSERT INTO book (customer, flight_num, airline_name, Num_Seats, was_cancelled)
VALUES ('swilson@gmail.com', '5', 'JetBlue Airways', 3, 0),
       ('aray@tiktok.com', '1', 'Delta airlines', 2, 0),
       ('bshelton@gmail.com', '4', 'United airlines', 4, 0),
       ('lbryan@gmail.com', '7', 'WestJet', 2, 0),
       ('tswift@gmail.com', '7', 'WestJet', 2, 0),
       ('jseinfeld@gmail.com', '7', 'WestJet', 4, 1),
       ('bshelton@gmail.com', '5', 'JetBlue Airways', 4, 1),
       ('maddiesmith@gmail.com', '8', 'Interjet', 2, 0),
       ('cbing10@gmail.com', '2', 'Southwest airlines', 2, 0),
       ('hwmit@gmail.com', '2', 'Southwest airlines', 5, 1);


INSERT INTO owners_rate_customers (owner_email, customer, score)
VALUES ('gburdell3@gmail.com', 'swilson@gmail.com', 5),
       ('cbing10@gmail.com', 'aray@tiktok.com', 5),
       ('mgeller5@gmail.com', 'bshelton@gmail.com', 3),
       ('arthurread@gmail.com', 'lbryan@gmail.com', 4),
       ('arthurread@gmail.com', 'tswift@gmail.com', 4),
       ('lebron6@gmail.com', 'jseinfeld@gmail.com', 1),
       ('hwmit@gmail.com', 'maddiesmith@gmail.com', 2);

INSERT INTO customers_rate_owners (customer, owner_email, score)
VALUES ('swilson@gmail.com', 'gburdell3@gmail.com', 5),
       ('aray@tiktok.com', 'cbing10@gmail.com', 5),
       ('bshelton@gmail.com', 'mgeller5@gmail.com', 3),
       ('lbryan@gmail.com', 'arthurread@gmail.com', 4),
       ('tswift@gmail.com', 'arthurread@gmail.com', 4),
       ('jseinfeld@gmail.com', 'lebron6@gmail.com', 1),
       ('maddiesmith@gmail.com', 'hwmit@gmail.com', 2);