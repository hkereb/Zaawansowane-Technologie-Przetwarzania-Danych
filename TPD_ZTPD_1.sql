-- pomocniczo
--DROP TABLE samochody;

SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE samochod AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2),
    MEMBER FUNCTION wartosc RETURN NUMBER,
    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER
);
/ 

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek NUMBER;
    BEGIN
        wiek := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_produkcji);
        RETURN cena * POWER(0.9, wiek);
    END;

    MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS
        wiek NUMBER;
    BEGIN
        wiek := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_produkcji);
        RETURN wiek + (kilometry / 10000);
    END;
END;
/ 

CREATE TABLE samochody OF samochod;

INSERT INTO samochody VALUES (samochod('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000));
INSERT INTO samochody VALUES (samochod('FORD', 'MONDEO', 80000, TO_DATE('10-05-1997', 'DD-MM-YYYY'), 45000));
INSERT INTO samochody VALUES (samochod('MAZDA', '323', 12000, TO_DATE('22-09-2000', 'DD-MM-YYYY'), 52000));

-- 1
SELECT * FROM samochody;
-- 2
SELECT s.marka, s.cena, s.wartosc() FROM samochody s;
-- 3
SELECT * FROM samochody s ORDER BY VALUE(s);

-- -----------------------------------------------------------------------
CREATE TABLE wlasciciele (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    auto samochod
);

INSERT INTO wlasciciele VALUES ('JAN', 'KOWALSKI', samochod('FIAT', 'SEICENTO', 30000, TO_DATE('02-12-2010', 'DD-MM-YYYY'), 19500));
INSERT INTO wlasciciele VALUES ('ADAM', 'NOWAK', samochod('OPEL', 'ASTRA', 34000, TO_DATE('01-06-2009', 'DD-MM-YYYY'), 33700));
-- 4.
SELECT * FROM wlasciciele;

DROP TABLE wlasciciele;

CREATE OR REPLACE TYPE wlasciciel AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
);
/

CREATE TABLE wlasciciele OF wlasciciel;
INSERT INTO wlasciciele VALUES (wlasciciel('JAN', 'KOWALSKI'));
INSERT INTO wlasciciele VALUES (wlasciciel('ADAM', 'NOWAK'));

-- 7.
ALTER TYPE samochod ADD ATTRIBUTE (wlasciciel_ref REF wlasciciel) CASCADE;

DELETE FROM samochody;

ALTER TABLE samochody ADD SCOPE FOR (wlasciciel_ref) IS wlasciciele;

INSERT INTO samochody VALUES (samochod('FIAT', 'BRAVA', 60000, TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000, (SELECT REF(w) FROM wlasciciele w WHERE w.nazwisko = 'KOWALSKI')));
INSERT INTO samochody VALUES (samochod('FORD', 'MONDEO', 80000, TO_DATE('10-05-1997', 'DD-MM-YYYY'), 45000, (SELECT REF(w) FROM wlasciciele w WHERE w.nazwisko = 'NOWAK')));

-- 10.
SELECT * FROM samochody;

-- -----------------------------------------------------------------------
DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty('');
BEGIN
    moje_przedmioty(1) := 'MATEMATYKA';
    moje_przedmioty.EXTEND(9);
    FOR i IN 2..10 LOOP
        moje_przedmioty(i) := 'PRZEDMIOT_' || i;
    END LOOP;
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    moje_przedmioty.TRIM(2);
    FOR i IN moje_przedmioty.FIRST()..moje_przedmioty.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.EXTEND();
    moje_przedmioty(9) := '9';
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moje_przedmioty.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moje_przedmioty.COUNT());
END;
/

-- 12.
DECLARE
    TYPE t_ksiazki IS VARRAY(5) OF VARCHAR2(50);
    moje_ksiazki t_ksiazki := t_ksiazki();
