-- cleanup
DROP TYPE "T_DATA";
DROP TYPE "T_PARAMS";
DROP TYPE "T_RULES";
DROP TABLE "SIGNATURE";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP"('DEVUSER', 'P_SPM');
DROP VIEW "V_DATA";
DROP TABLE "RULES";

-- procedure setup
CREATE TYPE "T_DATA" AS TABLE ("CUSTOMER_ID" INTEGER, "CALENDAR_ID" INTEGER, "ITEM_ID" INTEGER);
CREATE TYPE "T_PARAMS" AS TABLE ("NAME" VARCHAR(60), "INTARGS" INTEGER, "DOUBLEARGS" DOUBLE, "STRINGARGS" VARCHAR(100));
CREATE TYPE "T_RULES" AS TABLE ("RESULT" VARCHAR(255), "SUPPORT" DOUBLE, "CONFIDENCE" DOUBLE, "LIFT" DOUBLE);

CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" NVARCHAR(256), "TYPE_NAME" NVARCHAR(256), "PARAMETER_TYPE" VARCHAR(7));
INSERT INTO "SIGNATURE" VALUES (1, 'DEVUSER', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'DEVUSER', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'DEVUSER', 'T_RULES', 'OUT');

CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE"('AFLPAL', 'SPM', 'DEVUSER', 'P_SPM', "SIGNATURE");

-- data & view setup
CREATE VIEW "V_DATA" AS 
	SELECT "CUSTOMER_ID", "CALENDAR_ID", "ITEM_ID"
		FROM "PAL"."ORDER_FACTS"
	;
CREATE COLUMN TABLE "RULES" LIKE "T_RULES";

-- runtime
DROP TABLE "#PARAMS";
CREATE LOCAL TEMPORARY COLUMN TABLE "#PARAMS" LIKE "T_PARAMS";
INSERT INTO "#PARAMS" VALUES ('MIN_SUPPORT', null, 0.003, null);

TRUNCATE TABLE "RULES";

CALL "P_SPM" ("V_DATA", "#PARAMS", "RULES") WITH OVERVIEW;

SELECT * FROM "RULES" ORDER BY "CONFIDENCE" DESC;
