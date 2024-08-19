with x_onebss1 as (
        select * from x_onebss a
        where tthd_id = 6 
         AND loaitb_id not in (2116,147,39,290,175,122,319,208) -- dk chi Huong+319,208: elearning va eticket
         AND dichvuvt_id not in (1,4,7,8,10,11,12)
         AND khoanmuctt_id in (1,5,52,142) -- form 3 
)

-- Step 2: Main query using the pre-defined CTEs
, KQ as (
SELECT
--    CASE
--        WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
--        ELSE 'DNHM'
--    END AS Dinh_nghia,
pBH,
--    TEN_LOAIHD,
    LOAIHINH_TB ,
    SUM(CASE WHEN tien >0 THEN 1 ELSE 0 END) AS SL_PS_CUOC,
    SUM(CASE WHEN tien+km_lapdat <=0  THEN 1 ELSE 0 END) AS SL_0_PS_CUOC,
    SUM(tien) AS tien_PS,
    SUM(ABS(vat)) AS vat_PS,
    SUM(tien)+SUM(ABS(vat)) tong_PS,
--    SUM(ABS(km_lapdat)) AS tien_KM,
--    SUM(ABS(vat_km)) AS vat_km,
--    SUM(ABS(km_lapdat))+SUM(ABS(vat_km)) tong_KM,
--    SUM(tien) + SUM(km_lapdat) AS tien_thu,
--    SUM(vat) + SUM(vat_km) AS vat_thu,
--    (SUM(vat) + SUM(vat_km)+SUM(tien) + SUM(km_lapdat)) tong_thu,
     SUM(CASE
            WHEN TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202407 THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_trong_thang,
        SUM(CASE
            WHEN TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202407 THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_trong_thang,
        SUM(CASE
            WHEN TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202407 THEN vat + vat_km + tien + km_lapdat
            ELSE 0
        END) AS tong_thu_trong_thang
        ,
        SUM(CASE
            WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202407 and trangthai= 1 THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_thang_truoc,
        SUM(CASE
            WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202407 and trangthai= 1 THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_thang_truoc,
        SUM(CASE
            WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202407  and trangthai= 1 THEN vat + vat_km + tien + km_lapdat
            ELSE 0
        END) AS tong_thu_thang_truoc
        ,
         SUM(CASE
            WHEN ngay_tt is null or kenhthu is null  or TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) > 202407 THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_chua_thu,
        SUM(CASE
            WHEN ngay_tt is null or kenhthu is null  or TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) > 202407 THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_chua_thu,
        SUM(CASE
            WHEN ngay_tt is null or kenhthu is null or TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) > 202407 THEN vat + vat_km + tien + km_lapdat
            ELSE 0
        END) AS tong_thu_chua_thu
FROM
    x_onebss1

GROUP BY
pBH,
--     TEN_LOAIHD,
     LOAIHINH_TB
       
 , CASE
            WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
            ELSE 'DNHM'
        END
 )
select * from KQ;
