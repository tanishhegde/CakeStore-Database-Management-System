CREATE DATABASE IF NOT EXISTS Cake_Store;
USE Cake_Store;

-- ==========================
-- Tables
-- ==========================

CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY,
    Amount DECIMAL(10,2),
    Method VARCHAR(50),
    Payment_Date DATE
);

CREATE TABLE Outlet (
    Outlet_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(200),
    Phone_Number VARCHAR(15)
);

CREATE TABLE Employees (
    Employee_ID INT PRIMARY KEY,
    E_Name VARCHAR(100),
    RoleOfPerson VARCHAR(50),
    Phone_Number VARCHAR(15),
    Outlet_ID INT,
    Production_ID INT,
    FOREIGN KEY (Outlet_ID) REFERENCES Outlet(Outlet_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    NameOfPerson VARCHAR(100),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(15)
);

CREATE TABLE Cake_Catalogue (
    Cake_ID INT PRIMARY KEY AUTO_INCREMENT,
    C_Name VARCHAR(100),
    C_Category VARCHAR(50),
    C_Description TEXT,
    Price DECIMAL(8,2),
    Quantity INT
);

CREATE TABLE Order_Table (
    Order_ID INT PRIMARY KEY AUTO_INCREMENT,
    Order_Date DATE,
    StatusOrder VARCHAR(20),
    Total_Amount DECIMAL(10,2),
    Customer_ID INT,
    Outlet_ID INT,
    Cake_ID INT,
    Payment_ID INT,
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (Outlet_ID) REFERENCES Outlet(Outlet_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
     FOREIGN KEY (Cake_ID) REFERENCES Cake_Catalogue(Cake_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
     FOREIGN KEY (Payment_ID) REFERENCES Payment(Payment_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Customers_Address (
    Customer_ID INT,
    Address VARCHAR(200),
    PRIMARY KEY (Customer_ID, Address),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Customers_Phone_Numbers (
    Customer_ID INT,
    Phone_Number VARCHAR(15),
    PRIMARY KEY (Customer_ID, Phone_Number),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Outlet_Phone_Numbers (
    Outlet_ID INT,
    Phone_Number VARCHAR(15),
    PRIMARY KEY (Outlet_ID, Phone_Number),
    FOREIGN KEY (Outlet_ID) REFERENCES Outlet(Outlet_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ==========================
-- Inserts
-- ==========================

-- Payment
INSERT INTO Payment (Payment_ID, Amount, Method, Payment_Date) VALUES
(1, 450.00, 'Credit Card', '2025-01-12'),
(2, 720.50, 'UPI', '2025-01-15'),
(3, 299.99, 'Cash', '2025-02-01'),
(4, 1500.00, 'Debit Card', '2025-02-05');

-- Outlet
INSERT INTO Outlet (Outlet_ID, Name, Address, Phone_Number) VALUES
(1, 'Sweet Haven', 'MG Road, Bengaluru', '9876543210'),
(2, 'Cake World', 'Indiranagar, Bengaluru', '9988776655'),
(3, 'Bakers Hub', 'Koramangala, Bengaluru', '9123456780');

-- Employees
INSERT INTO Employees (Employee_ID, E_Name, RoleOfPerson, Phone_Number, Outlet_ID, Production_ID) VALUES
(1, 'Ramesh Kumar', 'Manager', '9123012301', 1, NULL),
(2, 'Anita Sharma', 'Chef', '9898989898', 1, NULL),
(3, 'John Mathew', 'Cashier', '9000090000', 2, NULL),
(4, 'Sara Ali', 'Baker', '8080808080', 3, NULL);

-- Customers
INSERT INTO Customers (Customer_ID, NameOfPerson, Email, PhoneNumber) VALUES
(1, 'Aarav Gupta', 'aarav@example.com', '8881112222'),
(2, 'Riya Sharma', 'riya@example.com', '9991112222'),
(3, 'Karan Verma', 'karan@example.com', '7771112222'),
(4, 'Meera Rao', 'meera@example.com', '9662223333');

-- Cake Catalogue
INSERT INTO Cake_Catalogue (C_Name, C_Category, C_Description, Price, Quantity) VALUES
('Chocolate Truffle', 'Chocolate', 'Rich dark chocolate cake', 450.00, 10),
('Vanilla Delight', 'Classic', 'Soft vanilla sponge cake', 350.00, 20),
('Red Velvet', 'Premium', 'Red velvet cream cheese cake', 550.00, 8),
('Black Forest', 'Classic', 'Cherry and chocolate layered cake', 500.00, 15);

-- Orders
INSERT INTO Order_Table (Order_Date, StatusOrder, Total_Amount, Customer_ID, Outlet_ID, Cake_ID, Payment_ID) VALUES
('2025-02-10', 'Completed', 450.00, 1, 1, 1, 1),
('2025-02-12', 'Pending', 550.00, 2, 2, 3, 2),
('2025-02-15', 'Completed', 350.00, 3, 1, 2, 3),
('2025-02-16', 'Cancelled', 500.00, 4, 3, 4, 4);

-- Customer Addresses
INSERT INTO Customers_Address (Customer_ID, Address) VALUES
(1, 'HSR Layout, Bengaluru'),
(2, 'Whitefield, Bengaluru'),
(3, 'JP Nagar, Bengaluru'),
(4, 'BTM Layout, Bengaluru');

-- Customer Phone Numbers
INSERT INTO Customers_Phone_Numbers (Customer_ID, Phone_Number) VALUES
(1, '8881112222'),
(1, '8881113333'),
(2, '9991112222'),
(3, '7771112222');

-- Outlet Phone Numbers
INSERT INTO Outlet_Phone_Numbers (Outlet_ID, Phone_Number) VALUES
(1, '9876543210'),
(1, '9765432109'),
(2, '9988776655'),
(3, '9123456780');

-- ==========================================
-- TRIGGERS
-- ==========================================

-- 1. Prevent Negative Stock
DELIMITER //

CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON Cake_Catalogue
FOR EACH ROW
BEGIN
    IF NEW.Quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cake stock cannot be negative!';
    END IF;
END;
//

DELIMITER ;


-- 2. Auto Reduce Cake Stock on Order Insert
DELIMITER //

CREATE TRIGGER trg_reduce_cake_stock
AFTER INSERT ON Order_Table
FOR EACH ROW
BEGIN
    UPDATE Cake_Catalogue
    SET Quantity = Quantity - 1
    WHERE Cake_ID = NEW.Cake_ID;
END;
//

DELIMITER ;


-- 3. Auto Calculate Order Total
DELIMITER //

CREATE TRIGGER trg_calculate_order_total
BEFORE INSERT ON Order_Table
FOR EACH ROW
BEGIN
    IF NEW.Total_Amount IS NULL OR NEW.Total_Amount = 0 THEN
        SET NEW.Total_Amount = (
            SELECT Price FROM Cake_Catalogue WHERE Cake_ID = NEW.Cake_ID
        );
    END IF;
END;
//

DELIMITER ;


-- 4. Validate Payment Exists
DELIMITER //

CREATE TRIGGER trg_validate_payment
BEFORE INSERT ON Order_Table
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Payment WHERE Payment_ID = NEW.Payment_ID) = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid Payment_ID! Payment record does not exist.';
    END IF;
END;
//

DELIMITER ;


-- 5. Logging table for cancelled orders
CREATE TABLE IF NOT EXISTS Cancelled_Orders_Log (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT,
    Cancelled_On TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Reason VARCHAR(255)
);

-- 5. Log Cancelled Orders Trigger
DELIMITER //

CREATE TRIGGER trg_log_cancelled_order
AFTER UPDATE ON Order_Table
FOR EACH ROW
BEGIN
    IF OLD.StatusOrder <> 'Cancelled' AND NEW.StatusOrder = 'Cancelled' THEN
        INSERT INTO Cancelled_Orders_Log (Order_ID, Reason)
        VALUES (NEW.Order_ID, 'Order cancelled by system/user');
    END IF;
END;
//

DELIMITER ;


-- 6. Sales Audit Table
CREATE TABLE IF NOT EXISTS Sales_Audit (
    Audit_ID INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID INT,
    Cake_ID INT,
    Customer_ID INT,
    Outlet_ID INT,
    Amount DECIMAL(10,2),
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Sales Audit Trigger
DELIMITER //

CREATE TRIGGER trg_sales_audit
AFTER INSERT ON Order_Table
FOR EACH ROW
BEGIN
    INSERT INTO Sales_Audit (Order_ID, Cake_ID, Customer_ID, Outlet_ID, Amount)
    VALUES (NEW.Order_ID, NEW.Cake_ID, NEW.Customer_ID, NEW.Outlet_ID, NEW.Total_Amount);
END;
//

DELIMITER ;

-- ==========================================
-- PROCEDURES
-- ==========================================

DELIMITER //

-- 1. Procedure: Place an Order
CREATE PROCEDURE Place_Order (
    IN p_customer INT,
    IN p_outlet INT,
    IN p_cake INT,
    IN p_payment INT
)
BEGIN
    INSERT INTO Order_Table (
        Order_Date,
        StatusOrder,
        Customer_ID,
        Outlet_ID,
        Cake_ID,
        Payment_ID
    )
    VALUES (
        CURDATE(),
        'Pending',
        p_customer,
        p_outlet,
        p_cake,
        p_payment
    );
END;
//


-- 2. Procedure: Restock Cakes
CREATE PROCEDURE Restock_Cake (
    IN p_cake_id INT,
    IN p_add_quantity INT
)
BEGIN
    UPDATE Cake_Catalogue
    SET Quantity = Quantity + p_add_quantity
    WHERE Cake_ID = p_cake_id;
END;
//

DELIMITER ;

-- ==========================================
-- FUNCTIONS
-- ==========================================

DELIMITER //

-- 1. Function: Get Total Sales of a Cake
CREATE FUNCTION GetCakeSales(cake INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN (
        SELECT SUM(Total_Amount)
        FROM Order_Table
        WHERE Cake_ID = cake AND StatusOrder = 'Completed'
    );
END;
//


-- 2. Function: Check Stock Health
CREATE FUNCTION CheckStock(cake INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE qty INT;

    SELECT Quantity INTO qty
    FROM Cake_Catalogue
    WHERE Cake_ID = cake;

    IF qty <= 0 THEN
        RETURN 'OUT OF STOCK';
    ELSEIF qty < 5 THEN
        RETURN 'LOW STOCK';
    ELSE
        RETURN 'OK';
    END IF;
END;
//

DELIMITER ;
