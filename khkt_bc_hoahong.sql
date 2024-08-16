    select MA_TB ma_thue_bao
            ,coalesce(d.LOAIHINH_TB,a.DICHVU_vt_id) loai_hinh_thue_bao
            ,c.TEN_DVVT ten_dich_vu,MA_GD ma_giao_dich
            ,TEN_TB ten_khach_hang, MA_KH, THUEBAO_ID
            ,TENKIEU_LD, DIACHI_LD dia_chi_khach_hang
            ,NVL(NGAY_BBBG, TO_DATE('01/05/2024', 'DD/MM/YYYY'))  ngay_nghiem_thu
            ,SOTHANG_DC so_thang_tra_truoc
            ,DATCOC_CSD gia_tri_goicuoc_tra_truoc
            ,DTHU_GOI gtri_goicuoc_thang
            ,THANG_TLDG_DT, SL_MAILING SL_Hopdong_dientu
            ,MANV_PTM ma_tiep_thi
            ,tennv_ptm tennv_tiepthi,ten_pb phong_tiep_thi, nguon
            ,NVCT, DLCN, DLPN, KENH_CHUOI, DUQ, CTVXHH
        from (
                        with line_hd_tb as ( select dichvuvt_id
                                                    ,ma_tb,loaitb_id
                                            from css_hcm.hd_thuebao
                                            group by dichvuvt_id,ma_tb,loaitb_id
                                                )
                        , src as ( select a.*
                                        ,case 
                                            when nguon in('va_ĐLCN-PTTT','va_FPT','va_tgdd') 
                                            then 2 else b.dichvuvt_id 
                                        end as dichvuvt_id
                                        , CASE 
                                            WHEN a.tennv_ptm in ('TGDD','FPT') THEN 21 
                                            WHEN a.TENKIEU_LD = 'phattrienmoi' THEN 20 
                                            ELSE b.LOAITB_ID 
                                        END AS LOAITB_ID 
                                    FROM khkt_bc_hoahong a
                                    left join line_hd_tb b on a.ma_tb = b.ma_tb
                                    where thang_ptm = 202405
                                            )
                                            
                SELECT thang_ptm,dichvuvt_id,LOAITB_ID,MA_GD, MA_KH, THUEBAO_ID, MA_TB, DICHVU_vt_id
                        , TENKIEU_LD, TEN_TB, DIACHI_LD, NGAY_BBBG
                        , MA_PB, TEN_PB, MA_TO, TEN_TO, MANV_PTM, TENNV_PTM
                        , SOTHANG_DC, DATCOC_CSD, DTHU_DNHM, DTHU_GOI, THANG_TLDG_DT, SL_MAILING
                        , NHOM_TIEPTHI, LOAI_THULAO, LUONG_DONGIA_NVPTM, LUONG_DONGIA_NVHOTRO
                        , case when nhom_tiepthi in (1,2) then (nvl(LUONG_DONGIA_NVPTM,0)+nvl(LUONG_DONGIA_NVHOTRO,0)) else 0 end as NVCT,
                            case when nhom_tiepthi = 4 then (nvl(LUONG_DONGIA_NVPTM,0)+nvl(LUONG_DONGIA_NVHOTRO,0)) else 0 end as DLCN,
                            case when nhom_tiepthi = 5 then (nvl(LUONG_DONGIA_NVPTM,0)+nvl(LUONG_DONGIA_NVHOTRO,0)) else 0 end as DLPN,
                            case when nhom_tiepthi = 6 then (nvl(LUONG_DONGIA_NVPTM,0)+nvl(LUONG_DONGIA_NVHOTRO,0)) else 0 end as kenh_chuoi,
                            case when nhom_tiepthi = 7 then (nvl(LUONG_DONGIA_NVPTM,0)+nvl(LUONG_DONGIA_NVHOTRO,0)) else 0 end as DUQ,
                            case when nhom_tiepthi = 8 then (nvl(LUONG_DONGIA_NVPTM,0)+nvl(LUONG_DONGIA_NVHOTRO,0)) else 0 end as CTVXHH  
                                ,nguon 
                FROM src       
                ) a
        left join ttkd_bsc.dm_nhomld b on a.NHOM_TIEPTHI = b.nhomld_id
        left join css_hcm.dichvu_vt c on a.DICHVUVT_ID = c.DICHVUVT_ID
        left join css_hcm.loaihinh_tb d on d.LOAITB_ID = a.LOAITB_ID
        WHERE NGAY_BBBG BETWEEN TO_DATE('01/05/2024 00:00:00', 'DD/MM/YYYY HH24:MI:SS') 
                            AND TO_DATE('31/05/2024 23:59:59', 'DD/MM/YYYY HH24:MI:SS')
            OR  (NGAY_BBBG is null and thang_ptm = 202405)
;
