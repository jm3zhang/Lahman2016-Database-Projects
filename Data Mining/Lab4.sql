Drop PROCEDURE if exists update_value;
DELIMITER $$ 
CREATE PROCEDURE update_value()

BEGIN
    Update lab4_halloffame  SET inducted = '0' where lab4_halloffame.inducted = 'N';
    Update lab4_halloffame  SET inducted = '1' where lab4_halloffame.inducted = 'Y'; 
    -- Update lab4_halloffame  SET votedBy = '1' where lab4_halloffame.votedBy = 'BBWAA';
    -- Update lab4_halloffame  SET votedBy = '2' where lab4_halloffame.votedBy = 'Nominating Vote';
    -- Update lab4_halloffame  SET votedBy = '3' where lab4_halloffame.votedBy = 'Veterans'; 
    -- Update lab4_halloffame  SET votedBy = '4' where lab4_halloffame.votedBy = 'Old Timers'; 
    -- Update lab4_halloffame  SET votedBy = '5' where lab4_halloffame.votedBy = 'Run Off'; 
    -- Update lab4_halloffame  SET votedBy = '6' where lab4_halloffame.votedBy = 'Final Ballot'; 
    -- Update lab4_halloffame  SET votedBy = '7' where lab4_halloffame.votedBy = 'Negro League'; 
    -- Update lab4_halloffame  SET votedBy = '8' where lab4_halloffame.votedBy = 'Centennial'; 
    -- Update lab4_halloffame  SET votedBy = '9' where lab4_halloffame.votedBy = 'Special Election'; 
END $$

drop table if exists lab4_batting;

create table lab4_batting as 
select playerid, sum(G) as b_G, sum(AB) as b_AB, sum(R) as b_R, sum(H) as b_H, sum(2B) as b_2B, sum(3B) as b_3B, sum(HR) as b_HR, 
sum(RBI) as b_RBI, sum(SB) b_SB, sum(CS) as b_CS, sum(BB) as b_BB, sum(SO) as b_SO, sum(IBB) as b_IBB, sum(HBP) as b_HBP, sum(SH) as b_SH, 
sum(SF) as b_SF, sum(GIDP) as b_GIDP from Batting group by playerid;

alter table lab4_batting add constraint `pk_lab4_batting` primary key (playerid);

drop table if exists lab4_pitching;

create table lab4_pitching as
select playerid, sum(W) as p_W, sum(L) as p_L, sum(G) as p_G, sum(GS) as p_GS, sum(CG) as p_CG, sum(SHO) as p_SHO, sum(SV) as p_SV, 
sum(IPouts) as p_IPouts, sum(H) as p_H, sum(ER) as p_ER, sum(HR) as p_HR, sum(BB) as p_BB, sum(SO) as p_SO, 
sum(BAOpp) as p_BAOpp, sum(ERA) as p_ERA, sum(IBB) as p_IBB, sum(WP) as p_WP, sum(HBP) as p_HBP, sum(BK) as p_BK, sum(BFP) as p_BFP, 
sum(GF) as p_GF, sum(R) as p_R, sum(SH) as p_SH, sum(SF) as p_SF, sum(GIDP) as p_GIDP from Pitching group by playerid;

alter table lab4_pitching add constraint `pk_lab4_pitching` primary key (playerid);

drop table if exists lab4_halloffame;

create table lab4_halloffame as select * from HallOfFame;

call update_value();

drop table if exists lab4_halloffame_class;

create table lab4_halloffame_class as select playerid, yearid, votedBy, votes, category, inducted as classification from lab4_halloffame group by playerid,yearid;

drop table if exists lab4_data;

create table lab4_data as
select * from lab4_halloffame_class left outer join lab4_batting using (playerid) left outer join lab4_pitching using (playerid);


-- select playerid, b_2B, b_3B, b_HR, 
-- b_RBI,
-- p_HR,
-- sum(classification) as classification
-- from lab4_data group by playerid;


-- select playerid, b_G, b_AB, b_R, b_H, b_2B, b_3B, b_HR, 
-- b_RBI, b_SB, b_CS, b_BB, b_SO, b_IBB, b_HBP, b_SH,
-- b_SF, b_GIDP,
-- p_W, p_L, p_G, p_GS, p_CG, p_SHO, p_SV,
-- p_IPouts, p_H, p_ER, p_HR, p_BB, p_SO,
-- p_BAOpp, p_ERA, p_IBB, p_WP, p_HBP, p_BK, p_BFP,
-- p_GF, p_R, p_SH, p_SF, p_GIDP,
-- sum(classification) as classification 
-- from lab4_data where category = 'Player' group by playerid;

select playerid, p_HBP, p_SHO, b_AB, p_L, p_SV, p_GF, p_CG, p_R, b_HBP, b_GIDP, b_BB, b_H, b_SH, b_IBB, b_2B, b_3B, b_SB, b_RBI, b_SO, b_G, p_W, b_R,
sum(classification) as classification 
from lab4_data where category = 'Player' group by playerid;
