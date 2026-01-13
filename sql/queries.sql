-- Question 1
insert into cd.facilities (
    facid, name, membercost, guestcost,
    initialoutlay, monthlymaintenance
)
values
    (9, 'Spa', 20, 30, 100000, 800);


-- Question 2
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

-- Question 3
UPDATE
    cd.facilities
SET
    initialoutlay = 10000
WHERE
    facid = 1;

-- Question 3
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

-- Question 4
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

-- Question 5
delete from
    cd.bookings;

-- Question 6
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

-- Question 7
select
    *
from
    cd.facilities
where
    name LIKE '%Tennis%'

-- Question 8
select
    *
from
    cd.facilities
where
    facid in (1, 5)

-- Question 9
select
    memid,
    surname,
    firstname,
    joindate
FROM
    cd.members
WHERE
    joindate > '2012-09-01';

-- Question 10
FROM
  cd.members
UNION
SELECT
    name
FROM
    cd.facilities;

-- Question 11
SELECT
    starttime
from
    cd.bookings
        JOIN cd.members on cd.members.memid = cd.bookings.memid
WHERE
    cd.members.firstname = 'David'
  and cd.members.surname = 'Farrell';

-- Question 12
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

-- Question 13
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

-- Question 14
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

-- Question 15
SELECT DISTINCT
    m2.firstname ,
    m2.surname
FROM
    cd.members as m1
        inner join cd.members as m2 ON m2.memid = m1.recommendedby
order by surname, firstname;

-- Question 16
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

-- Question 17
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

-- Question 18
SELECT
    facid,
    sum(slots) as "Total Slots"
FROM
    cd.bookings
group by
    facid
ORDER BY
    facid;

-- Question 19
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

-- Question 20
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

-- Question 21
SELECT
    count(DISTINCT memid)
FROM
    cd.bookings;

-- Question 22
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

-- Question 23
select
    count(*) over(),
    firstname,
    surname
from
    cd.members
order by
    joindate

-- Question 24
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

-- Question 25
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

-- Question 26
select
    surname || ', ' || firstname as name
from
    cd.members

-- Question 27
select
    memid,
    telephone
from
    cd.members
where
    telephone ~ '[()]';

-- Question 28
select
    substr (mems.surname, 1, 1) as letter,
    count(*) as count
from
    cd.members mems
group by
    letter
order by
    lette
