# **ToDo-App**
## A multi-platform ToDo App written in flutter while having real-time data synchronisation.
***
## WINDOWS/LINUX
![image](https://github.com/user-attachments/assets/de999747-c388-4383-9f46-ab5134e9df39)
***
## ANDROID 
![Screenshot_2024-09-13-17-43-39-80_d09b905abf7f8178a2728afe155283c0](https://github.com/user-attachments/assets/902165a1-943e-473c-a473-acfca00c4345)

*** 
# ABOUT
This Application uses a mysql database to read/write/store data.<br/>
Every Action gets automatically updated.<br/>If the Application is deleted the data still remains intact.
***
# HOW TO DOWNLOAD 
## WINDOWS.
+ [Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170) is required for to run this application
+ [You can Download it from here.](https://drive.google.com/file/d/1b7x0vt2NdB1YblGVyE93mAQguHZ01kq3/view?usp=sharing)<br/>
## ANDROID.
+ [You can Download it from here.](https://drive.google.com/file/d/1_ovZbv6dVy_or72Ep25YAPf1O0L_92ub/view?usp=sharing) <br/>
## LINUX.
+
***
# LABELS 
Labels can be used to oragnise tasks.<br/>
Similar type of tasks can be put under a single label.
***
# HOW TO USE
## 1.Creating a Task.
A Task can be Created by simply selecting a label and pressing on the new task button <br/>
![image](https://github.com/user-attachments/assets/d64fde69-9700-4c91-98ed-abfc79a180c6)

>[!NOTE]
> Tasks cannot have same title and title is case sensitive.
> A Task will not be created with an empty title.
> Other Fields are optional.

>[!IMPORTANT]
>The Task will be save automatically when the page is closed.

## 2.Updating a Task.
A Task can be updated by simply pressing on the title of the task on the homepage. <br/>
![image](https://github.com/user-attachments/assets/f5d2b480-f836-48a1-94c5-de3eaf0bc95f) <br/>
![image](https://github.com/user-attachments/assets/9e8ca0ca-4f7d-4742-a129-087e4ec0c386)

>[!NOTE]
> If title is set to empty then the task will not get update.

>[!IMPORTANT]
>The Task will be save automatically when the page is closed.

## 3.Marking a task as completed or incomplete  
### A task can be marked as completed or incomplete in two ways.
1.By holding the title of the task. <br/>
![image](https://github.com/user-attachments/assets/7f6cdeb1-17bb-41d7-afcf-c245646c75b3) <br/>
2. Or by pressing on the title of the task and then pressing mark as completed button. <br/>
![image](https://github.com/user-attachments/assets/f219e6ab-98b3-43a4-84cd-a648bc7c69c2) <br/>

## 4.Dos and Don'ts 
1. Try to keep Title short and unique.
2. Try to keep detail short and simple enough to describe the title.
3. A label with empty tasks will be automatically deleted.
4. Titles and labels are case sensitive i.e.. Hello ≠ HELLO.
5. If Two Tasks/Labels with same text/name exists then the one created first will be displayed.
6. Escape characters like ```\n``` and ```\t``` can be used to decorate.

## 5.Commands
1. ```iscompleted:``` if this command is entered in the search box, only the completed tasks from a specific label will appear.
2. ```isimportant:``` if this command is entered in the search box, only the important tasks from a specific label will appear.
3. ```isnotimportant:``` if this command is entered in the search box, only the non-important tasks from a specific label will appear.
4. ```isnotcompleted:``` if this command is entered in the search box, only the non-completed tasks from a specific label will appear.
***
# BUG REPORTS CAN BE SENT TO hellf0rg0d _AT_ proton.me

