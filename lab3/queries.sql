SELECT FirstName, LastName FROM Customer WHERE Email = '';
SELECT Brand, Model,Price, StockQuantity FROM Product WHERE CategoryID = 1;
SELECT Model FROM Product WHERE Brand = 'Fender';
SELECT Status FROM CustomerOrder WHERE ShippingAddress = 'Київ%';
SELECT PickUpDAte,Duration,Status FROM Rent;
SELECT Status FROM StudioBooking WHERE RecordDate >= '2026-04-01' AND RecordDate < '2026-05-01'>;
SELECT * FROM SetUpService;

UPDATE StudioBooking
SET Status = 'Completed'
WHERE RecordDate = '2026-04-08 18:00:00';
UPDATE Product
SET StockQuantity = 1
WHERE Model = 'Telecaster Custom';

DELETE FROM StudioBooking
WHERE Status = 'Booked' AND RecordDate >= '2026-04-10 00:00:00' AND < '2026-04-11 00:00:00';
