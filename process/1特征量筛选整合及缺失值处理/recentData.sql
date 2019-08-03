#缺失值删除
#房屋
CREATE TABLE apartdata AS
	SELECT *
	FROM raw_data_analysis
	WHERE type=1 
	AND r_id IN (
	         SELECT r_id 
	         FROM raw_data_analysis
	         WHERE aval>'2017.02.22'
	         AND akey='成交日期'
	         AND type=1

	         )
;

CREATE TABLE apartdata1 AS
	SELECT r_id,akey,aval 
	FROM apartdata
	WHERE r_id
	NOT IN (
		SELECT r_id 
		FROM apartdata 
		WHERE aval 
		IN('暂无数据','未知','- -室- -厅','0')
		OR aval
		LIKE '未知%' 
		AND akey 
		IN ('小区名称','建成年代','建筑面积','成交价','房屋户型','房屋朝向','所在楼层','装修情况','配备电梯','交易权属','房权所属','产权年限','房屋年限','房屋用途')
		)
	AND akey 
	IN ('小区名称','建成年代','建筑面积','成交价','房屋户型','房屋朝向','所在楼层','装修情况','配备电梯','交易权属','房权所属','产权年限','房屋年限','房屋用途')
;


#小区
CREATE TABLE commudata1 AS
	SELECT r_id,akey,aval
	FROM raw_data_analysis
	WHERE type=2
	AND r_id
	NOT IN(
		SELECT r_id 
		FROM raw_data_analysis 
		where type=2
		AND (aval 
			IN('暂无信息','暂无参考均价','暂无数据')
			AND akey 
			IN ('均价','小区名称','小区地址','物业费用')
			)
		) 
	AND akey
	IN ('均价','小区名称','小区地址','物业费用')
;

#过滤房产信息中无对应小区的数据

CREATE TABLE tem_aval AS
	SELECT aval
	FROM commudata1
	WHERE akey="小区名称"
;

CREATE TABLE temr_id AS
	SELECT r_id 
	FROM apartdata1 
	WHERE akey="小区名称"
	AND aval
	IN (
		SELECT aval 
		FROM tem_aval
		)
;

CREATE TABLE apartdata2 AS
	SELECT * 
	FROM apartdata1 
	WHERE r_id 
	IN (
		SELECT r_id 
		FROM temr_id
		)
;

#备份
#CREATE TABLE apartdata3 AS SELECT * FROM apartdata1 WHERE r_id IN (SELECT r_id FROM temr_id);

#过滤小区信息中无对应房产的数据
CREATE TABLE tem_aval2 AS
	SELECT aval 
	FROM apartdata2 
	WHERE akey="小区名称"
;

CREATE TABLE temr_id2 AS 
	SELECT r_id 
	FROM commudata1 
	WHERE akey="小区名称" 
	AND aval 
	IN (
		SELECT aval 
		FROM tem_aval2
		)
;

CREATE TABLE commudata2 AS
	SELECT * 
	FROM commudata1 
	WHERE r_id 
	IN (
		SELECT r_id 
		FROM temr_id2
		)
;

#连接表 匹配信息

CREATE TABLE rela_id AS 
	SELECT a.r_id f,b.r_id q,b.akey q_akey,b.aval q_aval 
	FROM apartdata2 a 
	INNER JOIN commudata2 b 
	ON a.aval=b.aval 
	WHERE a.akey='小区名称' 
	AND b.akey ='小区名称'
;

CREATE TABLE rela_id1 AS 
	SELECT a.f,b.r_id,b.akey,b.aval 
	FROM rela_id a 
	INNER JOIN commudata2 b 
	ON a.q=b.r_id
;

#将筛选过后的小区信息插入至房产数据中
INSERT INTO 
	apartdata2(r_id,aval,akey) 
	SELECT f AS r_id,aval,akey 
	FROM rela_id1
;

#将表排序得到最终表
CREATE TABLE update_alldata AS 
	SELECT * 
	FROM apartdata2 
	ORDER BY r_id 
	ASC
;


