select a.LOAITB_ID,a.LOAIHINH_TB,a.khoanmuctt_id, a.MA_GD, a.HDTB_ID, a.THUEBAO_ID, a.MA_TB,c.ten_kh, a.MA_LOAIHD, a.TEN_LOAIHD, a.TEN_KIEULD, a.NGAY_YC, a.NGAY_HT, a.TEN_NV, a.TEN_DV, a.PBH, a.DONVI_TT_ID, a.TEN_PB_TTVT, a.NGAY_TT, a.NGAY_HD, a.SERI, a.SOSERI, 
 a.TIEN, a.VAT,a.TIEN+a.VAT tong_ps, (CASE
            WHEN 
                 (TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202501  or ngay_tt is null )
                and tenchuquan not LIKE '%Ph_ M_ H_ng%'
                and trangthai = 1

            THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_trong_thang,
        (CASE
            WHEN 
                 (TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202501  or ngay_tt is null )
                and tenchuquan not LIKE '%Ph_ M_ H_ng%'
                and trangthai = 1

            THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_trong_thang,
        (CASE
            WHEN 
                (TO_NUMBER(TO_CHAR(NGAY_TT, 'YYYYMM')) = 202501  or ngay_tt is null )
                and tenchuquan not LIKE '%Ph_ M_ H_ng%'
                and trangthai = 1

            THEN vat + vat_km + tien + km_lapdat
            ELSE 0
        END) AS tong_thu_trong_thang
        ,
        (CASE
            WHEN (TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) <> 202501 and trangthai= 1)

            THEN tien + km_lapdat
            ELSE 0
        END) AS tien_thu_thang_truoc,
        (CASE
            WHEN (TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) <> 202501 and trangthai= 1)

            THEN vat + vat_km
            ELSE 0
        END) AS vat_thu_thang_truoc,
        (CASE
            WHEN 
                (TO_NUMBER(TO_CHAR(ngay_tt, 'YYYYMM')) <> 202501  and trangthai= 1)

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
where a.thang = 202501 and       a.tthd_id = 6 
         AND a.loaitb_id not in (35,80,148,350,2116,147,39,290,175,122,319,208,288,373) -- dk chi Huong+319,208: elearning va eticket
         AND a.dichvuvt_id not in (1,4,7,8,9,10,11,12)
         AND a.khoanmuctt_id in (1,5,52,142) and a.ma_tb in(select ma_tb from onebss_202501)
