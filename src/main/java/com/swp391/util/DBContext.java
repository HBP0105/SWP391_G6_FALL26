package com.swp391.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {

    private final String URL = "jdbc:sqlserver://localhost:1433;databaseName=HeadphoneSalesDB;encrypt=true;trustServerCertificate=true";
    private final String USER = "sa";
    private final String PASSWORD = "sa";

    public Connection getConnection() throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
