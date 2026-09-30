USE master;
GO

IF DB_ID('InstrumentSelectionRecommendationSystem') IS NULL
BEGIN
    CREATE DATABASE InstrumentSelectionRecommendationSystem;
END;
GO

USE InstrumentSelectionRecommendationSystem;
GO

IF OBJECT_ID('dbo.AUDIT_LOG', 'U') IS NULL
BEGIN
    CREATE TABLE AUDIT_LOG (
        log_id INT PRIMARY KEY IDENTITY(1,1),
        event_type VARCHAR(50) NOT NULL,
        description VARCHAR(MAX) NOT NULL,
        created_at DATETIME DEFAULT GETDATE()
    );
END;
GO

IF OBJECT_ID('dbo.CATEGORY', 'U') IS NULL
BEGIN
    CREATE TABLE CATEGORY (
        category_id INT PRIMARY KEY IDENTITY(1,1),
        category_name VARCHAR(50) NOT NULL UNIQUE
    );
END;
GO

IF OBJECT_ID('dbo.MUSICAL_BACKGROUND', 'U') IS NULL
BEGIN
    CREATE TABLE MUSICAL_BACKGROUND (
        background_id INT PRIMARY KEY IDENTITY(1,1),
        experience_level VARCHAR(20) NOT NULL
            CHECK (experience_level IN ('Beginner', 'Intermediate', 'Advanced'))
    );
END;
GO

IF OBJECT_ID('dbo.PERSONALITY', 'U') IS NULL
BEGIN
    CREATE TABLE PERSONALITY (
        personality_id INT PRIMARY KEY IDENTITY(1,1),
        personality_type VARCHAR(50) NOT NULL UNIQUE,
        details VARCHAR(MAX)
    );
END;
GO

IF OBJECT_ID('dbo.GENRE', 'U') IS NULL
BEGIN
    CREATE TABLE GENRE (
        genre_id INT PRIMARY KEY IDENTITY(1,1),
        genre_name VARCHAR(50) NOT NULL UNIQUE
    );
END;
GO

IF OBJECT_ID('dbo.[USER]', 'U') IS NULL
BEGIN
    CREATE TABLE [USER] (
        user_id INT PRIMARY KEY IDENTITY(1,1),
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        first_name VARCHAR(50) NOT NULL,
        last_name VARCHAR(50) NOT NULL,
        email VARCHAR(100) NOT NULL UNIQUE,
        role VARCHAR(20) NOT NULL DEFAULT 'User'
            CHECK (role IN ('User', 'Admin')),
        personality_id INT NULL,
        background_id INT NULL,
        FOREIGN KEY (personality_id) REFERENCES PERSONALITY(personality_id) ON DELETE SET NULL,
        FOREIGN KEY (background_id) REFERENCES MUSICAL_BACKGROUND(background_id) ON DELETE SET NULL
    );
END;
GO

