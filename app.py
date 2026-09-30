import os
from flask import Flask, render_template, request, redirect, session
from database import get_connection
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)

app.secret_key = os.getenv("SECRET_KEY")


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/register", methods=["GET", "POST"])
def register():

    if request.method == "POST":

        username = request.form["username"]
        first_name = request.form["first_name"]
        last_name = request.form["last_name"]
        email = request.form["email"]
        password = request.form["password"]

        password_hash = generate_password_hash(password)

        connection = None
        cursor = None

        try:
            connection = get_connection()
            cursor = connection.cursor()

            cursor.execute(
                """
                EXEC sp_RegisterUser
                    @Username=?,
                    @Email=?,
                    @Password=?,
                    @FirstName=?,
                    @LastName=?
                """,
                username,
                email,
                password_hash,
                first_name,
                last_name
            )


            row = cursor.fetchone()

            connection.commit()

            return render_template(
                "register.html",
                success="Account created successfully!"
            )

        except Exception as error:

            if connection:
                connection.rollback()

            return render_template(
                "register.html",
                error=str(error)
            )

        finally:

            if cursor:
                cursor.close()

            if connection:
                connection.close()

    return render_template("register.html")

@app.route("/login", methods=["GET", "POST"])
def login():

    if request.method == "POST":

        username = request.form["username"]
        password = request.form["password"]

        connection = None
        cursor = None

        try:
            connection = get_connection()
            cursor = connection.cursor()

            cursor.execute(
                """
                EXEC sp_LoginUser
                    @Username=?
                """,
                username
            )

            user = cursor.fetchone()

            if user is None:
                return render_template(
                    "login.html",
                    error="Username not found."
                )

            if not check_password_hash(user.password, password):
                return render_template(
                    "login.html",
                    error="Incorrect password."
                )


            session["user_id"] = user.user_id
            session["username"] = user.username
            session["first_name"] = user.first_name
            session["role"] = user.role

            return redirect("/dashboard")

        except Exception as error:

            return render_template(
                "login.html",
                error=str(error)
            )

        finally:

            if cursor:
                cursor.close()

            if connection:
                connection.close()

    return render_template("login.html")

@app.route("/dashboard")
def dashboard():

    if "user_id" not in session:
        return redirect("/login")

    return render_template(
        "dashboard.html",
        username=session["username"],
        first_name=session["first_name"],
        role=session["role"]
    )

@app.route("/logout")
def logout():

    session.clear()

    return redirect("/")

