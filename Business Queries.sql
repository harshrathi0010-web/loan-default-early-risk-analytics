

CREATE DATABASE LOAN_DATA;

USE LOAN_DATA;
SHOW TABLES;

CREATE TABLE loan (
    loan_status            VARCHAR(50),
    loan_amnt              INT,
    term                   VARCHAR(20),
    int_rate               FLOAT,
    installment            FLOAT,
    grade                  VARCHAR(5),
    sub_grade              VARCHAR(10),
    emp_length             FLOAT,
    home_ownership         VARCHAR(20),
    annual_inc             FLOAT,
    verification_status    VARCHAR(50),
    purpose                VARCHAR(100),
    addr_state             VARCHAR(10),
    dti                    FLOAT,
    delinq_2yrs            INT,
    earliest_cr_line       DATETIME,
    inq_last_6mths         INT,
    open_acc               INT,
    pub_rec_bankruptcies   FLOAT,
    pub_rec                INT,
    revol_bal              INT,
    revol_util             FLOAT,
    total_acc              INT,
    initial_list_status    VARCHAR(10),
    application_type       VARCHAR(20),
    mort_acc               FLOAT,
    issue_d                VARCHAR(20),
    issue_id               DATETIME,
    credit_history_length  FLOAT,
    income_to_loan_ratio   FLOAT,
    revol_util_bucket      VARCHAR(20),
    default_flag           INT
);
SHOW TABLES;
SELECT*FROM loan ;



Select count(default_flag) FROM loan;
Select default_flag fROm loan;


# SQL Queries related to business context and insights

#Ques1.What is the overall portfolio size, total funded amount, average interest rate, and overall default rate? (KPI Summary)

# -------------BASIC (1-5) — Aggregation & Grouping---------------

SELECT SUM(loan_amnt)  as total_loan_amount,
ROUND(AVG(int_rate),2) as avg_int_rate ,
SUM(default_flag) as at_risk_loans,
ROUND(AVG(dti),2) as avg_dti,
ROUND(SUM(default_flag) *100/count(*),2) as avg_risk_pct 
 FROM  loan;
 
 
 #Ques 2. What is the loan count and total exposure by purpose?
 SELECT 
	purpose ,
	Count(*) as total_loans,
    SUM(loan_amnt) as total_exposure,
    ROUND(avg(int_rate),2) as avg_int_rate 
    from loan
    GROUP BY purpose 
    ORDER BY total_exposure DESC;
    
#Ques3.  What is the average interest rate and average income by grade?
     

 SELECT 
 grade ,
round(avg(int_rate),2) as avg_int_rate ,
round(avg(annual_inc),2) as avg_annual_inc 
 from loan
 group by grade 
 order by grade;
 
 #Que4.  What is the loan volume and average DTI by home ownership status?
 
  SELECT 
  home_ownership as Home_Ownership,
  SUM(loan_amnt) as Total_Loan_Amnt,
  ROUND(avg(dti),2) as Avg_Dti
  FROM LOAN
  GROUP BY home_ownership
  ORDER BY total_loan_amnt DESC;
  
  #Ques5. How many loans were issued per year, and what was the total funded amount?
   
   SELECT 
   issue_d,
   SUM(loan_amnt) as Total_loan_Amnt,
   count(*) As no_of_total_loan
   FROM loan
   GROUP BY issue_d;
   
  #--------------- INTERMEDIATE (6-10) — CASE logic, HAVING, Subqueries---------------
   
   #Ques6. What is the early-risk rate by grade? 
   
   SELECT 
   grade,
   COUNT(*)  as total_loan,
   SUM(default_flag) as at_risk_loan,
   ROUND(SUM(default_flag)*100/count(*) ,2) as at_risk_rate_pct 
   FROM loan
   GROUP BY grade
   ORDER BY grade;
   
   #Ques 7.Which loan purposes have above-average interest rates AND enough
--     volume to be meaningful? 

   SELECT	
			purpose ,
            count(*) as total_loans,
            round(avg(int_rate),2)  as avg_int_rate
             FROM loan
             GROUP BY purpose 
             HAVING count(*) >=50
             and avg(int_rate) > (select avg(int_rate) from loan) 
             ORDER BY avg_int_rate DESC;
             
#Ques 8. Bucket borrowers into DTI risk bands and compare early-risk rate.

 
 Select 
	CASE 
		WHEN dti<30 then 'Low (<30)'
        WHEN dti<70 then 'medium(<70)'
        WHEN dti<100 then 'high(<100)'
        end as dti_band,
        count(*) as total_loan
        from loan
        GROUP BY dti_band
        ORDER BY dti_band;
        
#Ques 9 . Which loans fall below the 10th percentile of income-to-loan ratio?
--     (identifies "income-stretched" borrowers — subquery on a computed percentile).


 SELECT 
	grade,purpose ,annual_inc,loan_amnt,income_to_loan_ratio
    from loan
    WHERE income_to_loan_ratio<(
    SELECT income_to_loan_ratio
    FROM(
		select income_to_loan_ratio,percent_rank() OVER (ORDER BY income_to_Loan_ratio) as pct1
        from loan
        ) ranked
        where pct1>=0.10
        ORDER BY pct1
        limit 1
        )
        ORDER BY income_to_loan_ratio ASC ;
        
 # ADVANCED-------------  — CTEs & Window Functions------------
 
 
 #Ques 10 . # Percentile ranking of borrowers by income-to-loan ratio within
--      each grade — surfaces the most "stretched" borrowers per risk tier.
SELECT 
    grade,
    ROUND(income_to_loan_ratio,2),
    ROUND(PERCENT_RANK() OVER (
        PARTITION BY grade ORDER BY income_to_loan_ratio
    ) * 100, 1) AS income_ratio_percentile_in_grade
FROM loan
ORDER BY grade, income_ratio_percentile_in_grade;

# ------------END OF QUERIES ------------------




             
   
   
   
  


