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
        d.thungan_tt_id, d.ht_tra_id, d.kenhthu_id, d.trangthai, cq.tenchuquan,cq.chuquan_id,b.tthd_id
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
        TO_NUMBER(TO_CHAR(b.ngay_ht, 'yyyymm')) = 202407
        AND a.loaihd_id IN (1, 3, 8, 6, 7)
        AND b.donvi_id IS NOT NULL
        AND cq.chuquan_id in (145,264,266)
        AND b.tthd_id in (2,3,4,5,6)        
)

,
x_onebss AS (
    SELECT 
        a.tthd_id,a.loaihd_id,a.kieuld_id,a.trangthai,a.khoanmuctt_id,dv.dichvuvt_id,a.loaitb_id, q.loaihinh_tb,a.ma_gd, a.hdtb_id, a.thuebao_id, a.ma_tb, b.MA_LOAIHD, 
        b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc, a.ngay_ht, d.ten_nv, m.ten_dv, 
         a.ngay_tt, round(sum(a.tien)) tien, round(sum(a.vat)) vat, round(sum(a.km_lapdat)) km_lapdat, 
        round(sum(a.vat_km)) vat_km,
        h.ht_tra, i.KENHTHU, 
        CASE 
            WHEN a.trangthai = 1 THEN 'Da thu tien'
            WHEN a.trangthai = 0 THEN 'Chua thu tien' 
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
 --dieu kien o day, tuy vao loai form bao cao
    WHERE a.tthd_id = 6 AND a.trangthai = 1 
 --
    GROUP BY a.tthd_id,a.HDTB_ID,dv.dichvuvt_id,q.loaihinh_tb, a.loaitb_id, a.ma_gd, a.hdtb_id, a.thuebao_id, a.ma_tb, b.MA_LOAIHD, 
        b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc, a.ngay_ht, d.ten_nv, m.ten_dv, 
       a.ngay_tt, h.ht_tra, i.KENHTHU, a.khoanmuctt_id, a.trangthai,a.kieuld_id,a.loaihd_id
       ,
        CASE 
            WHEN a.trangthai = 1 THEN 'Da thu tien'
            WHEN a.trangthai = 0 THEN 'Chua thu tien' 
        END ,
        a.tenchuquan
)
-----Custom
, KQ as (
SELECT 
    CASE 
        WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
        ELSE 'DNHM'
    END AS Dinh_nghia,
    TEN_LOAIHD,
    LOAIHINH_TB ,
    count(LOAIHINH_TB) so_luong
    
    --tong_thu_trong_thang:
    ,
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
        
            --tong_thu_thang_truoc:
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
        
          --tong_thu:
    , 
    SUM(tien) + SUM(km_lapdat) AS tien_thu,
    SUM(vat) + SUM(vat_km) AS vat_thu,
    (SUM(vat) + SUM(vat_km)+SUM(tien) + SUM(km_lapdat)) tong_thu
   
    , 
    case 
            when tenchuquan LIKE '%Ph_ M_ H_ng%' then 'Phu My Hung' 
        when dichvuvt_id in (7,8,9) then 'TSL'
        when dichvuvt_id in (1,11,4,12 ) then'CD'
        else 'unknown'
     end as dich_vu
     
FROM 
    x_onebss
    
    --lua chon dich_vu
--    where dichvuvt_id in (7,8,9,1,11,4,12)
    


GROUP BY 
     TEN_LOAIHD,
        LOAIHINH_TB,
        CASE 
            WHEN tenchuquan LIKE '%Ph_ M_ H_ng%' THEN 'Phu My Hung' 
            WHEN dichvuvt_id IN (7, 8, 9) THEN 'TSL'
            WHEN dichvuvt_id IN (1, 11, 4, 12) THEN 'CD'
             else 'unknown'
        END
 , CASE 
            WHEN MA_LOAIHD IN ('THAYDOI_DV', 'DOITOCDO_ADSL') THEN 'SDM'
            ELSE 'DNHM'
        END
 )
--map them ma_doanh_thu:
     SELECT 
    TEN_LOAIHD,a.LOAIHINH_TB,
    CASE 
        WHEN a.Dinh_nghia = 'SDM' THEN 'DCD0A1VNTVNT008'
        ELSE b.MA_DTHU
    END AS ma_doanh_thu
    , SO_LUONG, TIEN_THU_TRONG_THANG, VAT_THU_TRONG_THANG, TONG_THU_TRONG_THANG, TIEN_THU_THANG_TRUOC, VAT_THU_THANG_TRUOC, TONG_THU_THANG_TRUOC
    ,dich_vu, TIEN_THU, VAT_THU, TONG_THU
    
FROM 
    KQ a
LEFT JOIN 
    vietanhvh.dm_ma_doanhthu b 
ON 
    a.loaihinh_tb = b.loaihinh_tb
     ;