@app.route("/profile", methods=["GET", "POST"])
def profile():


    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    connection = None
    cursor = None

    try:
        connection = get_connection()
        cursor = connection.cursor()





        if request.method == "POST":

            first_name = request.form["first_name"]
            last_name = request.form["last_name"]
            email = request.form["email"]

            personality_id = request.form["personality_id"]
            background_id = request.form["background_id"]


            if personality_id == "":
                personality_id = None

            if background_id == "":
                background_id = None

            cursor.execute(
                """
                EXEC sp_UpdateUserProfile
                    @UserID=?,
                    @FirstName=?,
                    @LastName=?,
                    @Email=?,
                    @PersonalityID=?,
                    @BackgroundID=?
                """,
                user_id,
                first_name,
                last_name,
                email,
                personality_id,
                background_id
            )

            connection.commit()


            session["first_name"] = first_name





        cursor.execute(
            """
            SELECT
                user_id,
                username,
                first_name,
                last_name,
                email,
                personality_id,
                background_id
            FROM [USER]
            WHERE user_id = ?
            """,
            user_id
        )

        user = cursor.fetchone()





        cursor.execute(
            """
            SELECT
                personality_id,
                personality_type
            FROM PERSONALITY
            ORDER BY personality_id
            """
        )

        personalities = cursor.fetchall()





        cursor.execute(
            """
            SELECT
                background_id,
                experience_level
            FROM MUSICAL_BACKGROUND
            ORDER BY background_id
            """
        )

        backgrounds = cursor.fetchall()

        if request.method == "POST":

            return render_template(
                "profile.html",
                user=user,
                personalities=personalities,
                backgrounds=backgrounds,
                success="Profile updated successfully!"
            )

        return render_template(
            "profile.html",
            user=user,
            personalities=personalities,
            backgrounds=backgrounds
        )

    except Exception as error:

        if connection:
            connection.rollback()

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/preferences", methods=["GET", "POST"])
def preferences():

    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()





        if request.method == "POST":

            budget = request.form["budget"]
            noise_preference = request.form["noise_preference"]
            practice_time = request.form["practice_time"]
            playing_setting = request.form["playing_setting"]


            headphone_required = 1 if "headphone_required" in request.form else 0
            portability_required = 1 if "portability_required" in request.form else 0


            selected_genres = request.form.getlist("genres")


            if budget == "":
                budget = None

            if noise_preference == "":
                noise_preference = None

            if practice_time == "":
                practice_time = None

            if playing_setting == "":
                playing_setting = None


            cursor.execute(
                """
                EXEC sp_SaveUserPreferences
                    @UserID=?,
                    @Budget=?,
                    @NoisePreference=?,
                    @HeadphoneRequired=?,
                    @PortabilityRequired=?,
                    @PracticeTimeMinutes=?,
                    @PlayingSetting=?
                """,
                user_id,
                budget,
                noise_preference,
                headphone_required,
                portability_required,
                practice_time,
                playing_setting
            )


            cursor.execute(
                """
                DELETE FROM USER_GENRE
                WHERE user_id = ?
                """,
                user_id
            )


            for genre_id in selected_genres:

                cursor.execute(
                    """
                    EXEC sp_SaveUserGenrePreference
                        @UserID=?,
                        @GenreID=?
                    """,
                    user_id,
                    genre_id
                )

            connection.commit()





        cursor.execute(
            """
            SELECT
                budget,
                noise_preference,
                headphone_required,
                portability_required,
                practice_time_minutes,
                playing_setting
            FROM USER_PREFERENCE
            WHERE user_id = ?
            """,
            user_id
        )

        preference = cursor.fetchone()





        cursor.execute(
            """
            SELECT
                genre_id,
                genre_name
            FROM GENRE
            ORDER BY genre_name
            """
        )

        genres = cursor.fetchall()





        cursor.execute(
            """
            SELECT genre_id
            FROM USER_GENRE
            WHERE user_id = ?
            """,
            user_id
        )

        genre_rows = cursor.fetchall()

        selected_genres = []

        for row in genre_rows:
            selected_genres.append(row.genre_id)

        if request.method == "POST":

            return render_template(
                "preferences.html",
                preference=preference,
                genres=genres,
                selected_genres=selected_genres,
                success="Preferences saved successfully!"
            )

        return render_template(
            "preferences.html",
            preference=preference,
            genres=genres,
            selected_genres=selected_genres
        )

    except Exception as error:

        if connection:
            connection.rollback()

        return render_template(
            "preferences.html",
            preference=None,
            genres=[],
            selected_genres=[],
            error=str(error)
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/recommendations")
def recommendations():

    if "user_id" not in session:
        return redirect("/login")

    user_id = session["user_id"]

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC sp_GenerateUserRecommendations
                @UserID=?
            """,
            user_id
        )

        recommendations = cursor.fetchall()

        connection.commit()

        return render_template(
            "recommendations.html",
            recommendations=recommendations
        )

    except Exception as error:

        if connection:
            connection.rollback()

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/instruments")
def instruments():

    if "user_id" not in session:
        return redirect("/login")

    search_text = request.args.get("search", "")
    category_id = request.args.get("category_id", "")

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()


        cursor.execute(
            """
            SELECT
                category_id,
                category_name
            FROM CATEGORY
            ORDER BY category_name
            """
        )

        categories = cursor.fetchall()


        search_parameter = search_text if search_text != "" else None
        category_parameter = category_id if category_id != "" else None


        cursor.execute(
            """
            EXEC sp_SearchInstruments
                @SearchText=?,
                @CategoryID=?
            """,
            search_parameter,
            category_parameter
        )

        instrument_results = cursor.fetchall()

        return render_template(
            "instruments.html",
            instruments=instrument_results,
            categories=categories,
            search_text=search_text,
            selected_category=category_id
        )

    except Exception as error:

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/admin")
def admin():

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    return render_template(
        "admin.html",
        username=session["username"]
    )

@app.route("/admin/users")
def admin_users():

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC sp_AdminGetUsers
            """
        )

        users = cursor.fetchall()

        return render_template(
            "admin_users.html",
            users=users,
            session_user_id=session["user_id"]
        )

    except Exception as error:

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/admin/users/role", methods=["POST"])
def admin_change_user_role():

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    user_id = request.form["user_id"]
    role = request.form["role"]

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC sp_AdminUpdateUserRole
                @UserID=?,
                @Role=?
            """,
            user_id,
            role
        )

        connection.commit()

        return redirect("/admin/users")

    except Exception as error:

        if connection:
            connection.rollback()

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/admin/users/delete", methods=["POST"])
def admin_delete_user():

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    user_id = int(request.form["user_id"])


    if user_id == session["user_id"]:
        return "You cannot delete your own account."

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC sp_AdminDeleteUser
                @UserID=?
            """,
            user_id
        )

        connection.commit()

        return redirect("/admin/users")

    except Exception as error:

        if connection:
            connection.rollback()

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/admin/instruments")
def admin_instruments():

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
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
                i.recommended_practice_minutes,
                i.category_id,
                c.category_name
            FROM INSTRUMENT i

            INNER JOIN CATEGORY c
                ON i.category_id = c.category_id

            ORDER BY i.instrument_name
            """
        )

        instruments = cursor.fetchall()

        return render_template(
            "admin_instruments.html",
            instruments=instruments
        )

    except Exception as error:
        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/admin/instruments/add", methods=["GET", "POST"])
def admin_add_instrument():

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()


        cursor.execute(
            """
            SELECT
                category_id,
                category_name
            FROM CATEGORY
            ORDER BY category_name
            """
        )

        categories = cursor.fetchall()

        if request.method == "POST":

            instrument_name = request.form["instrument_name"]
            instrument_type = request.form["type"]
            difficulty = request.form["difficulty_level"]
            category_id = request.form["category_id"]
            min_price = request.form["min_price"]
            noise_level = request.form["noise_level"]
            practice_minutes = request.form["practice_minutes"]
            description = request.form["description"]

            headphone_support = 1 if "headphone_support" in request.form else 0
            portable = 1 if "portable" in request.form else 0

            if min_price == "":
                min_price = None

            if noise_level == "":
                noise_level = None

            if practice_minutes == "":
                practice_minutes = None

            cursor.execute(
                """
                EXEC sp_AdminAddInstrument
                    @InstrumentName=?,
                    @Type=?,
                    @DifficultyLevel=?,
                    @Description=?,
                    @CategoryID=?,
                    @MinPrice=?,
                    @NoiseLevel=?,
                    @HeadphoneSupport=?,
                    @Portable=?,
                    @RecommendedPracticeMinutes=?
                """,
                instrument_name,
                instrument_type,
                difficulty,
                description,
                category_id,
                min_price,
                noise_level,
                headphone_support,
                portable,
                practice_minutes
            )

            connection.commit()

            return redirect("/admin/instruments")

        return render_template(
            "admin_add_instrument.html",
            categories=categories
        )

    except Exception as error:

        if connection:
            connection.rollback()

        return render_template(
            "admin_add_instrument.html",
            categories=[],
            error=str(error)
        )

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/admin/instruments/edit/<int:instrument_id>", methods=["GET", "POST"])
def admin_edit_instrument(instrument_id):

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()

        if request.method == "POST":

            instrument_name = request.form["instrument_name"]
            instrument_type = request.form["type"]
            difficulty = request.form["difficulty_level"]
            category_id = request.form["category_id"]
            min_price = request.form["min_price"]
            noise_level = request.form["noise_level"]
            practice_minutes = request.form["practice_minutes"]
            description = request.form["description"]

            headphone_support = 1 if "headphone_support" in request.form else 0
            portable = 1 if "portable" in request.form else 0

            if min_price == "":
                min_price = None

            if noise_level == "":
                noise_level = None

            if practice_minutes == "":
                practice_minutes = None

            cursor.execute(
                """
                EXEC sp_AdminUpdateInstrument
                    @InstrumentID=?,
                    @InstrumentName=?,
                    @Type=?,
                    @DifficultyLevel=?,
                    @Description=?,
                    @CategoryID=?,
                    @MinPrice=?,
                    @NoiseLevel=?,
                    @HeadphoneSupport=?,
                    @Portable=?,
                    @RecommendedPracticeMinutes=?
                """,
                instrument_id,
                instrument_name,
                instrument_type,
                difficulty,
                description,
                category_id,
                min_price,
                noise_level,
                headphone_support,
                portable,
                practice_minutes
            )

            connection.commit()

            return redirect("/admin/instruments")


        cursor.execute(
            """
            SELECT *
            FROM INSTRUMENT
            WHERE instrument_id = ?
            """,
            instrument_id
        )

        instrument = cursor.fetchone()

        if instrument is None:
            return "Instrument not found."


        cursor.execute(
            """
            SELECT
                category_id,
                category_name
            FROM CATEGORY
            ORDER BY category_name
            """
        )

        categories = cursor.fetchall()

        return render_template(
            "admin_edit_instrument.html",
            instrument=instrument,
            categories=categories
        )

    except Exception as error:

        if connection:
            connection.rollback()

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/admin/instruments/delete/<int:instrument_id>", methods=["POST"])
def admin_delete_instrument(instrument_id):

    if "user_id" not in session:
        return redirect("/login")

    if session["role"] != "Admin":
        return "Access denied. Admin only."

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor()

        cursor.execute(
            """
            EXEC sp_AdminDeleteInstrument
                @InstrumentID=?
            """,
            instrument_id
        )

        connection.commit()

        return redirect("/admin/instruments")

    except Exception as error:

        if connection:
            connection.rollback()

        return str(error)

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()

@app.route("/forgot-password", methods=["GET", "POST"])
def forgot_password():

    if request.method == "POST":

        action = request.form["action"]
        email = request.form["email"]

        connection = None
        cursor = None

        try:

            connection = get_connection()
            cursor = connection.cursor()





            if action == "find":

                cursor.execute(
                    """
                    SELECT username
                    FROM [USER]
                    WHERE email = ?
                    """,
                    email
                )

                user = cursor.fetchone()

                if user is None:

                    return render_template(
                        "forgot_password.html",
                        error="No account was found with that email."
                    )

                return render_template(
                    "forgot_password.html",
                    username=user.username,
                    email=email
                )





            if action == "reset":

                new_password = request.form["new_password"]
                confirm_password = request.form["confirm_password"]

                if new_password != confirm_password:

                    cursor.execute(
                        """
                        SELECT username
                        FROM [USER]
                        WHERE email = ?
                        """,
                        email
                    )

                    user = cursor.fetchone()

                    return render_template(
                        "forgot_password.html",
                        username=user.username,
                        email=email,
                        error="Passwords do not match."
                    )

                password_hash = generate_password_hash(
                    new_password
                )

                cursor.execute(
                    """
                    EXEC sp_ResetUserPassword
                        @Email=?,
                        @NewPassword=?
                    """,
                    email,
                    password_hash
                )

                connection.commit()

                return render_template(
                    "login.html",
                    error="Password reset successful. Please login with your new password."
                )

        except Exception as error:

            if connection:
                connection.rollback()

            return render_template(
                "forgot_password.html",
                error=str(error)
            )

        finally:

            if cursor:
                cursor.close()

            if connection:
                connection.close()

    return render_template(
        "forgot_password.html"
    )

if __name__ == "__main__":
    app.run()