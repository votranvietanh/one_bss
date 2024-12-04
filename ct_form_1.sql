select a.LOAIHINH_TB, a.MA_GD, a.HDTB_ID, a.THUEBAO_ID, a.MA_TB,c.ten_kh, a.MA_LOAIHD, a.TEN_LOAIHD, a.TEN_KIEULD, a.NGAY_YC, a.NGAY_HT, a.TEN_NV, a.TEN_DV, a.PBH, a.DONVI_TT_ID, a.TEN_PB_TTVT, a.NGAY_TT, a.NGAY_HD, a.SERI, a.SOSERI, 
 (CASE
            WHEN 
                 (TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202411  or ngay_tt is null )
                and tenchuquan not LIKE '%Ph_ M_ H_ng%'
                and trangthai = 1
                                
            THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_trong_thang,
        (CASE
            WHEN 
                 (TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202411  or ngay_tt is null )
                and tenchuquan not LIKE '%Ph_ M_ H_ng%'
                and trangthai = 1
                                
            THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_trong_thang,
        (CASE
            WHEN 
                (TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202411  or ngay_tt is null )
                and tenchuquan not LIKE '%Ph_ M_ H_ng%'
                and trangthai = 1
                                
            THEN vat + vat_km + tien + km_lapdat
            ELSE 0
        END) AS tong_thu_trong_thang
        ,
        (CASE
            WHEN (TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) <> 202411 and trangthai= 1)
           
            THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_thang_truoc,
        (CASE
            WHEN (TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) <> 202411 and trangthai= 1)
            
            THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_thang_truoc,
        (CASE
            WHEN 
                (TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) <> 202411  and trangthai= 1)

            THEN vat + vat_km + tien + km_lapdat
            ELSE 0
        END) AS tong_thu_thang_truoc
        ,
         (CASE
            WHEN ((ngay_tt is null or kenhthu is null)  and trangthai = 0)or (trangthai <> 1 and ngay_tt is not null)
                THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_chua_thu,
        (CASE
            WHEN ((ngay_tt is null or kenhthu is null)  and trangthai = 0)or (trangthai <> 1 and ngay_tt is not null)
            THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_chua_thu,
        (CASE
            WHEN ((ngay_tt is null or kenhthu is null)  and trangthai = 0)or (trangthai <> 1 and ngay_tt is not null)
            THEN vat + vat_km + tien + km_lapdat
            ELSE 0
        END) AS tong_thu_chua_thu,
a.KM_LAPDAT, a.VAT_KM, a.HT_TRA,  a.KENHTHU, a.TRANGTHAI_TT, a.TENCHUQUAN, a.CHUQUAN_ID 
from ttkdhcm_ktnv.baocao_doanhthu_dongtien_pktkh a
left join css_hcm.db_thuebao b on a.thuebao_id = b.thuebao_id
left join css_hcm.db_khachhang c on b.KHACHHANG_ID =c.KHACHHANG_ID
where a.thang = 202411 and  a.khoanmuctt_id  in (1,2,3,4,9,17)
        and a.tthd_id = 6 and a.dichvuvt_id in (1,4,7,8,9,10,11,12)
;
