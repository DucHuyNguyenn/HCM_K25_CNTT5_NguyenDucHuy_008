CREATE DATABASE soccer_player_management;

USE soccer_player_management;


-- tạo bảng team bong đá
CREATE TABLE  teams(
	team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL UNIQUE,
    founded_year YEAR NOT NULL ,
    stadium VARCHAR(100) NOT NULL UNIQUE,
    ranking_postison INT DEFAULT 0
);

-- tạo bảng huấn luyện viên 

CREATE TABLE coaches(
	coach_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL UNIQUE,
    nationality VARCHAR(50) NOT NULL,
    experience_year INT DEFAULT 0,
    team_id INT ,
    CONSTRAINT fk_team_id FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- tạo bảng player 

CREATE TABLE players(
	player_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL UNIQUE,
    jersey_number INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(12,2) NOT NULL,
    team_id INT NOT NULL,
    CONSTRAINT fk_team_id_player FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- tạo bảng trận đấu

CREATE TABLE matches(
	match_id INT PRIMARY KEY AUTO_INCREMENT,
    home_team_id INT,
    away_team_id INT,
    match_date DATETIME NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    match_status VARCHAR(30) DEFAULT 'Scheduled'
);

-- tạo bảng thông số 

CREATE TABLE player_statics(
	stat_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    match_id INT,
    goals INT DEFAULT 0,
    assits INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    rating_score DECIMAL(3,1) DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

-- phần 2 DML 
-- insert dữ liệu 

-- bảng đội bóng(teams)
INSERT INTO teams(team_name,founded_year,stadium,ranking_postison)
VALUES
('Manchester City',1901,'Etihad Stadium' ,1),
('Real Madrid',1902,'Santiago Bernabeu',2),
('Hanoi FC',2006,'Hang Day Stadium',3),
('Saigon United',2015,'Thong Nhat Stadium',5),
('Thép Xanh Nam Định',1979,'Thiên Trường Stadium',10);


-- bảng huấn luyện viên(coaches)

INSERT INTO coaches(full_name,nationality,experience_year,team_id)
VALUES
('Pep Guardiola','Spanish',15,1),
('Carlo Anceloti','Italian',25,2),
('Chu Đình Nghiêm','Vietnamese',12,3),
('Alexander Polking','German-Brazilian',10,4),
('Park-Hang-Seo','Korean',30,5);

-- bảng player

INSERT INTO players(full_name,jersey_number,position,salary,team_id)
VALUES
('Erling Haaland',9,'Forward',450000000,1),
('Kevin De Bruyne',17,'Midfield',400000000,1),
('Nguyễn Quang Hải',19,'Midfield',60000000,3),
('Kylian Mbappe',7,'Forward',500000000,2),
('Nguyễn Văn Quyết',10,'Forward',55000000,3);

-- bảng matches 
INSERT INTO matches(home_team_id,away_team_id,match_date,stadium,match_status)
VALUES
(1,2,'2026-05-10 19:00:00','Etihad Stadium','Finished'),
(3,4,'2026-05-12 18:30:00','Hang Day Stadium','Finished'),
(5,1,'2026-05-15 20:00:00','Thiên Trường Stadium','Scheduled'),
(2,3,'2026-05-20 21:00:00','Santiago Bernabeu','Scheduled'),
(4,5,'2026-05-25 17:00:00','Thong Nhat Stadium','Scheduled');

-- bảng chấm điểm cầu thủalter
INSERT INTO player_statics(player_id,match_id,goals,assits,yellow_cards,rating_score)
VALUES
(1,1,2,1,0,9.5),
(4,1,1,0,1,8.2),
(3,2,0,2,0,8.5),
(5,2,3,0,0,9.0),
(1,4,0,0,3,5.0);


-- CÂU 2 UPDATE VÀ DELETE 

-- lệnh tăng lương 15% cho tất cả các cầu thủ
UPDATE players p 
SET salary = salary * 1.15
WHERE 

-- cậu lệnh xóa các bản ghi có lớn hơn 2 thẻ vàng 
DELETE FROM player_statics
WHERE yellow_cards > 2;

-- Phần 3 Truy vấn cơ bản
-- câu 1
SELECT p.full_name,p.jersey_number,p.position
FROM players p
WHERE p.position = 'Midfield' and salary > 50000000;
-- câu 2

SELECT team_name,stadium
FROM teams
WHERE stadium LIKE 'S%';

-- câu 3
SELECT match_id,stadium,match_date
FROM matches
ORDER BY match_date DESC 
LIMIT 3 OFFSET 2;


-- Phần 4 Truy vấn nâng cao
-- câu 1
SELECT p.full_name,t.team_name,ps.goals,ps.assits
FROM teams t
JOIN players p
ON t.team_id = p.player_id
JOIN player_statics ps
ON p.player_id = ps.player_id;

-- câu 2
SELECT t.team_name ,COUNT(ps.goals) AS total_team_goals
FROM teams t
JOIN players p 
ON p.team_id = t.team_id
JOIN player_statics ps
ON ps.player_id = p.player_id 
GROUP BY t.team_id
HAVING COUNT(ps.goals) >10;

-- câu 3
SELECT player_id,full_name,salary
FROM players
WHERE salary = (SELECT MAX(SALARY) FROM players);

-- Phần 5 INDEX VÀ VIEW
-- câu 1
CREATE INDEX indx_pos_sal ON players(position,salary);

-- câu 2
CREATE VIEW vw_team AS
SELECT t.team_name,COUNT(p.player_id),SUM(p.salary)
FROM teams t
LEFT JOIN players p
ON p.team_id = t.team_id
GROUP BY t.team_id;
SELECT * FROM vw_team;

-- Phần 6 
-- câu 1
DELIMITER $$
CREATE TRIGGER promote_slary
AFTER UPDATE 
ON player_statics 
FOR EACH ROW
BEGIN 
	IF(NEW.goals > 10) THEN
		UPDATE players 
        SET salary = salary*1.05
        WHERE player_id = NEW.player_id;
	END IF;
END $$
 DELIMITER ;
 
 -- câu 2 
 -- không có cột đội nào thắng trong bảng trận đấu ạ
 
 -- phần 7 PROCEDURE 
 
 DELIMITER $$
 CREATE PROCEDURE give_back_rank(IN p_player_id INT)
 BEGIN
		SELECT 
			CASE
				WHEN player_statics.goals > 20 THEN 'Excellent'
                WHEN player_statics.goals > 10 THEN 'Good'
				WHEN player_statics.goals < 10 THEN 'Averange'
		END AS 'rank_player'
	FROM player_statics
    WHERE player_statics.player_id = p_player_id;
 END$$
 DELIMITER ;
 
 CALL give_back_rank(5);
 
 -- câu 2
 
 CREATE TABLE exchange_log(
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    player_name VARCHAR(100) NOT NULL UNIQUE,
    new_team VARCHAR(50) NOT NULL UNIQUE,
    salary INT NOT NULL
 );
 
 
 DELIMITER $$
 CREATE PROCEDURE change_club(IN p_player_id INT,IN team_id INT)
 
 BEGIN
		DECLARE player_name VARCHAR(50);
        DECLARE player_salary INT;
	START TRANSACTION;
    
		
        
		SELECT full_name,salary INTO player_name,player_salary FROM players
        WHERE player_id = p_player_id;
        
		UPDATE players
        SET players.team_id = team_id
		WHERE player_id = p_player_id;
	
		-- INSERT VÀO BẢNG LOG
        INSERT INTO exchange_log(player_name,new_team,salary)
        VALUES(player_name,team_id,player_salary);
	COMMIT;
 END $$
DELIMITER ;

CALL change_club(1,2);
 