BEGIN
    moje_ksiazki.EXTEND(2);
    moje_ksiazki(1) := 'Gra Endera';
    moje_ksiazki(2) := 'Król Lew';
    DBMS_OUTPUT.PUT_LINE('Książki count: ' || moje_ksiazki.COUNT);
    moje_ksiazki.TRIM(1); 
    DBMS_OUTPUT.PUT_LINE('Po usunieciu: ' || moje_ksiazki.COUNT);
    moje_ksiazki.EXTEND(1);
    moje_ksiazki(2) := 'Fundacja';
    FOR i IN moje_ksiazki.FIRST()..moje_ksiazki.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moje_ksiazki(i));
    END LOOP;
END;
/

-- 13.
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(20);
    moi_wykladowcy t_wykladowcy := t_wykladowcy();
BEGIN
    moi_wykladowcy.EXTEND(2);
    moi_wykladowcy(1) := 'MORZY';
    moi_wykladowcy(2) := 'WOJCIECHOWSKI';
    moi_wykladowcy.EXTEND(8);
    FOR i IN 3..10 LOOP
        moi_wykladowcy(i) := 'WYKLADOWCA_' || i;
    END LOOP;
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    moi_wykladowcy.TRIM(2);
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
    END LOOP;
    moi_wykladowcy.DELETE(5,7);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    moi_wykladowcy(5) := 'ZAKRZEWICZ';
    moi_wykladowcy(6) := 'KROLIKOWSKI';
    moi_wykladowcy(7) := 'KOSZLAJDA';
    FOR i IN moi_wykladowcy.FIRST()..moi_wykladowcy.LAST() LOOP
        IF moi_wykladowcy.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(moi_wykladowcy(i));
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Limit: ' || moi_wykladowcy.LIMIT());
    DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || moi_wykladowcy.COUNT());
END;
/

-- 14.
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(15);
    miesiace t_miesiace := t_miesiace();
BEGIN
    miesiace.EXTEND(3);
    miesiace(1) := 'STYCZEN';
    miesiace(2) := 'LUTY';
    miesiace(3) := 'MARZEC';
    miesiace.DELETE(2); 
    FOR i IN miesiace.FIRST()..miesiace.LAST() LOOP
        IF miesiace.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE(miesiace(i));
        END IF;
    END LOOP;
END;
/

-- 15.
CREATE OR REPLACE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE OR REPLACE TYPE stypendium AS OBJECT (
    nazwa VARCHAR2(50),
    kraj VARCHAR2(30),
    jezyki jezyki_obce
);
/
CREATE TABLE stypendia OF stypendium;

