                                       *************************************************
                                       *        Section One: Setup                     *
									   *************************************************
clear
cd "C:\Users\daichaoyi1\Desktop\i_t_k structure"
set obs 1

*setup # of individual
gen ind=60000                  //input # of individual

*setup time span
gen initial_date_1=mdy(06,30,2016)          //input initial date
gen initial_date_2=mdy(07,12,2016)
gen end_date=mdy(11,23,2016)           //input end date

*set up range of heroid
gen initial_heroid=105             //input initial heroid
gen end_heroid=186                    //186                //input end heroid


*---------------------
*create macro variable
gen interval_1=end_date-initial_date_1+1
gen interval_2=end_date-initial_date_2+1
gen num_hero=end_heroid-initial_heroid+1

global ind=ind
global initial_date_1=initial_date_1
global initial_date_2=initial_date_2
global end_date=end_date
global interval_1=interval_1
global interval_2=interval_2
global initial_heroid=initial_heroid
global end_heroid=end_heroid
global num_hero=num_hero


                                       *************************************************
                                       *        Section Two: preparation               *
									   *************************************************								   
									   
* for buy_table 1v1_table 3v3_table 5v5_table create "date"  "time" under a new time framing by deducting 5 hours. 

*------preparing 1v1_table
clear
use game_1v1_table.dta
gen begintime1=clock(dteventtime, "MD20Yhm")
format begintime1 %tc
local fivehours=1000*60*60*5
gen double new_timeframe=begintime1-`fivehours'
format new_timeframe %tc
gen hrs=hh(new_timeframe)
gen min=mm(new_timeframe)
gen sed=ss(new_timeframe)
gen time=hms(hrs,min,sed)
format time %tc_HH:MM:SS
drop hrs min sed
gen new_timeframe_text= string(new_timeframe,"%tc")
gen new_date_text=substr(new_timeframe_text,1,length(new_timeframe_text)-9)
gen date=date(new_date_text,"DMY")
format date %tdnn/dd/yy
drop begintime1 new_date_text
*list all the heroid purchased during the date interval
sort r date heroid
rename new_timeframe new_time_game
gen k=1
save game_1v1_new.dta,replace


*------------preparing 3v3_table
clear
use game_3v3_table.dta
gen begintime1=clock(dteventtime, "MD20Yhm")
format begintime1 %tc
local fivehours=1000*60*60*5
gen double new_timeframe=begintime1-`fivehours'
format new_timeframe %tc
gen hrs=hh(new_timeframe)
gen min=mm(new_timeframe)
gen sed=ss(new_timeframe)
gen time=hms(hrs,min,sed)
format time %tc_HH:MM:SS
drop hrs min sed
gen new_timeframe_text= string(new_timeframe,"%tc")
gen new_date_text=substr(new_timeframe_text,1,length(new_timeframe_text)-9)
gen date=date(new_date_text,"DMY")
format date %tdnn/dd/yy
drop begintime1 new_date_text
*list all the heroid purchased during the date interval
sort r date heroid
rename new_timeframe new_time_game
gen k=2
save game_3v3_new.dta,replace


*------------preparing 5v5_table(adjustment time frame)
clear
use game_5v5_table.dta
gen double begintime1= clock(dteventtime, "YMD hms") 
format begintime1 %tc
local fivehours=1000*60*60*5
gen double new_timeframe=begintime1-`fivehours'
format new_timeframe %tc
gen hrs=hh(new_timeframe)
gen min=mm(new_timeframe)
gen sed=ss(new_timeframe)
gen time=hms(hrs,min,sed)
format time %tc_HH:MM:SS
drop hrs min sed
gen new_timeframe_text= string(new_timeframe,"%tc")
gen new_date_text=substr(new_timeframe_text,1,length(new_timeframe_text)-9)
gen date=date(new_date_text,"DMY")
format date %tdnn/dd/yy
drop begintime1 new_date_text
*list all the heroid purchased during the date interval
sort r date heroid
rename new_timeframe new_time_game
gen k=3
save game_5v5_new.dta,replace


*------preparing id_mapping
//clear 
//use id_mapping.dta
//format id %20.0g
//save id_mapping_new.dta,replace


*------preparing initialskin
//clear 
//use initial_heroskinlist.dta
//format v2 %20.0g
//gen double tstar= clock(v1, "MD20Yhm") 
//format tstar %tc
//local fivehours=1000*60*60*5
//gen double t_star=tstar-`fivehours'
//format t_star %tc
//gen hrs=hh(t_star)
//gen min=mm(t_star)
//gen sed=ss(t_star)
//gen time=hms(hrs,min,sed)
//format time %tc_HH:MM:SS
//drop hrs min sed
//gen new_timeframe_text= string(t_star,"%tc")
//gen new_date_text=substr(new_timeframe_text,1,length(new_timeframe_text)-9)
//gen date=date(new_date_text,"DMY")
//format date %tdnn/dd/yy
//drop tstar new_date_text new_timeframe_text
//rename v2 id
//merge m:m id using id_mapping.dta
//drop _merge
//order r,before (v1)
//order t_star time date, before(v1)
//save initial_heroskinlist_new.dta,replace


 
*----------- Reshape Enemyhero
clear 
use game_1v1_new.dta
keep r date k enemyhero new_time_game is_win
keep if date>=$initial_date_2
save 1v1_enemy.dta,replace


