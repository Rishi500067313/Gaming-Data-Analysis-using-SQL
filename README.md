# SQL_Logic_Build_Practice
Assignment for SQL

Questions:

1. prep_user has the game data for a user per day on a platform. Check if there are any duplicates for an event on August 1st, 2022.

2. user_login contains all of the events/rows from prep_user of type 'purchase'. Count the number of users that made a purchase, but didn't make it in user_login.

3. There was a backfill run for prep_user for the following dates: August 1st - Aug 5th, 2022. How would you check the backfill?

4. user_login.first_login_date is first day from prep_user.date for a given user_key irrespective of type login or transaction. Write a query to identify first_login_date mismatches between prep_user & user_login.

5. "dim_user contains list of user_ids processed on a given day(date_id). Identify unique users starts with ‘-‘ (the symbol hyphen) who didn't make a purchase on a given day.
    Note: date from prep_user should be used to join with date_id from dim_user table."

6. From prep_score table identify user_id per day per platform who scored second highest.
            A. Query using window function
            B. Query without using window function"

7. From raw_events table, title can be identified by tid and platform can be identified by plat in the event_params. Count distinct number of users per title per platform.

8. From raw_events table, Retrieve the ‘character_attr’ JSON struct from ‘event_params’.  Result should expand ‘character_attr’ which is an array of JSON struct into columns that contains the possible attribute within the JSON struct (i.e. ‘selection’, ‘type’, ‘target’).


![image](https://github.com/Rishi500067313/SQL_Logic_Build_Practice/assets/50805925/bff85662-68e7-4bb0-a05c-89f30e52b076)
