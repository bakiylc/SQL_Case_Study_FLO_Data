--SORU 1 Customers isimli bir veritaban�ve verilen veri setindeki de�i�kenleri i�erecek FLO isimli bir tablo olu�turunuz.
CREATE DATABASE CUSTOMERS

CREATE TABLE FLO (
	master_id							VARCHAR(50),
	order_channel						VARCHAR(50),
	last_order_channel					VARCHAR(50),
	first_order_date					DATE,
	last_order_date						DATE,
	last_order_date_online				DATE,
	last_order_date_offline				DATE,
	order_num_total_ever_online			INT,
	order_num_total_ever_offline		INT,
	customer_value_total_ever_offline	FLOAT,
	customer_value_total_ever_online	FLOAT,
	interested_in_categories_12			VARCHAR(50),
	store_type							VARCHAR(10)
);

--SORU 2: Ka� farkl� m��terinin al��veri� yapt���n� g�sterecek sorguyu yaz�n�z.
Select COUNT(DISTINCT(Master_id)) as DISTINCT_KISI_SAYISI from FLO

--SORU 3: Toplam yap�lan al��veri� say�s� ve ciroyu getirecek sorguyu yaz�n�z.
select SUM(order_num_total_ever_online + order_num_total_ever_offline) as Toplam_Siparis_Sayisi , SUM(customer_value_total_ever_offline + customer_value_total_ever_online) as Total_ciro from FLO

--SORU 4:  Al��veri� ba��na ortalama ciroyu getirecek sorguyu yaz�n�z.
select SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_online + order_num_total_ever_offline)  as AlisverisBasiOrtalama from FLO

--SORU 5: En son al��veri� yap�lan kanal (last_order_channel) �zerinden yap�lan al��veri�lerin toplam ciro ve al��veri� say�lar�n� getirecek sorguyu yaz�n�z.
Select 
	SUM(customer_value_total_ever_offline + customer_value_total_ever_online) as Ciro , 
	SUM(order_num_total_ever_online + order_num_total_ever_offline) as AlisverisSayisi , 
	last_order_channel   
From FLO
Group by last_order_channel

--SORU 6: Store type k�r�l�m�nda elde edilen toplam ciroyu getiren sorguyu yaz�n�z.
Select 
	SUM(customer_value_total_ever_offline + customer_value_total_ever_online) as Ciro ,  
	store_type as MagazaTuru
From FLO
Group by store_type

--SORU 7: Y�l k�r�l�m�nda al��veri� say�lar�n� getirecek sorguyu yaz�n�z (Y�l olarak m��terinin ilk al��veri� tarihi (first_order_date) y�l�n� baz al�n�z)
select 
	SUM(order_num_total_ever_online + order_num_total_ever_offline) as Alisveris_Sayisi ,
	DATEPART(Year,first_order_date) as YIL
from FLO
group by DATEPART(Year,first_order_date)
order by 2

--SORU 8: En son al��veri� yap�lan kanal k�r�l�m�nda al��veri� ba��na ortalama ciroyu hesaplayacak sorguyu yaz�n�z.
select 
	SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_online + order_num_total_ever_offline) as OrtalamaCiro ,
	SUM(order_num_total_ever_online + order_num_total_ever_offline) as ToplamSiparisSayisi,
	last_order_channel
From FLO
Group by last_order_channel

--SORU 9: Son 12 ayda en �ok ilgi g�ren kategoriyi getiren sorguyu yaz�n�z.
SELECT interested_in_categories_12, 
       COUNT(*) FREKANS_BILGISI 
FROM FLO
GROUP BY interested_in_categories_12
ORDER BY 2 DESC;

--SORU 10:  En �ok tercih edilen store_type bilgisini getiren sorguyu yaz�n�z.
select Top 1 
	store_type, 
	count(*) as frekans_bilgisi
from FLO 
group by store_type 

--SORU 11: En son al��veri� yap�lan kanal (last_order_channel) baz�nda, en �ok ilgi g�ren kategoriyi ve bu kategoriden ne kadarl�k al��veri� yap�ld���n� getiren sorguyu yaz�n�z.
-- 1. Yol : 
SELECT 
    f.last_order_channel,
    top1.kategori,
    top1.toplam_siparis_sayisi
FROM 
    (SELECT DISTINCT last_order_channel FROM FLO) f
OUTER APPLY (
    SELECT TOP 1 
        interested_in_categories_12 AS kategori,
        SUM(order_num_total_ever_online + order_num_total_ever_offline) AS toplam_siparis_sayisi
    FROM FLO
    WHERE last_order_channel = f.last_order_channel
    GROUP BY interested_in_categories_12
    ORDER BY toplam_siparis_sayisi DESC
) AS top1;

