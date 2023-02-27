#Creating Database and using it for our analysis
create database rewards;
use rewards;

#Creating Tables from our relaional datamodel
# --Users
CREATE TABLE IF NOT EXISTS `rewards`.`users` (
  `user_ID` VARCHAR(45) NOT NULL,
  `created_date` VARCHAR(50) NULL DEFAULT NULL,
  `birth_date` VARCHAR(45) NULL DEFAULT NULL,
  `gender` VARCHAR(45) NULL DEFAULT NULL,
  `last_rewards_login` VARCHAR(45) NULL DEFAULT NULL,
  `state` VARCHAR(45) NULL DEFAULT NULL,
  `sign_up_platform` VARCHAR(45) NULL DEFAULT NULL,
  `sign_up_source` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`user_ID`));
  
  # --Receipts
  CREATE TABLE IF NOT EXISTS `rewards`.`receipts` (
  `receipt_ID` VARCHAR(45) NOT NULL,
  `store_name` VARCHAR(100) NULL DEFAULT NULL,
  `purchase_date` VARCHAR(45) NULL DEFAULT NULL,
  `purchase_time` VARCHAR(45) NULL DEFAULT NULL,
  `date_scanned` VARCHAR(45) NULL DEFAULT NULL,
  `total_spent` DOUBLE NULL DEFAULT NULL,
  `rewards_receipt_status` VARCHAR(45) NULL DEFAULT NULL,
  `user_ID` VARCHAR(100) NULL DEFAULT NULL,
  `user_viewed` VARCHAR(45) NULL DEFAULT NULL,
  `purchase_item_count` FLOAT NULL DEFAULT NULL,
  `create_date` VARCHAR(45) NULL DEFAULT NULL,
  `pending_date` VARCHAR(45) NULL DEFAULT NULL,
  `modify_date` VARCHAR(45) NULL DEFAULT NULL,
  `flagged_date` VARCHAR(45) NULL DEFAULT NULL,
  `processed_date` VARCHAR(100) NULL DEFAULT NULL,
  `Finished_date` VARCHAR(45) NULL DEFAULT NULL,
  `Rejected_date` VARCHAR(45) NULL DEFAULT NULL,
  `Needs_fetch_review` VARCHAR(45) NULL DEFAULT NULL,
  `Digital_review` VARCHAR(20) NULL DEFAULT NULL,
  `Deleted` VARCHAR(45) NULL DEFAULT NULL,
  `Non_point_earning_receipt` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`receipt_ID`),
  INDEX `user_ID_idx` (`user_ID` ASC) VISIBLE,
  CONSTRAINT `user_ID`
    FOREIGN KEY (`user_ID`)
    REFERENCES `rewards`.`users` (`user_ID`));
    
    # --Receipt_items
    CREATE TABLE IF NOT EXISTS `rewards`.`receipt_items` (
  `REWARDS_RECEIPT_ID` VARCHAR(45) NULL DEFAULT NULL,
  `ITEM_INDEX` INT NULL DEFAULT NULL,
  `REWARDS_RECEIPT_ITEM_ID` VARCHAR(45) NOT NULL,
  `DESCRIPTION` VARCHAR(1000) NULL,
  `BARCODE` VARCHAR(45) NULL DEFAULT NULL,
  `BRAND_CODE` VARCHAR(45) NULL DEFAULT NULL,
  `QUANTITY_PURCHASED` DOUBLE NULL DEFAULT NULL,
  `TOTAL_FINAL_PRICE` DOUBLE NULL DEFAULT NULL,
  `POINTS_EARNED` FLOAT NULL DEFAULT NULL,
  `REWARDS_GROUP` VARCHAR(45) NULL DEFAULT NULL,
  `MODIFY_DATE` VARCHAR(45) NULL DEFAULT NULL,
  `ORIGINAL_RECEIPT_ITEM_TEXT` VARCHAR(1000) NULL,
  PRIMARY KEY (`REWARDS_RECEIPT_ITEM_ID`),
  INDEX `BRAND_CODE_idx` (`BRAND_CODE` ASC) VISIBLE,
  INDEX `REWARDS_RECEIPT_ID_idx` (`REWARDS_RECEIPT_ID` ASC) VISIBLE,
  CONSTRAINT `BRAND_CODE`
    FOREIGN KEY (`BRAND_CODE`)
    REFERENCES `rewards`.`brands` (`Brand_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `REWARDS_RECEIPT_ID`
    FOREIGN KEY (`REWARDS_RECEIPT_ID`)
    REFERENCES `rewards`.`receipts` (`receipt_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
    
    # --Brands
    CREATE TABLE IF NOT EXISTS `rewards`.`brands` (
  `Brand_ID` VARCHAR(50) NOT NULL,
  `Barcode` BIGINT NULL DEFAULT NULL,
  `Brand_code` VARCHAR(45) NULL DEFAULT NULL,
  `CPG_ID` VARCHAR(45) CHARACTER SET 'ascii' NULL DEFAULT NULL,
  `Category` VARCHAR(45) NULL DEFAULT NULL,
  `Category_code` VARCHAR(45) NULL DEFAULT NULL,
  `Name` VARCHAR(45) NULL DEFAULT NULL,
  `Romance_text` VARCHAR(1000) NULL DEFAULT NULL,
  `Related_brand_ids` VARCHAR(200) NULL DEFAULT NULL,
  PRIMARY KEY (`Brand_ID`),
  INDEX `fk` (`Brand_code` ASC) VISIBLE);
  
  select * from users;
  select * from receipts;
  select * from receipt_items;
  select * from brands;


#Qn 1 - Which brand saw the most dollars spent in the month of June?

select b.`Name`, sum(r.total_spent) as total_spent from Brands b
join Receipt_items ri on b.Brand_code = ri.Brand_code
join Receipts r on ri.rewards_receipt_ID = r.receipt_ID
WHERE substring(r.purchase_date,6,2 ) = "06"
GROUP BY b.`Name`
ORDER BY total_spent desc
limit 1;

# Answer - Brand Name: KEEBLER (Total Spent = 1172145.83)

#Qn 2 - Which user spent the most money in the month of August?

select u.user_ID , sum(r.total_spent) as total_spent from users u
join Receipts r on u.user_ID = r.user_ID
WHERE substring(r.purchase_date,6,2) = "08"
GROUP BY u.user_ID
ORDER BY total_spent desc
limit 1;

# Answer - User_ID : 609ab37f7a2e8f2f95ae968f (Total Spent = 157739.13999999998)

#Qn 3 - What user bought the most expensive item?

with cte as (
select distinct r.user_ID, ri.total_final_price/ri.quantity_purchased as cost, 
dense_rank() over(order by ri.total_final_price/ri.quantity_purchased desc) rank_cost from receipts r 
join receipt_items ri on r.receipt_ID = ri.rewards_receipt_ID)
select user_ID, cost from cte 
where rank_cost = 1;

# Answer: User_ID: 617376b8a9619d488190e0b6, (Cost - 31005.99)
#Two users have boought the bost expensive item

#Qn 4 - What is the name of the most expensive item purchased?

select * from receipt_items;
select  ri.Brand_code, ri.total_final_price/ri.quantity_purchased as unit_price from receipt_items ri
order by 2 desc
limit 1;

#Answer: 'Starbucks Iced Coffee Premium Coffee Beverage Unsweetened Blonde Roast Bottle 48 Oz 1 Ct'

#Qn 5 - How many users scanned in each month?

select substring(r.purchase_date,6,2) as month,  count(u.user_ID) from users u
join Receipts r on u.user_ID = r.user_ID
group by substring(r.purchase_date,6,2)
order by 1 desc;

#--Answer: 
#Month: 12, Count of users: 8170
#Month: 11, Count of users: 7481
#Month: 10, Count of users: 7014
#Month: 09, Count of users: 6295
#Month: 08, Count of users: 6102
#Month: 07, Count of users: 5927
#Month: 06, Count of users: 5215
#Month: 05, Count of users: 5344
#Month: 04, Count of users: 4738
#Month: 03, Count of users: 4762
#Month: 02, Count of users: 3668
#Month: 01, Count of users: 3819