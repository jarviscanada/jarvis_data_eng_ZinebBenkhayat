# Introduction

# SQL Queries

###### Table Setup (DDL)

```sql
CREATE TABLE cd.facilities (
                            fac_id INTEGER,
                            name VARCHAR(100) NOT NULL,
                            member_cost NUMERIC NOT NULL,
                            guest_cost NUMERIC NOT NULL,
                            initial_outlay NUMERIC NOT NULL,
                            monthly_maintenance NUMERIC NOT NULL,
                            PRIMARY KEY (fac_id)
);
CREATE TABLE cd.members (
                         mem_id INTEGER,
                         surname VARCHAR(200) NOT NULL,
                         firstname VARCHAR(200) NOT NULL,
                         address VARCHAR(300) NOT NULL,
                         zipcode INTEGER NOT NULL,
                         telephone VARCHAR(20) NOT NULL,
                         join_date TIMESTAMP NOT NULL,
                         recommended_by INTEGER,
                         FOREIGN KEY (recommended_by) REFERENCES cd.members(mem_id),
                         PRIMARY KEY (mem_id)
);
CREATE TABLE  cd.bookings (
                          book_id INTEGER,
                          fac_id INTEGER NOT NULL,
                          mem_id INTEGER NOT NULL,
                          start_time TIMESTAMP NOT NULL,
                          slots INTEGER NOT NULL,
                          PRIMARY KEY (book_id),
                          FOREIGN KEY (fac_id) REFERENCES cd.facilities(fac_id) ON DELETE CASCADE,
                          FOREIGN KEY (mem_id) REFERENCES cd.members(mem_id) ON DELETE CASCADE
);

```

###### Question 1: The club is adding a new facility - a spa. We need to add it into the facilities table. 

```sql
insert into cd.facilities (
    facid, name, membercost, guestcost,
    initialoutlay, monthlymaintenance
)
values
    (9, 'Spa', 20, 30, 100000, 800);

```

###### Question 2: Let's try adding the spa to the facilities table again. This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant

```sql
insert into cd.facilities (
    facid, name, membercost, guestcost,
    initialoutlay, monthlymaintenance
)
select
    (
        select
            max(facid)
        from
            cd.facilities
    )+ 1,
    'Spa',
    20,
    30,
    100000,
    800;

```
###### Question 3: We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000: you need to alter the data to fix the error.

```sql
UPDATE
    cd.facilities
SET
    initialoutlay = 10000
WHERE
    facid = 1;

```

###### Question 4: We want to alter the price of the second tennis court so that it costs 10% more than the first one.
```sql
update
    cd.facilities facs
set
    membercost = (
        select
            membercost * 1.1
        from
            cd.facilities
        where
            facid = 0
    ),
    guestcost = (
        select
            guestcost * 1.1
        from
            cd.facilities
        where
            facid = 0
    )
where
    facs.facid = 1;


```
###### Question 5: As part of a clearout of our database, we want to delete all bookings from the cd.bookings table
```sql
delete from
    cd.bookings;

```
###### Question 6: How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost
```sql
select
    facid,
    name,
    membercost,
    monthlymaintenance
from
    cd.facilities
where
    membercost > 0
  and (
    membercost < monthlymaintenance / 50.0
    );

```

###### Question 7: How can you produce a list of all facilities with the word 'Tennis' in their name?
```sql
select
    *
from
    cd.facilities
where
    name LIKE '%Tennis%'

```
###### Question 8: How can you retrieve the details of facilities with ID 1 and 5?
```sql
select
    *
from
    cd.facilities
where
    facid in (1, 5)


```
###### Question 9: How can you produce a list of members who joined after the start of September 2012
```sql
select
    memid,
    surname,
    firstname,
    joindate
FROM
    cd.members
WHERE
    joindate > '2012-09-01';

```
###### Question 10:  want a combined list of all surnames and all facility names.
```sql
FROM 
  cd.members 
UNION
SELECT
    name
FROM
    cd.facilities;

```

###### Question 11:  How can you produce a list of the start times for bookings by members named 'David Farrell
```sql
SELECT
    starttime
from
    cd.bookings
        JOIN cd.members on cd.members.memid = cd.bookings.memid
WHERE
    cd.members.firstname = 'David'
  and cd.members.surname = 'Farrell';

```
###### Question 12:  How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
```sql
SELECT
    starttime,
    name
FROM
    cd.bookings
        JOIN cd.facilities ON cd.bookings.facid = cd.facilities.facid
WHERE
    name LIKE '%Tennis Court%'
  AND starttime >= '2012-09-21'
  and starttime < '2012-09-22'
order by
    starttime;

```
###### Question 13: How can you output a list of all members, including the individual who recommended them (if any)
```sql
SELECT
    m1.firstname as memfname,
    m1.surname as memsname,
    m2.firstname as recfname,
    m2.surname as recsname
FROM
    cd.members as m1
        left outer join cd.members as m2 ON m2.memid = m1.recommendedby
order by
    memsname,
    memfname;

```
###### Question 14: How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
```sql
SELECT
    m1.firstname as memfname,
    m1.surname as memsname,
    m2.firstname as recfname,
    m2.surname as recsname
FROM
    cd.members as m1
        left outer join cd.members as m2 ON m2.memid = m1.recommendedby
order by
    memsname,
    memfname;

```

