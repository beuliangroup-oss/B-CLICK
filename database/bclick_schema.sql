-- ==============================================================================
-- NAMA PROJECT  : B-CLICK (Preloved Premium Marketplace)
-- DEVELOPER     : Beulian Group
-- DESKRIPSI     : Skema Database Awal untuk MVP E-Commerce
-- ==============================================================================

-- Buat database jika belum ada dan gunakan database tersebut
CREATE DATABASE IF NOT EXISTS bclick_db;
USE bclick_db;

-- Hapus tabel jika sudah ada (berguna untuk reset database saat testing)
-- Urutan drop harus dari child ke parent untuk menghindari error constraint
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

-- ==============================================================================
-- 1. TABEL PENGGUNA (USERS)
-- ==============================================================================
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role ENUM('admin', 'seller', 'buyer') DEFAULT 'buyer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 2. TABEL KATEGORI PRODUK (CATEGORIES)
-- ==============================================================================
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE,
    icon_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================================================
-- 3. TABEL BARANG PRELOVED (PRODUCTS)
-- ==============================================================================
CREATE TABLE products (
    id VARCHAR(36) PRIMARY KEY,
    seller_id VARCHAR(36) NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) NOT NULL,
    item_condition ENUM('Like New', 'Sangat Baik', 'Cacat Minor') NOT NULL,
    images JSON, -- Menyimpan array URL gambar
    status ENUM('Available', 'In Cart', 'Sold') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

-- ==============================================================================
-- 4. TABEL PESANAN & PENGIRIMAN (ORDERS)
-- ==============================================================================
CREATE TABLE orders (
    id VARCHAR(36) PRIMARY KEY,
    buyer_id VARCHAR(36) NOT NULL,
    total_amount DECIMAL(15, 2) NOT NULL,
    shipping_address TEXT NOT NULL,
    courier VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100),
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ==============================================================================
-- 5. TABEL DETAIL PESANAN (ORDER_ITEMS)
-- ==============================================================================
CREATE TABLE order_items (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    product_id VARCHAR(36) NOT NULL,
    price_at_purchase DECIMAL(15, 2) NOT NULL,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- ==============================================================================
-- 6. TABEL PEMBAYARAN (PAYMENTS)
-- ==============================================================================
CREATE TABLE payments (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(100) UNIQUE, -- ID referensi dari Payment Gateway (misal: Midtrans/Xendit)
    payment_status ENUM('Unpaid', 'Paid', 'Failed', 'Refunded') DEFAULT 'Unpaid',
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);
