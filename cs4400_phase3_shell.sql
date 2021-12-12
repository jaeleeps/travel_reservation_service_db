-- cs4400: introduction to database systems (fall 2021)
-- phase iii: stored procedures & views [v0] tuesday, november 9, 2021 @ 12:00am edt
-- team 59
-- felix wang (fwang356)
-- jacob brachey (jbrachey3)
-- jaeyoung lee (jlee3414)
-- hyuntaek lim (hlim96)
-- directions:
-- please follow all instructions for phase iii as listed on canvas.
-- fill in the team number and names and gt usernames for all members above.

-- id: 1a
-- name: register_customer

-- this procedure is to register a new customer if (and only if) the following conditions are met:
-- the new customer’s email and phone number will be unique in the system.
-- the new customer’s credit card number will be unique in the system.
-- the new customer’s phone number will be unique in the system.
-- if the customer to be added already exists as an account and client, but not as a customer, we will add them as a customer to indicate that they are now both an owner and a customer.
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
    -- todo: implement your solution here

-- checking duplicate emails and credit card numbers
    if exists(select email from customer where email = i_email)
    then
        leave sp_main;
    end if;

    if exists(select ccnumber from customer where ccnumber = i_cc_number)
    then
        leave sp_main;
    end if;

-- check whether phone number is unique too
    if exists(select phone_number from clients where phone_number = i_phone_number)
    then
        leave sp_main;
    end if;

-- adding an existing client to customer
    if exists(select email from accounts where email = i_email)
    then
        insert into customer (ccnumber, cvv, exp_date, location)
        values (i_cc_number, i_cvv, i_exp_date, i_location);
    end if;

-- besides the edge cases,
    insert into accounts (email, first_name, last_name, password)
    values (i_email, i_first_name, i_last_name, i_password);
    insert into clients (email, phone_number)
    values (i_email, i_phone_number);
    insert into customer (email, ccnumber, cvv, exp_date, location)
    values (i_email, i_cc_number, i_cvv, i_exp_date, i_location);

end //
delimiter ;

-- id: 1b
-- name: register_owner
-- this procedure is to register a new owner if (and only if) the following conditions are met

-- the new owner’s email and phone number will be unique in the system.
-- the new owner’s phone number will be unique in the system.
-- if the owner to be added already exists as an account and client, but not as an owner, we will add them as an owner to indicate that they are now both a customer and an owner.
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
    -- todo: implement your solution here

-- owner's email check
    if exists(select email from owners where email = i_email)
    then
        leave sp_main;
    end if;

-- owner's phone number check
    if exists(select phone_number from clients where phone_number = i_phone_number)
    then
        leave sp_main;
    end if;

-- adding an existing client (customer) as an owner
    if exists(select email from accounts where email = i_email)
    then
        insert into owners
        values (i_email);
    end if;

    insert into accounts (email, first_name, last_name, password)
    values (i_email, i_first_name, i_last_name, i_password);
    insert into clients (email, phone_number)
    values (i_email, i_phone_number);
    insert into owners
    values (i_email);

end //
delimiter ;

-- id: 1c
-- name: remove_owner

-- this procedure is to delete an owner if (and only if) the following conditions are met
-- the owner has no listed properties.
-- if an owner is deleted, their reviews of customers should be deleted as well
-- if an owner is deleted, customer reviews of the owner should be deleted as well
-- only the owner should be removed from the system – if the owner is also a customer, then the customer should remain in the system.
-- if the owner is not also a customer, then the client and account associated with this owner should be removed as well.
drop procedure if exists remove_owner;
delimiter //
create procedure remove_owner(
    in i_owner_email varchar(50)
)
sp_main:
begin
    -- todo: implement your solution here

-- when property exists -> break this!
    if exists(select owner_email from property where property.owner_email = i_owner_email)
    then
        leave sp_main;
    end if;

    -- no property, delete owners
-- if i_owner_email does not exist in the properties (no property but yes owner), then delete the corresponding row
    delete
    from owners
    where owners.email = i_owner_email;

    if not exists(select email from customer where customer.email = i_owner_email)
    then
        delete from owners where owners.email like i_owner_email;
        delete from clients where clients.email like i_owner_email;
        delete from accounts where accounts.email like i_owner_email;
    end if;

