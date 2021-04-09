/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * FROM Facilities
WHERE membercost != 0;


/* Q2: How many facilities do not charge a fee to members? */
SELECT * FROM Facilities
WHERE membercost = 0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance 
FROM  Facilities
WHERE membercost < monthlymaintenance * 0.2;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * 
FROM Facilities
WHERE facid IN (1, 5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance < 100 THEN 'cheap'
	 WHEN monthlymaintenance > 100 THEN 'expensive'
	 END AS list_of_facilities
FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM Members
ORDER BY joindate DESC;


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT f.name as court_name, CONCAT(m.firstname, ' ', m.surname) AS member_name
FROM Facilities f JOIN Bookings b ON f.facid = b.facid 
JOIN Members m ON b.memid = m.memid
WHERE f.name = "Table Tennis"
ORDER BY member_name;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name AS facility_name, CONCAT(m.firstname, ' ', m.surname ) AS member_name, f.membercost AS member_cost
FROM Facilities f JOIN Bookings b ON f.facid = b.facid 
JOIN Members m ON b.memid = m.memid
WHERE (b.starttime BETWEEN '2012-09-14 00:00:00'AND '2012-09-14 23:59:59') AND (f.membercost > 30 OR f.guestcost > 30)
ORDER BY member_cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT name, CONCAT(firstname, ' ', surname ) AS member_name, membercost
FROM 
(
    SELECT f.name, m.firstname, m.surname, f.membercost 
      FROM Facilities f JOIN Bookings b using (facid) 
                        JOIN Members m using (memid)
      WHERE (b.starttime BETWEEN '2012-09-14 00:00:00'AND '2012-09-14 23:59:59') AND (f.guestcost > 30 OR f.membercost > 30)
      ) AS subquery
ORDER BY membercost DESC;


/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
q10_df = pd.read_sql_query('SELECT name, subquery.revenue AS revenue \
                            FROM ( \
                                  SELECT f.name, SUM(CASE WHEN b.memid = 0 \
                                                          THEN b.slots * f.guestcost \
                                                          ELSE b.slots * f.membercost \
                                                     END) AS revenue \
                                  FROM Bookings b JOIN Facilities f USING (facid) \
                                  GROUP BY f.name) AS subquery \
                            WHERE revenue < 1000 \
                            ORDER BY revenue;', engine)
q10_df


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
q11_df = pd.read_sql_query('SELECT m.surname AS member_surname, m.firstname AS member_firstname, \
                            m.recommendedby AS recommender_id, r.surname AS recommender_surname, \
                            r.firstname AS recommender_firstname \
                            FROM Members AS m JOIN Members AS r ON m.recommendedby = r.memid \
                            WHERE recommender_surname IS NOT NULL AND recommender_firstname IS NOT NULL \
                            ORDER BY recommender_surname, recommender_firstname;', engine)
q11_df


/* Q12: Find the facilities with their usage by member, but not guests */
q12_df = pd.read_sql_query('SELECT sub.facid, f.name, COUNT(sub.memid) AS member_usage \
                            FROM ( \
                                   SELECT facid, memid \
                                   FROM Bookings \
                                   WHERE memid !=0 ) AS sub \
                            JOIN Facilities f ON sub.facid = f.facid \
                            GROUP BY sub.facid;', engine)
q12_df


/* Q13: Find the facilities usage by month, but not guests */
q13_df = pd.read_sql_query('SELECT strftime("%m", starttime) AS month, COUNT(memid) AS member_usage \
                            FROM Bookings \
                            WHERE memid != 0 \
                            GROUP BY month;', engine)
q13_df