-- 2.Yol : 
SELECT DISTINCT last_order_channel,
(
	SELECT top 1 interested_in_categories_12
	FROM FLO  
	WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc 
),
(
	SELECT top 1 SUM(order_num_total_ever_online+order_num_total_ever_offline)
	FROM FLO  
	WHERE last_order_channel=f.last_order_channel
	group by interested_in_categories_12
	order by 
	SUM(order_num_total_ever_online+order_num_total_ever_offline) desc 
)
FROM FLO F

--SORU 12: En �ok al��veri� yapan ki�inin ID�sini getiren sorguyu yaz�n�z. 
select top 1 master_id , SUM(order_num_total_ever_offline + order_num_total_ever_online ) as toplam_siparis_sayisi from flo 
group by master_id
order by toplam_siparis_sayisi desc

--SORU 13: En �ok al��veri� yapan ki�inin al��veri� ba��na ortalama cirosunu ve al��veri� yapma g�n ortalamas�n� (al��veri� s�kl���n�) getiren sorguyu yaz�n�z.
SELECT 
    f.master_id,
    ROUND(f.total_ciro / NULLIF(f.siparis_sayisi, 0), 2) AS Alisveris_Ort_Ciro,
    ROUND(DATEDIFF(DAY, f.first_order_date, f.last_order_date) * 1.0 / NULLIF(f.siparis_sayisi, 0), 2) AS Alisveris_Sikligi  
FROM 
(
    SELECT TOP 1  
        master_id, 
        first_order_date,
        last_order_date,
        SUM(order_num_total_ever_online + order_num_total_ever_offline) AS siparis_sayisi, 
        SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS total_ciro 
    FROM FLO
    GROUP BY master_id, first_order_date, last_order_date
    ORDER BY total_ciro DESC
) f;

--SORU 14: En �ok al��veri�yapan (ciro baz�nda) ilk 100 ki�inin al��veri�yapma g�n ortalamas�n� (al��veri�s�kl���n�) getiren sorguyu yaz�n�z. 
Select TOP 100
f.master_id , 
ROUND(DATEDIFF(DAY,first_order_date,last_order_date) / f.total_siparis_sayisi,2) as alisveris_yapma_g�n_ort ,
f.Total_ciro ,
f.total_siparis_sayisi
FROM 
( Select 
	master_id, 
	first_order_date , 
	last_order_date,
	SUM(customer_value_total_ever_offline+customer_value_total_ever_online) as Total_ciro,
	SUM(order_num_total_ever_online+order_num_total_ever_offline) as total_siparis_sayisi
	From FLO
	Group by master_id , first_order_date , last_order_date
) F
order by f.Total_ciro desc

--SORU 15: En son al��veri� yap�lan kanal (last_order_channel) k�r�l�m�nda en �ok al��veri� yapan m��teriyi getiren sorguyu yaz�n�z.
1. YOL : 

WITH KanalCiro AS (
    SELECT 
        last_order_channel,
        master_id,
        SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS toplam_ciro
    FROM FLO
    GROUP BY last_order_channel, master_id
),
KanalBazindaEnCokCiroYapan AS (
    SELECT 
        last_order_channel,
        master_id,
        toplam_ciro,
        ROW_NUMBER() OVER (PARTITION BY last_order_channel ORDER BY toplam_ciro DESC) AS sira
    FROM KanalCiro
)
SELECT 
    last_order_channel,
    master_id AS EN_COK_ALISVERIS_YAPAN_MUSTERI,
    toplam_ciro AS CIRO
FROM KanalBazindaEnCokCiroYapan
WHERE sira = 1;


2. YOL : 
SELECT DISTINCT last_order_channel ,
(
Select TOP 1 master_id 
FROM FLO
where last_order_channel = f.last_order_channel
GROUP BY master_id
ORDER BY 
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) desc
) as Musteri , 
(
select TOP 1 SUM(customer_value_total_ever_offline + customer_value_total_ever_online) 
FROM FLO
Where last_order_channel = f.last_order_channel
GROUP BY master_id
ORDER BY 
SUM(customer_value_total_ever_offline + customer_value_total_ever_online) desc
) as  Price 
FROM FLO as f 

--SORU 16:  En son al��veri� yapan ki�inin ID� sini getiren sorguyu yaz�n�z. (Max son tarihte birden fazla al��veri� yapan ID bulunmakta. Bunlar� da getiriniz.) 
Select master_id , last_order_date
FROM FLO
WHERE last_order_date = (SELECT MAX(last_order_date) FROM FLO)

