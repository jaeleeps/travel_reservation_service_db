-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase III: Stored Procedures & Views [v0] Tuesday, November 9, 2021 @ 12:00am EDT
-- Team __
-- Team Member Name (GT username)
-- Team Member Name (GT username)
-- Team Member Name (GT username)
-- Team Member Name (GT username)
-- Directions:
-- Please follow all instructions for Phase III as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.


-- ID: 1a
-- Name: register_customer
drop procedure if exists register_customer;
delimiter //
create procedure register_customer(
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12),
    in i_cc_number varchar(19),
    in i_cvv char(3),
    in i_exp_date date,
    in i_location varchar(50)
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 1b
-- Name: register_owner
drop procedure if exists register_owner;
delimiter //
create procedure register_owner(
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12)
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 1c
-- Name: remove_owner
drop procedure if exists remove_owner;
delimiter //
create procedure remove_owner(
    in i_owner_email varchar(50)
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 2a
-- Name: schedule_flight
drop procedure if exists schedule_flight;
delimiter //
create procedure schedule_flight(
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_from_airport char(3),
    in i_to_airport char(3),
    in i_departure_time time,
    in i_arrival_time time,
    in i_flight_date date,
    in i_cost decimal(6, 2),
    in i_capacity int,
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 2b
-- Name: remove_flight
drop procedure if exists remove_flight;
delimiter //
create procedure remove_flight(
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 3a
-- Name: book_flight
drop procedure if exists book_flight;
delimiter //
create procedure book_flight(
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_num_seats int,
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;

-- ID: 3b
-- Name: cancel_flight_booking
drop procedure if exists cancel_flight_booking;
delimiter //
create procedure cancel_flight_booking(
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 3c
-- Name: view_flight
create or replace view view_flight
            (
             flight_id,
             flight_date,
             airline,
             destination,
             seat_cost,
             num_empty_seats,
             total_spent
                )
as
-- TODO: replace this select query with your solution
select 'col1', 'col2', 'col3', 'col4', 'col5', 'col6', 'col7'
from flight;


-- ID: 4a
-- Name: add_property
drop procedure if exists add_property;
delimiter //
create procedure add_property(
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_description varchar(500),
    in i_capacity int,
    in i_cost decimal(6, 2),
    in i_street varchar(50),
    in i_city varchar(50),
    in i_state char(2),
    in i_zip char(5),
    in i_nearest_airport_id char(3),
    in i_dist_to_airport int
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 4b
-- Name: remove_property
drop procedure if exists remove_property;
delimiter //
create procedure remove_property(
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 5a
-- Name: reserve_property
/**
This procedure allows customers to reserve an available property advertised by an owner  if (and
only if) the following conditions are met:
• The combination of property_name, owner_email, and customer_email should be unique in the system
• The start date of the reservation should be in the future (use current date for comparison)
• The guest has not already reserved a property that overlaps with the dates of this reservation
• The available capacity for the property during the span of dates must be greater than or equal to i_num_guests during the span of dates provided
• Note: for simplicity, the available capacity of a property over a span of time will be
defined as the capacity of the property minus the total number of guests staying at that
property during that span of time
 */
-- FIXME: what about "was_cancelled" reserve?
drop procedure if exists reserve_property;
delimiter //
create procedure reserve_property(
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_start_date date,
    in i_end_date date,
    in i_num_guests int,
    in i_current_date date
)
sp_main:
begin
    if
#         • The combination of property_name, owner_email, and customer_email should be unique in the system            
            (not exists
                (
                    select 1
                    from Reserve as r
                    where r.Property_Name = i_property_name
                      and r.Owner_Email = i_owner_email
                      and r.Customer = i_customer_email
                )
                )
            and
#             • The start date of the reservation should be in the future (use current date for comparison)
            (i_current_date < i_start_date)
            and
#             • The guest has not already reserved a property that overlaps with the dates of this reservation
            (not exists
                (
                    select 1
                    from Reserve as r
                    where r.Customer = i_customer_email
                      and (
                            i_start_date between r.Start_Date and r.End_Date
                            or i_end_date between r.Start_Date and r.End_Date
                        )
                )
                )
            and
#             • The available capacity for the property during the span of dates must be greater than or equal to i_num_guests during the span of dates provided
            (
                select if(
                                       (
                                           select Capacity
                                           from Property p
                                           where p.Property_Name = i_property_name
                                       )
                                       -
                                       (
                                           select sum(r.Num_Guests)
                                           from Reserve r
                                                    left join Property p
                                                              on p.Property_Name = r.Property_Name
                                                                  and p.Owner_Email = r.Owner_Email
                                           where r.Property_Name = i_property_name
                                             and (
                                                   r.Start_Date between i_start_date and i_end_date
                                                   or r.End_Date between i_start_date and i_end_date
                                               )
                                       ) >= i_num_guests,
                                       1,
                                       0
                           )
            )
    then
        insert into Reserve
        (Property_Name, Owner_Email, Customer, Start_Date, End_Date, Num_Guests, Was_Cancelled)
        values (i_property_name, i_owner_email, i_customer_email, i_start_date, i_end_date, i_num_guests, 0);
    end if;
end//
delimiter ;


-- ID: 5b
-- Name: cancel_property_reservation
/**
This procedure allows a customer to cancel an existing property reservation if (and only if) the following conditions are met:
• The customer must already have reserved this property
• If the reservation is already cancelled, this procedure should do nothing
• The date of the reservation must be at a date in the future (use the current date passed in for comparison)
• To cancel a reservation, the was_cancelled attribute in the reserve table should be set to 1

 */
drop procedure if exists cancel_property_reservation;
delimiter //
create procedure cancel_property_reservation(
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_current_date date
)
sp_main:
begin
    update Reserve as r
#         • To cancel a reservation, the was_cancelled attribute in the reserve table should be set to 1
    set r.Was_Cancelled = 1
#         • The customer must already have reserved this property
    where r.Property_Name = i_property_name
      and r.Owner_Email = i_owner_email
      and r.Customer = i_customer_email
#         • If the reservation is already cancelled, this procedure should do nothing
      and r.Was_Cancelled = 0
#         • The date of the reservation must be at a date in the future (use the current date passed in for comparison)
      and r.Start_Date > i_current_date;
end //
delimiter ;


-- ID: 5c
-- Name: customer_review_property
drop procedure if exists customer_review_property;
delimiter //
create procedure customer_review_property(
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_content varchar(500),
    in i_score int,
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 5d
-- Name: view_properties
create or replace view view_properties
            (
             property_name,
             average_rating_score,
             description,
             address,
             capacity,
             cost_per_night
                )
as
-- TODO: replace this select query with your solution
select 'col1', 'col2', 'col3', 'col4', 'col5', 'col6'
from property;


-- ID: 5e
-- Name: view_individual_property_reservations
drop procedure if exists view_individual_property_reservations;
delimiter //
create procedure view_individual_property_reservations(
    in i_property_name varchar(50),
    in i_owner_email varchar(50)
)
sp_main:
begin
    drop table if exists view_individual_property_reservations;
    create table view_individual_property_reservations
    (
        property_name      varchar(50),
        start_date         date,
        end_date           date,
        customer_email     varchar(50),
        customer_phone_num char(12),
        total_booking_cost decimal(6, 2),
        rating_score       int,
        review             varchar(500)
    ) as
        -- TODO: replace this select query with your solution
    select 'col1', 'col2', 'col3', 'col4', 'col5', 'col6', 'col7', 'col8' from reserve;

end //
delimiter ;


-- ID: 6a
-- Name: customer_rates_owner
drop procedure if exists customer_rates_owner;
delimiter //
create procedure customer_rates_owner(
    in i_customer_email varchar(50),
    in i_owner_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 6b
-- Name: owner_rates_customer
drop procedure if exists owner_rates_customer;
delimiter //
create procedure owner_rates_customer(
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;


-- ID: 7a
-- Name: view_airports
create or replace view view_airports
            (
             airport_id,
             airport_name,
             time_zone,
             total_arriving_flights,
             total_departing_flights,
             avg_departing_flight_cost
                )
as
-- TODO: replace this select query with your solution    
select 'col1', 'col2', 'col3', 'col4', 'col5', 'col6'
from airport;

-- ID: 7b
-- Name: view_airlines
create or replace view view_airlines
            (
             airline_name,
             rating,
             total_flights,
             min_flight_cost
                )
as
-- TODO: replace this select query with your solution
select 'col1', 'col2', 'col3', 'col4'
from airline;


-- ID: 8a
-- Name: view_customers
create or replace view view_customers
            (
             customer_name,
             avg_rating,
             location,
             is_owner,
             total_seats_purchased
                )
as
    -- TODO: replace this select query with your solution
-- view customers
select 'col1', 'col2', 'col3', 'col4', 'col5'
from customer;


-- ID: 8b
-- Name: view_owners
create or replace view view_owners
            (
             owner_name,
             avg_rating,
             num_properties_owned,
             avg_property_rating
                )
as
-- TODO: replace this select query with your solution
select 'col1', 'col2', 'col3', 'col4'
from owners;


-- ID: 9a
-- Name: process_date
drop procedure if exists process_date;
delimiter //
create procedure process_date(
    in i_current_date date
)
sp_main:
begin
    -- TODO: Implement your solution here

end //
delimiter ;
