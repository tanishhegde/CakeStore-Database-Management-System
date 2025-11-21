# 🍰 CakeStore Database Management System

CakeStore is a simple full-stack mini-application that demonstrates managing a bakery store using a MySQL database and a Streamlit frontend. It includes a complete SQL schema with dummy data and an interactive UI for managing cakes, customers, and orders.

---

## 📦 Project Overview

This project consists of:

- **CakeStore.sql** – Contains the full database schema and initial dummy data.
- **Streamlit App (app.py)** – A simple frontend to interact with the database.
- Demonstration of CRUD operations depending on your app logic.

---

## 🚀 Getting Started

### 1️⃣ Prerequisites

Make sure you have the following installed:

- **MySQL Server** (8.x recommended)
- **Python 3.8+**
- **pip**
- **Streamlit**

---

## 🗄️ Database Setup

### 1. Start MySQL Server  
Ensure MySQL is running on your system.

### 2. Create the Database & Load Dummy Data  
Run the following command in your terminal:

```bash
mysql < CakeStore.sql
```

This will automatically:

- Create the **CakeStore** database
- Create all required tables
- Insert initial dummy data into the tables

---

## 🎨 Running the Streamlit App

Once the database is set up, run the app using:

```bash
streamlit run app.py
```

Streamlit will start a local web server (usually at **http://localhost:8501**).  
Open the link in your browser to use the application.

---

## ⚙️ Configuration

Make sure your `app.py` contains the correct database connection details:

```python
host = "localhost"
user = "root"
password = "yourpassword"
database = "CakeStore"
```

---

## 📁 Project Structure

```
CakeStore/
│
├── CakeStore.sql # MySQL schema + dummy data
├── app.py # Streamlit frontend application
├── documents # SRS, ER Diagram, Relational Schema
└── README.md # Project documentation

---

## ✨ Features (Update These Based on Your App)

- View available cakes  
- Add / update / delete cake items  
- View customers  
- Place and manage orders  
- Basic dashboard UI using Streamlit  

---

## 📝 Notes

- Ensure that the MySQL service is running **before** launching the Streamlit app.
- If the app cannot connect to MySQL, double-check:
  - MySQL username/password  
  - Host & port  
  - Whether the `CakeStore` database exists  

---

## ✍️ Author

Tanish Hegde
Sumithra Suresh
