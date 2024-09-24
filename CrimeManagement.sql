use CrimeManagement;

CREATE TABLE Crime (
 CrimeID INT PRIMARY KEY,
 IncidentType VARCHAR(255),
 IncidentDate DATE,
 Location VARCHAR(255),
 Description TEXT,
 Status VARCHAR(255)
);

CREATE TABLE Victim (
 VictimID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 ContactInfo VARCHAR(255),
 Injuries VARCHAR(255),
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

CREATE TABLE Suspect (
 SuspectID INT PRIMARY KEY,
 CrimeID INT,
 Name VARCHAR(255),
 Description TEXT,
 CriminalHistory TEXT,
 FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- Insert sample data
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
 (1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
 (2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under 
Investigation'),
 (3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed');

INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries)
VALUES
 (1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
 (2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
 (3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None');
INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory)
VALUES
 (1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
 (2, 2, 'Unknown', 'Investigation ongoing', NULL),
 (3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests');
 
alter table Victim add Age int;
update Victim set Age=51 where Name='John Doe';
update Victim set Age=30 where Name='Jane Smith';

alter table Suspect add Age int;
update Suspect set Age=47 where Name='Robber 1';
update Suspect set Age=31 where Name='Unknown';
update Suspect set Age=33 where Name='Suspect 1';


/* 1.Select all open incidents.*/
select * from Crime where status='open';

/* 2.Find the total number of incidents.*/
select count(CrimeID) as no_of_incidents from Crime; 

/* 3.List all unique incident types.*/
select distinct IncidentType from Crime;

/* 4.Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'.*/
select * from Crime where IncidentDate between '2023-09-01' and '2023-09-10';

/* 5.List persons involved in incidents in descending order of age.*/
select Name,Age
from Suspect
order by Age desc;

/* 6.Find the average age of persons involved in incidents.*/
select avg(Victim.Age) as Victims_avg_age, avg(Suspect.Age) Suspects_avg_age
from Victim 
join Suspect on Victim.CrimeID=Suspect.CrimeID;

/* 7.List incident types and their counts, only for open cases.*/
select IncidentType, count(IncidentType) as No_of_cases 
from Crime
where Status='Open' group by IncidentType;

/* 8.Find persons with names containing 'Doe'.*/
select Victim.Name
from Victim 
where Victim.Name like '%Doe';

/* 9.Retrieve the names of persons involved in open cases and closed cases.*/
select Victim.Name,Suspect.Name,Status from Crime
join Victim on Crime.CrimeID=Victim.CrimeID
join Suspect on Crime.CrimeID=Suspect.CrimeID
where Status='Open' or Status='closed';

/* 10.List incident types where there are persons aged 30 or 35 involved.*/
select IncidentType ,Victim.Age as Victim_age
from Crime
join Victim on Crime.CrimeID=Victim.CrimeID
where Victim.Age between 30 and 35 ;

/* 11.Find persons involved in incidents of the same type as 'Robbery'.*/
select Suspect.Name from Crime
join Suspect on Crime.CrimeID=Suspect.CrimeID
where IncidentType='Robbery'; 

/* 12.List incident types with more than one open case.*/
select IncidentType,count(*) as Open_cases
from Crime 
where Status='Open'
group by IncidentType
having count(*) > 1;

/* 13.List all incidents with suspects whose names also appear as victims in other incidents.*/
select c.*,
s.Name as SuspectName, v.Name as VictimName
from Crime c
full outer JOIN Suspect s ON c.CrimeID = s.CrimeID
full outer JOIN Victim v ON s.Name = v.Name
WHERE v.CrimeID <> c.CrimeID; 

/* 14.Retrieve all incidents along with victim and suspect details.*/
select Crime.*,Victim.*,Suspect.*
from Crime
join Victim on Crime.CrimeID=Victim.CrimeID
join Suspect on Crime.CrimeID=Suspect.CrimeID;

/* 15.Find incidents where the suspect is older than any victim.*/
select Crime.*,s.suspectID,s.name,s.age
from Crime 
JOIN Suspect s ON Crime.CrimeID = s.CrimeID
where s.age > ALL (select v.age from Victim v
where v.CrimeID = Crime.CrimeID);

/* 16.Find suspects involved in multiple incidents:*/
select s.Name, count(s.CrimeID) as No_of_incidents
from Suspect s
group by s.Name
having count(s.CrimeID) > 1;

/* 17.List incidents with no suspects involved.*/
select * from Crime 
join Suspect on Crime.CrimeID=Suspect.CrimeID
where Suspect.Name is null;

/* 18.List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 
'Robbery'.*/
select  Crime.*
from Crime
where IncidentType = 'Homicide'and CrimeID NOT IN (select CrimeID
from Crime
where IncidentType <> 'Robbery' and IncidentType <> 'Homicide');

/* 19.Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 
'No Suspect' if there are none.*/
select c.CrimeID, c.IncidentType, c.IncidentDate, c.Location, s.Name as SuspectName
from Crime c
join Suspect s on c.CrimeID = s.CrimeID
union
select c.CrimeID, c.IncidentType, c.IncidentDate, c.Location, 'No Suspect' as SuspectName
from Crime c
where NOT EXISTS (select 1 from Suspect s where s.CrimeID = c.CrimeID);

/* 20.List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault*/
select s.Name, c.IncidentType
from Suspect s
join (select CrimeID, IncidentType
from Crime
where IncidentType IN ('Robbery', 'Assault')) c on s.CrimeID = c.CrimeID;

