-- cleanup
DROP TYPE "T_DATA";
DROP TYPE "T_PARAMS";
DROP TYPE "T_CONTINUOUS";
DROP TYPE "T_CATEGORICAL";
DROP TABLE "SIGNATURE";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP"('DEVUSER', 'P_DS');
DROP TABLE "RESULTS_CONTINUOUS";
DROP TABLE "RESULTS_CATEGORICAL";

-- procedure setup
CREATE TYPE "T_DATA" AS TABLE ("ID" INTEGER, "POLICY" NVARCHAR(10), "AGE" INTEGER, "AMOUNT" INTEGER, "OCCUPATION" NVARCHAR(10), "FRAUD" NVARCHAR(10));
CREATE TYPE "T_PARAMS" AS TABLE ("NAME" VARCHAR(60), "INTARGS" INTEGER, "DOUBLEARGS" DOUBLE, "STRINGARGS" VARCHAR(100));
CREATE TYPE "T_CONTINUOUS" AS TABLE ("VARIABLE" VARCHAR(100), "STATISTIC" VARCHAR(50), "VALUE" DOUBLE);
CREATE TYPE "T_CATEGORICAL" AS TABLE ("VARIABLE" VARCHAR(100), "CATEGORY" VARCHAR(100), "STATISTIC" VARCHAR(50), "VALUE" DOUBLE);

CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" NVARCHAR(256), "TYPE_NAME" NVARCHAR(256), "PARAMETER_TYPE" VARCHAR(7));
INSERT INTO "SIGNATURE" VALUES (1, 'DEVUSER', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'DEVUSER', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'DEVUSER', 'T_CONTINUOUS', 'OUT');
INSERT INTO "SIGNATURE" VALUES (4, 'DEVUSER', 'T_CATEGORICAL', 'OUT');

CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE"('AFLPAL', 'DATASUMMARY', 'DEVUSER', 'P_DS', "SIGNATURE");

-- data setup
CREATE COLUMN TABLE "RESULTS_CONTINUOUS" LIKE "T_CONTINUOUS";
CREATE COLUMN TABLE "RESULTS_CATEGORICAL" LIKE "T_CATEGORICAL";

-- runtime
DROP TABLE "#PARAMS";
CREATE LOCAL TEMPORARY COLUMN TABLE "#PARAMS" LIKE "T_PARAMS";
--INSERT INTO "#PARAMS" VALUES ('CATEGORY_COL', 3, null, null); -- default -1
--INSERT INTO "#PARAMS" VALUES ('SIGNIFICANCE_LEVEL', null, 0.05, null); -- 0 --> 1
--INSERT INTO "#PARAMS" VALUES ('TRIMMED_PERCENTAGE', null, 0.05, null); -- 0 --> 0.5

TRUNCATE TABLE "RESULTS_CONTINUOUS";
TRUNCATE TABLE "RESULTS_CATEGORICAL";

CALL "P_DS" ("PAL"."CLAIMS", "#PARAMS", "RESULTS_CONTINUOUS", "RESULTS_CATEGORICAL") WITH OVERVIEW;

SELECT * FROM "RESULTS_CONTINUOUS";
SELECT * FROM "RESULTS_CATEGORICAL";
