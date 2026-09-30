# Instrument Selection Recommendation System

## Database Programming (DPG621S)

### Group 1

The **Instrument Selection Recommendation System** is a database programming project developed for the Database Programming course.

The purpose of the system is to help users find musical instruments that may suit them based on their personality, musical interests, preferred genres and experience level.

---

## Project Team

|      Full Name     | Student Number |
|--------------------|----------------|
| Jone Sampanha      | 223029912      |
| Jessica Richter    | 219134901      |
| Paul Sikokwani     | 200600893      |
| Dumisani Ngwira    | 220104689      |
| Natalia Nakwatumba | 225058308      |

**Course Coordinator:** Dr. G. K. Kapuire  
**Course:** Database Programming (DPG621S)  
**Group:** 1

---

## Project Objective

The main objective of the project is to create a database-driven application that recommends suitable musical instruments to users.

The system stores information about users, personalities, musical experience, genres, instruments and recommendations.

---

## Main Features

The system allows users to:

- Create an account
- Log in to the system
- Enter and update personal information
- Select their personality
- Select their musical experience level
- Choose preferred music genres
- View available musical instruments
- Receive instrument recommendations
- View their profile
- Log out

The system also allows an administrator to manage users and instrument information.

---

## Database

The project uses a relational database created in **Microsoft SQL Server**.

The main database tables include:

- `USER`
- `PERSONALITY`
- `MUSICAL_BACKGROUND`
- `GENRE`
- `CATEGORY`
- `INSTRUMENT`
- `RECOMMENDATION`
- `USER_GENRE`
- `INSTRUMENT_GENRE`
- `RECOMMENDATION_INSTRUMENT`
- `AUDIT_LOG`

Primary keys and foreign keys are used to connect related information between the tables.

The final SQL script contains the database structure, relationships, constraints, stored procedures, triggers and the basic data needed by the application.

---

## Stored Procedures

Stored procedures are used to perform database operations and keep some of the SQL logic inside the database.

Examples used in the project include:

### `sp_RegisterUser`

Registers a new user in the system.

### `sp_SaveUserGenrePreference`

Saves a genre selected by a user.

### `sp_GenerateUserRecommendations`

Finds instruments connected to the user's preferred genres and is used as part of the recommendation process.

The final database also contains additional procedures used by the completed prototype.

---

## Triggers

The project contains database triggers.

### `trg_UserRegistrationAudit`

Automatically records a new user registration in the audit log.

### `trg_ValidateRecommendationScore`

Checks that a recommendation match score is between `0` and `100` before it is stored.

---

## Technologies Used

The project uses:

- Python
- Flask
- HTML
- CSS
- SQL
- Microsoft SQL Server
- Git
- GitHub

---

## Project Structure

```text
InstrumentRecommendationSystem/
│
├── app.py
├── templates/
├── static/
├── database/
├── requirements.txt
├── .env
├── .gitignore
└── README.md
```

The exact files inside the folders may be different depending on the final version of the prototype.

---

## How to Run the Project

### 1. Prepare the database

Open **Microsoft SQL Server Management Studio (SSMS)** and run the final SQL script supplied with the project.

The script creates or updates the database objects required by the prototype.

### 2. Open the project folder

Open the project folder in Visual Studio Code or another code editor.

### 3. Install the Python requirements

In the terminal, run:

```bash
pip install -r requirements.txt
```

### 4. Configure the environment file

Create or update the `.env` file with the local settings required by the application.

Do not upload real secret keys, database passwords or other private information to GitHub.

Example:

```text
SECRET_KEY=your-own-secret-key
```

Use your own local values where required.

### 5. Start the application

Run:

```bash
python app.py
```

### 6. Open the prototype

After the Flask application starts, open the local address shown in the terminal in a web browser.

For example, Flask commonly uses:

```text
http://127.0.0.1:5000
```

The exact address can be different depending on the computer and application settings.

---

## Security Note

The submitted SQL file does **not** include existing users' real passwords or password hashes.

Passwords and secret keys should not be written directly in the README or uploaded publicly.

The `.env` file should also be kept private if it contains real credentials or secret values.

---

## Final Submission

The final project submission should contain the latest revised version of the work, including:

- Completed prototype
- Final/revised SQL database script
- Stored procedures
- Triggers
- Database design work
- Log sheet
- Testing or supporting project work required for the submission

The SQL script and prototype should match each other so that the application can connect to and use the final database correctly.

---

## Project Purpose

This project was created to demonstrate the use of database design, SQL programming and a simple Flask application to solve a real-life problem.

The recommendation system helps a user choose musical instruments by using information such as personality, musical experience and preferred genres.
