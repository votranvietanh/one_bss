WITH x_onebss1 AS (
    SELECT * 
    FROM x_onebss a
    WHERE tthd_id < 6 
      AND trangthai = 1
      AND loaitb_id NOT IN (2116, 147, 39, 290, 175, 122)
      AND MA_LOAIHD not like '%DATCOC%'
      AND KHOANMUCTT_ID <> 11
),
KQ AS (
    SELECT
        TEN_LOAIHD,
        LOAIHINH_TB,
        COUNT(LOAIHINH_TB) AS so_luong,
        
        -- Tổng thu trong tháng
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
            END) AS tong_thu_trong_thang,

        -- Tổng thu tháng trước
        SUM(CASE 
                WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202407 AND trangthai = 1 THEN tien + km_lapdat
                ELSE 0 
            END) AS tien_thu_thang_truoc,
        SUM(CASE 
                WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202407 AND trangthai = 1 THEN vat + vat_km
                ELSE 0 
            END) AS vat_thu_thang_truoc,
        SUM(CASE 
                WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202407 AND trangthai = 1 THEN vat + vat_km + tien + km_lapdat
                ELSE 0 
            END) AS tong_thu_thang_truoc,

        -- Tổng thu
        SUM(tien) + SUM(km_lapdat) AS tien_thu,
        SUM(vat) + SUM(vat_km) AS vat_thu,
        (SUM(vat) + SUM(vat_km) + SUM(tien) + SUM(km_lapdat)) AS tong_thu,

        CASE 
            WHEN tenchuquan LIKE '%Ph_ M_ H_ng%' THEN 'Phu My Hung'
            WHEN dichvuvt_id IN (7, 8, 9) THEN 'TSL'
            WHEN dichvuvt_id IN (1, 11, 4, 12, 10) THEN 'CD'
            ELSE 'GTTT'
        END AS dich_vu
    FROM 
        x_onebss1
    GROUP BY
        TEN_LOAIHD,
        LOAIHINH_TB
        ,
        CASE
            WHEN tenchuquan LIKE '%Ph_ M_ H_ng%' THEN 'Phu My Hung'
            WHEN dichvuvt_id IN (7, 8, 9) THEN 'TSL'
            WHEN dichvuvt_id IN (1, 11, 4, 12, 10) THEN 'CD'
            ELSE 'GTTT'
        END
)
SELECT * 
FROM KQ;
