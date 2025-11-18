import streamlit as st
import mysql.connector
import pandas as pd


# ---------------------------------------------------
# DATABASE CONNECTION
# ---------------------------------------------------
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="streamlit_user",
        password="Sumithra@123",
        database="Cake_Store"
    )


# ---------------------------------------------------
# PAGE SETUP
# ---------------------------------------------------
st.set_page_config(page_title="Cake Store DB", layout="wide")
st.title("🍰 Cake Store Database Dashboard")


# ---------------------------------------------------
# UTILITIES
# ---------------------------------------------------
def fetch_df(query):
    conn = get_connection()
    df = pd.read_sql(query, conn)
    conn.close()
    return df


def get_list(table, col):
    df = fetch_df(f"SELECT {col} FROM {table}")
    return df[col].tolist()


def execute_sql(query, params=None):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query, params if params else [])
    conn.commit()
    conn.close()


# ---------------------------------------------------
# SIDEBAR
# ---------------------------------------------------
menu = st.sidebar.selectbox(
    "Choose Action",
    [
        "View Tables", "Insert Data",
        "Place Order (Procedure)",
        "Restock Cake (Procedure)",
        "Run Functions",
        "Cancel Order",
        "Analytics Dashboard",
        "Run Custom Query"
    ]
)

# ---------------------------------------------------
# VIEW TABLES
# ---------------------------------------------------
if menu == "View Tables":
    st.header("📊 View Tables")

    tables = fetch_df("SHOW TABLES")
    table = st.selectbox("Select a table", tables.iloc[:, 0])

    if table:
        df = fetch_df(f"SELECT * FROM {table}")
        st.dataframe(df, use_container_width=True)


# ---------------------------------------------------
# INSERT DATA (generic)
# ---------------------------------------------------
elif menu == "Insert Data":
    st.header("➕ Insert Data")

    tables = fetch_df("SHOW TABLES")
    table = st.selectbox("Select Table", tables.iloc[:, 0])

    if table:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(f"DESCRIBE {table}")
        cols = cursor.fetchall()
        conn.close()

        auto_inc = ["Order_ID", "Cake_ID"]

        form = {}
        st.subheader(f"Inserting into {table}")

        for col in cols:
            name, dtype = col[0], col[1]

            if name in auto_inc:
                continue

            if "int" in dtype:
                form[name] = st.number_input(name, step=1)
            elif "date" in dtype:
                form[name] = st.date_input(name)
            else:
                form[name] = st.text_input(name)

        if st.button("Insert Record"):
            col_names = ", ".join(form.keys())
            placeholders = ", ".join(["%s"] * len(form))
            values = list(form.values())
            query = f"INSERT INTO {table} ({col_names}) VALUES ({placeholders})"

            try:
                execute_sql(query, values)
                st.success("✔ Record inserted!")
            except Exception as e:
                st.error(f"❌ {e}")


# ---------------------------------------------------
# PLACE ORDER — CALL PROCEDURE
# ---------------------------------------------------
elif menu == "Place Order (Procedure)":
    st.header("🛒 Place Order")

    customer = st.selectbox("Customer ID", get_list("Customers", "Customer_ID"))
    outlet = st.selectbox("Outlet ID", get_list("Outlet", "Outlet_ID"))
    cake = st.selectbox("Cake ID", get_list("Cake_Catalogue", "Cake_ID"))
    payment = st.selectbox("Payment ID", get_list("Payment", "Payment_ID"))

    if st.button("Place Order"):
        try:
            execute_sql("CALL Place_Order(%s,%s,%s,%s)", (customer, outlet, cake, payment))
            st.success("✔ Order placed successfully!")
        except Exception as e:
           st.error(f"❌ {e}")


# ---------------------------------------------------
# RESTOCK CAKE — CALL PROCEDURE
# ---------------------------------------------------
elif menu == "Restock Cake (Procedure)":
    st.header("📦 Restock Cake")

    cake_id = st.selectbox("Select Cake", get_list("Cake_Catalogue", "Cake_ID"))
    qty = st.number_input("Add Quantity", step=1)

    if st.button("Restock"):
        execute_sql("CALL Restock_Cake(%s, %s)", (cake_id, qty))
        st.success("✔ Stock updated!")


# ---------------------------------------------------
# RUN FUNCTIONS
# ---------------------------------------------------
elif menu == "Run Functions":
    st.header("🧠 Run MySQL Functions")

    st.subheader("GetCakeSales(cake_id)")
    cake = st.selectbox("Select Cake ID", get_list("Cake_Catalogue", "Cake_ID"))
    if st.button("Get Sales"):
        df = fetch_df(f"SELECT GetCakeSales({cake}) AS TotalSales")
        st.info(f"Total Sales for Cake {cake}: ₹{df['TotalSales'][0]}")

    st.subheader("CheckStock(cake_id)")
    cake2 = st.selectbox("Check Stock for Cake", get_list("Cake_Catalogue", "Cake_ID"))
    if st.button("Check Stock"):
        df = fetch_df(f"SELECT CheckStock({cake2}) AS StockStatus")
        st.warning(f"Stock Status: {df['StockStatus'][0]}")


# ---------------------------------------------------
# CANCEL ORDER
# ---------------------------------------------------
elif menu == "Cancel Order":
    st.header("❌ Cancel an Order")

    orders = get_list("Order_Table", "Order_ID")
    order_id = st.selectbox("Select Order to Cancel", orders)

    if st.button("Cancel Order"):
        execute_sql(
            "UPDATE Order_Table SET StatusOrder='Cancelled' WHERE Order_ID=%s",
            (order_id,)
        )
        st.success("✔ Order cancelled! (Logged automatically)")


# ---------------------------------------------------
# ANALYTICS DASHBOARD
# ---------------------------------------------------
elif menu == "Analytics Dashboard":
    st.header("📈 Dashboard")

    col1, col2, col3 = st.columns(3)

    col1.metric("Total Orders", fetch_df("SELECT COUNT(*) AS c FROM Order_Table")["c"][0])
    col2.metric("Completed", fetch_df("SELECT COUNT(*) AS c FROM Order_Table WHERE StatusOrder='Completed'")["c"][0])
    col3.metric("Cancelled", fetch_df("SELECT COUNT(*) AS c FROM Order_Table WHERE StatusOrder='Cancelled'")["c"][0])

    st.subheader("Best Selling Cakes")
    df_best = fetch_df("""
        SELECT C.C_Name, COUNT(*) AS Sold
        FROM Order_Table O
        JOIN Cake_Catalogue C ON O.Cake_ID=C.Cake_ID
        WHERE StatusOrder='Completed'
        GROUP BY O.Cake_ID
        ORDER BY Sold DESC
    """)
    st.bar_chart(df_best.set_index("C_Name"))


# ---------------------------------------------------
# RUN SELECT QUERIES
# ---------------------------------------------------
elif menu == "Run Custom Query":
    st.header("🔍 Custom Query")

    sql = st.text_area("Enter SELECT query only")

    if st.button("Run"):
        if not sql.strip().lower().startswith("select"):
            st.error("Only SELECT queries are allowed.")
        else:
            st.dataframe(fetch_df(sql), use_container_width=True)
 
