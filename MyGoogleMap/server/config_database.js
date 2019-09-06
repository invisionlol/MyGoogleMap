const express = require('express');
const app = express.Router();
const mysql = require('mysql');

// --------------------------------------------

const mHost = "localhost";
const mUsername = "root";
const mPassword = "";
const mDatabase = "cm_location_recorder";

const conn = mysql.createConnection({
    host: mHost,
    user: mUsername,
    password: mPassword,
    database: mDatabase
});

connectDB(); // Start Database

//-----------------------------------------

function connectDB() {
    const conn = mysql.createConnection({
        host: mHost,
        user: mUsername,
        password: mPassword
    });
    conn.connect((error) => {
        conn.query("CREATE DATABASE IF NOT EXISTS " + mDatabase + " CHARACTER SET utf8 COLLATE utf8_general_ci", function (error, result) {
            console.log("Database Available");
            connectTable();
        });
    });
}

function connectTable() {
    const sql = "CREATE TABLE IF NOT EXISTS locations (id INT AUTO_INCREMENT PRIMARY KEY, lat DOUBLE, lng DOUBLE, title VARCHAR(500), timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)";
    conn.query(sql, function (error, result) {
        if (error) throw error;
        console.log("Table Available");
    });
}

module.exports = app;
module.exports.conn = conn;
