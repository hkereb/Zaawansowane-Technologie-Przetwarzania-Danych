SET SERVEROUTPUT ON;

-- 1.
CREATE TABLE movies AS SELECT * FROM ZTPD.movies;

-- 3.
SELECT id, title FROM movies WHERE cover IS NULL;

-- 4
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM movies 
WHERE cover IS NOT NULL;

-- 5.
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM movies 
WHERE cover IS NULL;

-- 6.
SELECT directory_name, directory_path 
FROM all_directories 
WHERE directory_name = 'TPD_DIR';

-- 7.
UPDATE movies 
SET cover = EMPTY_BLOB(), mime_type = 'image/jpeg' 
WHERE id = 66;
COMMIT;

-- 8.
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM movies 
WHERE id IN (65, 66);

-- 9.
DECLARE
    v_bfile BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
    v_blob BLOB;
BEGIN
    SELECT cover INTO v_blob 
    FROM movies 
    WHERE id = 66 
    FOR UPDATE;
    
    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
    DBMS_LOB.FILECLOSE(v_bfile);
    
    COMMIT;
END;
/

-- 10.
CREATE TABLE temp_covers (
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

-- 11.
INSERT INTO temp_covers VALUES (65, BFILENAME('TPD_DIR', 'eagles.jpg'), 'image/jpeg');
COMMIT;

-- 12.
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS filesize 
FROM temp_covers;

-- 13.
DECLARE
    v_bfile BFILE;
    v_blob Tymczasowy BLOB;
    v_mime VARCHAR2(50);
BEGIN
    SELECT image, mime_type INTO v_bfile, v_mime 
    FROM temp_covers 
    WHERE movie_id = 65;
    
    DBMS_LOB.CREATETEMPORARY(v_blob, TRUE);
    
    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(v_blob, v_bfile, DBMS_LOB.GETLENGTH(v_bfile));
    DBMS_LOB.FILECLOSE(v_bfile);
    
    UPDATE movies 
    SET cover = v_blob, mime_type = v_mime 
    WHERE id = 65;
    
    DBMS_LOB.FREETEMPORARY(v_blob);
    COMMIT;
END;
/

-- 14.
SELECT id, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM movies 
WHERE id IN (65, 66);

-- 15.
DROP TABLE movies;

-- -----------------------------------------------------------------------

-- 16.
CREATE TABLE dokumenty (
    id NUMBER(12) PRIMARY KEY,
    dokument CLOB
);

-- 17.
DECLARE
    v_clob CLOB;
    v_text VARCHAR2(50) := 'Oto tekst. ';
BEGIN
    DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);
    FOR i IN 1..10000 LOOP
        DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_text), v_text);
    END LOOP;
    INSERT INTO dokumenty VALUES (1, v_clob);
    DBMS_LOB.FREETEMPORARY(v_clob);
    COMMIT;
END;
/

-- 18.
-- a) 
SELECT * FROM dokumenty;
-- b) 
SELECT id, UPPER(dokument) FROM dokumenty;
-- c)
SELECT id, LENGTH(dokument) FROM dokumenty;
-- d) 
SELECT id, DBMS_LOB.GETLENGTH(dokument) FROM dokumenty;
-- e)
SELECT id, SUBSTR(dokument, 5, 1000) FROM dokumenty;
-- f)
SELECT id, DBMS_LOB.SUBSTR(dokument, 1000, 5) FROM dokumenty;

-- 19.
INSERT INTO dokumenty VALUES (2, EMPTY_CLOB());

-- 20.
INSERT INTO dokumenty VALUES (3, NULL);
COMMIT;

-- 21.
SELECT * FROM dokumenty;
SELECT id, UPPER(dokument) FROM dokumenty;
SELECT id, LENGTH(dokument) FROM dokumenty;
SELECT id, DBMS_LOB.GETLENGTH(dokument) FROM dokumenty;
SELECT id, SUBSTR(dokument, 5, 1000) FROM dokumenty;
SELECT id, DBMS_LOB.SUBSTR(dokument, 1000, 5) FROM dokumenty;

-- 22
DECLARE
    v_bfile BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
    v_clob CLOB;
    v_dest_offset INTEGER := 1;
    v_src_offset INTEGER := 1;
    v_bfile_csid NUMBER := 0;
    v_lang_context INTEGER := 0;
    v_warning INTEGER := 0;
BEGIN
    SELECT dokument INTO v_clob 
    FROM dokumenty 
    WHERE id = 2 
    FOR UPDATE;
    
    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADCLOBFROMFILE(v_clob, v_bfile, DBMS_LOB.LOBMAXSIZE, 
                              v_dest_offset, v_src_offset, 
                              v_bfile_csid, v_lang_context, v_warning);
    DBMS_LOB.FILECLOSE(v_bfile);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status operacji: ' || v_warning);
END;
/

-- 23.
UPDATE dokumenty 
SET dokument = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt')) 
WHERE id = 3;
COMMIT;

-- 24.
SELECT * FROM dokumenty;

-- 25.
SELECT id, DBMS_LOB.GETLENGTH(dokument) AS rozmiar 
FROM dokumenty;

-- 26.
DROP TABLE dokumenty;