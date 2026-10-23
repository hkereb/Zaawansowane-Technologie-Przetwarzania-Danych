-- A. 
CREATE TABLE figury (
    id NUMBER(1) PRIMARY KEY,
    ksztalt MDSYS.SDO_GEOMETRY
);

-- B.
-- koło
INSERT INTO figury VALUES (
    1,
    SDO_GEOMETRY(
        2003, NULL, NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 4),
        SDO_ORDINATE_ARRAY(5,3, 7,5, 5,7)
    )
);

-- prostokąt
INSERT INTO figury VALUES (
    2,
    SDO_GEOMETRY(
        2003, NULL, NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 3),
        SDO_ORDINATE_ARRAY(1,1, 5,5)
    )
);

-- linia
INSERT INTO figury VALUES (
    3,
    SDO_GEOMETRY(
        2002, NULL, NULL,
        SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
        SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1)
    )
);

-- C.
INSERT INTO figury VALUES (
    4,
    SDO_GEOMETRY(
        2003, NULL, NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 1),
        SDO_ORDINATE_ARRAY(1,1, 2,1, 2,2, 1,2)
    )
);

-- D.
SELECT id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.01) AS val 
FROM figury;

-- E. 
DELETE FROM figury 
WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.01) <> 'TRUE';

-- F.
COMMIT;