end //
delimiter ;

-- id: 2a
-- name: schedule_flight

-- this procedure is used for an airline adding a new flight if (and only if) the following conditions are met:
-- the new flight numbers must be combined with the airline’s name to be uniquely identifiable
-- the flight cannot have the same to_airport and from_airport
-- the flight date must be in the future (use current date for comparison)

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
    -- todo: implement your solution here

-- gotta be unique flight num + airline name
    if exists(select concat(flight_num, airline_name)
              from flight
              where concat(flight_num, airline_name) = concat(i_flight_num, i_airline_name))
    then
        leave sp_main;
    end if;

-- same to_airport and from_airport -> terminate
    if i_from_airport = i_to_airport
    then
        leave sp_main;
    end if;

-- check flight date
    if i_flight_date < i_current_date
    then
        leave sp_main;
    end if;

    insert into flight
    values (i_flight_num, i_airline_name, i_from_airport, i_to_airport, i_departure_time, i_arrival_time, i_flight_date,
            i_cost, i_capacity);

end //
delimiter ;

-- id: 2b
-- name: remove_flight

-- this procedure is used for an airline to cancel an existing flight if (and only if) the following conditions are met:
-- the flight must be scheduled to depart at a date in the future compared to the current_date passed in
--  when a flight is cancelled, all bookings associated with the flight should also be deleted to reflect its cancellation

drop procedure if exists remove_flight;
delimiter //
create procedure remove_flight(
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
)
sp_main:
begin
    -- todo: implement your solution here

-- check whether the flight number and airline name are equal
-- then check the dates -> terminate
    if (select flight_date
        from flight
        where i_flight_num like flight.flight_num
          and i_airline_name like flight.airline_name) < i_current_date
    then
        leave sp_main;
    end if;

    delete from book where i_flight_num like book.flight_num and i_airline_name like book.airline_name;
    delete from flight where i_flight_num like flight.flight_num and i_airline_name like flight.airline_name;

end //
delimiter ;


-- id: 3a
-- name: book_flight
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
    -- todo: implement your solution here
    if
            i_num_seats >
            ((select capacity from flight where flight_num = i_flight_num and airline_name = i_airline_name) -
             (select sum(num_seats)
              from book
              where flight_num = i_flight_num
                and airline_name = i_airline_name
                and was_cancelled = 0))
    then
        leave sp_main;
    end if;

    if
            i_current_date >=
            (select flight_date from flight where flight_num = i_flight_num and airline_name = i_airline_name)
    then
        leave sp_main;
    end if;

    if
            (select count(*)
             from book
                      join flight on book.flight_num = flight.flight_num and book.airline_name = flight.airline_name
             where i_customer_email = book.customer
               and was_cancelled = 0
               and flight.flight_date =
                   (select flight_date from flight where flight_num = i_flight_num and airline_name = i_airline_name)) >
            0
    then
        leave sp_main;
    end if;

    if
            i_flight_num in
            (select flight_num
             from book
             where i_customer_email = customer
               and i_airline_name = airline_name
               and was_cancelled = 1)
    then
        leave sp_main;
    end if;

    if
            i_flight_num in
            (select flight_num from book where i_customer_email = customer and i_airline_name = airline_name)
    then
        update book
        set num_seats = num_seats + i_num_seats
        where i_flight_num in
              (select flight_num from book where i_customer_email = customer and i_airline_name = airline_name);
    else
        insert into book (customer, flight_num, airline_name, num_seats, was_cancelled)
        values (i_customer_email, i_flight_num, i_airline_name, i_num_seats, 0);
    end if;

end //
delimiter ;

-- id: 3b
-- name: cancel_flight_booking
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
    -- todo: implement your solution here
    if
            i_current_date >=
            (select flight_date from flight where flight_num = i_flight_num)
    then
        leave sp_main;
    end if;

    if
        not i_flight_num in
            (select flight_num from book where i_customer_email = customer and i_airline_name = airline_name)
    then
        leave sp_main;
    end if;

    update book
    set was_cancelled = 1
    where customer = i_customer_email
      and flight_num = i_flight_num
      and airline_name = i_airline_name;

end //
delimiter ;


