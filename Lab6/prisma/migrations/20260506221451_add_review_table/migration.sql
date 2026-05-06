-- CreateTable
CREATE TABLE "review" (
    "reviewid" SERIAL NOT NULL,
    "productid" INTEGER NOT NULL,
    "customerid" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "createdat" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "review_pkey" PRIMARY KEY ("reviewid")
);

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_productid_fkey" FOREIGN KEY ("productid") REFERENCES "product"("productid") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "review" ADD CONSTRAINT "review_customerid_fkey" FOREIGN KEY ("customerid") REFERENCES "customer"("customerid") ON DELETE CASCADE ON UPDATE NO ACTION;
