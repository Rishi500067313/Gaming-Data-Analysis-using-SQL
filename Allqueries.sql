#Query to get total count of duplicates
SELECT user_key, type, date, count(1) as Num_duplicate_records
	FROM ea_test.prep_user p
    where date in ('2022-08-01')
    group by p.date, p.type, p.user_key
    having count(1) > 1;

---------------------------------------------------------------------------------------------------------------------------
#Query to get actual duplicates
with dup_record as (
    select user_key, type, date, 
           row_number() over(partition by user_key, type order by date desc ) as row_num 
    from  ea_test.prep_user 
    where date in ('2022-08-01')
)
select user_key, type, date from dup_record where row_num > 1;

---------------------------------------------------------------------------------------------------------------------------
#Query to get distinct user who are not loggedin Approach 1
select count(distinct p.user_key) as Num_of_user
from ea_test.prep_user p
left join ea_test.dim_user d on p.user_key = d.user_key
left join ea_test.user_login u on u.user_id = d.user_id
where p.type in ('purchase') and u.user_id is null;

---------------------------------------------------------------------------------------------------------------------------
#Query to get distinct user who are not loggedin Approach 2
select count(distinct p.user_key) as Num_of_user
from ea_test.prep_user p
left join ea_test.dim_user d on p.user_key = d.user_key
where d.user_id not in (select user_id from ea_test.user_login) and p.type in ('purchase');


---------------------------------------------------------------------------------------------------------------------------
#Query to check records inserted for each day during backfills
select Date, count(*) as Record_Num 
from ea_test.prep_user 
where date between '2022-08-01' and '2022-08-05' 
group by date 
order by date;

---------------------------------------------------------------------------------------------------------------------------
#Query to identify date mismatches between prep_user & user_login.
with pre_work as (
    select pr.user_key, di.user_id, date,
           row_number() over(
            partition by pr.user_key order by date
         ) as row_num
        from ea_test.prep_user pr
             left join ea_test.dim_user di on pr.user_key = di.user_key
)

select p_w.user_key, p_w.user_id, p_w.date, us.first_login_date
from ea_test.user_login us
      join pre_work p_w on p_w.user_id = us.user_id and p_w.row_num = 1
where us.first_login_date != p_w.date;

---------------------------------------------------------------------------------------------------------------------------
#Query to find users who did not made purchase
select di.user_key
from ea_test.dim_user di
     left join ea_test.prep_user pr on pr.date = di.date_id
where
    pr.type not in ('purchase') and di.user_key like '-%';

---------------------------------------------------------------------------------------------------------------------------
# query using windoww function
with sec_score as (
    select user_id, platform, date, Score, 
           rank() over(
             partition by date, platform 
             order by score desc
		   ) as row_num 
    from ea_test.prep_score
)
Select user_id, platform, date, Score 
from sec_score 
where row_num = 2;

---------------------------------------------------------------------------------------------------------------------------
#query without using window function
with sec_score as (
    select ps1.user_id, ps1.platform, ps1.date, max(ps1.Score) as score
    from ea_test.prep_score ps1 
    join ea_test.prep_score ps2 
    where ps1.date = ps2.date and ps1.platform = ps2.platform and ps2.score > ps1.score
    group by user_id, date, platform
)
select user_id, c.platform, c.date, c.Score 
from sec_score c 
join (select date, platform, max(score) as score 
	  from sec_score 
      group by date, platform) a on a.date= c.date and a.platform = c.platform and a.score = c.score;

---------------------------------------------------------------------------------------------------------------------------
#query to get raw_events in shape
with pre_process as(
select
    user_id,
    substring_index(substring_index(event_params, 'plat=', -1), ',', 1) AS platform,
    substring_index(substring_index(event_params, 'tid=', -1), '}', 1) AS title
from ea_test.raw_events_1
)
select platform, title, count(distinct(user_id)) from pre_process group by title, platform;

---------------------------------------------------------------------------------------------------------------------------
#query for valid json & seperation
with json_val as (
    select
        user_id as player_id,
        (
            case
                when json_valid(
                    substring_index(
                        substring_index(event_params, 'character_attr=[', -1), ']', 1)) = 0 
                then concat('{"',
                    substring_index(
                        substring_index(event_params, 'character_attr=[', -1), ']', 1),
                    '"}'
                )
                else substring_index(
                    substring_index(event_params, 'character_attr=[', -1), ']', 1
                )
            end
        ) as character_attr
    from
        ea_test.raw_events_1
),
pre_item_process as (
    select
        player_id,
        character_attr,
        replace(
            replace(replace(j.item, '|', '","'), '{"{', '{'), '}"}', '}'
        ) as items
    from
        json_val
        join json_table(
            replace(
                json_array(replace(character_attr, '","', '|')), '},{', '}","{'),
            '$[*]' columns (item varchar(1000) PATH '$')
    ) j
)
SELECT
    player_id,
    character_attr,
    items,
    JSON_VALUE(items, '$.selection') AS selection,
    JSON_VALUE(items, '$.type') AS type,
    JSON_VALUE(items, '$.target') AS target
FROM
    pre_item_process;