INSERT INTO stypendia VALUES ('SOKRATES', 'FRANCJA', jezyki_obce('ANGIELSKI', 'FRANCUSKI', 'NIEMIECKI'));
INSERT INTO stypendia VALUES ('ERASMUS', 'NIEMCY', jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI'));

SELECT * FROM stypendia;
SELECT s.jezyki FROM stypendia s;

UPDATE stypendia
SET jezyki = jezyki_obce('ANGIELSKI', 'NIEMIECKI', 'HISZPANSKI', 'FRANCUSKI')
WHERE nazwa = 'ERASMUS';

CREATE OR REPLACE TYPE lista_egzaminow AS TABLE OF VARCHAR2(20);
/
CREATE OR REPLACE TYPE semestr AS OBJECT (
    numer NUMBER,
    egzaminy lista_egzaminow
);
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;

INSERT INTO semestry VALUES (semestr(1, lista_egzaminow('MATEMATYKA', 'LOGIKA', 'ALGEBRA')));
INSERT INTO semestry VALUES (semestr(2, lista_egzaminow('BAZY DANYCH', 'SYSTEMY OPERACYJNE')));

SELECT s.numer, e.* FROM semestry s, TABLE(s.egzaminy) e;
SELECT e.* FROM semestry s, TABLE(s.egzaminy) e;
SELECT * FROM TABLE(SELECT s.egzaminy FROM semestry s WHERE numer = 1);

INSERT INTO TABLE(SELECT s.egzaminy FROM semestry s WHERE numer = 2) VALUES ('METODY NUMERYCZNE');

UPDATE TABLE(SELECT s.egzaminy FROM semestry s WHERE numer = 2) e
SET e.column_value = 'SYSTEMY ROZPROSZONE'
WHERE e.column_value = 'SYSTEMY OPERACYJNE';

DELETE FROM TABLE(SELECT s.egzaminy FROM semestry s WHERE numer = 2) e
WHERE e.column_value = 'BAZY DANYCH';

-- 16.
CREATE OR REPLACE TYPE koszyk_produktow AS TABLE OF VARCHAR2(50);
/
CREATE TABLE zakupy (
    id_zakupu NUMBER,
    koszyk koszyk_produktow
) NESTED TABLE koszyk STORE AS tab_koszyk;

INSERT INTO zakupy VALUES (1, koszyk_produktow('MĄKA', 'KAKAO', 'MLEKO'));
INSERT INTO zakupy VALUES (2, koszyk_produktow('KAWA', 'HERBATA'));

SELECT * FROM zakupy;

DELETE FROM zakupy z
WHERE EXISTS (
    SELECT 1 FROM TABLE(z.koszyk) k WHERE k.column_value = 'KAKAO'
);

-- 17.
CREATE OR REPLACE TYPE instrument AS OBJECT (
    nazwa VARCHAR2(20),
    dzwiek VARCHAR2(20),
    MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN dzwiek;
    END;
END;
/

CREATE OR REPLACE TYPE instrument_dety UNDER instrument (
    material VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY instrument_dety AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'dmucham: ' || dzwiek;
    END;
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN glosnosc || ':' || dzwiek;
    END;
END;
/

CREATE OR REPLACE TYPE instrument_klawiszowy UNDER instrument (
    producent VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN
        RETURN 'stukam w klawisze: ' || dzwiek;
    END;
END;
/

DECLARE
    tamburyn instrument := instrument('tamburyn', 'brzdek-brzdek');
    trabka instrument_dety := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
    fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian', 'ping-ping', 'steinway');
BEGIN
    DBMS_OUTPUT.PUT_LINE(tamburyn.graj);
    DBMS_OUTPUT.PUT_LINE(trabka.graj);
    DBMS_OUTPUT.PUT_LINE(trabka.graj('glosno'));
    DBMS_OUTPUT.PUT_LINE(fortepian.graj);
END;
/

-- 18.
CREATE OR REPLACE TYPE istota AS OBJECT (
    nazwa VARCHAR2(20),
    NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
) NOT INSTANTIABLE NOT FINAL;
/

CREATE OR REPLACE TYPE lew UNDER istota (
    liczba_nog NUMBER,
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR
);
/
CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara CHAR) RETURN CHAR IS
    BEGIN
        RETURN 'upolowana ofiara: ' || ofiara;
    END;
END;
/

DECLARE
    KrolLew lew := lew('LEW', 4);
BEGIN
    DBMS_OUTPUT.PUT_LINE(KrolLew.poluj('antylopa'));
END;
/

-- 19.
DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn', 'brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki', 'ding-ding', 'metalowe');
    trabka := instrument_dety('trabka', 'tra-ta-ta', 'metalowa');
    saksofon := TREAT(instrument('saksofon', 'tra-taaaa') AS instrument_dety);
END;
/

-- 20.
CREATE TABLE instrumenty OF instrument;

INSERT INTO instrumenty VALUES (instrument('tamburyn', 'brzdek-brzdek'));
INSERT INTO instrumenty VALUES (instrument_dety('trabka', 'tra-ta-ta', 'metalowa'));
INSERT INTO instrumenty VALUES (instrument_klawiszowy('fortepian', 'ping-ping', 'steinway'));

SELECT i.nazwa, i.graj() FROM instrumenty i;