* 3v3 
*identify the sample that has missing enemyhero
clear 
use game_3v3_new.dta
keep r date enemyhero 
keep if date>=$initial_date_2
split enemyhero, p(+)  // since each game has three enemyheroes, split them and reshape the row "enemyhero" into three rows, each row has only one enemyheroes. 
destring enemyhero1 enemyhero2 enemyhero3,replace
gen missing=0 
replace missing=1 if enemyhero1==. 
replace missing=1 if enemyhero2==.
replace missing=1 if enemyhero3==.
keep if missing==1
keep r missing
bysort r: gen count=_n
keep if count==1
drop count
save missing_sample_3v3.dta,replace
*delete the sample that has missing enemyhero
clear 
use game_3v3_new.dta
merge m:1 r using missing_sample_3v3.dta
drop _merge
drop if missing==1
keep r date k enemyhero new_time_game is_win
split enemyhero, p(+)  // since each game has three enemyheroes, split them and reshape the row "enemyhero" into three rows, each row has only one enemyheroes. 
drop enemyhero
gen row=_n
reshape long enemyhero, i(row) j(repeat)
destring enemyhero, replace
drop row repeat 
save 3v3_enemy.dta,replace


*5v5
*identify the sample that has missing enemyhero
clear 
use game_5v5_new.dta
keep r date enemyhero
keep if date>=$initial_date_2
split enemyhero, p(+)  // since each game has three enemyheroes, split them and reshape the row "enemyhero" into three rows, each row has only one enemyheroes. 
destring enemyhero1 enemyhero2 enemyhero3 enemyhero4 enemyhero5,replace
gen missing=0 
replace missing=1 if enemyhero1==. 
replace missing=1 if enemyhero2==.
replace missing=1 if enemyhero3==.
replace missing=1 if enemyhero4==.
replace missing=1 if enemyhero5==.
keep if missing==1
keep r missing
bysort r: gen count=_n
keep if count==1
drop count
save missing_sample_5v5.dta,replace
*delete the sample that has missing enemyhero
clear 
use game_5v5_new.dta
merge m:1 r using missing_sample_5v5.dta
drop _merge
drop if missing==1
keep r date k enemyhero new_time_game is_win
split enemyhero, p(+)  // since each game has three enemyheroes, split them and reshape the row "enemyhero" into three rows, each row has only one enemyheroes. 
drop enemyhero
gen row=_n
reshape long enemyhero, i(row) j(repeat)
destring enemyhero, replace
drop row repeat 
append using 1v1_enemy.dta
append using 3v3_enemy.dta
save enemyhero.dta,replace
erase 1v1_enemy.dta
erase 3v3_enemy.dta

*create id list associated with missing hero
clear
use missing_sample_3v3.dta
append using missing_sample_5v5.dta
keep r 
bysort r: gen order=_n
keep if order==1
keep r
save missing_list.dta,replace
erase missing_sample_3v3.dta
erase missing_sample_5v5.dta



*further clean enemyhero.dta
clear
use enemyhero.dta
merge m:1 r using missing_list.dta
keep if _merge==1
save enemyhero.dta,replace


