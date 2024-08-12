WITH ct AS (
    SELECT 
          khoanmuctt_id,
        hdtb_id,
        phieutt_id, 
        SUM(CASE WHEN khoanmuctt_id = 19 THEN tien ELSE 0 END) km_lapdat, 
        SUM(CASE WHEN khoanmuctt_id = 19 THEN vat ELSE 0 END) vat_km,
        SUM(CASE WHEN khoanmuctt_id NOT IN (19, 11, 5, 29,21) THEN tien ELSE 0 END) tien_thu,
        SUM(CASE WHEN khoanmuctt_id NOT IN (19, 11, 5, 29,21) THEN vat ELSE 0 END) vat_thu
    FROM css_hcm.ct_phieutt
    GROUP BY hdtb_id, phieutt_id, khoanmuctt_id
)
,
dich_vu as (
     select thuebao_id,chuquan_id from css_hcm.db_adsl
         union all
    select thuebao_id,chuquan_id from css_hcm.db_cntt 
        union all 
     select thuebao_id,chuquan_id from css_hcm.db_mgwan
        union all 
     select thuebao_id,chuquan_id from css_hcm.db_IMS 
        union all 
     select thuebao_id,chuquan_id from css_hcm.db_CD
        union all 
    select distinct thuebao_id, chuquan_id from css_hcm.db_tsl
)
,
std_onebss AS (
    SELECT 
       b.loaitb_id, a.ma_gd, b.hdtb_id, b.thuebao_id, b.ma_tb, a.loaihd_id, b.kieuld_id, 
        a.ngay_yc, b.ngay_ht, a.ctv_id, a.nhanviengt_id, d.ngay_tt, 
        c.tien_thu tien, c.vat_thu vat, c.km_lapdat, c.vat_km,c.khoanmuctt_id,
        d.thungan_tt_id, d.ht_tra_id, d.kenhthu_id, d.trangthai, cq.tenchuquan,cq.chuquan_id
    FROM 
        css_hcm.hd_khachhang a
    LEFT JOIN 
        css_hcm.hd_thuebao b ON a.hdkh_id = b.hdkh_id
    LEFT JOIN 
        ct c ON b.hdtb_id = c.hdtb_id
    JOIN 
        css_hcm.phieutt_hd d ON c.phieutt_id = d.phieutt_id AND (c.tien_thu <> 0 OR km_lapdat <> 0)
    LEFT JOIN 
        dich_vu dvu on b.thuebao_id = dvu.thuebao_id
    LEFT JOIN 
        css_hcm.chuquan cq ON cq.chuquan_id = dvu.chuquan_id
    
    WHERE 
        TO_NUMBER(TO_CHAR(b.ngay_ins, 'yyyymm')) = 202406
        AND a.loaihd_id IN (1, 3, 8, 6, 7)
        AND b.donvi_id IS NOT NULL
        AND cq.chuquan_id in (145,264,266)
--        and c.khoanmuctt_id in (2,3,4,5,6)
        AND b.tthd_id in (2,3,4,5,6)
--       and d.trangthai = 0
)
--select * from std_onebss;
,
x_onebss AS (
    SELECT 
        a.loaihd_id,a.kieuld_id,a.trangthai,a.khoanmuctt_id,dv.dichvuvt_id,a.loaitb_id, q.loaihinh_tb,a.ma_gd, a.hdtb_id, a.thuebao_id, a.ma_tb, b.MA_LOAIHD, 
        b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc, a.ngay_ht, d.ten_nv, m.ten_dv, 
         a.ngay_tt, round(sum(a.tien)) tien, round(sum(a.vat)) vat, round(sum(a.km_lapdat)) km_lapdat, 
        round(sum(a.vat_km)) vat_km,
        h.ht_tra, i.KENHTHU, 
        CASE 
            WHEN a.trangthai = 1 THEN 'Da thu tien'
            ELSE  'Chua thu tien' 

        END AS trangthai_tt,
        a.tenchuquan
    FROM 
        std_onebss a
    JOIN 
        css_hcm.loai_hd b ON a.loaihd_id = b.loaihd_id
    LEFT JOIN 
        css_hcm.kieu_ld c ON a.kieuld_id = c.kieuld_id
    LEFT JOIN 
        admin_hcm.nhanvien_onebss d ON d.nhanvien_id = a.ctv_id
    LEFT JOIN 
        admin_hcm.donvi m ON d.DONVI_ID = m.DONVI_ID
    LEFT JOIN 
        admin_hcm.donvi s ON m.DONVI_cha_ID = s.DONVI_ID
    LEFT JOIN 
        css_hcm.hinhthuc_tra h ON h.ht_tra_id = a.ht_tra_id
    LEFT JOIN 
        css_hcm.kenhthu i ON a.kenhthu_id = i.kenhthu_id
    LEFT JOIN 
        css_hcm.loaihinh_tb q ON q.loaitb_id = a.loaitb_id
     LEFT JOIN 
         css_hcm.dichvu_vt dv on q.dichvuvt_id =dv.dichvuvt_id
--         where a.trangthai = 1
         group by a.HDTB_ID,dv.dichvuvt_id,q.loaihinh_tb, a.loaitb_id, a.ma_gd, a.hdtb_id, a.thuebao_id, a.ma_tb, b.MA_LOAIHD, 
        b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc, a.ngay_ht, d.ten_nv, m.ten_dv, 
       a.ngay_tt, h.ht_tra, i.KENHTHU, a.khoanmuctt_id, a.trangthai,a.kieuld_id,a.loaihd_id
       ,
        CASE 
            WHEN a.trangthai = 1 THEN 'Da thu tien'
            ELSE  'Chua thu tien' 
        END ,
        a.tenchuquan
)

