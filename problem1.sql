DROP DATABASE IF EXISTS FinanceDB;

CREATE DATABASE FinanceDB;

use FinanceDB;

CREATE TABLE FiscalYearTable(
id int AUTO_INCREMENT,
fiscal_year varchar(30) NOT NULL,
start_date Date NOT NULL,
end_date DATE NOT NULL,
PRIMARY KEY(id));


DELIMITER $$
$$
CREATE DEFINER=`root`@`localhost` TRIGGER fiscalyearinsert
BEFORE INSERT
ON FiscalYearTable FOR EACH ROW
BEGIN
          IF NEW.start_date >= NEW.end_date
          THEN
               SIGNAL SQLSTATE '45000'
               SET MESSAGE_TEXT = 'Start date must be less than the end date';

         ELSEIF FLOOR(DATEDIFF(NEW.end_date ,NEW.start_date)/30)!=12
         THEN
               SIGNAL SQLSTATE '45000'
               SET MESSAGE_TEXT = 'The difference between start date and end date must be one year';

    	END IF;

              END$$
DELIMITER ;


DELIMITER $$
$$
CREATE TRIGGER fiscalyearupdate
BEFORE UPDATE
ON FiscalYearTable FOR EACH ROW
BEGIN
          IF NEW.start_date >= NEW.end_date
          THEN
               SIGNAL SQLSTATE '45000'
               SET MESSAGE_TEXT = 'Start date must be less than the end date';
          
         ELSEIF FLOOR(DATEDIFF(NEW.end_date ,NEW.start_date)/30)!=12
         THEN
               SIGNAL SQLSTATE '45000'
               SET MESSAGE_TEXT = 'The difference between them must be one year';

    		END IF;
              END$$
DELIMITER ;