*------preparing buy_table
clear
use buy_table.dta
gen heroid=int(heroskin/100)
*create a new time frame(deduct five hours)
gen begintime1=clock(dteventtime, "MD20Yhm")
format begintime1 %tc
local fivehours=1000*60*60*5
gen double new_timeframe=begintime1-`fivehours'
format new_timeframe %tc
gen hrs=hh(new_timeframe)
gen min=mm(new_timeframe)
gen sed=ss(new_timeframe)
gen time=hms(hrs,min,sed)
format time %tc_HH:MM:SS
drop hrs min sed
gen new_timeframe_text= string(new_timeframe,"%tc")
gen new_date_text=substr(new_timeframe_text,1,length(new_timeframe_text)-9)
gen date=date(new_date_text,"DMY")
format date %tdnn/dd/yy
drop begintime1 new_date_text
*list all the heroid purchased during the date interval
sort r date heroid
rename new_timeframe new_time_buy
merge m:1 r using missing_list.dta
keep if _merge==1
drop _merge 
save buy_new.dta,replace  


*create player.dta  // number of games the player i played at date t. 
clear 
use game_1v1_new.dta
keep r date time k
save 1v1.dta,replace

clear 
use game_3v3_new.dta
keep r date time k
append using 1v1.dta
save 3v3.dta,replace

clear 
use game_5v5_new.dta
keep r date time k
append using 1v1.dta
append using 3v3.dta   
sort r date time k
keep if date>=$initial_date_2
save  player.dta,replace
erase 1v1.dta
erase 3v3.dta

  


                                *****************************************
                                * Section Three: Create i_t_k dataset   *
                                *****************************************
//-----------create i_t_k dataset
clear
set obs $interval_2                     //set the # of dates
gen date=_n-1+$initial_date_2     
format date %tdnn/dd/yy
save timeline.dta,replace

clear 
*create game_type dimension     
set obs 3             
gen k=_n        
save game_type.dta,replace

*create i 
clear
set obs $ind             //set the # of individuals 
gen r=_n               
merge 1:1 r using missing_list.dta
keep if _merge==1
drop _merge
cross using timeline.dta
sort r date
cross using game_type.dta
sort r date k
save i_t_k.dta,replace            //generate the initial i_t_k dataset 
erase timeline.dta
erase game_type.dta


//-----------create i_t_y dataset
clear
set obs $interval_2                     //set the # of dates
gen date=_n-1+$initial_date_2      
format date %tdnn/dd/yy
save timeline.dta,replace

*create i 
clear
set obs $ind             //set the # of individuals 
gen r=_n  
merge 1:1 r using missing_list.dta
keep if _merge==1
drop _merge         
cross using timeline.dta
sort r date
save i_t_y.dta,replace
erase timeline.dta


//-------------------create Y_1 and Y_3 variable   Y_1: binary variable for whether purchase occurs (after all games)    
clear                                             // Y_3: total spending: after the last game of the day and within day t 
use player.dta
bysort r date: gen num_games=_N   // num_games is the number a player played at date t  
bysort r date: gen order=_n      
keep if order==num_games       //num_games have already been generated in player.dta
drop order
rename time time_lastgame
joinby r date using buy_new.dta
drop if time==.
keep if time>time_lastgame  
collapse(sum) Y_3=imoney, by (r date)
merge 1:1 r date using i_t_y.dta
drop if _merge==1
drop _merge
replace Y_3=0 if Y_3==.
gen Y_1=1 if Y_3>0
replace Y_1=0 if Y_3==0
save i_t_y.dta,replace


//-------------------create Y_1 and Y_3 variable   Y_1: binary variable for whether purchase occurs (after all games)    
clear                                             // Y_3: total spending: after the last game of the day and within day t 
use player.dta
bysort r date k: gen num_games=_N   // num_games is the number a player played at date t  
bysort r date k: gen order=_n      
keep if order==num_games       //num_games have already been generated in player.dta
drop order
rename time time_lastgame
joinby r date using buy_new.dta
drop if time==.
keep if time>time_lastgame  
collapse(sum) Y_3=imoney, by (r date k)
merge 1:1 r date k using i_t_k.dta
drop if _merge==1
drop _merge
replace Y_3=0 if Y_3==.
gen Y_1=1 if Y_3>0
replace Y_1=0 if Y_3==0
save i_t_y.dta,replace                    


//--------------------create Y_2 and Y_4 variable     Y_2: binary variable for whether purchase occurs between t+1 and t+7 
clear                                              // Y_4: total spending: between t+1 and t+7
set more off
global end=(-7)+$end_date
forvalues t=$initial_date_2(1)$end{
clear              
use buy_new.dta
keep if date>=`t'+1 & date<=`t'+7 
keep r imoney
collapse (sum) Y_4=imoney, by (r)
gen date=`t'
merge 1:1 r date using i_t_y.dta 
drop if _merge==1
drop _merge
save i_t_y.dta, replace
}
replace Y_4=0 if Y_4==.  
gen Y_2=1 if Y_4>0
replace Y_2=0 if Y_4==0
order Y_2, after (Y_1)
order Y_3, after (Y_2)
order Y_4, after (Y_3)
save i_t_y.dta, replace


//--------------------create Y_5 variable     Y_5: total number of games played between t+1 and t+7  
clear
set more off
global end=(-7)+$end_date
forvalues t=$initial_date_2(1)$end{              
clear 
use player.dta
drop time
keep if date>=`t'+1 & date<=`t'+7     //iterate over all t 
bysort r: gen Y_5=_N   // num_games is the number a player played at date t  
bysort r: gen order=_n      
keep if order==Y_5       //num_games have already been generated in player.dta
drop order
replace date=`t'
merge 1:1 r date using i_t_y.dta
drop if _merge==1
drop _merge
save i_t_y.dta,replace
}
replace Y_5=0 if Y_5==. 
order Y_5, after (Y_4)
save i_t_y.dta, replace




//-------------------create conditional variables
*group one   r<=10000
clear
use buy_new.dta
merge m:1 r using missing_list.dta
keep if _merge==1
drop _merge
keep if r<=10000
keep r after_item new_time_buy
save buy_use_1.dta,replace

clear
set more off
use enemyhero.dta   
keep if r<=10000
keep r date k enemyhero new_time_game is_win
joinby r using buy_use_1.dta
drop if new_time_buy>new_time_game     // time in the buy table denoted as: new_time_buy    time in the 1v1 table denoted as new_time_1v1
order new_time_buy,after(new_time_game)
sort r new_time_game new_time_buy
bysort r new_time_game: gen num=_N      // for each match of time, only keep the lastest of the buy time.
bysort r new_time_game: gen last=_n
keep if last==num
drop last num
tostring enemyhero,replace
keep r date k enemyhero is_win after_item new_time_buy new_time_game
split after_item, p(+)      //reshape after_item to convert heroskin into hero
drop after_item
gen row=_n
reshape long after_item, i(row) j(repeat)
destring after_item,replace
gen hero=int(after_item/100)
tostring hero,replace
drop after_item
reshape wide hero,i(row) j(repeat)
gen concat= "" 
gen num_skin=0   // num_skin is the number of skin for that enemyhero before the game.
ds hero*
local nwords:  word count `r(varlist)'
local num_hero=-1+`nwords'
forval j = 1/`num_hero' { 
    replace  concat= concat+ hero`j'   if real(hero`j')!=. & real(hero`j+1')==.
    replace  concat= concat+ hero`j'+ "+"   if real(hero`j')!=. & real(hero`j+1')!=.
	replace  num_skin=num_skin+1  if real(hero`j')==real(enemyhero) & real(hero`j')!=0         
} 
replace  concat= concat+hero`nwords'  if real(hero`nwords')!=.
replace num_skin=num_skin+1 if real(hero`nwords')==real(enemyhero) & real(hero`nwords')!=.  
gen purchase=1 if strpos(concat,enemyhero)      
replace purchase=0 if purchase==.
keep r date k enemyhero is_win purchase num_skin
save X_cond_1.dta,replace





*group two r>10000 & r<=20000
clear
use buy_new.dta
merge m:1 r using missing_list.dta
keep if _merge==1
drop _merge
keep if r>10000 & r<=20000
keep r after_item new_time_buy
save buy_use_2.dta,replace

clear
set more off
use enemyhero.dta   
keep if r>10000 & r<=20000
keep r date k enemyhero new_time_game is_win
joinby r using buy_use_2.dta
drop if new_time_buy>new_time_game     // time in the buy table denoted as: new_time_buy    time in the 1v1 table denoted as new_time_1v1
sort r new_time_game new_time_buy
bysort r new_time_game: gen num=_N      // for each match of time, only keep the lastest of the buy time.
bysort r new_time_game: gen last=_n
keep if last==num
drop last num
tostring enemyhero,replace
keep r date k enemyhero is_win after_item new_time_buy new_time_game
split after_item, p(+)      //reshape after_item to convert heroskin into hero
drop after_item
gen row=_n
reshape long after_item, i(row) j(repeat)
destring after_item,replace
gen hero=int(after_item/100)
tostring hero,replace
drop after_item
reshape wide hero,i(row) j(repeat)
gen concat= "" 
gen num_skin=0   // num_skin is the number of skin for that enemyhero before the game.
ds hero*
local nwords:  word count `r(varlist)'
local num_hero=-1+`nwords'
forval j = 1/`num_hero' { 
    replace  concat= concat+ hero`j'   if real(hero`j')!=. & real(hero`j+1')==.
    replace  concat= concat+ hero`j'+ "+"   if real(hero`j')!=. & real(hero`j+1')!=.
	replace  num_skin=num_skin+1  if real(hero`j')==real(enemyhero) & real(hero`j')!=0         
} 
replace  concat= concat+hero`nwords'  if real(hero`nwords')!=.
replace num_skin=num_skin+1 if real(hero`nwords')==real(enemyhero) & real(hero`nwords')!=.  
gen purchase=1 if strpos(concat,enemyhero)      
replace purchase=0 if purchase==.
keep r date k enemyhero is_win purchase num_skin
save X_cond_2.dta,replace




*group three  r>20000 & r<=30000
clear
use buy_new.dta
merge m:1 r using missing_list.dta
keep if _merge==1
drop _merge
keep if r>20000 & r<=30000
keep r after_item new_time_buy
save buy_use_3.dta,replace

clear
set more off
use enemyhero.dta   
keep if r>20000 & r<=30000
keep r date k enemyhero new_time_game is_win
joinby r using buy_use_3.dta
drop if new_time_buy>new_time_game     // time in the buy table denoted as: new_time_buy    time in the 1v1 table denoted as new_time_1v1
sort r new_time_game new_time_buy
bysort r new_time_game: gen num=_N      // for each match of time, only keep the lastest of the buy time.
bysort r new_time_game: gen last=_n
keep if last==num
drop last num
tostring enemyhero,replace
keep r date k enemyhero is_win after_item new_time_buy new_time_game
split after_item, p(+)      //reshape after_item to convert heroskin into hero
drop after_item
gen row=_n
reshape long after_item, i(row) j(repeat)
destring after_item,replace
gen hero=int(after_item/100)
tostring hero,replace
drop after_item
reshape wide hero,i(row) j(repeat)
gen concat= "" 
gen num_skin=0   // num_skin is the number of skin for that enemyhero before the game.
ds hero*
local nwords:  word count `r(varlist)'
local num_hero=-1+`nwords'
forval j = 1/`num_hero' { 
    replace  concat= concat+ hero`j'   if real(hero`j')!=. & real(hero`j+1')==.
    replace  concat= concat+ hero`j'+ "+"   if real(hero`j')!=. & real(hero`j+1')!=.
	replace  num_skin=num_skin+1  if real(hero`j')==real(enemyhero) & real(hero`j')!=0         
} 
replace  concat= concat+hero`nwords'  if real(hero`nwords')!=.
replace num_skin=num_skin+1 if real(hero`nwords')==real(enemyhero) & real(hero`nwords')!=.  
gen purchase=1 if strpos(concat,enemyhero)      
replace purchase=0 if purchase==.
keep r date k enemyhero is_win purchase num_skin
save X_cond_3.dta,replace



*group four  r>30000 & r<=40000
clear
use buy_new.dta
merge m:1 r using missing_list.dta
keep if _merge==1
drop _merge
keep if r>30000 & r<=40000
keep r after_item new_time_buy
save buy_use_4.dta,replace

clear
set more off
use enemyhero.dta   
keep if r>30000 & r<=40000
keep r date k enemyhero new_time_game is_win
joinby r using buy_use_4.dta
drop if new_time_buy>new_time_game     // time in the buy table denoted as: new_time_buy    time in the 1v1 table denoted as new_time_1v1
sort r new_time_game new_time_buy
bysort r new_time_game: gen num=_N      // for each match of time, only keep the lastest of the buy time.
bysort r new_time_game: gen last=_n
keep if last==num
drop last num
tostring enemyhero,replace
keep r date k enemyhero is_win after_item new_time_buy new_time_game
split after_item, p(+)      //reshape after_item to convert heroskin into hero
drop after_item
gen row=_n
reshape long after_item, i(row) j(repeat)
destring after_item,replace
gen hero=int(after_item/100)
tostring hero,replace
drop after_item
reshape wide hero,i(row) j(repeat)
gen concat= "" 
gen num_skin=0   // num_skin is the number of skin for that enemyhero before the game.
ds hero*
local nwords:  word count `r(varlist)'
local num_hero=-1+`nwords'
forval j = 1/`num_hero' { 
    replace  concat= concat+ hero`j'   if real(hero`j')!=. & real(hero`j+1')==.
    replace  concat= concat+ hero`j'+ "+"   if real(hero`j')!=. & real(hero`j+1')!=.
	replace  num_skin=num_skin+1  if real(hero`j')==real(enemyhero) & real(hero`j')!=0         
} 
replace  concat= concat+hero`nwords'  if real(hero`nwords')!=.
replace num_skin=num_skin+1 if real(hero`nwords')==real(enemyhero) & real(hero`nwords')!=.  
gen purchase=1 if strpos(concat,enemyhero)      
replace purchase=0 if purchase==.
keep r date k enemyhero is_win purchase num_skin
save X_cond_4.dta,replace




*group five  r>40000 & r<=50000
clear
use buy_new.dta
merge m:1 r using missing_list.dta
keep if _merge==1
drop _merge
keep if r>40000 & r<=50000
keep r after_item new_time_buy
save buy_use_5.dta,replace

clear
set more off
use enemyhero.dta   
keep if r>40000 & r<=50000
keep r date k enemyhero new_time_game is_win
joinby r using buy_use_5.dta
drop if new_time_buy>new_time_game     // time in the buy table denoted as: new_time_buy    time in the 1v1 table denoted as new_time_1v1
sort r new_time_game new_time_buy
bysort r new_time_game: gen num=_N      // for each match of time, only keep the lastest of the buy time.
bysort r new_time_game: gen last=_n
keep if last==num
drop last num
tostring enemyhero,replace
keep r date k enemyhero is_win after_item new_time_buy new_time_game
split after_item, p(+)      //reshape after_item to convert heroskin into hero
drop after_item
gen row=_n
reshape long after_item, i(row) j(repeat)
destring after_item,replace
gen hero=int(after_item/100)
tostring hero,replace
drop after_item
reshape wide hero,i(row) j(repeat)
gen concat= "" 
gen num_skin=0   // num_skin is the number of skin for that enemyhero before the game.
ds hero*
local nwords:  word count `r(varlist)'
local num_hero=-1+`nwords'
forval j = 1/`num_hero' { 
    replace  concat= concat+ hero`j'   if real(hero`j')!=. & real(hero`j+1')==.
    replace  concat= concat+ hero`j'+ "+"   if real(hero`j')!=. & real(hero`j+1')!=.
	replace  num_skin=num_skin+1  if real(hero`j')==real(enemyhero) & real(hero`j')!=0         
} 
replace  concat= concat+hero`nwords'  if real(hero`nwords')!=.
replace num_skin=num_skin+1 if real(hero`nwords')==real(enemyhero) & real(hero`nwords')!=.  
gen purchase=1 if strpos(concat,enemyhero)      
replace purchase=0 if purchase==.
keep r date k enemyhero is_win purchase num_skin
save X_cond_5.dta,replace



*group six  r>50000 & r<=60000
clear
use buy_new.dta
merge m:1 r using missing_list.dta
keep if _merge==1
drop _merge
keep if r>50000 & r<=60000
keep r after_item new_time_buy
save buy_use_6.dta,replace

clear
set more off
use enemyhero.dta   
keep if r>50000 & r<=60000
keep r date k enemyhero new_time_game is_win
joinby r using buy_use_6.dta
drop if new_time_buy>new_time_game     // time in the buy table denoted as: new_time_buy    time in the 1v1 table denoted as new_time_1v1
sort r new_time_game new_time_buy
bysort r new_time_game: gen num=_N      // for each match of time, only keep the lastest of the buy time.
bysort r new_time_game: gen last=_n
keep if last==num
drop last num
tostring enemyhero,replace
keep r date k enemyhero is_win after_item new_time_buy new_time_game
split after_item, p(+)      //reshape after_item to convert heroskin into hero
drop after_item
gen row=_n
reshape long after_item, i(row) j(repeat)
destring after_item,replace
gen hero=int(after_item/100)
tostring hero,replace
drop after_item
reshape wide hero,i(row) j(repeat)
gen concat= "" 
gen num_skin=0   // num_skin is the number of skin for that enemyhero before the game.
ds hero*
local nwords:  word count `r(varlist)'
local num_hero=-1+`nwords'
forval j = 1/`num_hero' { 
    replace  concat= concat+ hero`j'   if real(hero`j')!=. & real(hero`j+1')==.
    replace  concat= concat+ hero`j'+ "+"   if real(hero`j')!=. & real(hero`j+1')!=.
	replace  num_skin=num_skin+1  if real(hero`j')==real(enemyhero) & real(hero`j')!=0         
} 
replace  concat= concat+hero`nwords'  if real(hero`nwords')!=.
replace num_skin=num_skin+1 if real(hero`nwords')==real(enemyhero) & real(hero`nwords')!=.  
gen purchase=1 if strpos(concat,enemyhero)      
replace purchase=0 if purchase==.
keep r date k enemyhero is_win purchase num_skin
save X_cond_6.dta,replace


clear 
use X_cond_1.dta
append using X_cond_2.dta
append using X_cond_3.dta
append using X_cond_4.dta
append using X_cond_5.dta
append using X_cond_6.dta
save X_cond.dta,replace
erase X_cond_1.dta 
erase X_cond_2.dta 
erase X_cond_3.dta 
erase X_cond_4.dta 
erase X_cond_5.dta 
erase X_cond_6.dta 
erase buy_use_1.dta
erase buy_use_2.dta
erase buy_use_3.dta
erase buy_use_4.dta
erase buy_use_5.dta
erase buy_use_6.dta



*Revise X_cond with inventory_revise
clear
use X_cond_before_clean.dta
merge m:1 r enemyhero date using inventory_revise.dta
replace num_skin=num_skin+1 if num_skin>=1 & _merge==3     //notice! for those num_skin==0 & _merge==3, since time of buy is after than the time of play, don't incorporate the revise.
drop _merge inventory*
save X_cond.dta,replace



*X_1-X_6
*-------------------------
clear
use X_cond.dta
keep if purchase==1 
keep if num_skin==1
keep if is_win==1
bysort r date enemyhero k: gen freq=_N
collapse(sum) X_1=freq, by(r date k) 
save X_1.dta,replace

clear
use X_cond.dta
keep if purchase==1 
keep if num_skin>1 
keep if is_win==1
bysort r date enemyhero k: gen freq=_N
collapse(sum) X_2=freq, by(r date k)
save X_2.dta,replace

clear
use X_cond.dta
keep if purchase==0
keep if is_win==1
bysort r date enemyhero k: gen freq=_N
collapse(sum) X_3=freq, by(r date k)
save X_3.dta,replace

clear
use X_cond.dta
keep if purchase==1 
keep if num_skin==1
keep if is_win==0
bysort r date enemyhero k: gen freq=_N
collapse(sum) X_4=freq, by(r date k) 
save X_4.dta,replace

clear
use X_cond.dta
keep if purchase==1 
keep if num_skin>1
keep if is_win==0
bysort r date enemyhero k: gen freq=_N
collapse(sum) X_5=freq, by(r date k) 
save X_5.dta,replace

clear
use X_cond.dta
keep if purchase==0
keep if is_win==0
bysort r date enemyhero k: gen freq=_N
collapse(sum) X_6=freq, by(r date k) 
save X_6.dta,replace



*X_7-X_12 (r-date structure)
*-------------------------
clear 
use X_cond.dta
keep if purchase==1
keep if num_skin==1
keep if is_win==1
bysort r date enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_7=order, by (r date k)
save X_7.dta,replace


clear 
use X_cond.dta
keep if purchase==1
keep if num_skin>1
keep if is_win==1
bysort r date enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_8=order, by (r date k)
save X_8.dta,replace


clear 
use X_cond.dta
keep if purchase==0
keep if is_win==1
bysort r date enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_9=order, by (r date k)
save X_9.dta,replace


clear 
use X_cond.dta
keep if purchase==1
keep if num_skin==1
keep if is_win==0
bysort r date enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_10=order, by (r date k)
save X_10.dta,replace

clear 
use X_cond.dta
keep if purchase==1
keep if num_skin>1
keep if is_win==0
bysort r date enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_11=order, by (r date k)
save X_11.dta,replace

clear 
use X_cond.dta
keep if purchase==0
keep if is_win==0
bysort r date enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_12=order, by (r date k)
save X_12.dta,replace


clear
use i_t_k.dta
merge 1:1 r date k using X_1.dta
drop if _merge==2     // the reason for deletion is that the X_1 was created from buy_new, whose initial date was from 6/30
drop _merge
replace X_1=0 if X_1==.

merge 1:1 r date k using X_2.dta
drop if _merge==2
drop _merge
replace X_2=0 if X_2==.

merge 1:1 r date k using X_3.dta
drop if _merge==2
drop _merge
replace X_3=0 if X_3==.

merge 1:1 r date k using X_4.dta
drop if _merge==2
drop _merge
replace X_4=0 if X_4==.

merge 1:1 r date k using X_5.dta
drop if _merge==2
drop _merge
replace X_5=0 if X_5==.

merge 1:1 r date k using X_6.dta
drop if _merge==2
drop _merge
replace X_6=0 if X_6==.

merge 1:1 r date k using X_7.dta
drop if _merge==2
drop _merge
replace X_7=0 if X_7==.

merge 1:1 r date k using X_8.dta
drop if _merge==2
drop _merge
replace X_8=0 if X_8==.

merge 1:1 r date k using X_9.dta
drop if _merge==2
drop _merge
replace X_9=0 if X_9==.

merge 1:1 r date k using X_10.dta
drop if _merge==2
drop _merge
replace X_10=0 if X_10==.

merge 1:1 r date k using X_11.dta
drop if _merge==2
drop _merge
replace X_11=0 if X_11==.

merge 1:1 r date k using X_12.dta
drop if _merge==2
drop _merge
replace X_12=0 if X_12==.
save i_t_k.dta,replace




*create X_13 variable  (allow for duplicates)
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_1.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_1=0 if X_1==.
collapse(sum) X_13=X_1, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_13=0 if X_13==.
order X_13,last
sort r date k
save i_t_k.dta,replace




*create X_14 variable  (allow for duplicates)
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_2.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_2=0 if X_2==.
collapse(sum) X_14=X_2, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_14=0 if X_14==.
order X_14,last
sort r date k
save i_t_k.dta,replace




*create X_15 variable  (allow for duplicates)
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_3.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_3=0 if X_3==.
collapse(sum) X_15=X_3, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_15=0 if X_15==.
order X_15,last
sort r date k
save i_t_k.dta,replace




*create X_16 variable  (allow for duplicates)
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_4.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_4=0 if X_4==.
collapse(sum) X_16=X_4, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_16=0 if X_16==.
order X_16,last
sort r date k
save i_t_k.dta,replace



*create X_17 variable  (allow for duplicates)
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_5.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_5=0 if X_5==.
collapse(sum) X_17=X_5, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_17=0 if X_17==.
order X_17,last
sort r date k
save i_t_k.dta,replace



*create X_18 variable  (allow for duplicates)
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_6.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_6=0 if X_6==.
collapse(sum) X_18=X_6, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_18=0 if X_18==.
order X_18,last
sort r date k
save i_t_k.dta,replace


*create X_19 variable  (not allow duplicates)
clear 
use X_cond.dta
keep if purchase==1
keep if num_skin==1
keep if is_win==1
bysort r date enemyhero k: gen order=_n
keep if order==1
drop order
save X_19_prep.dta,replace

clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_19_prep.dta  
keep if date>=`t'-7 & date<=`t'-1     
bysort r enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_19=order, by(r k)    
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_19=0 if X_19==.
order X_19,last
sort r date k
save i_t_k.dta,replace
erase X_19_prep.dta



*create X_20 variable  (not allow duplicates)
clear 
use X_cond.dta
keep if purchase==1
keep if num_skin>1
keep if is_win==1
bysort r date enemyhero k: gen order=_n
keep if order==1
drop order
save X_20_prep.dta,replace

clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_20_prep.dta  
keep if date>=`t'-7 & date<=`t'-1     
bysort r enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_20=order, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_20=0 if X_20==.
order X_20,last
sort r date k
save i_t_k.dta,replace
erase X_20_prep.dta




*create X_21 variable  (not allow duplicates)
clear 
use X_cond.dta
keep if purchase==0
keep if is_win==1
bysort r date enemyhero k: gen order=_n
keep if order==1
drop order
save X_21_prep.dta,replace

clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_21_prep.dta  
keep if date>=`t'-7 & date<=`t'-1     
bysort r enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_21=order, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_21=0 if X_21==.
order X_21,last
sort r date k
save i_t_k.dta,replace
erase X_21_prep.dta




*create X_22 variable  (not allow duplicates)
clear 
use X_cond.dta
keep if purchase==1
keep if num_skin==1
keep if is_win==0
bysort r date enemyhero k: gen order=_n
keep if order==1
drop order
save X_22_prep.dta,replace

clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_22_prep.dta  
keep if date>=`t'-7 & date<=`t'-1     
bysort r enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_22=order, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_22=0 if X_22==.
order X_22,last
sort r date k
save i_t_k.dta,replace
erase X_22_prep.dta




*create X_23 variable  (not allow duplicates)
clear 
use X_cond.dta
keep if purchase==1
keep if num_skin>1
keep if is_win==0
bysort r date enemyhero k: gen order=_n
keep if order==1
drop order
save X_23_prep.dta,replace

clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_23_prep.dta  
keep if date>=`t'-7 & date<=`t'-1     
bysort r enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_23=order, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_23=0 if X_23==.
order X_23,last
sort r date k
save i_t_k.dta,replace
erase X_23_prep.dta





*create X_24 variable  (not allow duplicates)
clear 
use X_cond.dta
keep if purchase==0
keep if is_win==0
bysort r date enemyhero k: gen order=_n
keep if order==1
drop order
save X_24_prep.dta,replace

clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_24_prep.dta  
keep if date>=`t'-7 & date<=`t'-1     
bysort r enemyhero k: gen order=_n
keep if order==1
collapse(sum) X_24=order, by(r k)     
gen date=`t'
merge 1:1 r date k using i_t_k.dta
drop _merge
save i_t_k.dta,replace
}
replace X_24=0 if X_24==.
order X_24,last
sort r date k
save i_t_k.dta,replace
erase X_24_prep.dta





*create release date 
clear
use buy_new.dta
sort r date time before_item
keep r date dteventtime before_item
bysort r: gen order=_n
keep if order==1                // only take the earliest record for each individual as the inventory record
drop order
split before_item, p(+) 
drop before_item
gen row=_n
reshape long before_item, i(row) j(repeat)
destring before_item,replace
drop if before_item==.
tostring before_item,replace
gen type=substr(before_item,4,2)
destring type,replace
gen reason=3 if type==00
replace reason=4 if type!=00
keep r date before_item reason
rename before_item heroskin
save buy_release_1.dta,replace

clear
use buy_new.dta
sort r date time before_item
bysort r: gen order=_n
keep if order!=1 
drop order       
keep r date heroskin reason
tostring heroskin,replace
append using buy_release_1.dta
save buy_release.dta,replace
erase buy_release_1.dta

clear
use game_1v1_new.dta
keep r date heroid1 
rename heroid1 heroid
save 1v1_release.dta,replace

clear
use game_3v3_new.dta
keep r date heroid1
rename heroid1 heroid
save 3v3_release.dta,replace

clear 
use game_5v5_new.dta
keep r date heroid1
rename heroid1 heroid
append using 1v1_release.dta
append using 3v3_release.dta
replace heroid=heroid*100
rename heroid heroskin
tostring heroskin,replace
append using buy_release.dta
replace reason=3 if reason==.
sort r heroskin date
bysort r heroskin: gen order=_n
keep if order==1
drop order
rename date released_date
save released_date.dta,replace
erase buy_release.dta
erase 1v1_release.dta
erase 3v3_release.dta


*create X_29
clear
set obs $interval_2                     //set the # of dates
gen date=_n-1+$initial_date_2      
format date %tdnn/dd/yy
save timeline.dta,replace

*create i 
clear
set obs $ind             //set the # of individuals 
gen r=_n  
merge 1:1 r using missing_list.dta
keep if _merge==1
drop _merge         
cross using timeline.dta
sort r date
save i_date.dta,replace
erase timeline.dta

clear
use i_date.dta
joinby r using released_date.dta
keep if released_date<=date
gen gap=date-released_date
gen X_29=1 if gap<=30 & reason==3
replace X_29=0 if X_29==.
collapse(sum) X_29=X_29, by(r date)
save X_29.dta,replace



*create X_30 variable
clear
use i_date.dta
joinby r using released_date.dta
keep if released_date<=date
gen gap=date-released_date
gen X_30=1 if gap<=30 & reason==4
replace X_30=0 if X_30==.
destring heroskin,generate(hero)
replace hero=int(hero/100)
bysort r date hero: gen order=_n
keep if order==1
collapse(sum) X_30=X_30, by(r date)
save X_30.dta,replace



*create X_31 variable
clear
use i_date.dta
joinby r using released_date.dta
keep if released_date<=date
gen gap=date-released_date
gen X_31=1 if gap<=90 & reason==3
replace X_31=0 if X_31==.
collapse(sum) X_31=X_31, by(r date)
save X_31.dta,replace



*create X_32 variable
clear
use i_date.dta
joinby r using released_date.dta
keep if released_date<=date
gen gap=date-released_date
gen X_32=1 if gap<=90 & reason==4
replace X_32=0 if X_32==.
destring heroskin,generate(hero)
replace hero=int(hero/100)
bysort r date hero: gen order=_n
keep if order==1
collapse(sum) X_32=X_32, by(r date)
save X_32.dta,replace
erase i_date.dta

clear
use i_t.dta
merge 1:1 r date using X_29.dta
drop if _merge==2
drop _merge
replace X_29=0 if X_29==.

merge 1:1 r date using X_30.dta
drop if _merge==2
drop _merge
replace X_30=0 if X_30==.

merge 1:1 r date using X_31.dta
drop if _merge==2
drop _merge
replace X_31=0 if X_31==.

merge 1:1 r date using X_32.dta
drop if _merge==2
drop _merge
replace X_32=0 if X_32==.
save i_t.dta,replace



*create X_33 variable
clear 
use enemyhero.dta
keep if is_win==1
bysort r date: gen X_33=_N
bysort r date: gen order=_n
keep if order==X_33
keep r date X_33
save X_33_cond.dta,replace

clear 
use i_t.dta
merge 1:1 r date using X_33_cond.dta
drop _merge
replace X_33=0 if X_33==.
save i_t.dta,replace



*create X_34 variable
clear 
use enemyhero.dta
keep if is_win==0
bysort r date: gen X_34=_N
bysort r date: gen order=_n
keep if order==X_34
keep r date X_34
save X_34_cond.dta,replace

clear 
use i_t.dta
merge 1:1 r date using X_34_cond.dta
drop _merge
replace X_34=0 if X_34==.
save i_t.dta,replace



*create X_35 variable
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_33_cond.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_33=0 if X_33==.
collapse(sum) X_35=X_33, by(r)    
gen date=`t'
merge 1:1 r date using i_t.dta 
drop if _merge==1
drop _merge
save i_t.dta,replace
}
replace X_35=0 if X_35==.
order X_35,last
sort r date
save i_t.dta,replace



