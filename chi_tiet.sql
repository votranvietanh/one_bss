--Ngay 1 đầu tháng chạy file chi tiết với các bảng online vì nếu để quá mùng 1 thì các TB sẽ xuất hiện ngày thanh toán sau tháng 9? mà trong form thì ko có cột này nên sẽ nhầm tiền
--
create table onebss_T8 as
WITH ct AS (
    SELECT 
        khoanmuctt_id,
        hdtb_id,
        phieutt_id,
       
        SUM(tien) tien,
        SUM(vat) vat

    FROM css.v_ct_phieutt@dataguard
    GROUP BY hdtb_id, phieutt_id, khoanmuctt_id
)
,
dich_vu as (
     select thuebao_id,chuquan_id from css.v_db_adsl@dataguard
         union all
    select thuebao_id,chuquan_id from css.v_db_cntt@dataguard
        union all 
     select thuebao_id,chuquan_id from css.v_db_mgwan@dataguard
        union all 
     select thuebao_id,chuquan_id from css.v_db_IMS@dataguard
        union all 
     select thuebao_id,chuquan_id from css.v_db_CD@dataguard
        union all 
     select thuebao_id,chuquan_id from css.v_db_gp@dataguard
        union all 
    select distinct thuebao_id, chuquan_id from css.v_db_tsl@dataguard
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
        css.v_hd_khachhang@dataguard a
    LEFT JOIN 
        css.v_hd_thuebao@dataguard b ON a.hdkh_id = b.hdkh_id
    LEFT JOIN 
        ct c ON b.hdtb_id = c.hdtb_id
    JOIN 
        css.v_phieutt_hd@dataguard d ON c.phieutt_id = d.phieutt_id AND (c.tien <> 0)
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
      ((TO_CHAR(b.ngay_ins, 'yyyymm')) = (TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM'))
            or (d.ngay_tt < trunc(sysdate, 'month')
                    and nvl(ngay_ht, sysdate) >= trunc(sysdate, 'month')
                    and (TO_CHAR(b.ngay_ins, 'yyyymm')) = (TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM')
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






---refactor CT
select a.LOAIHINH_TB, a.MA_GD, a.HDTB_ID, a.THUEBAO_ID, a.MA_TB,c.ten_kh, a.MA_LOAIHD, a.TEN_LOAIHD, a.TEN_KIEULD, a.NGAY_YC, a.NGAY_HT, a.TEN_NV, a.TEN_DV, a.PBH, a.DONVI_TT_ID, a.TEN_PB_TTVT, a.NGAY_TT, a.NGAY_HD, a.SERI, a.SOSERI, a.TIEN, a.VAT, a.KM_LAPDAT, a.VAT_KM, a.HT_TRA,  a.KENHTHU, a.TRANGTHAI_TT, a.TENCHUQUAN, a.CHUQUAN_ID 
from ttkdhcm_ktnv.baocao_doanhthu_dongtien_pktkh a
left join css_hcm.db_thuebao b on a.thuebao_id = b.thuebao_id
left join css_hcm.db_khachhang c on b.KHACHHANG_ID =c.KHACHHANG_ID
where a.thang = 202411 and  a.khoanmuctt_id  in (1,2,3,4,9,17)
        and a.tthd_id = 6 and a.dichvuvt_id in (1,4,7,8,9,10,11,12)
;
