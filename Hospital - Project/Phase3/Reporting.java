//STEP 1. Import required packages

import java.sql.*;
import java.util.Scanner;

public class Reporting {
    // JDBC driver name and database URL
    static final String JDBC_DRIVER = "oracle.jdbc.driver.OracleDriver";
    static final String DB_URL = "jdbc:oracle:thin:@oracle.wpi.edu:1521:orcl";

    public static void Connect(String USER, String PASS, int result) {
        Connection conn = null;
        Statement stmt = null;
        String sql;
        String sql1="";
        String sql2="";
        try {
            //STEP 2: Register JDBC driver
            Class.forName("oracle.jdbc.driver.OracleDriver");

            //STEP 3: Open a connection
            System.out.println("Connecting to database...");
            conn = DriverManager.getConnection(DB_URL, USER, PASS);

            Scanner reader = new Scanner(System.in);  // Reading from System.in

            //STEP 3.5: Pick a Query
            switch (result) {
                case 1:
                    /*Obtain Patient SSN: ….
                    Patient First Name: …
                    Patient Last Name: …
                    Patient Address: given patient SSN*/

                    System.out.println("Enter Patient SSN: ");
                    String PatientSSN = reader.nextLine(); // Scans the next token of the input
                    //System.out.println("INPUT:"+PatientSSN);
                    sql = "SELECT * FROM Patient WHERE SSN='"+PatientSSN+"'";
                    reader.close();
                    //System.out.println(sql);
                    break;
                case 2:
                    System.out.println("Enter Doctor ID: ");
                    int DoctorID = reader.nextInt(); // Scans the next token of the input as an int.
                    //System.out.println("INPUT:"+DoctorID);
                    sql = "SELECT * FROM Doctor WHERE ID='"+DoctorID+"'";
                    reader.close();
                    //System.out.println(sql);
                    break;
                case 3:
                    System.out.println("Enter Admission Number: ");
                    int AdmissionNumber = reader.nextInt(); // Scans the next token of the input as an int.
                    //System.out.println("INPUT:"+AdmissionNumber);
                    sql = "SELECT ANum,Patient_SSN,AdmissionDate,TotalPayment FROM Admission WHERE ANum='"+AdmissionNumber+"'";
                    sql1 = "SELECT DISTINCT RoomNum,StartDate,EndDate FROM StayIN WHERE AdmissionNum='"+AdmissionNumber+"'";
                    sql2 = "SELECT DISTINCT DoctorID FROM Examine WHERE AdmissionNum='"+AdmissionNumber+"'";
                    reader.close();
                    //System.out.println(sql);
                    break;
                case 4:
                    System.out.println("Enter Admission Number: ");
                    int AdmissNum = reader.nextInt();
                    System.out.println("Enter the new total payment: ");
                    int totPay = reader.nextInt();
                    sql = "UPDATE Admission SET TotalPayment = '"+totPay+"' WHERE ANum = '"+AdmissNum+"'";
                    reader.close();
                    break;
                default:
                    reader.close();
                    System.out.println("Please run the program like so:");
                    System.out.println("java Reporting <userName> <Passowrd> <Action>");
                    System.out.println("The action must be a number between 1 and 4");
                    return;
            }

           // String sql = "";


                    //STEP 4: Execute a query
            System.out.println("Creating statement...");
            stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            int UpdateSet = stmt.executeUpdate(sql);


            //STEP 5: Extract data from result set
            while (rs.next()) {
                switch(result) {
                    case 1://Retrive patient data
                    //Retrieve by column name
                    String PatSSN = rs.getString("SSN");
                    String PatFirstName = rs.getString("FirstName");
                    String PatLastName = rs.getString("LastName");
                    String PatAddress = rs.getString("Address");

                    // Display values
                    System.out.println("Patient SSN: " + PatSSN);
                    System.out.println("Patient First Name: " + PatFirstName);
                    System.out.println("Patient Last Name: " + PatLastName);
                    System.out.println("Patient Address: " + PatAddress);
                    break;
                    case 2://Retrieve Doctor Data
                    int DocID = rs.getInt("ID");
                    String DocFirstName = rs.getString("FirstName");
                    String DocLastName = rs.getString("LastName");
                    String DocGender = rs.getString("Gender");

                    // Display values
                    System.out.println("Doctor ID: " + DocID);
                    System.out.println("Doctor First Name: " + DocFirstName);
                    System.out.println("Doctor Last Name: " + DocLastName);
                    System.out.println("Doctor Gender: " + DocGender);
                    break;
                    case 3: //Retrive Admission Data

                        int AdmissionID = rs.getInt("ANum");
                        String PatientSSN = rs.getString("Patient_SSN");
                        java.sql.Date AdmissionDate = rs.getDate("AdmissionDate");
                        float TotalPayment = Float.parseFloat(rs.getString("TotalPayment"));

                        // Display values
                        System.out.println("Admission ID: " + AdmissionID);
                        System.out.println("Patient SSN: " + PatientSSN);
                        System.out.println("Admission Date (Start Date): " + AdmissionDate.toString());
                        System.out.println("Total Payment: " + TotalPayment);
                        System.out.println("Rooms:");
                        ResultSet rs1 = stmt.executeQuery(sql1);
                        while(rs1.next()) {
                            int RoomNum = rs1.getInt("RoomNum");
                            java.sql.Date StartDate = rs1.getDate("StartDate");
                            java.sql.Date EndDate = rs1.getDate("EndDate");
                            System.out.print("\tRoomNum: " + RoomNum);
                            System.out.print("\tStartDate: " + StartDate.toString());
                            System.out.println("\tEndDate: " + EndDate.toString());
                        }

                        ResultSet rs2 = stmt.executeQuery(sql2);
                        System.out.println("Doctors examined the patient in this admission:");
                        while(rs2.next()) {
                            int DoctorID = rs2.getInt("DoctorID");
                            System.out.println("\tDoctorID:" + DoctorID);
                        }


                        rs1.close();
                        rs2.close();
                        break;
                    case 4: //Update Addmission data
                        System.out.println("Update Successful!");
                        break;
                    default:
                        System.out.println("THIS SHOULD NOT HAPPEN!");
                        return;
                }

            }
            //STEP 6: Clean-up environment
            rs.close();
            stmt.close();
            conn.close();
        } catch (SQLException se) {
            //Handle errors for JDBC
            se.printStackTrace();
        } catch (Exception e) {
            //Handle errors for Class.forName
            e.printStackTrace();
        } finally {
            //finally block used to close resources
            try {
                if (stmt != null)
                    stmt.close();
            } catch (SQLException se2) {
            }// nothing we can do
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }//end finally try
        }//end try
    }

    public static void main(String[] args) {


        if (args.length < 2) {
            System.out.println("Please run the program like so:");
            System.out.println("java Reporting <userName> <Passowrd> <Action>");
            return;
        } else if (args.length == 2) {
            System.out.println("1- Report Patients Basic Information");
            System.out.println("2- Report Doctors Basic Information");
            System.out.println("3- Report Admissions Information");
            System.out.println("4- Update Admissions Payment");
            return;
        } else if (args.length > 3) {
            System.out.println("Please run the program like so:");
            System.out.println("java Reporting <userName> <Passowrd> <Action>");
            return;
        } else {//proper arg length
            try {
                int result = Integer.parseInt(args[2]);
                String USER = args[0];
                String PASS = args[1];
                //System.out.println(USER);
                //System.out.println(PASS);
                if (result > 4 || result < 1) {
                    System.out.println("Please run the program like so:");
                    System.out.println("java Reporting <userName> <Passowrd> <Action>");
                    System.out.println("The action must be a number between 1 and 4");
                    return;
                } else {
                    Connect(USER, PASS, result);
                }
            }
            catch(NumberFormatException nfe) {
                System.out.println("NumberFormatException: " + nfe.getMessage());
                System.out.println("Please run the program like so:");
                System.out.println("java Reporting <userName> <Passowrd> <Action>");
                return;
            }
        }


        System.out.println("Goodbye!");

    return;
    }//end main

}//end Reporting