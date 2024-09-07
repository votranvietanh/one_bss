create table onebss_T8 as
WITH ct AS (
    SELECT 
        khoanmuctt_id,
        hdtb_id,
        phieutt_id,
       
        SUM(tien) tien,
        SUM(vat) vat

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
     select thuebao_id,chuquan_id from css_hcm.db_gp
        union all 
    select distinct thuebao_id, chuquan_id from css_hcm.db_tsl
)
,
std_onebss AS (
    SELECT 
       b.tthd_id,b.loaitb_id, a.ma_gd, b.hdtb_id, b.thuebao_id, b.ma_tb, a.loaihd_id, b.kieuld_id, b.donvi_id donvi_tt_id,
        a.ngay_yc, b.ngay_ht, a.ctv_id, a.nhanviengt_id, a.nhanvien_id -- xiu xoa a.nhanvien_id,
        , d.ngay_tt,d.ngay_hd, d.seri, d.soseri
        ,c.khoanmuctt_id
        , d.thungan_tt_id, d.ht_tra_id, d.kenhthu_id, d.trangthai, cq.tenchuquan,cq.chuquan_id
        
        , CASE WHEN c.khoanmuctt_id = 19 THEN c.tien ELSE 0 END km_lapdat
        , CASE WHEN c.khoanmuctt_id = 19 THEN c.vat ELSE 0 END vat_km
        , CASE WHEN c.khoanmuctt_id NOT IN (19) THEN c.tien ELSE 0 END tien_thu --5 token
        , CASE WHEN c.khoanmuctt_id NOT IN (19) THEN c.vat ELSE 0 END vat_thu
    FROM 
        css_hcm.hd_khachhang a
    LEFT JOIN 
        css_hcm.hd_thuebao b ON a.hdkh_id = b.hdkh_id
    LEFT JOIN 
        ct c ON b.hdtb_id = c.hdtb_id
    JOIN 
        css_hcm.phieutt_hd d ON c.phieutt_id = d.phieutt_id AND (c.tien <> 0)
    LEFT JOIN 
        dich_vu dvu on b.thuebao_id = dvu.thuebao_id
    LEFT JOIN 
        css_hcm.chuquan cq ON cq.chuquan_id = dvu.chuquan_id
    
    WHERE 
--         -- THANG 7
--         (TO_NUMBER(TO_CHAR(b.ngay_ins, 'yyyymm')) = 202407
--             or (d.ngay_tt < TRUNC(ADD_MONTHS(SYSDATE, -1), 'MONTH')
--                     and nvl(ngay_ht, sysdate) >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'MONTH')
--                 )
--         )
      --THANG 8 
      (TO_NUMBER(TO_CHAR(b.ngay_ins, 'yyyymm')) = 202408
            or (d.ngay_tt < trunc(sysdate, 'month')
                    and nvl(ngay_ht, sysdate) >= trunc(sysdate, 'month')
                )
        )
        AND b.donvi_id IS NOT NULL
        AND dvu.chuquan_id in (145,264,266)
        AND b.tthd_id in (2,3,4,5,6)

)
,
x_onebss AS (
    SELECT
        a.tthd_id,a.loaihd_id,a.kieuld_id,a.trangthai,a.khoanmuctt_id,dv.dichvuvt_id,a.loaitb_id, q.loaihinh_tb,a.ma_gd, a.hdtb_id, a.thuebao_id, a.ma_tb, b.MA_LOAIHD,
        b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc, a.ngay_ht
        , d.ten_nv, m.ten_dv,s.ten_dv pbh, 
        a.donvi_tt_id,l.ten_dv ten_pb_ttvt,
         a.ngay_tt,a.ngay_hd,a.seri,a.soseri
        , round(sum(a.tien_thu)) tien, round(sum(a.vat_thu)) vat, round(sum(a.km_lapdat)) km_lapdat, round(sum(a.vat_km)) vat_km,
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
        --ttvt

    LEFT JOIN 
        admin_hcm.donvi l ON l.DONVI_ID = a.donvi_tt_id
        --
    LEFT JOIN 
        css_hcm.hinhthuc_tra h ON h.ht_tra_id = a.ht_tra_id
    LEFT JOIN 
        css_hcm.kenhthu i ON a.kenhthu_id = i.kenhthu_id
    LEFT JOIN 
        css_hcm.loaihinh_tb q ON q.loaitb_id = a.loaitb_id
     LEFT JOIN 
         css_hcm.dichvu_vt dv on q.dichvuvt_id =dv.dichvuvt_id
    
     GROUP BY a.tthd_id,a.HDTB_ID,dv.dichvuvt_id,q.loaihinh_tb, a.loaitb_id, a.ma_gd, a.hdtb_id, a.thuebao_id, a.ma_tb, b.MA_LOAIHD, 
        b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc, a.ngay_ht
        , d.ten_nv, m.ten_dv,s.ten_dv
      ,a.donvi_tt_id,l.ten_dv,
       a.ngay_tt,a.ngay_hd,a.seri,a.soseri, h.ht_tra, i.KENHTHU, a.khoanmuctt_id, a.trangthai,a.kieuld_id,a.loaihd_id
       ,
        CASE 
            WHEN a.trangthai = 1 THEN 'Da thu tien'
            ELSE  'Chua thu tien' 
        END ,
        a.tenchuquan
)
select * from x_onebss;
