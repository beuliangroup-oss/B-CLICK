const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/db');

const app = express();

// Middleware
app.use(cors()); // Mengizinkan frontend mengambil data dari backend
app.use(express.json()); // Memproses request body dalam format JSON

// ==========================================
// ROUTES PRODUK (API ENDPOINTS)
// ==========================================

// 1. GET: Mengambil semua barang preloved
app.get('/api/products', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM products ORDER BY created_at DESC');
        res.status(200).json({
            success: true,
            data: rows
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Kesalahan server', error: error.message });
    }
});

// 2. POST: Mengunggah barang preloved baru
app.post('/api/products', async (req, res) => {
    // Simulasi input dari frontend
    const { id, seller_id, category_id, title, description, price, item_condition } = req.body;
    
    try {
        const query = `
            INSERT INTO products (id, seller_id, category_id, title, description, price, item_condition) 
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `;
        const values = [id, seller_id, category_id, title, description, price, item_condition];
        
        await db.query(query, values);
        res.status(201).json({ success: true, message: 'Produk berhasil ditambahkan!' });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Gagal menambahkan produk', error: error.message });
    }
});

// Jalankan Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server B-CLICK berjalan di http://localhost:${PORT}`);
});