-- Step 2: Main query using the pre-defined CTEs
, KQ as (
SELECT 
    CASE 
        WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
        ELSE 'DNHM'
    END AS Dinh_nghia,
    TEN_LOAIHD,
    LOAIHINH_TB ,
    SUM(CASE WHEN MA_LOAIHD = 'DATMOI' THEN 1 ELSE 0 END) AS SL_PS_CUOC,
    SUM(CASE WHEN MA_LOAIHD <> 'DATMOI' THEN 1 ELSE 0 END) AS SL_0_PS_CUOC,
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
            WHEN TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202406 THEN tien + km_lapdat
            ELSE 0 
        END) AS tien_thu_trong_thang,
        SUM(CASE 
            WHEN TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202406 THEN vat + vat_km
            ELSE 0 
        END) AS vat_thu_trong_thang,
        SUM(CASE 
            WHEN TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202406 THEN vat + vat_km + tien + km_lapdat
            ELSE 0 
        END) AS tong_thu_trong_thang
        ,
        SUM(CASE 
            WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202406 and trangthai= 1 THEN tien + km_lapdat
            ELSE 0 
        END) AS tien_thu_thang_truoc,
        SUM(CASE 
            WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202406 and trangthai= 1 THEN vat + vat_km
            ELSE 0 
        END) AS vat_thu_thang_truoc,
        SUM(CASE 
            WHEN TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) < 202406  and trangthai= 1 THEN vat + vat_km + tien + km_lapdat
            ELSE 0 
        END) AS tong_thu_thang_truoc
        ,
        SUM(CASE 
            WHEN trangthai =0 THEN tien + km_lapdat
            ELSE 0 
        END) AS tien_thu_chua_thu,
        SUM(CASE 
            WHEN trangthai =0 THEN vat + vat_km
            ELSE 0 
        END) AS vat_thu_chua_thu,
        SUM(CASE 
            WHEN trangthai =0 THEN vat + vat_km + tien + km_lapdat
            ELSE 0 
        END) AS tong_thu_chua_thu


    , case 
            when tenchuquan LIKE '%Ph_ M_ H_ng%' then 'Phu My Hung' 
        when dichvuvt_id in (7,8,9) then 'TSL'
        when dichvuvt_id in (1,11,4,12 ) then'CD'
     end as dich_vu
     
FROM 
    x_onebss
    
    where dichvuvt_id not in (7,8,9,1,11,4,12)
--        where dichvuvt_id in ( select DICHVUVT_ID from ttkd_bsc.DM_LOAIHINH_HSQD where GTGT_CNTT is not null)



GROUP BY 
     TEN_LOAIHD,
        LOAIHINH_TB,
        CASE 
            WHEN tenchuquan LIKE '%Ph_ M_ H_ng%' THEN 'Phu My Hung' 
            WHEN dichvuvt_id IN (7, 8, 9) THEN 'TSL'
            WHEN dichvuvt_id IN (1, 11, 4, 12) THEN 'CD'
        END
 , CASE 
            WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
            ELSE 'DNHM'
        END
 )
     SELECT 
    TEN_LOAIHD
    ,c.nhom_dichvu 
    ,a.LOAIHINH_TB,
    CASE 
        WHEN a.Dinh_nghia = 'SDM' THEN 'DCD0A1VNTVNT008'
        ELSE b.MA_DTHU
    END AS ma_doanh_thu
    , SL_PS_CUOC, SL_0_PS_CUOC, TIEN_PS, VAT_PS, TONG_PS, TIEN_KM, VAT_KM, TONG_KM, TIEN_THU, VAT_THU, TONG_THU, TIEN_THU_TRONG_THANG, VAT_THU_TRONG_THANG, TONG_THU_TRONG_THANG, TIEN_THU_THANG_TRUOC, VAT_THU_THANG_TRUOC,
   TONG_THU_THANG_TRUOC, TIEN_THU_CHUA_THU, VAT_THU_CHUA_THU, TONG_THU_CHUA_THU, nvl(c.GTGT_CNTT,DICH_VU) dich_vu
    
FROM 
    KQ a
LEFT JOIN 
    vietanhvh.dm_ma_doanhthu b 
ON 
    a.loaihinh_tb = b.loaihinh_tb
LEFT JOIN
    ttkd_bsc.DM_LOAIHINH_HSQD c
ON a.loaihinh_tb = c.loaihinh_tb
     ;
