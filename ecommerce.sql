-- Create an e-commerce database schema
CREATE DATABASE IF NOT EXISTS ecommerceDb;

-- Use the e-commerce database
USE ecommerceDb;

-- Create tables for the e-commerce database
CREATE TABLE brand (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE product_category (
    prod_category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand_id INT,
    category_id INT,
    base_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id),
    FOREIGN KEY (category_id) REFERENCES product_category(prod_category_id)
);

CREATE TABLE product_image (
    prod_image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    image_url VARCHAR(500) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

CREATE TABLE color (
    color_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE size_category (
    size_category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE size_option (
    size_option_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    value VARCHAR(50) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES size_category(size_category_id)
);

CREATE TABLE product_variation (
    prod_variation_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    color_id INT,
    size_option_id INT,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (color_id) REFERENCES color(color_id),
    FOREIGN KEY (size_option_id) REFERENCES size_option(size_option_id)
);

CREATE TABLE attribute_category (
    attribute_category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE attribute_type (
    attribute_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE product_attribute (
    prod_attribute_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    attribute_category_id INT,
    attribute_type_id INT,
    attribute_value VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (attribute_category_id) REFERENCES attribute_category(attribute_category_id),
    FOREIGN KEY (attribute_type_id) REFERENCES attribute_type(attribute_type_id)
);

CREATE TABLE product_item (
    prod_item_id INT AUTO_INCREMENT PRIMARY KEY,
    product_variation_id INT,
    stock_keeping_unit VARCHAR(100) NOT NULL UNIQUE,
    stock_quantity INT NOT NULL,
    price DECIMAL(10,2),
    FOREIGN KEY (product_variation_id) REFERENCES product_variation(prod_variation_id)
);

-- Sample data insertion
-- Insert into brand
INSERT INTO brand (name) VALUES ('Nike'),
                                ('Apple'),
                                ('Samsung');

-- Insert into product_category
INSERT INTO product_category (name) VALUES ('Clothing'),
                                           ('Electronics'),
                                           ('Shoes');

-- Insert into color
INSERT INTO color (name) VALUES ('Red'),
                                ('Blue'),
                                ('Black');

-- Insert into size_category
INSERT INTO size_category (name) VALUES ('Clothing Size'),
                                        ('Shoe Size');

-- Insert into size_option
INSERT INTO size_option (category_id, value) VALUES
    (1, 'S'), (1, 'M'), (1, 'L'),  -- Clothing Sizes
    (2, '42'), (2, '43');          -- Shoe Sizes

-- Insert into attribute_category
INSERT INTO attribute_category (name) VALUES ('Physical'),
                                             ('Technical');

-- Insert into attribute_type
INSERT INTO attribute_type (name) VALUES ('Text'),
                                         ('Number'),
                                         ('Boolean');

-- Insert into product
INSERT INTO product (name, brand_id, category_id, base_price) VALUES
('Air Max Sneakers', 1, 3, 120.00),
('iPhone 15', 2, 2, 999.99),
('Samsung T-Shirt', 3, 1, 30.00);

-- Insert into product_image
INSERT INTO product_image (product_id, image_url) VALUES
(1, 'https://unsplash.com/photos/a-pair-of-white-and-yellow-sneakers-on-a-table-TRoZdTq8oIg'),
(2, 'https://unsplash.com/photos/a-close-up-of-a-cell-phone-on-a-table-V35fOJJyhRo'),
(3, 'https://www.teez.in/products/samsung-t-shirt-for-men');

-- Insert into product_variation
INSERT INTO product_variation (product_id, color_id, size_option_id) VALUES
(1, 1, 4), -- Air Max Red 42
(1, 2, 5), -- Air Max Blue 43
(3, 3, 2); -- Samsung T-Shirt Black M

-- Insert into product_attribute
INSERT INTO product_attribute (product_id, attribute_category_id, attribute_type_id, attribute_value) VALUES
(1, 1, 1, 'Leather Material'),
(2, 2, 2, '256GB Storage');

-- Insert into product_item
INSERT INTO product_item (product_variation_id, stock_keeping_unit, stock_quantity, price) VALUES
(1, 'AMAX-RED-42', 10, 120.00),
(2, 'AMAX-BLU-43', 5, 120.00),
(3, 'SAM-TSHIRT-BLK-M', 20, 30.00);


-- Sample queries
-- Find all products with their images
SELECT
    p.name AS product_name,
    pi.image_url,
    p.base_price
FROM product p
JOIN product_image pi ON p.product_id = pi.product_id;

-- Find all products with their attributes
SELECT
    p.name AS product_name,
    ac.name AS attribute_category,
    at.name AS attribute_type,
    pa.attribute_value
FROM product p
JOIN product_attribute pa ON p.product_id = pa.product_id
JOIN attribute_category ac ON pa.attribute_category_id = ac.attribute_category_id
JOIN attribute_type at ON pa.attribute_type_id = at.attribute_type_id;

-- Find all red shoes in stock
SELECT
    p.name AS product_name,
    c.name AS color,
    so.value AS size,
    pi.stock_keeping_unit,
    pi.stock_quantity,
    pi.price
FROM product_item pi
JOIN product_variation pv ON pi.product_variation_id = pv.prod_variation_id
JOIN product p ON pv.product_id = p.product_id
JOIN color c ON pv.color_id = c.color_id
JOIN size_option so ON pv.size_option_id = so.size_option_id
JOIN product_category pc ON p.category_id = pc.prod_category_id
WHERE c.name = 'Red' AND pc.name = 'Shoes' AND pi.stock_quantity > 0;

-- Find all products in a specific category
SELECT
    p.name AS product_name,
    pc.name AS category,
    b.name AS brand,
    p.base_price
FROM product p
JOIN product_category pc ON p.category_id = pc.prod_category_id
JOIN brand b ON p.brand_id = b.brand_id
WHERE pc.name = 'Electronics';
