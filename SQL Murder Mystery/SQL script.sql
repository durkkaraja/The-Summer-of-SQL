--You vaguely remember that the crime was a murder that occurred sometime on Jan.15, 2018 and that it took place in SQL City.
--First step: take a look at the crime scene report.

select * 
from crime_scene_report 
where date = 20180115 and type = 'murder' and city = 'SQL City'

--Output:
--Description: Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave". 

--Next step: use the description to identify the two witnesses

select *   
from person  
where address_street_name = 'Northwestern Dr' or (address_street_name = 'Franklin Ave' and name like 'Annabel%') 
order by address_street_name, address_number desc 
limit 2 

--Output: 
--Details on the 2 witnesses (Annabel Miller; Morty Schapiro )

--Next step: find their interviews (by amending the previous query)

with witnesses as  
(select *    
from person   
where address_street_name = 'Northwestern Dr' or (address_street_name = 'Franklin Ave' and name like 'Annabel%')  
order by address_street_name, address_number desc  
limit 2  
) 
select transcript 
from interview 
join witnesses on interview.person_id = witnesses.id 

--Output:
--Transcript 1: I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.
--Transcript 2: I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".

--Next step: use the identifying characteristics in transcripts to find the murderer

with suspect as    
(select *   
from get_fit_now_check_in as check_in    
join get_fit_now_member as member    
on check_in.membership_id = member.id   
where check_in_date = 20180109   
and id like '48Z%'    
and membership_status = 'gold')   
select *   
from suspect join person  
on suspect.person_id = person.id  
join drivers_license as dl 
on person.license_id = dl.id 

--Output:
--Murderer: Jeremy Bowers

--Extra challenge: Try querying the interview transcript of the murderer to find the real villain behind this crime.
--Bonus: Try and complete this final step in no more than 2 queries.

--Next step: query the murderer’s interview transcript using his id

select transcript 
from interview 
where person_id = 67318 

--Output:
--Transcript: I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017. 

--Next step: use the identifying characteristics in transcripts to find the villain

with villains as 
(select *  
from drivers_license  
where (height between 65 and 67)   
and hair_color = 'red'  
and gender = 'female'  
and car_make = 'Tesla') 
select name 
from villains 
join person on villains.id = person.license_id 
join facebook_event_checkin as fb on person.id = fb.person_id 
where event_name = 'SQL Symphony Concert' and date like '201712%'  
group by person_id  
having count(*) = 3 

--Output:
--Villain: Miranda Priestly
