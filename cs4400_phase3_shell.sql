-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase III: Stored Procedures & Views [v0] Tuesday, November 9, 2021 @ 12:00am EDT
-- Team __
-- jbrachey3
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


-- ID: 5a (80)
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
                            r.Start_Date between i_start_date and i_end_date
                            or r.End_Date between i_start_date and i_end_date
#                             i_start_date between r.Start_Date and r.End_Date
#                             or i_end_date between r.Start_Date and r.End_Date
                        )
                      and r.Was_Cancelled = 0
                )
                )
            and
#             • The available capacity for the property during the span of dates must be greater than or equal to i_num_guests during the span of dates provided
            (
                select if(
                                   ((
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
                                        where r.Property_Name = i_property_name
                                          and (
                                                r.Start_Date between i_start_date and i_end_date
                                                or r.End_Date between i_start_date and i_end_date
                                            )
                                          and r.Was_Cancelled = 0
                                    )) >= i_num_guests,
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


-- ID: 5b (90)
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
    if
        (exists(
                select 1
                from Reserve as r
#         • The customer must already have reserved this property
                where r.Property_Name = i_property_name
                  and r.Owner_Email = i_owner_email
                  and r.Customer = i_customer_email
#         • If the reservation is already cancelled, this procedure should do nothing
                  and r.Was_Cancelled = 0
#         • The date of the reservation must be at a date in the future (use the current date passed in for comparison)
                  and i_current_date < r.Start_Date
            )
            )
    then
        update Reserve as r
#         • To cancel a reservation, the was_cancelled attribute in the reserve table should be set to 1
        set r.Was_Cancelled = 1
#         • The customer must already have reserved this property
        where r.Property_Name = i_property_name
          and r.Owner_Email = i_owner_email
          and r.Customer = i_customer_email
#         • If the reservation is already cancelled, this procedure should do nothing
          and r.Was_Cancelled = 0;
    end if;
end //
delimiter ;


-- ID: 5c (95)
-- Name: customer_review_property
/**
  This procedure allows customers to leave a review for a property at which they stayed if (and only if) the following conditions are met:
• The customer must have started a stay at this property at a date in the past that wasn’t cancelled
  (current date must be equal to or later than the start date of the reservation at this property)
• The combination of property_name, owner_email, and customer_email should be distinct in the review table
  (a customer should not be able to review a property more than once)
 */
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
    if
            (exists(
                    select 1
                    from Reserve as r
#         This procedure allows customers to leave a review for a property at which they stayed
                    where r.Property_Name = i_property_name
                      and r.Owner_Email = i_owner_email
                      and r.Customer = i_customer_email
#         • The customer must have started a stay at this property at a date in the past that wasn’t cancelled
#         (current date must be equal to or later than the start date of the reservation at this property)
                      and r.Start_Date <= i_current_date
                      and r.Was_Cancelled = 0
                )
                )
            and
            (not exists(
                    select 1
                    from Review as r
#         • The combination of property_name, owner_email, and customer_email should be distinct in the review table
#         (a customer should not be able to review a property more than once)
                    where r.Property_Name = i_property_name
                      and r.Owner_Email = i_owner_email
                      and r.Customer = i_customer_email
                )
                )
    then
        insert into Review (Property_Name, Owner_Email, Customer, Content, Score)
        values (i_property_name, i_owner_email, i_customer_email, i_content, i_score);
    end if;
end //
delimiter ;


-- ID: 5d (155)
-- Name: view_properties
/**
  This view displays the name, average rating score, description, concatenated address, capacity
  , and cost per night of all properties.
  Note: The concatenated address should have a comma and space (‘, ‘) between each part of the address
  (ie: “Blackhawks St, Chicago, IL, 60176”).
 */
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
select prop.Property_Name                                                     as property_name
     , (
    select avg(r.Score)
    from Review as r
    where r.Property_Name = prop.Property_Name
    group by r.Property_Name
)                                                                             as average_rating_score
     , prop.Descr                                                             as description
     , CONCAT(prop.Street, ', ', prop.City, ', ', prop.State, ', ', prop.Zip) as address
     , prop.Capacity                                                          as capacity
     , prop.Cost                                                              as cost_per_night
from Property as prop
;

-- ID: 5e (161)
-- Name: view_individual_property_reservations
/**
  This procedure creates a table that displays a single property’s reservations such as the name, start date, end date, customer email, customer phone number, the total cost of the booking, the property rating score from the customer if it exists (null if it doesn’t exist), and the property review from the customer if it exists (null if it doesn’t exist), if (and only if) the following conditions are met:
• The property name and owner email must exist in the system. If they do not exist in the system, a table should be created with no entries.
• For calculating total cost, include the start and end date in the number of days. The cost of a single reservation should be number of days * property cost, and if the reservation is cancelled only take 20% of this calculation.
• Note: within this procedure we will create a table titled: “view_individual_property_reservations” that will display the data mentioned above.
 */
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
    select r.Property_Name as property_name
         , r.Start_Date    as start_date
         , r.End_Date      as end_date
         , c.Email         as customer_email
         , c.Phone_Number  as customer_phone_num
         , cast(
                p.Cost * (datediff(r.End_Date, r.Start_Date) + 1)
                * if(Was_Cancelled = 1, 1.2, 1.0)
        as decimal(6, 2))  as total_booking_cost
         , rv.Score        as rating_score
         , rv.Content      as review
    from Reserve as r
             left join Property p
                       on p.Property_Name = r.Property_Name
                           and p.Owner_Email = r.Owner_Email
             left join Clients c
                       on r.Customer = c.Email
             left join Review rv
                       on rv.Property_Name = r.Property_Name
                           and rv.Owner_Email = r.Owner_Email
                           and rv.Customer = c.Email
    where r.Property_Name = i_property_name
      and r.Owner_Email = i_owner_email;
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
	-- first, make sure accounts are in database
	if i_customer_email not in (select email from customer)
	then leave sp_main; end if;

	if i_owner_email not in (select email from owners)
	then leave sp_main; end if;

	-- make sure customer and owner combo isn't already in customer_rates_owner
	if (select count(*) from customers_rate_owners
	where customer = i_customer_email and owner_email = i_owner_email) > 0
	then leave sp_main; end if;

	-- make sure the customer has stayed at a property owned by the owner and did not cancel
	if (select count(*)
	from reserve where customer = i_customer_email and owner_email = i_owner_email
	and start_date <= i_current_date and was_cancelled = 0) = 0
	then leave sp_main; end if;

	-- finally, add the rating to customer_rates_owner
	insert into customers_rate_owners
	values (i_customer_email, i_owner_email, i_score);
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
	-- first, make sure accounts are in database
	if i_owner_email not in (select email from owners)
	then leave sp_main; end if;

	if i_customer_email not in (select email from customer)
	then leave sp_main; end if;

	-- make sure customer and owner combo isn't already in owners_rate_customers
	if (select count(*) from owners_rate_customers
	where customer = i_customer_email and owner_email = i_owner_email) > 0
	then leave sp_main; end if;

	-- make sure the customer has stayed at a property owned by the owner and did not cancel
	if (select count(*)
	from reserve where owner_email = i_owner_email and customer = i_customer_email
	and start_date <= i_current_date and was_cancelled = 0) = 0
	then leave sp_main; end if;

	-- finally, add the rating to owners_rate_customers
	insert into owners_rate_customers
	values (i_owner_email, i_customer_email, i_score);
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
	select airport_id, airport_name, time_zone, total_arriving_flights, 
	total_departing_flights, avg_departing_flight_cost
	from (
		(select airport_id, airport_name, time_zone,
		count(distinct flight_num) as total_departing_flights,
        avg(cost) as avg_departing_flight_cost
		from airport
			left outer join flight
			on airport_id = from_airport group by airport_id) as temp_departure 
				natural join
				(select airport_id, count(distinct flight_num) as total_arriving_flights
				from airport left outer join flight
				on airport_id = to_airport group by airport_id) as temp_a);

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
	select airline_name, rating, count(*) as total_flights, min(cost) as min_flight_cost
	from airline natural join flight
	group by airline_name;


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
	select customer_name, avg_rating, location,
	count(distinct email) as is_owner, total_seats_purchased
		from (select customer_name, email as client_email,
		avg_rating, location, IFNULL(sum(num_seats), 0) as total_seats_purchased
			from (select concat(first_name, ' ', last_name) as customer_name, 
            email, avg(score) as avg_rating, location
				from (select * from customer natural join accounts) as temp_account_info
				left outer join owners_rate_customers
                on email = customer group by email) as temp_ratings
			left outer join book on email = customer group by email) as temp_seats
		left outer join owners on email = client_email group by client_email;


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
	select owner_name, avg_rating, 
	count(distinct street, city, state, zip) as num_properties_owned, avg_property_rating 
		from (select owner_name, email, avg_rating, avg(score) as avg_property_rating
			from (select owner_name, email, avg_rating
				from (select concat(first_name, ' ', last_name) as owner_name, email
					from owners natural join accounts) as temp_info
					left outer join 
						(select owner_email, avg(score) as avg_rating
						from customers_rate_owners group by owner_email) as temp_ratings
					on email = owner_email group by email) as temp_name_rating
			left outer join review 
			on email = owner_email group by email) as temp_prop_rating
		left outer join property on email = owner_email group by email;


-- ID: 9a (125)
-- Name: process_date
/**
  This procedure updates the database based on the current date by updating all customers’ locations
  who are taking a flight on that date to the state of their destination airport
  if (and only if) the following conditions are met:
• If a user cancels their flight for that date, their location should not be updated
• Note: a customer should not have more than one non-cancelled flight in a single day
 */
drop procedure if exists process_date;
delimiter //
create procedure process_date(
    in i_current_date date
)
sp_main:
begin
    update Customer c
        left join Book b
            on c.Email = b.Customer
        left join Flight f
            on b.Flight_Num = f.Flight_Num
        left join Airport a
            on f.To_Airport = a.Airport_Id
    set c.Location = a.State
    where b.Was_Cancelled = 0
        and f.Flight_Date = i_current_date
    ;
end //
delimiter ;