###### Question 15: How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
```sql
SELECT
    DISTINCT m2.firstname,
             m2.surname
FROM
    cd.members as m1
        inner join cd.members as m2 ON m2.memid = m1.recommendedby
order by
    surname,
    firstname;

```

###### Question 16: How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
```sql
SELECT
    distinct CONCAT(m1.firstname, ' ', m1.surname) as Member,
             (
                 SELECT
                     distinct CONCAT(m2.firstname, ' ', m2.surname)
                 FROM
                     cd.members as m2
                 WHERE
                     memid = m1.recommendedby
             ) AS reommender
FROM
    cd.members AS m1
order by
    member;

```

###### Question 17: Produce a count of the number of recommendations each member has made. Order by member ID.
```sql
SELECT
    recommendedby,
    COUNT(*)
FROM
    cd.members
where
    recommendedby is not null
group by
    recommendedby
ORDER BY
    recommendedby;

```

###### Question 18: Produce a list of the total number of slots booked per facility. For now, just produce an output table consisting of facility id and slots, sorted by facility id.
```sql
SELECT
    facid,
    sum(slots) as "Total Slots"
FROM
    cd.bookings
group by
    facid
ORDER BY
    facid;

```
###### Question 19: Produce a list of the total number of slots booked per facility in the month of September 2012. Produce an output table consisting of facility id and slots, sorted by the number of slots.
```sql
select
    facid,
    sum(slots) as "Total Slots"
from
    cd.bookings
where
    starttime >= '2012-09-01'
  and starttime < '2012-10-01'
group by
    facid
order by
    sum(slots);

```
###### Question 20: Produce a list of the total number of slots booked per facility per month in the year of 2012. Produce an output table consisting of facility id and slots, sorted by the id and month.
```sql
select
    facid,
    extract(
            month
            from
            starttime
    ) as month, 
  sum(slots) as "Total Slots"
from
    cd.bookings
where
    extract(
    year
    from
    starttime
    ) = 2012
group by
    facid,
    month
order by
    facid,
    month;

```
###### Question 21: Find the total number of members (including guests) who have made at least one booking.
```sql
SELECT
    count(DISTINCT memid)
FROM
    cd.bookings;

```
###### Question 22: Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
```sql
select
    mems.surname,
    mems.firstname,
    mems.memid,
    min(bks.starttime) as starttime
from
    cd.bookings bks
        inner join cd.members mems on mems.memid = bks.memid
where
    starttime >= '2012-09-01'
group by
    mems.surname,
    mems.firstname,
    mems.memid
order by
    mems.memid;

```

###### Question 23: Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.
```sql
select
    count(*) over(),
    firstname,
    surname
from
    cd.members
order by
    joindate

```

###### Question 24: Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.
```sql
SELECT
    ROW_NUMBER() OVER (
    ORDER BY 
      memid
  ) AS row_num,
    firstname,
    surname
FROM
    cd.members
ORDER BY
    joindate;

```

###### Question 25: Output the facility id that has the highest number of slots booked. Ensure that in the event of a tie, all tieing results get output.
```sql
select
    facid,
    total
from
    (
        select
            facid,
            sum(slots) total,
            rank() over (
        order by 
          sum(slots) desc
      ) rank
        from
            cd.bookings
        group by
            facid
    ) as ranked
where
    rank = 1

```

###### Question 26: Output the names of all members, formatted as 'Surname, Firstname'
```sql
select 
  surname || ', ' || firstname as name 
from 
  cd.members

```

###### Question 27: You've noticed that the club's member table has telephone numbers with very inconsistent formatting. You'd like to find all the telephone numbers that contain parentheses, returning the member ID and telephone number sorted by member ID.
```sql
select
    memid,
    telephone
from
    cd.members
where
    telephone ~ '[()]';

```

###### Question 28: You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet. Sort by the letter, and don't worry about printing out a letter if the count is 0.
```sql
select
    substr (mems.surname, 1, 1) as letter,
    count(*) as count
from
    cd.members mems
group by
    letter
order by
    lette

```