-- id: 3c
-- name: view_flight
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
-- todo: replace this select query with your solution
select flight_num,
       flight_date,
       airline_name,
       to_airport,
       cost,
       case
           when (select sum(num_seats)
                 from book
                 where was_cancelled = 0
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name) > 0
               then
               (capacity -
                (select sum(num_seats)
                 from book
                 where was_cancelled = 0
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name))
           else
               capacity
           end as num_empty_seats,
       case
           when (select count(*)
                 from book
                 where was_cancelled = 1
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name) > 0 and
                (select count(*)
                 from book
                 where was_cancelled = 0
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name) > 0
               then
                   ((select sum(num_seats)
                     from book
                     where was_cancelled = 0
                       and book.flight_num = flight.flight_num
                       and book.airline_name = flight.airline_name) * cost) +
                   ((select sum(num_seats)
                     from book
                     where was_cancelled = 1
                       and book.flight_num = flight.flight_num
                       and book.airline_name = flight.airline_name) * cost * 0.2)
           when (select count(*)
                 from book
                 where was_cancelled = 1
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name) > 0
               then
               ((select sum(num_seats)
                 from book
                 where was_cancelled = 1
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name) * cost * 0.2)
           when (select count(*)
                 from book
                 where was_cancelled = 0
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name) > 0
               then
               ((select sum(num_seats)
                 from book
                 where was_cancelled = 0s
                   and book.flight_num = flight.flight_num
                   and book.airline_name = flight.airline_name) * cost)
           else
               (select count(*)
                from book
                where was_cancelled = 0
                  and book.flight_num = flight.flight_num
                  and book.airline_name = flight.airline_name)
           end as total_spent
from flight;
# group by flight_num;

-- id: 4a
-- name: add_property
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
    -- todo: implement your solution here
    if
            (select count(*)
             from property
             where i_street = street
               and i_city = city
               and i_state = state
               and i_zip = zip) > 0
    then
        leave sp_main;
    end if;

    if
            i_property_name in
            (select property_name from property where owner_email = i_owner_email)
    then
        leave sp_main;
    end if;

    insert into property (property_name, owner_email, descr, capacity, cost, street, city, state, zip)
    values (i_property_name, i_owner_email, i_description, i_capacity, i_cost, i_street, i_city, i_state, i_zip);

    if
            i_nearest_airport_id is null or i_dist_to_airport is null or
            i_nearest_airport_id not in (select airport_id from airport)
    then
        leave sp_main;
    end if;

    insert into is_close_to (property_name, owner_email, airport, distance)
    values (i_property_name, i_owner_email, i_nearest_airport_id, i_dist_to_airport);

end //
delimiter ;


-- id: 4b
-- name: remove_property
drop procedure if exists remove_property;
delimiter //
create procedure remove_property(
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_current_date date
)
sp_main:
begin
    -- todo: implement your solution here
    if
                i_current_date >=
                (select start_date from reserve where i_property_name = property_name and i_owner_email = owner_email)
            and
                i_current_date <=
                (select end_date from reserve where i_property_name = property_name and i_owner_email = owner_email)
    then
        leave sp_main;
    end if;

    delete from is_close_to where i_property_name = property_name and i_owner_email = owner_email;
    delete from amenity where i_property_name = property_name and i_owner_email = property_owner;
    delete from review where i_property_name = property_name and i_owner_email = owner_email;
    delete from reserve where i_property_name = property_name and i_owner_email = owner_email;
    delete from property where i_property_name = property_name and i_owner_email = owner_email;

end //
delimiter ;


-- id: 5a (80)
-- name: reserve_property
/**
this procedure allows customers to reserve an available property advertised by an owner  if (and
only if) the following conditions are met:
• the combination of property_name, owner_email, and customer_email should be unique in the system
• the start date of the reservation should be in the future (use current date for comparison)
• the guest has not already reserved a property that overlaps with the dates of this reservation
• the available capacity for the property during the span of dates must be greater than or equal to i_num_guests during the span of dates provided
• note: for simplicity, the available capacity of a property over a span of time will be
defined as the capacity of the property minus the total number of guests staying at that
property during that span of time
 */