*create X_36 variable
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{              
clear 
use X_34_cond.dta  
keep if date>=`t'-7 & date<=`t'-1     
replace X_34=0 if X_34==.
collapse(sum) X_36=X_34, by(r)    
gen date=`t'
merge 1:1 r date using i_t.dta
drop if _merge==1
drop _merge
save i_t.dta,replace
}
replace X_36=0 if X_36==.
order X_36,last
sort r date
save i_t.dta,replace



*create fighting_ability_new.dta
clear 
use fighting_ability.dta
tostring status_date, replace
gen begintime1=clock(status_date, "YMD")
format begintime1 %tc
destring status_date,replace
local fivehours=1000*60*60*5
gen double new_timeframe=begintime1-`fivehours'
format new_timeframe %tc
gen new_timeframe_text= string(new_timeframe,"%tc")
gen new_date_text=substr(new_timeframe_text,1,length(new_timeframe_text)-9)
gen date=date(new_date_text,"DMY")
format date %tdnn/dd/yy
format uid %20.0g
rename uid id
merge m:1 id using id_mapping.dta
drop _merge
keep r date newgrade
order r date newgrade
sort r date
save fighting_ability_new.dta,replace



*create X_37
clear 
use i_t.dta
merge 1:1 r date using fighting_ability_new.dta
drop if _merge==2
drop _merge
rename newgrade X_37
save i_t.dta,replace



*create X_38
clear
set more off
global initial=7+$initial_date_2
forvalues t=$initial(1)$end_date{  
clear 
use i_t.dta
keep if date>=`t'-7 & date<=`t'-1
collapse(mean) X_38=X_37, by (r)
gen date=`t'
merge 1:1 r date using i_t.dta 
drop if _merge==1
drop _merge
save i_t.dta,replace
}
sort r date
order X_38, after(X_37)
save i_t.dta,replace




* create X39
clear 
use i_t.dta
format date %tdnn/dd/YY
gen week_day=dow(date)

gen X_39_mon=1 if week_day==1
replace X_39_mon=0 if X_39_mon==.

gen X_39_tue=1 if week_day==2
replace X_39_tue=0 if X_39_tue==.

gen X_39_wed=1 if week_day==3
replace X_39_wed=0 if X_39_wed==.

gen X_39_thu=1 if week_day==4
replace X_39_thu=0 if X_39_thu==.

gen X_39_fri=1 if week_day==5
replace X_39_fri=0 if X_39_fri==.

gen X_39_sat=1 if week_day==6
replace X_39_sat=0 if X_39_sat==.

drop week_day
save i_t.dta,replace



* create X_40
clear
use i_t.dta
gen month=month(date)

gen X_40_jul=1 if month==7
replace X_40_jul=0 if X_40_jul==.

gen X_40_aug=1 if month==8
replace X_40_aug=0 if X_40_aug==.

gen X_40_sep=1 if month==9
replace X_40_sep=0 if X_40_sep==.

gen X_40_oct=1 if month==10
replace X_40_oct=0 if X_40_oct==.

sort r date
drop month
save i_t.dta,replace









*create Y_6
clear
use player.dta
sort r date time
bysort r date: gen order=_n
replace order=order-1
rename time time_next
save match.dta,replace

clear
use buy_new.dta
keep r date time imoney
rename time buy_time
save buy_temp.dta,replace

clear
use player.dta
sort r date time
bysort r date: gen order=_n
merge m:m r date order using match.dta
keep if _merge==3
drop _merge
rename order g
merge m:m r date using buy_temp.dta
keep if _merge==3
drop _merge
keep if buy_time>=time & buy_time<time_next