IF OBJECT_ID('dbo.INSTRUMENT', 'U') IS NULL
BEGIN
    CREATE TABLE INSTRUMENT (
        instrument_id INT PRIMARY KEY IDENTITY(1,1),
        instrument_name VARCHAR(100) NOT NULL UNIQUE,
        type VARCHAR(50),
        difficulty_level VARCHAR(20) NOT NULL
            CHECK (difficulty_level IN ('Easy', 'Medium', 'Hard')),
        description VARCHAR(MAX),
        min_price DECIMAL(10,2) NULL CHECK (min_price >= 0 OR min_price IS NULL),
        noise_level VARCHAR(20) NULL
            CHECK (noise_level IN ('Low', 'Medium', 'High') OR noise_level IS NULL),
        headphone_support BIT NOT NULL DEFAULT 0,
        portable BIT NOT NULL DEFAULT 0,
        recommended_practice_minutes INT NULL
            CHECK (recommended_practice_minutes > 0 OR recommended_practice_minutes IS NULL),
        category_id INT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID('dbo.RECOMMENDATION', 'U') IS NULL
BEGIN
    CREATE TABLE RECOMMENDATION (
        recommendation_id INT PRIMARY KEY IDENTITY(1,1),
        match_score DECIMAL(5,2) NOT NULL CHECK (match_score BETWEEN 0 AND 100),
        ranking INT NOT NULL CHECK (ranking > 0),
        user_id INT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID('dbo.USER_GENRE', 'U') IS NULL
BEGIN
    CREATE TABLE USER_GENRE (
        user_id INT NOT NULL,
        genre_id INT NOT NULL,
        PRIMARY KEY (user_id, genre_id),
        FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE CASCADE,
        FOREIGN KEY (genre_id) REFERENCES GENRE(genre_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID('dbo.INSTRUMENT_GENRE', 'U') IS NULL
BEGIN
    CREATE TABLE INSTRUMENT_GENRE (
        instrument_id INT NOT NULL,
        genre_id INT NOT NULL,
        PRIMARY KEY (instrument_id, genre_id),
        FOREIGN KEY (instrument_id) REFERENCES INSTRUMENT(instrument_id) ON DELETE CASCADE,
        FOREIGN KEY (genre_id) REFERENCES GENRE(genre_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID('dbo.INSTRUMENT_PERSONALITY', 'U') IS NULL
BEGIN
    CREATE TABLE INSTRUMENT_PERSONALITY (
        instrument_id INT NOT NULL,
        personality_id INT NOT NULL,
        PRIMARY KEY (instrument_id, personality_id),
        FOREIGN KEY (instrument_id) REFERENCES INSTRUMENT(instrument_id) ON DELETE CASCADE,
        FOREIGN KEY (personality_id) REFERENCES PERSONALITY(personality_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID('dbo.RECOMMENDATION_INSTRUMENT', 'U') IS NULL
BEGIN
    CREATE TABLE RECOMMENDATION_INSTRUMENT (
        recommendation_id INT NOT NULL,
        instrument_id INT NOT NULL,
        PRIMARY KEY (recommendation_id, instrument_id),
        FOREIGN KEY (recommendation_id) REFERENCES RECOMMENDATION(recommendation_id) ON DELETE CASCADE,
        FOREIGN KEY (instrument_id) REFERENCES INSTRUMENT(instrument_id) ON DELETE CASCADE
    );
END;
GO

IF OBJECT_ID('dbo.USER_PREFERENCE', 'U') IS NULL
BEGIN
    CREATE TABLE USER_PREFERENCE (
        preference_id INT PRIMARY KEY IDENTITY(1,1),
        user_id INT NOT NULL UNIQUE,
        budget DECIMAL(10,2) NULL CHECK (budget >= 0 OR budget IS NULL),
        noise_preference VARCHAR(20) NULL
            CHECK (noise_preference IN ('Low', 'Medium', 'High') OR noise_preference IS NULL),
        headphone_required BIT NOT NULL DEFAULT 0,
        portability_required BIT NOT NULL DEFAULT 0,
        practice_time_minutes INT NULL
            CHECK (practice_time_minutes > 0 OR practice_time_minutes IS NULL),
        playing_setting VARCHAR(50) NULL,
        FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM CATEGORY)
BEGIN
    SET IDENTITY_INSERT CATEGORY ON;
    INSERT INTO CATEGORY (category_id, category_name) VALUES
        (1, 'Strings'),
        (2, 'Keyboards'),
        (3, 'Percussion'),
        (4, 'Wind');
    SET IDENTITY_INSERT CATEGORY OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM GENRE)
BEGIN
    SET IDENTITY_INSERT GENRE ON;
    INSERT INTO GENRE (genre_id, genre_name) VALUES
        (1, 'Gospel'),
        (2, 'Jazz'),
        (3, 'Rock'),
        (4, 'Classical'),
        (5, 'Pop');
    SET IDENTITY_INSERT GENRE OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM MUSICAL_BACKGROUND)
BEGIN
    SET IDENTITY_INSERT MUSICAL_BACKGROUND ON;
    INSERT INTO MUSICAL_BACKGROUND (background_id, experience_level) VALUES
        (1, 'Beginner'),
        (2, 'Intermediate'),
        (3, 'Advanced');
    SET IDENTITY_INSERT MUSICAL_BACKGROUND OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM PERSONALITY)
BEGIN
    SET IDENTITY_INSERT PERSONALITY ON;
    INSERT INTO PERSONALITY (personality_id, personality_type, details) VALUES
        (1, 'Creative', 'Enjoys creativity, expression and experimenting with ideas.'),
        (2, 'Outgoing', 'Enjoys energetic and social activities.'),
        (3, 'Calm', 'Prefers focused, relaxed and controlled activities.'),
        (4, 'Energetic', 'Enjoys active, powerful and high-energy activities.');
    SET IDENTITY_INSERT PERSONALITY OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM INSTRUMENT)
BEGIN
    SET IDENTITY_INSERT INSTRUMENT ON;
    INSERT INTO INSTRUMENT
        (instrument_id, instrument_name, type, difficulty_level, description, min_price,
         noise_level, headphone_support, portable, recommended_practice_minutes, category_id)
    VALUES
        (1, 'Acoustic Guitar', 'Acoustic', 'Easy', 'A string instrument suitable for many styles of music.', 2500.00, 'Medium', 0, 1, 30, 1),
        (2, 'Electric Guitar', 'Electric', 'Medium', 'An electric string instrument commonly used in rock and pop music.', 4000.00, 'Medium', 1, 1, 45, 1),
        (3, 'Piano', 'Acoustic', 'Medium', 'A keyboard instrument suitable for classical, jazz and other styles.', 12000.00, 'Medium', 0, 0, 60, 2),
        (4, 'Digital Keyboard', 'Electronic', 'Easy', 'An electronic keyboard that can be used with headphones.', 3500.00, 'Low', 1, 1, 30, 2),
        (5, 'Drums', 'Acoustic', 'Medium', 'A percussion instrument suitable for rhythmic and energetic playing.', 7000.00, 'High', 0, 0, 45, 3),
        (6, 'Violin', 'Acoustic', 'Hard', 'A string instrument commonly used in classical and expressive music.', 3000.00, 'Medium', 0, 1, 60, 1),
        (7, 'Saxophone', 'Acoustic', 'Medium', 'A wind instrument commonly associated with jazz and other styles.', 6000.00, 'High', 0, 1, 45, 4),
        (8, 'Flute', 'Acoustic', 'Medium', 'A portable wind instrument often used in classical music.', 2500.00, 'Medium', 0, 1, 30, 4);
    SET IDENTITY_INSERT INSTRUMENT OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM INSTRUMENT_GENRE)
BEGIN
    INSERT INTO INSTRUMENT_GENRE (instrument_id, genre_id) VALUES
        (1,1), (1,3), (1,5),
        (2,1), (2,3), (2,5),
        (3,1), (3,2), (3,4),
        (4,1), (4,2), (4,5),
        (5,1), (5,2), (5,3), (5,5),
        (6,4), (6,5),
        (7,1), (7,2),
        (8,2), (8,4);
END;
GO

IF NOT EXISTS (SELECT 1 FROM INSTRUMENT_PERSONALITY)
BEGIN
    INSERT INTO INSTRUMENT_PERSONALITY (instrument_id, personality_id) VALUES
        (1,1), (1,3),
        (2,1), (2,2), (2,4),
        (3,1), (3,3),
        (4,1), (4,3),
        (5,2), (5,4),
        (6,1), (6,3),
        (7,1), (7,2),
        (8,3);
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_AdminAddInstrument]
    @InstrumentName VARCHAR(100),
    @Type VARCHAR(50),
    @DifficultyLevel VARCHAR(20),
    @Description VARCHAR(MAX),
    @MinPrice DECIMAL(10,2),
    @NoiseLevel VARCHAR(20),
    @HeadphoneSupport BIT,
    @Portable BIT,
    @RecommendedPracticeMinutes INT,
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO INSTRUMENT
    (
        instrument_name,
        type,
        difficulty_level,
        description,
        min_price,
        noise_level,
        headphone_support,
        portable,
        recommended_practice_minutes,
        category_id
    )
    VALUES
    (
        @InstrumentName,
        @Type,
        @DifficultyLevel,
        @Description,
        @MinPrice,
        @NoiseLevel,
        @HeadphoneSupport,
        @Portable,
        @RecommendedPracticeMinutes,
        @CategoryID
    );
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_AdminDeleteInstrument]
    @InstrumentID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM INSTRUMENT
    WHERE instrument_id = @InstrumentID;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_AdminDeleteUser]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [USER]
    WHERE user_id = @UserID;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_AdminGetUsers]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.user_id,
        u.username,
        u.first_name,
        u.last_name,
        u.email,
        u.role,
        p.personality_type,
        mb.experience_level
    FROM [USER] u

    LEFT JOIN PERSONALITY p
        ON u.personality_id = p.personality_id

    LEFT JOIN MUSICAL_BACKGROUND mb
        ON u.background_id = mb.background_id

    ORDER BY u.user_id;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_AdminUpdateInstrument]
    @InstrumentID INT,
    @InstrumentName VARCHAR(100),
    @Type VARCHAR(50),
    @DifficultyLevel VARCHAR(20),
    @Description VARCHAR(MAX),
    @MinPrice DECIMAL(10,2),
    @NoiseLevel VARCHAR(20),
    @HeadphoneSupport BIT,
    @Portable BIT,
    @RecommendedPracticeMinutes INT,
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE INSTRUMENT
    SET
        instrument_name = @InstrumentName,
        type = @Type,
        difficulty_level = @DifficultyLevel,
        description = @Description,
        min_price = @MinPrice,
        noise_level = @NoiseLevel,
        headphone_support = @HeadphoneSupport,
        portable = @Portable,
        recommended_practice_minutes = @RecommendedPracticeMinutes,
        category_id = @CategoryID
    WHERE instrument_id = @InstrumentID;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_AdminUpdateUserRole]
    @UserID INT,
    @Role VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [USER]
    SET role = @Role
    WHERE user_id = @UserID;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GenerateUserRecommendations]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM RECOMMENDATION
    WHERE user_id = @UserID;
    CREATE TABLE #Scores
    (
        instrument_id INT,
        match_score DECIMAL(5,2)
    );
    INSERT INTO #Scores
    (
        instrument_id,
        match_score
    )
    SELECT
        i.instrument_id,
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM USER_GENRE ug
                INNER JOIN INSTRUMENT_GENRE ig
                    ON ug.genre_id = ig.genre_id
                WHERE ug.user_id = @UserID
                  AND ig.instrument_id = i.instrument_id
            )
            THEN 40
            ELSE 0
        END
        +
        CASE
            WHEN EXISTS
            (
                SELECT 1
                FROM INSTRUMENT_PERSONALITY ip
                WHERE ip.instrument_id = i.instrument_id
                  AND ip.personality_id = u.personality_id
            )
            THEN 30
            ELSE 0
        END
        +
        CASE
            WHEN mb.experience_level = 'Beginner'
                 AND i.difficulty_level = 'Easy'
                THEN 20
            WHEN mb.experience_level = 'Intermediate'
                 AND i.difficulty_level IN ('Easy', 'Medium')
                THEN 20
            WHEN mb.experience_level = 'Advanced'
                 AND i.difficulty_level IN ('Easy', 'Medium', 'Hard')
                THEN 20
            ELSE 0
        END
        +
        CASE
            WHEN
                (
                    up.budget IS NULL
                    OR i.min_price IS NULL
                    OR i.min_price <= up.budget
                )
                AND
                (
                    up.noise_preference IS NULL
                    OR
                    (
                        up.noise_preference = 'Low'
                        AND i.noise_level = 'Low'
                    )
                    OR
                    (
                        up.noise_preference = 'Medium'
                        AND i.noise_level IN ('Low', 'Medium')
                    )
                    OR
                    (
                        up.noise_preference = 'High'
                        AND i.noise_level IN ('Low', 'Medium', 'High')
                    )
                )
                AND
                (
                    up.headphone_required = 0
                    OR i.headphone_support = 1
                )
                AND
                (
                    up.portability_required = 0
                    OR i.portable = 1
                )
                AND
                (
                    up.practice_time_minutes IS NULL
                    OR i.recommended_practice_minutes IS NULL
                    OR i.recommended_practice_minutes
                        <= up.practice_time_minutes
                )
            THEN 10
            ELSE 0
        END
    FROM INSTRUMENT i
    CROSS JOIN [USER] u
    LEFT JOIN MUSICAL_BACKGROUND mb
        ON u.background_id = mb.background_id
    LEFT JOIN USER_PREFERENCE up
        ON u.user_id = up.user_id
    WHERE u.user_id = @UserID;
    DECLARE @InstrumentID INT;
    DECLARE @Score DECIMAL(5,2);
    DECLARE @Ranking INT = 1;
    DECLARE @RecommendationID INT;
    DECLARE RecommendationCursor CURSOR LOCAL FOR
        SELECT
            instrument_id,
            match_score
        FROM #Scores
        WHERE match_score > 0
        ORDER BY
            match_score DESC,
            instrument_id ASC;
    OPEN RecommendationCursor;
    FETCH NEXT FROM RecommendationCursor
    INTO @InstrumentID, @Score;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO RECOMMENDATION
        (
            match_score,
            ranking,
            user_id
        )
        VALUES
        (
            @Score,
            @Ranking,
            @UserID
        );
        SET @RecommendationID = SCOPE_IDENTITY();
        INSERT INTO RECOMMENDATION_INSTRUMENT
        (
            recommendation_id,
            instrument_id
        )
        VALUES
        (
            @RecommendationID,
            @InstrumentID
        );
        SET @Ranking = @Ranking + 1;
        FETCH NEXT FROM RecommendationCursor
        INTO @InstrumentID, @Score;
    END;
    CLOSE RecommendationCursor;
    DEALLOCATE RecommendationCursor;
    SELECT
        r.ranking,
        i.instrument_name,
        r.match_score,
        i.type,
        i.difficulty_level,
        c.category_name,
        i.description
    FROM RECOMMENDATION r
    INNER JOIN RECOMMENDATION_INSTRUMENT ri
        ON r.recommendation_id = ri.recommendation_id
    INNER JOIN INSTRUMENT i
        ON ri.instrument_id = i.instrument_id
    INNER JOIN CATEGORY c
        ON i.category_id = c.category_id
    WHERE r.user_id = @UserID
    ORDER BY r.ranking;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_LoginUser]
    @Username VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        user_id,
        username,
        email,
        password,
        first_name,
        last_name,
        role,
        personality_id,
        background_id
    FROM [USER]
    WHERE username = @Username;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_RegisterUser]
    @Username VARCHAR(50),
    @Email VARCHAR(100),
    @Password VARCHAR(255),
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @PersonalityID INT = NULL,
    @BackgroundID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM [USER]
            WHERE username = @Username
        )
        BEGIN
            RAISERROR('Username already exists.', 16, 1);
        END;

        IF EXISTS (
            SELECT 1
            FROM [USER]
            WHERE email = @Email
        )
        BEGIN
            RAISERROR('Email already exists.', 16, 1);
        END;

        INSERT INTO [USER]
        (
            username,
            email,
            password,
            first_name,
            last_name,
            role,
            personality_id,
            background_id
        )
        VALUES
        (
            @Username,
            @Email,
            @Password,
            @FirstName,
            @LastName,
            'User',
            @PersonalityID,
            @BackgroundID
        );

        SELECT SCOPE_IDENTITY() AS NewUserID;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_RemoveUserGenrePreference]
    @UserID INT,
    @GenreID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM USER_GENRE
    WHERE user_id = @UserID
      AND genre_id = @GenreID;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_ResetUserPassword]
    @Email VARCHAR(100),
    @NewPassword VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM [USER]
        WHERE email = @Email
    )
    BEGIN
        RAISERROR('Email address not found.', 16, 1);
        RETURN;
    END;

    UPDATE [USER]
    SET password = @NewPassword
    WHERE email = @Email;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_SaveUserGenrePreference]
    @UserID INT,
    @GenreID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM USER_GENRE
        WHERE user_id = @UserID
          AND genre_id = @GenreID
    )
    BEGIN
        INSERT INTO USER_GENRE
        (
            user_id,
            genre_id
        )
        VALUES
        (
            @UserID,
            @GenreID
        );
    END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_SaveUserPreferences]
    @UserID INT,
    @Budget DECIMAL(10,2) = NULL,
    @NoisePreference VARCHAR(20) = NULL,
    @HeadphoneRequired BIT = 0,
    @PortabilityRequired BIT = 0,
    @PracticeTimeMinutes INT = NULL,
    @PlayingSetting VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM USER_PREFERENCE
        WHERE user_id = @UserID
    )
    BEGIN
        UPDATE USER_PREFERENCE
        SET
            budget = @Budget,
            noise_preference = @NoisePreference,
            headphone_required = @HeadphoneRequired,
            portability_required = @PortabilityRequired,
            practice_time_minutes = @PracticeTimeMinutes,
            playing_setting = @PlayingSetting
        WHERE user_id = @UserID;
    END
    ELSE
    BEGIN
        INSERT INTO USER_PREFERENCE
        (
            user_id,
            budget,
            noise_preference,
            headphone_required,
            portability_required,
            practice_time_minutes,
            playing_setting
        )
        VALUES
        (
            @UserID,
            @Budget,
            @NoisePreference,
            @HeadphoneRequired,
            @PortabilityRequired,
            @PracticeTimeMinutes,
            @PlayingSetting
        );
    END;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_SearchInstruments]
    @SearchText VARCHAR(100) = NULL,
    @CategoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        i.instrument_id,
        i.instrument_name,
        i.type,
        i.difficulty_level,
        i.description,
        i.min_price,
        i.noise_level,
        i.headphone_support,
        i.portable,
        c.category_name
    FROM INSTRUMENT i

    INNER JOIN CATEGORY c
        ON i.category_id = c.category_id

    WHERE
        (
            @SearchText IS NULL
            OR i.instrument_name LIKE '%' + @SearchText + '%'
            OR i.description LIKE '%' + @SearchText + '%'
        )

        AND
        (
            @CategoryID IS NULL
            OR i.category_id = @CategoryID
        )

    ORDER BY i.instrument_name;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_UpdateUserProfile]
    @UserID INT,
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @PersonalityID INT = NULL,
    @BackgroundID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if another user already has this email
    IF EXISTS (
        SELECT 1
        FROM [USER]
        WHERE email = @Email
          AND user_id <> @UserID
    )
    BEGIN
        RAISERROR('Email already belongs to another user.', 16, 1);
        RETURN;
    END;

    UPDATE [USER]
    SET
        first_name = @FirstName,
        last_name = @LastName,
        email = @Email,
        personality_id = @PersonalityID,
        background_id = @BackgroundID
    WHERE user_id = @UserID;

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('User not found.', 16, 1);
    END;
END;
GO

CREATE OR ALTER TRIGGER [dbo].[trg_RecommendationAudit]
ON [dbo].[RECOMMENDATION]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AUDIT_LOG
    (
        event_type,
        description
    )
    SELECT
        'RECOMMENDATION_CREATED',
        CONCAT(
            'Recommendation created for User ID ',
            user_id,
            ' with score ',
            match_score,
            ' and ranking ',
            ranking
        )
    FROM inserted;
END;
GO

CREATE OR ALTER TRIGGER [dbo].[trg_UserRegistrationAudit]
ON [dbo].[USER]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AUDIT_LOG (event_type, description)
    SELECT
        'USER_REGISTERED',
        CONCAT(
            'New user registered: ',
            username,
            ' (User ID: ',
            user_id,
            ')'
        )
    FROM inserted;
END;
GO