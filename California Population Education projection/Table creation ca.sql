CREATE TABLE ca_edu(
	date_year TEXT,
    age TEXT,
    gender VARCHAR(6),
    edu_attainment TEXT,
    income TEXT,
    population INT
);

COPY ca_edu
FROM 'C:\Users\cvyas\Downloads\cleaned_CA_Educational_Attainment___Personal_Income_2008-2014.csv'
WITH CSV HEADER DELIMITER ',' QUOTE '"';