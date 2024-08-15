# CDS one_bss

# FORM 1: BÁO CÁO DOANH THU LẮP ĐẶT CÁC DỊCH VỤ BRCĐ-TSL
# FORM 2: BÁO CÁO DÒNG TIỀN ĐÃ THU CÁC DỊCH VỤ BRCĐ-TSL-CNTT NHƯNG CHƯA NGHIỆM THU
# FORM 3: BÁO CÁO DOANH THU LẮP ĐẶT CÁC DỊCH VỤ CNTT-GTGT

**dieukien:**

**1. 5951 recs , 5937 Cũ**
--where khoanmuctt_id  in (1,2,3,4,9,17)
and tthd_id = 6 and dichvuvt_id in (1,4,7,8,10,11,12);
**2. 388 recs**
--tthd_id < 6 and trangthai = 1
--and loaitb_id not in (2116,147,39,290,175,122)
**3.499 recs**
-- loaitb_id not in (2116,147,39,290,175,122) -- dk chi Huong
--and dichvuvt_id not in (1,4,7,8,10,11,12)
--and khoanmuctt_id in (1,5,52,142); -- form 3;


1. lệch tiền MN001264250, MN001264239 ( tiền của mình nó da + them ca vat ? ) =>> ra form
				--select * from x_onebss where ma_tb = 'MN001264250';MN001264250
                                --select * from css.v_ct_phieutt where hdtb_id ='25442659';

			**view chenh lech**:
--select a.ma_tb,a.tien,b.tien,a.tien- b.tien aa ,a.vat-b.vat bb
from x_onebss a
join x_ma_TB_CDBR b on a.ma_tb =b.ma_tb
where a.khoanmuctt_id  in (1,2,3,4,9,17)
and a.tthd_id = 6 and dichvuvt_id in (1,4,7,8,10,11,12)
and a.ma_tb  in (select ma_tb from x_ma_TB_CDBR) --3
and a.ma_tb in ('MN001264250','MN001264239') --HCM-LD/01691678




		 **form trùng 271, thiếu 42(40 ins T6 , 3TB (hcm_ca_00056696 T7, hcm_ca_00104967 T8, hcm_ca_00114098 null) 
			+185**


--select count(*) from x_onebss
where
loaitb_id not in (2116,147,39,290,175,122) -- dk chi Huong
and dichvuvt_id not in (1,4,7,8,10,11,12)
and khoanmuctt_id in (1,5,52,142) -- form 3;
and ma_tb  in (select ma_tb from x_ma_tb_gtgt_07) --3
;			
