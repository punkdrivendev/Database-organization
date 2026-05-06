-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "buyin_status" AS ENUM ('Accepted', 'Rejected', 'PreparedForSale', 'Sold');

-- CreateEnum
CREATE TYPE "instrument_condition" AS ENUM ('LikeNew', 'Excellent', 'Good', 'Fair', 'NeedsRepair');

-- CreateEnum
CREATE TYPE "message_role" AS ENUM ('user', 'ai_model');

-- CreateEnum
CREATE TYPE "order_status" AS ENUM ('New', 'Paid', 'Shipped', 'Delivered', 'Cancelled');

-- CreateEnum
CREATE TYPE "rent_status" AS ENUM ('Active', 'Returned', 'Cancelled');

-- CreateEnum
CREATE TYPE "repair_status" AS ENUM ('Accepted', 'InProgress', 'WaitingForParts', 'Completed', 'Cancelled', 'IssuedToCustomer');

-- CreateEnum
CREATE TYPE "setup_status" AS ENUM ('Accepted', 'InProgress', 'Completed', 'Cancelled', 'IssuedToCustomer');

-- CreateEnum
CREATE TYPE "setup_type" AS ENUM ('Basic', 'Full', 'StringsReplacement', 'IntonationAdjustment', 'NeckAdjustment');

-- CreateEnum
CREATE TYPE "studio_booking_status" AS ENUM ('Booked', 'Completed', 'Cancelled');

-- CreateTable
CREATE TABLE "brand" (
    "brandid" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,

    CONSTRAINT "brand_pkey" PRIMARY KEY ("brandid")
);

-- CreateTable
CREATE TABLE "category" (
    "categoryid" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,

    CONSTRAINT "category_pkey" PRIMARY KEY ("categoryid")
);

-- CreateTable
CREATE TABLE "customer" (
    "customerid" SERIAL NOT NULL,
    "firstname" VARCHAR(100) NOT NULL,
    "lastname" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(20),
    "passwordhash" VARCHAR(255) NOT NULL,

    CONSTRAINT "customer_pkey" PRIMARY KEY ("customerid")
);

-- CreateTable
CREATE TABLE "customerorder" (
    "orderid" SERIAL NOT NULL,
    "customerid" INTEGER NOT NULL,
    "orderdate" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "order_status" NOT NULL DEFAULT 'New',
    "shippingaddress" VARCHAR(255) NOT NULL,

    CONSTRAINT "customerorder_pkey" PRIMARY KEY ("orderid")
);

-- CreateTable
CREATE TABLE "instrumentbuyin" (
    "buyinid" SERIAL NOT NULL,
    "customerid" INTEGER NOT NULL,
    "productid" INTEGER NOT NULL,
    "condition" "instrument_condition" NOT NULL,
    "status" "buyin_status" NOT NULL,
    "buyinprice" DECIMAL(10,2) NOT NULL,
    "sellingprice" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "instrumentbuyin_pkey" PRIMARY KEY ("buyinid")
);

-- CreateTable
CREATE TABLE "orderitem" (
    "orderitemid" SERIAL NOT NULL,
    "orderid" INTEGER NOT NULL,
    "productid" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unitprice" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "orderitem_pkey" PRIMARY KEY ("orderitemid")
);

-- CreateTable
CREATE TABLE "product" (
    "productid" SERIAL NOT NULL,
    "categoryid" INTEGER NOT NULL,
    "brandid" INTEGER NOT NULL,
    "model" VARCHAR(100) NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "stockquantity" INTEGER NOT NULL,

    CONSTRAINT "product_pkey" PRIMARY KEY ("productid")
);

-- CreateTable
CREATE TABLE "rent" (
    "rentid" SERIAL NOT NULL,
    "customerid" INTEGER NOT NULL,
    "productid" INTEGER NOT NULL,
    "pickupdate" TIMESTAMP(6) NOT NULL,
    "duration" INTEGER NOT NULL,
    "returndate" TIMESTAMP(6) NOT NULL,
    "status" "rent_status" NOT NULL,
    "percentagefromprice" DECIMAL(5,2) NOT NULL,
    "depositamount" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "rent_pkey" PRIMARY KEY ("rentid")
);

