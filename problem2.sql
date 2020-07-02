DROP DATABASE IF EXISTS HospitalRecords;

CREATE DATABASE HospitalRecords;

use HospitalRecords;

CREATE TABLE Procedures(
proc_id int,
anest_name varchar(30) NOT NULL,
start_time TIME NOT NULL,
end_time TIME NOT NULL,
PRIMARY KEY(proc_id));


DELIMITER $$
$$
CREATE TRIGGER ProceduresInsert
BEFORE INSERT
ON Procedures FOR EACH ROW
BEGIN
          IF NEW.start_time >= NEW.end_time
          THEN
               SIGNAL SQLSTATE '45000'
               SET MESSAGE_TEXT = 'Start time must be less than the end time';

    	END IF;

              END$$
DELIMITER ;


DELIMITER $$
$$
CREATE TRIGGER ProceduresUpdate
BEFORE UPDATE
ON Procedures FOR EACH ROW
BEGIN
          IF NEW.start_time >= NEW.end_time
          THEN
               SIGNAL SQLSTATE '45000'
               SET MESSAGE_TEXT = 'Start date must be less than the end date';

    		END IF;
              END$$
DELIMITER ;



--query to search (only for overlapped procedures)
--in this query we are getting the overlapped procedures
select *
from Procedures as P, Procedures as C
where P.anest_name = C.anest_name and (P.end_time <= C.end_time or P.start_time >= C.start_time) and 
P.start_time < C.end_time
--another query to search


select stats.p_id, max(c)

from

	(select p.proc_id as p_id, start_p.proc_id start_p_id, count(containing_start_p.proc_id) c

	from Procedures p

	join Procedures start_p on

		start_p.anest_name  = p.anest_name and

		start_p.start_time >= p.start_time and start_p.start_time < p.end_time

	join Procedures containing_start_p on

		containing_start_p.anest_name = start_p.anest_name and

		start_p.start_time >= containing_start_p.start_time and start_p.start_time < containing_start_p.end_time

	group by p.proc_id, start_p.proc_id) stats

group by stats.p_id;
​

​

​

​

--another query to search

select q.id, q.anest_name, q.start_time, q.end_time, max(other_procedure.start_time_intersections)

from Procedures q

join ( -- join with the table of statistics of starting time, for procedures that start within my (q) intervale

	select

		p.*,

		(select count(1) from Procedures other

		where

			p.start_time >= other.start_time and p.start_time < other.end_time and

			p.anest_name = other.anest_name

		) as start_time_intersections

	from Procedures p

) other_procedure on

	other_procedure.anest_name = q.anest_name and

	other_procedure.start_time >= q.start_time and other_procedure.start_time < q.end_time

group by q.id, q.anest_name, q.start_time, q.end_time

​

-- another query to search

​

select *

from Procedures q

join ( -- join with the table of statistics of starting time, for procedures that start within my (q) intervale

	select

		p.*,

		(select count(1) from Procedures other

		where

			p.start_time >= other.start_time and p.start_time < other.end_time and

			p.anest_name = other.anest_name

		) as start_time_intersections

	from Procedures p

) other_procedure on

	other_procedure.anest_name = q.anest_name and

	other_procedure.start_time >= q.start_time and other_procedure.start_time < q.end_time