-- fixme: what about "was_cancelled" reserve?
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
#         • the combination of property_name, owner_email, and customer_email should be unique in the system
            (not exists
                (
                    select 1
                    from reserve as r
                    where r.property_name = i_property_name
                      and r.owner_email = i_owner_email
                      and r.customer = i_customer_email
                )
                )
            and
#             • the start date of the reservation should be in the future (use current date for comparison)
            (i_current_date < i_start_date)
            and
#             • the guest has not already reserved a property that overlaps with the dates of this reservation
            (not exists
                (
                    select 1
                    from reserve as r
                    where r.customer = i_customer_email
                      and (
                            r.start_date between i_start_date and i_end_date
                            or r.end_date between i_start_date and i_end_date
                            or i_start_date between r.start_date and r.end_date
                            or i_end_date between r.start_date and r.end_date
                        )
                      and r.was_cancelled = 0
                )
                )
            and
#             • the available capacity for the property during the span of dates must be greater than or equal to i_num_guests during the span of dates provided
            (
                    (
                            (
                                select capacity
                                from property p
                                where p.property_name = i_property_name
                                  and p.owner_email = i_owner_email
                            )
                            -
                            (
                                select ifnull(sum(r.num_guests), 0)
                                from reserve r
                                         left join property p
                                                   on p.property_name = r.property_name
                                where r.property_name = i_property_name
                                  and p.owner_email = i_owner_email
                                  and (
                                        r.start_date between i_start_date and i_end_date
                                        or r.end_date between i_start_date and i_end_date
                                        or i_start_date between r.start_date and r.end_date
                                        or i_end_date between r.start_date and r.end_date
                                    )
                                  and r.was_cancelled = 0
                            )
                        ) >= i_num_guests
                )
    then
        insert into reserve
        (property_name, owner_email, customer, start_date, end_date, num_guests, was_cancelled)
        values (i_property_name, i_owner_email, i_customer_email, i_start_date, i_end_date, i_num_guests, 0);
    end if;
end//
delimiter ;

/**
  texaslonghornshouse#
  mscott22@gmail.com#
  boblee15@gmail.com#
  2021-12-25#
  2021-12-26
  #4
  #0########
 */