-- CreateTable
CREATE TABLE "repairservice" (
    "repairid" SERIAL NOT NULL,
    "customerid" INTEGER NOT NULL,
    "productid" INTEGER NOT NULL,
    "accepteddate" TIMESTAMP(6) NOT NULL,
    "completiondate" TIMESTAMP(6),
    "status" "repair_status" NOT NULL,
    "problemdescription" TEXT NOT NULL,
    "repairdetails" TEXT NOT NULL,
    "estimatedprice" DECIMAL(10,2) NOT NULL,
    "finalprice" DECIMAL(10,2),

    CONSTRAINT "repairservice_pkey" PRIMARY KEY ("repairid")
);

-- CreateTable
CREATE TABLE "setupservice" (
    "setupid" SERIAL NOT NULL,
    "customerid" INTEGER NOT NULL,
    "productid" INTEGER NOT NULL,
    "accepteddate" TIMESTAMP(6) NOT NULL,
    "completeddate" TIMESTAMP(6),
    "status" "setup_status" NOT NULL,
    "setuptype" "setup_type" NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "setupservice_pkey" PRIMARY KEY ("setupid")
);

-- CreateTable
CREATE TABLE "studiobooking" (
    "studioid" SERIAL NOT NULL,
    "customerid" INTEGER NOT NULL,
    "recorddate" TIMESTAMP(6) NOT NULL,
    "status" "studio_booking_status" NOT NULL,
    "duration" INTEGER NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "studiobooking_pkey" PRIMARY KEY ("studioid")
);

-- CreateIndex
CREATE UNIQUE INDEX "brand_name_key" ON "brand"("name");

-- CreateIndex
CREATE UNIQUE INDEX "category_name_key" ON "category"("name");

-- CreateIndex
CREATE UNIQUE INDEX "customer_email_key" ON "customer"("email");

-- CreateIndex
CREATE UNIQUE INDEX "instrumentbuyin_productid_key" ON "instrumentbuyin"("productid");

-- CreateIndex
CREATE UNIQUE INDEX "orderitem_orderid_productid_key" ON "orderitem"("orderid", "productid");

-- AddForeignKey
ALTER TABLE "customerorder" ADD CONSTRAINT "customerorder_customerid_fkey" FOREIGN KEY ("customerid") REFERENCES "customer"("customerid") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "instrumentbuyin" ADD CONSTRAINT "instrumentbuyin_customerid_fkey" FOREIGN KEY ("customerid") REFERENCES "customer"("customerid") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "instrumentbuyin" ADD CONSTRAINT "instrumentbuyin_productid_fkey" FOREIGN KEY ("productid") REFERENCES "product"("productid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "orderitem" ADD CONSTRAINT "orderitem_orderid_fkey" FOREIGN KEY ("orderid") REFERENCES "customerorder"("orderid") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "orderitem" ADD CONSTRAINT "orderitem_productid_fkey" FOREIGN KEY ("productid") REFERENCES "product"("productid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_brandid_fkey" FOREIGN KEY ("brandid") REFERENCES "brand"("brandid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_categoryid_fkey" FOREIGN KEY ("categoryid") REFERENCES "category"("categoryid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "rent" ADD CONSTRAINT "rent_customerid_fkey" FOREIGN KEY ("customerid") REFERENCES "customer"("customerid") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "rent" ADD CONSTRAINT "rent_productid_fkey" FOREIGN KEY ("productid") REFERENCES "product"("productid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "repairservice" ADD CONSTRAINT "repairservice_customerid_fkey" FOREIGN KEY ("customerid") REFERENCES "customer"("customerid") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "repairservice" ADD CONSTRAINT "repairservice_productid_fkey" FOREIGN KEY ("productid") REFERENCES "product"("productid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "setupservice" ADD CONSTRAINT "setupservice_customerid_fkey" FOREIGN KEY ("customerid") REFERENCES "customer"("customerid") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "setupservice" ADD CONSTRAINT "setupservice_productid_fkey" FOREIGN KEY ("productid") REFERENCES "product"("productid") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "studiobooking" ADD CONSTRAINT "studiobooking_customerid_fkey" FOREIGN KEY ("customerid") REFERENCES "customer"("customerid") ON DELETE CASCADE ON UPDATE NO ACTION;
