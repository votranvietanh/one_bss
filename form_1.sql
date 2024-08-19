with x_onebss1 as (
        select * from x_onebss a
        where a.khoanmuctt_id  in (1,2,3,4,9,17)
        and a.tthd_id = 6 and dichvuvt_id in (1,4,7,8,10,11,12)
)
-- Step 2: Main query using the pre-defined CTEs
, KQ as (
SELECT
--    CASE
--        WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
--        ELSE 'DNHM'
--    END AS Dinh_nghia,
    TEN_LOAIHD,
    LOAIHINH_TB ,
    SUM(CASE WHEN tien>0 THEN 1 ELSE 0 END) AS SL_PS_CUOC,
    SUM(CASE WHEN tien+km_lapdat <= 0 THEN 1 ELSE 0 END) AS SL_0_PS_CUOC,
    SUM(tien) AS tien_PS,
    SUM(ABS(vat)) AS vat_PS,
    SUM(tien)+SUM(ABS(vat)) tong_PS,
    SUM(ABS(km_lapdat)) AS tien_KM,
    SUM(ABS(vat_km)) AS vat_km,
    SUM(ABS(km_lapdat))+SUM(ABS(vat_km)) tong_KM,
    SUM(tien) + SUM(km_lapdat) AS tien_thu,
    SUM(vat) + SUM(vat_km) AS vat_thu,
    (SUM(vat) + SUM(vat_km)+SUM(tien) + SUM(km_lapdat)) tong_thu,
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
    , case
            when tenchuquan LIKE '%Ph_ M_ H_ng%' then 'Phu My Hung'
        when dichvuvt_id in (7,8,9) then 'TSL'
        when dichvuvt_id in (1,11,4,12,10 ) then'CD'
     end as dich_vu

FROM
    x_onebss1

GROUP BY
     TEN_LOAIHD,
        LOAIHINH_TB,
        CASE
            WHEN tenchuquan LIKE '%Ph_ M_ H_ng%' THEN 'Phu My Hung'
            WHEN dichvuvt_id IN (7, 8, 9) THEN 'TSL'
            WHEN dichvuvt_id IN (1, 11, 4, 12,10) THEN 'CD'
        END
 , CASE
            WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
            ELSE 'DNHM'
        END
 )
select * from KQ
;