-- id: 5b (90)
-- name: cancel_property_reservation
/**
this procedure allows a customer to cancel an existing property reservation if (and only if) the following conditions are met:
• the customer must already have reserved this property
• if the reservation is already cancelled, this procedure should do nothing
• the date of the reservation must be at a date in the future (use the current date passed in for comparison)
• to cancel a reservation, the was_cancelled attribute in the reserve table should be set to 1
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
                from reserve as r
#         • the customer must already have reserved this property
                where r.property_name = i_property_name
                  and r.owner_email = i_owner_email
                  and r.customer = i_customer_email
#         • if the reservation is already cancelled, this procedure should do nothing
                  and r.was_cancelled = 0
#         • the date of the reservation must be at a date in the future (use the current date passed in for comparison)
                  and i_current_date < r.start_date
            )
            )
    then
        update reserve as r
#         • to cancel a reservation, the was_cancelled attribute in the reserve table should be set to 1
        set r.was_cancelled = 1
#         • the customer must already have reserved this property
        where r.property_name = i_property_name
          and r.owner_email = i_owner_email
          and r.customer = i_customer_email
#         • if the reservation is already cancelled, this procedure should do nothing
          and r.was_cancelled = 0;
    end if;
end //
delimiter ;


-- id: 5c (95)
-- name: customer_review_property
/**
  this procedure allows customers to leave a review for a property at which they stayed if (and only if) the following conditions are met:
• the customer must have started a stay at this property at a date in the past that wasn’t cancelled
  (current date must be equal to or later than the start date of the reservation at this property)
• the combination of property_name, owner_email, and customer_email should be distinct in the review table
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
                    from reserve as r
#         this procedure allows customers to leave a review for a property at which they stayed
                    where r.property_name = i_property_name
                      and r.owner_email = i_owner_email
                      and r.customer = i_customer_email
#         • the customer must have started a stay at this property at a date in the past that wasn’t cancelled
#         (current date must be equal to or later than the start date of the reservation at this property)
                      and r.start_date <= i_current_date
                      and r.was_cancelled = 0
                )
                )
            and
            (not exists(
                    select 1
                    from review as r
#         • the combination of property_name, owner_email, and customer_email should be distinct in the review table
#         (a customer should not be able to review a property more than once)
                    where r.property_name = i_property_name
                      and r.owner_email = i_owner_email
                      and r.customer = i_customer_email
                )
                )
    then
        insert into review (property_name, owner_email, customer, content, score)
        values (i_property_name, i_owner_email, i_customer_email, i_content, i_score);
    end if;
end //
delimiter ;


-- id: 5d (155)
-- name: view_properties
/**
  this view displays the name, average rating score, description, concatenated address, capacity
  , and cost per night of all properties.
  note: the concatenated address should have a comma and space (‘, ‘) between each part of the address
  (ie: “blackhawks st, chicago, il, 60176”).
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
select prop.property_name                                                     as property_name
     , (
    select avg(r.score)
    from review as r
    where r.property_name = prop.property_name
    group by r.property_name
)                                                                             as average_rating_score
     , prop.descr                                                             as description
     , concat(prop.street, ', ', prop.city, ', ', prop.state, ', ', prop.zip) as address
     , prop.capacity                                                          as capacity
     , prop.cost                                                              as cost_per_night
from property as prop
;

-- id: 5e (161)
-- name: view_individual_property_reservations
/**
  this procedure creates a table that displays a single property’s reservations such as the name, start date, end date, customer email, customer phone number, the total cost of the booking, the property rating score from the customer if it exists (null if it doesn’t exist), and the property review from the customer if it exists (null if it doesn’t exist), if (and only if) the following conditions are met:
• the property name and owner email must exist in the system. if they do not exist in the system, a table should be created with no entries.
• for calculating total cost, include the start and end date in the number of days. the cost of a single reservation should be number of days * property cost, and if the reservation is cancelled only take 20% of this calculation.
• note: within this procedure we will create a table titled: “view_individual_property_reservations” that will display the data mentioned above.
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
    select r.property_name as property_name
         , r.start_date    as start_date
         , r.end_date      as end_date
         , c.email         as customer_email
         , c.phone_number  as customer_phone_num
         , cast(
                p.cost * (datediff(r.end_date, r.start_date) + 1)
                * if(was_cancelled = 1, 1.2, 1.0)
        as decimal(6, 2))  as total_booking_cost
         , rv.score        as rating_score
         , rv.content      as review
    from reserve as r
             left join property p
                       on p.property_name = r.property_name
                           and p.owner_email = r.owner_email
             left join clients c
                       on r.customer = c.email
             left join review rv
                       on rv.property_name = r.property_name
                           and rv.owner_email = r.owner_email
                           and rv.customer = c.email
    where r.property_name = i_property_name
      and r.owner_email = i_owner_email;
end //
delimiter ;


-- id: 6a
-- name: customer_rates_owner
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
    -- todo: implement your solution here
    -- first, make sure accounts are in database
    if i_customer_email not in (select email from customer)
    then
        leave sp_main;
    end if;

    if i_owner_email not in (select email from owners)
    then
        leave sp_main;
    end if;

    -- make sure customer and owner combo isn't already in customer_rates_owner
    if (select count(*)
        from customers_rate_owners
        where customer = i_customer_email
          and owner_email = i_owner_email) > 0
    then
        leave sp_main;
    end if;

    -- make sure the customer has stayed at a property owned by the owner and did not cancel
    if (select count(*)
        from reserve
        where customer = i_customer_email
          and owner_email = i_owner_email
          and start_date <= i_current_date
          and was_cancelled = 0) = 0
    then
        leave sp_main;
    end if;

    -- finally, add the rating to customer_rates_owner
    insert into customers_rate_owners
    values (i_customer_email, i_owner_email, i_score);
end //
delimiter ;


-- id: 6b
-- name: owner_rates_customer
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
    -- todo: implement your solution here
    -- first, make sure accounts are in database
    if i_owner_email not in (select email from owners)
    then
        leave sp_main;
    end if;

    if i_customer_email not in (select email from customer)
    then
        leave sp_main;
    end if;

    -- make sure customer and owner combo isn't already in owners_rate_customers
    if (select count(*)
        from owners_rate_customers
        where customer = i_customer_email
          and owner_email = i_owner_email) > 0
    then
        leave sp_main;
    end if;

    -- make sure the customer has stayed at a property owned by the owner and did not cancel
    if (select count(*)
        from reserve
        where owner_email = i_owner_email
          and customer = i_customer_email
          and start_date <= i_current_date
          and was_cancelled = 0) = 0
    then
        leave sp_main;
    end if;

    -- finally, add the rating to owners_rate_customers
    insert into owners_rate_customers
    values (i_owner_email, i_customer_email, i_score);
end //
delimiter ;


-- id: 7a
-- name: view_airports
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
    -- todo: replace this select query with your solution
select airport_id,
       airport_name,
       time_zone,
       total_arriving_flights,
       total_departing_flights,
       avg_departing_flight_cost
from (
      (select airport_id,
              airport_name,
              time_zone,
              count(distinct flight_num) as total_departing_flights,
              avg(cost)                  as avg_departing_flight_cost
       from airport
                left outer join flight
                                on airport_id = from_airport
       group by airport_id) as temp_departure
         natural join
     (select airport_id, count(distinct flight_num) as total_arriving_flights
      from airport
               left outer join flight
                               on airport_id = to_airport
      group by airport_id) as temp_a);

-- id: 7b
-- name: view_airlines
create or replace view view_airlines
            (
             airline_name,
             rating,
             total_flights,
             min_flight_cost
                )
as
    -- todo: replace this select query with your solution
select airline_name, rating, count(*) as total_flights, min(cost) as min_flight_cost
from airline
         natural join flight
group by airline_name;


-- id: 8a
-- name: view_customers
create or replace view view_customers
            (
             customer_name,
             avg_rating,
             location,
             is_owner,
             total_seats_purchased
                )
as
    -- todo: replace this select query with your solution
    -- view customers
select customer_name,
       ifnull(avg_rating, 0),
       location,
       count(distinct email) as is_owner,
       total_seats_purchased
from (select customer_name,
             email                     as client_email,
             avg_rating,
             location,
             ifnull(sum(num_seats), 0) as total_seats_purchased
      from (select concat(first_name, ' ', last_name) as customer_name,
                   email,
                   avg(score)                         as avg_rating,
                   location
            from (select *
                  from customer
                           natural join accounts) as temp_account_info
                     left outer join owners_rate_customers
                                     on email = customer
            group by email) as temp_ratings
               left outer join book on email = customer
      group by email) as temp_seats
         left outer join owners on email = client_email
group by client_email;


-- id: 8b
-- name: view_owners
create or replace view view_owners
            (
             owner_name,
             avg_rating,
             num_properties_owned,
             avg_property_rating
                )
as
    -- todo: replace this select query with your solution
select owner_name,
       avg_rating,
       count(distinct street, city, state, zip) as num_properties_owned,
       avg_property_rating
from (select owner_name, email, avg_rating, avg(score) as avg_property_rating
      from (select owner_name, email, avg_rating
            from (select concat(first_name, ' ', last_name) as owner_name, email
                  from owners
                           natural join accounts) as temp_info
                     left outer join
                 (select owner_email, avg(score) as avg_rating
                  from customers_rate_owners
                  group by owner_email) as temp_ratings
                 on email = owner_email
            group by email) as temp_name_rating
               left outer join review
                               on email = owner_email
      group by email) as temp_prop_rating
         left outer join property on email = owner_email
group by email;


-- id: 9a (125)
-- name: process_date
/**
  this procedure updates the database based on the current date by updating all customers’ locations
  who are taking a flight on that date to the state of their destination airport
  if (and only if) the following conditions are met:
• if a user cancels their flight for that date, their location should not be updated
• note: a customer should not have more than one non-cancelled flight in a single day
 */
drop procedure if exists process_date;
delimiter //
create procedure process_date(
    in i_current_date date
)
sp_main:
begin
    update customer c
        left join book b
        on c.email = b.customer
        left join flight f
        on b.flight_num = f.flight_num
        left join airport a
        on f.to_airport = a.airport_id
    set c.location = a.state
    where b.was_cancelled = 0
      and f.flight_date = i_current_date;
end //
delimiter ;