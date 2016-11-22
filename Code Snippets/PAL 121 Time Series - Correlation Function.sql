-- cleanup
DROP TYPE "T_DATA";
DROP TYPE "T_PARAMS";
DROP TYPE "T_RESULTS";
DROP TABLE "SIGNATURE";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP"('DEVUSER', 'P_CF');
DROP TABLE "RESULTS";

-- procedure setup
CREATE TYPE "T_DATA" AS TABLE ("ID" INTEGER, "VALUE" DOUBLE);
CREATE TYPE "T_PARAMS" AS TABLE ("NAME" VARCHAR(60), "INTARGS" INTEGER, "DOUBLEARGS" DOUBLE, "STRINGARGS" VARCHAR(100));
CREATE TYPE "T_RESULTS" AS TABLE ("LAG" INTEGER, "ACV_CCV" DOUBLE, "ACF_CCF" DOUBLE, "PACF" DOUBLE);

CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" NVARCHAR(256), "TYPE_NAME" NVARCHAR(256), "PARAMETER_TYPE" VARCHAR(7));
INSERT INTO "SIGNATURE" VALUES (1, 'DEVUSER', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'DEVUSER', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'DEVUSER', 'T_RESULTS', 'OUT');

CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE"('AFLPAL', 'CORRELATIONFUNCTION', 'DEVUSER', 'P_CF', "SIGNATURE");

-- data setup
CREATE TABLE "RESULTS" LIKE "T_RESULTS";

-- runtime
DROP TABLE "#PARAMS";
CREATE LOCAL TEMPORARY COLUMN TABLE "#PARAMS" LIKE "T_PARAMS";
INSERT INTO "#PARAMS" VALUES ('THREAD_NUMBER', 4, null, null);
--INSERT INTO "#PARAMS" VALUES ('USE_FFT', -1, null, null); -- -1:auto; 0:brute force; 1:FFT (default:-1)
--INSERT INTO "#PARAMS" VALUES ('MAX_LAG', 10, null, null); -- default sqrt(n)
--INSERT INTO "#PARAMS" VALUES ('CALCULATE_PACF', 1, null, null); -- 0:no; 1:yes (default:1)

TRUNCATE TABLE "RESULTS";

CALL "P_CF" ("PAL"."IOTSIGNALS", "#PARAMS", "RESULTS") WITH OVERVIEW;

SELECT * FROM "RESULTS";
