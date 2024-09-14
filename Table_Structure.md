# STRUCTURE OF USER TABLE
| Field | Type | Null | Key | Default | Extra |
|---|---|---|---|---|---|       
| os | varchar(25) | YES | | NULL | |
| model | varchar(255) | YES | | NULL | |
| isPhysicalDevice | varchar(10) | YES | | NULL | |
| name |  varchar(255) | YES | | NULL | |
| uid | varchar(255) | NO | PRI | NULL | |
# STRUCTURE OF TABLE FOR EACH USER.
| Field | Type | Null | Key | Default | Extra |
|---|---|---|---|---|---|
| label | varchar(255) | YES | | NULL | |
| title | varchar(255) | YES | | NULL | |
| details | varchar(255) | YES | | NULL | |
| date | date | YES | | NULL | |
| time | time | YES | | NULL | |
| important | varchar(0) | YES | | NULL | |
| complete | varchar(0) | YES | | NULL | |
