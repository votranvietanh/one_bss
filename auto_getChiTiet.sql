SELECT TO_CHAR(TO_NUMBER(SUBSTR('202512', 5, 2)) + 1, 'FM00') AS result
FROM dual;


CREATE OR REPLACE PROCEDURE create_onebss_table IS
    v_date DATE := TRUNC(SYSDATE, 'MM');
    v_yyyymm VARCHAR2(6) := TO_CHAR(TRUNC(SYSDATE, 'MM'), 'YYYYMM');
    v_sql   CLOB;
BEGIN
    v_sql := '
    CREATE TABLE onebss_' || v_yyyymm || ' AS 
    WITH ct AS (
        SELECT 
            khoanmuctt_id,
            hdtb_id,
            phieutt_id,
            SUM(tien) tien,
            SUM(vat) vat
        FROM css.v_ct_phieutt@dataguard
        GROUP BY hdtb_id, phieutt_id, khoanmuctt_id
    ),
    dich_vu AS (
         SELECT thuebao_id, chuquan_id FROM css.v_db_adsl@dataguard
         UNION ALL SELECT thuebao_id, chuquan_id FROM css.v_db_cntt@dataguard
         UNION ALL SELECT thuebao_id, chuquan_id FROM css.v_db_mgwan@dataguard
         UNION ALL SELECT thuebao_id, chuquan_id FROM css.v_db_IMS@dataguard
         UNION ALL SELECT thuebao_id, chuquan_id FROM css.v_db_CD@dataguard
         UNION ALL SELECT thuebao_id, chuquan_id FROM css.v_db_gp@dataguard
         UNION ALL SELECT DISTINCT thuebao_id, chuquan_id FROM css.v_db_tsl@dataguard
    ),
    std_onebss AS (
        SELECT b.ngay_ins, b.tthd_id, b.loaitb_id, a.ma_gd, b.hdtb_id, b.thuebao_id, b.ma_tb,
               a.loaihd_id, b.kieuld_id, b.donvi_id donvi_tt_id, a.ngay_yc, b.ngay_ht, a.ctv_id, a.nhanviengt_id,
               a.nhanvien_id, d.ngay_tt, d.ngay_hd, d.seri, d.soseri, c.khoanmuctt_id, d.thungan_tt_id,
               d.ht_tra_id, d.kenhthu_id, d.trangthai, cq.tenchuquan, cq.chuquan_id,
               CASE WHEN c.khoanmuctt_id = 19 THEN c.tien ELSE 0 END km_lapdat,
               CASE WHEN c.khoanmuctt_id = 19 THEN c.vat ELSE 0 END vat_km,
               CASE WHEN c.khoanmuctt_id NOT IN (19) THEN c.tien ELSE 0 END tien_thu,
               CASE WHEN c.khoanmuctt_id NOT IN (19) THEN c.vat ELSE 0 END vat_thu
        FROM css.v_hd_khachhang@dataguard a
        LEFT JOIN css.v_hd_thuebao@dataguard b ON a.hdkh_id = b.hdkh_id
        LEFT JOIN ct c ON b.hdtb_id = c.hdtb_id
        JOIN css.v_phieutt_hd@dataguard d ON c.phieutt_id = d.phieutt_id AND (c.tien <> 0)
        LEFT JOIN dich_vu dvu ON b.thuebao_id = dvu.thuebao_id
        LEFT JOIN css_hcm.chuquan cq ON cq.chuquan_id = dvu.chuquan_id
        WHERE (
            TO_CHAR(b.ngay_ins, ''YYYYMM'') = TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, ''MM''), -1), ''YYYYMM'')
            OR (
                d.ngay_tt < TRUNC(SYSDATE, ''MM'')
                AND NVL(ngay_ht, SYSDATE) >= TRUNC(SYSDATE, ''MM'')
                AND TO_CHAR(b.ngay_ins, ''YYYYMM'') = TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, ''MM''), -1), ''YYYYMM'')
            )
        )
        AND dvu.chuquan_id IN (145, 264, 266)
        AND b.tthd_id IN (2, 3, 4, 5, 6)
    ),
    x_onebss AS (
        SELECT a.ngay_ins, a.tthd_id, a.loaihd_id, a.kieuld_id, a.trangthai, a.khoanmuctt_id,
               dv.dichvuvt_id, a.loaitb_id, q.loaihinh_tb, a.ma_gd, a.hdtb_id, a.thuebao_id, a.ma_tb,
               b.MA_LOAIHD, b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc, a.ngay_ht, d.ten_nv, m.ten_dv,
               s.ten_dv pbh, a.donvi_tt_id, l.ten_dv ten_pb_ttvt, a.ngay_tt, a.ngay_hd, a.seri, a.soseri,
               ROUND(SUM(a.tien_thu)) tien, ROUND(SUM(a.vat_thu)) vat,
               ROUND(SUM(a.km_lapdat)) km_lapdat, ROUND(SUM(a.vat_km)) vat_km,
               h.ht_tra, i.KENHTHU,
               CASE WHEN a.trangthai = 1 THEN ''Da thu tien'' ELSE ''Chua thu tien'' END AS trangthai_tt,
               a.tenchuquan
        FROM std_onebss a
        JOIN css_hcm.loai_hd b ON a.loaihd_id = b.loaihd_id
        LEFT JOIN css_hcm.kieu_ld c ON a.kieuld_id = c.kieuld_id
        LEFT JOIN admin_hcm.nhanvien_onebss d ON d.nhanvien_id = a.ctv_id
        LEFT JOIN admin_hcm.donvi m ON d.DONVI_ID = m.DONVI_ID
        LEFT JOIN admin_hcm.donvi s ON m.DONVI_cha_ID = s.DONVI_ID
        LEFT JOIN admin_hcm.donvi l ON l.DONVI_ID = a.donvi_tt_id
        LEFT JOIN css_hcm.hinhthuc_tra h ON h.ht_tra_id = a.ht_tra_id
        LEFT JOIN css_hcm.kenhthu i ON a.kenhthu_id = i.kenhthu_id
        LEFT JOIN css_hcm.loaihinh_tb q ON q.loaitb_id = a.loaitb_id
        LEFT JOIN css_hcm.dichvu_vt dv ON q.dichvuvt_id = dv.dichvuvt_id
        GROUP BY a.ngay_ins, a.tthd_id, a.HDTB_ID, dv.dichvuvt_id, q.loaihinh_tb, a.loaitb_id, a.ma_gd,
                 a.hdtb_id, a.thuebao_id, a.ma_tb, b.MA_LOAIHD, b.TEN_LOAIHD, c.ten_kieuld, a.ngay_yc,
                 a.ngay_ht, d.ten_nv, m.ten_dv, s.ten_dv, a.donvi_tt_id, l.ten_dv, a.ngay_tt, a.ngay_hd,
                 a.seri, a.soseri, h.ht_tra, i.KENHTHU, a.khoanmuctt_id, a.trangthai, a.kieuld_id,
                 a.loaihd_id, a.tenchuquan
    )
    SELECT * FROM x_onebss';

    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('Đã tạo bảng ONEBSS_' || v_yyyymm);
END;
/


-- 2. Lên lịch chạy tự động
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_CREATE_ONEBSS_MONTHLY',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'CREATE_ONEBSS_TABLE',
    start_date      => TRUNC(ADD_MONTHS(SYSDATE, 1), 'MM') + 7/24, -- 7h sáng ngày 1 tháng tới
    repeat_interval => 'FREQ=MONTHLY;BYMONTHDAY=1;BYHOUR=7;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Tự động tạo bảng ONEBSS vào 7g sáng ngày đầu mỗi tháng'
  );
END;
/

SELECT job_name, enabled, last_start_date, next_run_date
FROM v_scheduler_jobs
WHERE job_name = 'JOB_CREATE_ONEBSS';

SELECT job, what, next_date FROM user_jobs;

SELECT job, what, next_date, next_sec, failures, broken 
FROM dba_jobs;

SELECT * FROM all_scheduler_jobs WHERE job_name LIKE '%ONEBSS%';

BEGIN
  DBMS_SCHEDULER.DROP_JOB('JOB_CREATE_ONEBSS', force => TRUE);
END;
/




