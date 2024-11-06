Create Database Telecome_Team_104;

use Telecome_Team_104;


go
create procedure createAllTables
as  
    --Customer Profile
    create table Customer_profile
	(
		nationalID int primary key,
		first_name varchar(50),
		last_name varchar(50),
		email varchar(50),
		address varchar(50),
		date_of_birth date,
	);

	--Customer Account
	--In the schema there is not account type but in the milestone
	-- there is a check for the type??
	create table Customer_Acccount
	(
		mobileNo char(11) primary key,
		pass varchar(50),
		balance decimal(10,1),
		account_type varchar(50),
		start_date date,
		status varchar(50),
		points int default 0,
		nationalID int foreign key references Customer_profile(nationalID),
		type varchar(50),
		--?
		check (type in ('Post Paid', 'Prepaid','Pay_as_you_go')),
		check (status in ('active', 'onhold')),
	);


	--Service Plan
	create table Service_Plan
	(
		planID int identity(1,1) primary key,
		SMS_offered int,
		minutes_offered int,
		data_offered int,
		name varchar(50),
		price int,
		description varchar(50),
	);

	--Subscription
	create table Subscription
	(
		mobileNo char(11) foreign key references Customer_Acccount(mobileNo),
		planID int foreign key references Service_Plan(planID),
		subscription_date date,
		status varchar(50),
		primary key(mobileNo, planID),
		check (status in ('active', 'onhold')),
	);
	
	--Plan Usage
	create table Plan_Usage
	(
		usageID int identity(1,1) primary key,
		start_date date,
		end_date date,
		data_consumption int,
		minutes_used int,
		SMS_sent int,
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		planID int foreign key references Service_Plan(planID),
	);

	--Payment
	create table Payment
	(
		paymentID int identity(1,1) primary key,
		amount decimal(10,1),
		date_of_payment date,
		payment_method varchar(50),
		status varchar(50),
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		check (status in('successful','pedning','rejected')),
		check (payment_method in ('credit', 'cash')),
	);


	--Process Payment
	create table Process_Payment(
		paymentID int identity(1,1) primary key,
		planID int foreign key references Service_Plan(planID),
		foreign key (paymentID) references Payment(paymentID),
		--casues an error needs to be checked
		remaing_balance as case
		when (select amount from Payment P where P.paymentID = paymentID) < (select price from Service_Plan Sp where Sp.planID = planID) 
		then (select amount from Payment P where P.paymentID = paymentID) - (select price from Service_Plan Sp where Sp.planID = planID)
		else 0
		end,
		extra_amount as case
		when (select amount from Payment P where P.paymentID = paymentID) > (select price from Service_Plan Sp where Sp.planID = planID) 
		then (select price from Service_Plan Sp where Sp.planID = planID) - (select amount from Payment P where P.paymentID = paymentID)
		else 0
		end,
	);

	--Wallet
	create table Wallet(
		walletID int identity(1,1) primary key,
		current_balance decimal(10,1),
		currency varchar(50),
		last_modified_date date,
		nationalID int foreign key references Customer_profile(nationalID),
		--Why not moboileNO foreign key?
		mobileNo char(11) --foreign key references Customer_Account(mobileNo),
	);

	--Transfer money
	create table Transfer_money(
	walletID1 int foreign key references Wallet(walletID),
	walletID2 int foreign key references Wallet(walletID),
	transfer_id int identity(1,1),
	amount decimal(10,2),
	tranfser_date date,
	primary key (walletID1, walletID2, transfer_id),
	);

	--Benefits
	create table Benefits(
		benefitID int identity(1,1) primary key,
		description varchar(50),
		validty_date int,
		status varchar(50),
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		check (status in ('active', 'expired')),
	);

	--Points Group
	create table Points_Group(
		pointID int identity(1,1),
		benefitID int foreign key references Benefits(benefitID),
		pointsAmount int,
		paymentID int foreign key references Payment(paymentID),
		primary key(pointID, benefitID),
	);

	--Exclusive Offer
	create table Exclusive_Offer(
		offerID int identity(1,1),
		benefitID int foreign key references Benefits(benefitID),
		internet_offered int,
		SMS_offered int,
		minutes_offered int,
		primary key (offerID, benefitID),
	);

	--Cashback
	create table Cashback(
		cashbackID int identity(1,1),
		benefitID int foreign key references Benefits(benefitID),
		walletID int foreign key references Wallet(walletID),
		amount int,
		credit_date date,
		primary key(cashbackID, benefitID),
	);

	--Plan Provides Benefits
	create table Plan_Provides_Benefits(
		benefitID int foreign key references Benefits(benefitID),
		planID int foreign key references Service_Plan(planID),
		primary key(planID, benefitID),
	);

	--Shop
	create table Shop(
		shopID int identity(1,1) primary key,
		name varchar(50),
		category varchar(50),
	);
	
	--Physcial Shop
	create table Physical_Shop(
	shopID int primary key,
	address varchar(50),
	working_hours varchar(50),
	foreign key (shopID) references Shop(shopID),
	);

	--E-shop
	create table E_Shop(
	shopID int primary key,
	URL varchar(50),
	rating int,
	foreign key (shopID) references Shop(shopID),
	);

	--Voucher
	create table Voucher(
		voucherID int identity(1,1) primary key,
		expiry_date date,
		points int,
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		shopID int foreign key references Shop(shopID),
		redeem_date date,
	);

	--Technical Support Tciket
	create table Techincal_Support_Ticket(
		ticketID int identity(1,1),
		mobileNo char(11) foreign key references Customer_Account(mobileNo),
		issue_description varchar(50),
		priority_level int,
		status varchar(50),
		primary key(ticketID, mobileNo),
		check (status in ('Open', 'In Progress','Resolved')),
	);
go

--TODO: Cashback is calculated as 10% of the payment
--amount.


exec createAllTables;

drop procedure createAllTables;