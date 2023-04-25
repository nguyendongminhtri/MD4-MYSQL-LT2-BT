create table customer (
cID int primary key auto_increment,
Name varchar(25),
cAge tinyint
);
create table orders (
oID int primary key auto_increment,
cID int, 
oDate datetime,
oTotalPrice int
);
alter table orders alter column oTotalPrice set default null;
alter table orders add foreign key (cID) references customer (cID);
create table product (
pID int primary key auto_increment,
pName varchar(25),
pPrice int
);

create table orderdetail (
oID int,
pID int,
odQTY int,
foreign key (oID) references orders (oID),
foreign key (pID) references product (pID)
);
INSERT INTO customer(Name, cAge) values ('Minh Quan',10) ,('Ngoc Oanh',20) ,('Hong Ha',50);
INSERT INTO orders (oID, cID, oDate) values (1,1,'2006-03-21'), (2,2,'2006-03-23'), (3,1, '2006-03-16');
INSERT INTO orders (oID, cID, oDate) values (8,3,'2006-03-21');
INSERT INTO product( pName, pPrice) values ('May Giat',3), ('Tu Lanh',5), ('Dieu Hoa',7), ('Quat', 1), ('Bep Dien',2);
INSERT INTO orderdetail (oID, pID, odQTY) values (1,1,3), (1,3,7),(1,4,2), (2,1,1),(3,1,8),(2,5,4),(2,3,3);
-- 2.	Hiển thị các thông tin  gồm oID, oDate, oTotalPrice của tất cả các hóa đơn trong bảng Orders, 
-- danh sách phải sắp xếp theo thứ tự ngày tháng, hóa đơn mới hơn nằm trên như hình sau:
select * from orders order by oDate desc;
-- 3.	Hiển thị tên và giá của các sản phẩm có giá cao nhất như sau:
select pName, pPrice from product where pPrice = (select max(pPrice) from product);
-- 4.	Hiển thị danh sách các khách hàng đã mua hàng, 
-- và danh sách sản phẩm được mua bởi các khách đó như sau:
select Name as cName, pName from customer join orders on orders.cID = customer.cID join orderdetail on orders.oID = orderdetail.oID
join product on product.pID = orderdetail.pID;
-- 5.	Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào như sau:
SELECT name as cName from customer t1
  WHERE NOT EXISTS (SELECT 1 FROM orders t2 WHERE t1.cID = t2.cID);
--   6.	Hiển thị chi tiết của từng hóa đơnnhư sau :
select orders.oID,  oDate, odQTY, product.pName, product.pPrice from orderdetail join orders on orderdetail.oID = orders.oID
join product on orderdetail.pID = product.pID;

-- 7.	Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn (giá một hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng 
-- xuất hiện trong hóa đơn. Giá bán của từng loại được tính = odQTY*pPrice) như sau:
select orders.oID, orders.oDate, sum(orderdetail.odQTY*product.pPrice) as Total from orderdetail join orders on orderdetail.oID = orders.oID
join product on orderdetail.pID = product.pID group by orderdetail.oID;
-- 8.	Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị như sau:
create view Salses as SELECT SUM(tmp.Total) as Sales
FROM (
  SELECT  sum(orderdetail.odQTY*product.pPrice) as Total from orderdetail join orders on orderdetail.oID = orders.oID
join product on orderdetail.pID = product.pID group by orderdetail.oID
) AS tmp;
select * from salses;
drop view salses;
-- 9. Xoa khoa chinh
ALTER TABLE customer CHANGE cID cID int(10) UNSIGNED NOT NULL;
-- 10.	Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa mã khách 
-- (cID) thì mã khách trong bảng Order cũng được sửa theo: .	[2.5]
delimiter //
create trigger cusUpdate 
after update on customer
for each row 
update `Orders` set cID = new.cID where cID = old.cID;
// delimiter ;
DROP TRIGGER cusUpdate;
alter table orders drop foreign key orders_ibfk_1;
alter table customer drop primary key;

UPDATE customer set cID = 10 WHERE cID=5;
SET SQL_SAFE_UPDATES = 0;

-- 11.	
-- Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của một 
-- sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên vào thông qua tham số, 
-- và các thông tin liên quan đến sản phẩm đó ở trong bảng OrderDetail
DELIMITER //
CREATE PROCEDURE delProduct(in delPName varchar(25))
begin
delete from orderdetail where pID = (select pID from product where pName = delPName);
delete from product  where pName = delPName;
end //
DELIMITER ;
call delProduct('May Giat');


