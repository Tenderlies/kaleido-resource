-- 新增字段
ALTER TABLE `t_g_third_user_info` ADD COLUMN `dept_name` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '部门名称' AFTER `dept_id`;

ALTER TABLE `t_g_third_user_info` ADD COLUMN `account_auth` int(11) NULL DEFAULT 0 COMMENT '账号权限值，1核验，2管控，4核查，8离锡审批' AFTER `cart_permit_type`;

ALTER TABLE `t_g_third_user_info` ADD COLUMN `account_auth_remark` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '账号权限说明' AFTER `account_auth`;

ALTER TABLE `t_g_third_user_info` ADD COLUMN `func_auth` int(11) NULL DEFAULT 0 COMMENT '功能权限值，1账号管理权限，2人员查看权限，4查看人员详情权限，8后管权限，16苏康码查询权限，32全流程追溯权限，64核酸检测权限，128标准地址权限' AFTER `account_auth_remark`;

ALTER TABLE `t_g_third_user_info` ADD COLUMN `func_auth_remark` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '功能权限说明' AFTER `func_auth`;

ALTER TABLE `t_g_third_user_info` ADD COLUMN `deleted` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否删除' AFTER `func_auth_remark`;

CREATE TABLE `t_g_third_user_role_region` (
  `id` varchar(32) NOT NULL COMMENT '主键标识',
  `user_id` int(11) NOT NULL COMMENT '用户标识',
  `role_value` int(11) NOT NULL COMMENT '角色值',
  `role_type` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '角色类型',
  `region_level` int(11) NOT NULL COMMENT '角色区域级别',
  `region_code` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '行政区域编号',
  `region_name` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '行政区域名称',
  `district_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '区代码',
  `district_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '区名称',
  `streets_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '街道代码',
  `streets_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '街道名称',
  `community_code` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '社区代码',
  `community_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '社区名称',
  `isolation_district_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '隔离点区域编码',
  `isolation_district_name` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '隔离点区域名称',
  `isolation_std_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '隔离点标准编码',
  `isolation_std_name` varchar(1000) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '隔离点名称',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_rela` (`user_id`,`role_value`) USING BTREE COMMENT '用户角色索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户角色区域';

-- 管控社区统计视图
CREATE ALGORITHM = UNDEFINED DEFINER = `root`@`%` SQL SECURITY DEFINER VIEW `v_epi_control_community_stat` AS select `a`.`account_code` AS `regionCode`,`a`.`account_name` AS `regionName`,-(1) AS `accountId`,'' AS `accountName`,`a`.`p_id` AS `pCode`,`a`.`level` AS `LEVEL`,1 AS `stattype`,count((case when ((`c`.`todo_type` = 1) or (`c`.`todo_type` = 5) or (`c`.`todo_type` = 6)) then `c`.`id` end)) AS `toDispatchCount`,count((case when (`c`.`todo_type` = 3) then `c`.`id` end)) AS `noNeedCount`,count((case when (`c`.`todo_type` = 4) then `c`.`id` end)) AS `ingCount`,count((case when ((`c`.`todo_type` = 3) or (`c`.`todo_type` = 8)) then `c`.`id` end)) AS `finishCount`,count((case when (((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 2) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `loseCount`,count((case when (((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 1) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `noCheckCount`,count((case when (`c`.`todo_type` = 2) then `c`.`id` end)) AS `waitingReceiveCount`,count((case when (`c`.`todo_type` = 5) then `c`.`id` end)) AS `backingCount`,count((case when (`c`.`todo_type` = 7) then `c`.`id` end)) AS `finishingCount` from (`t_g_region_catalog` `a` left join `t_g_epi_control` `c` on(((`a`.`account_code` = `c`.`community_code`) and (`c`.`isolate_district_code` is null) and (`c`.`community_code` is not null) and (`c`.`community_code` <> '') and (`c`.`community_name` is not null) and (`c`.`community_name` <> '') and (`c`.`isolate_district_code` is null) and (`c`.`community_account_id` is not null)))) where ((1 = 1) and (`a`.`level` = 4)) group by `a`.`account_code`,`a`.`account_name`,`a`.`p_id`,`a`.`level` union all select `a`.`account_code` AS `regionCode`,`a`.`account_name` AS `regionName`,`b`.`id` AS `accountId`,`b`.`real_name` AS `accountName`,`a`.`p_id` AS `pCode`,`a`.`level` AS `LEVEL`,1 AS `stat_type`,count((case when ((`c`.`todo_type` = 1) or (`c`.`todo_type` = 5) or (`c`.`todo_type` = 6)) then `c`.`id` end)) AS `toDispatchCount`,count((case when (`c`.`todo_type` = 3) then `c`.`id` end)) AS `noNeedCount`,count((case when (`c`.`todo_type` = 4) then `c`.`id` end)) AS `ingCount`,count((case when ((`c`.`todo_type` = 3) or (`c`.`todo_type` = 8)) then `c`.`id` end)) AS `finishCount`,count((case when (((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 2) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `loseCount`,count((case when (((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 1) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `noCheckCount`,count((case when (`c`.`todo_type` = 2) then `c`.`id` end)) AS `waitingReceiveCount`,count((case when (`c`.`todo_type` = 5) then `c`.`id` end)) AS `backingCount`,count((case when (`c`.`todo_type` = 7) then `c`.`id` end)) AS `finishingCount` from (((`t_g_region_catalog` `a` left join `t_g_epi_control` `c` on(((`a`.`account_code` = `c`.`community_code`) and (`c`.`isolate_district_code` is null) and (`c`.`community_code` is not null) and (`c`.`community_code` <> '') and (`c`.`community_name` is not null) and (`c`.`community_name` <> '') and (`c`.`isolate_district_code` is null) and (`c`.`community_account_id` is not null)))) left join `t_g_third_user_info` `b` on((`c`.`community_account_id` = `b`.`id`))) left join `t_g_third_user_role_region` `d` on(((`b`.`id` = `d`.`user_id`) and (`a`.`account_code` = `d`.`region_code`)))) where ((1 = 1) and (`a`.`level` = 4) and (`d`.`role_value` = 2)) group by `a`.`account_code`,`a`.`account_name`,`b`.`id`,`b`.`real_name`,`a`.`p_id`,`a`.`level`;
-- 管控隔离点统计视图
CREATE ALGORITHM = UNDEFINED DEFINER = `root`@`%` SQL SECURITY DEFINER VIEW `v_epi_control_isolation_stat` AS select `a`.`account_code` AS `regionCode`,`a`.`account_name` AS `regionName`,-(1) AS `accountId`,'' AS `accountName`,`a`.`p_id` AS `pCode`,`a`.`level` AS `LEVEL`,2 AS `statType`,count((case when ((`c`.`todo_type` = 1) or (`c`.`todo_type` = 5) or (`c`.`todo_type` = 6)) then `c`.`id` end)) AS `toDispatchCount`,count((case when (`c`.`todo_type` = 3) then `c`.`id` end)) AS `noNeedCount`,count((case when (`c`.`todo_type` = 4) then `c`.`id` end)) AS `ingCount`,count((case when ((`c`.`todo_type` = 3) or (`c`.`todo_type` = 8)) then `c`.`id` end)) AS `finishCount`,count((case when (((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 2) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `loseCount`,count((case when (((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 1) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `noCheckCount`,count((case when (`c`.`todo_type` = 2) then `c`.`id` end)) AS `waitingReceiveCount`,count((case when (`c`.`todo_type` = 5) then `c`.`id` end)) AS `backingCount`,count((case when (`c`.`todo_type` = 7) then `c`.`id` end)) AS `finishingCount` from (`t_g_region_catalog` `a` left join `t_g_epi_control` `c` on(((`a`.`account_code` = `c`.`isolate_district_code`) and (`c`.`isolate_district_code` is not null) and (`c`.`isolate_district_code` <> '') and (`c`.`isolation_code` is not null) and (`c`.`isolation_code` <> '') and (`c`.`isolate_account_id` is not null)))) where ((1 = 1) and (`a`.`level` = 2)) group by `a`.`account_code`,`a`.`account_name`,`a`.`p_id`,`a`.`level` union all select `a`.`account_code` AS `regionCode`,`a`.`account_name` AS `regionName`,`b`.`id` AS `accountId`,`b`.`real_name` AS `accountName`,`a`.`p_id` AS `pCode`,`a`.`level` AS `LEVEL`,2 AS `stat_type`,count((case when (((`b`.`id` = `c`.`isolate_account_id`) and (`c`.`todo_type` = 1)) or (`c`.`todo_type` = 5) or (`c`.`todo_type` = 6)) then `c`.`id` end)) AS `toDispatchCount`,count((case when ((`b`.`id` = `c`.`isolate_account_id`) and (`c`.`todo_type` = 3)) then `c`.`id` end)) AS `noNeedCount`,count((case when ((`b`.`id` = `c`.`isolate_account_id`) and (`c`.`todo_type` = 4)) then `c`.`id` end)) AS `ingCount`,count((case when (((`b`.`id` = `c`.`isolate_account_id`) and (`c`.`todo_type` = 3)) or (`c`.`todo_type` = 8)) then `c`.`id` end)) AS `finishCount`,count((case when ((`b`.`id` = `c`.`isolate_account_id`) and ((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 2) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `loseCount`,count((case when ((`b`.`id` = `c`.`isolate_account_id`) and ((`c`.`todo_type` = 7) or (`c`.`todo_type` = 8)) and (`c`.`control_exception` = 1) and (`c`.`control_end_time` is not null) and (`c`.`control_end_time` > '2022-03-09 00:00:00')) then `c`.`id` end)) AS `noCheckCount`,count((case when ((`b`.`id` = `c`.`isolate_account_id`) and (`c`.`todo_type` = 2)) then `c`.`id` end)) AS `waitingReceiveCount`,count((case when ((`b`.`id` = `c`.`isolate_account_id`) and (`c`.`todo_type` = 5)) then `c`.`id` end)) AS `backingCount`,count((case when ((`b`.`id` = `c`.`isolate_account_id`) and (`c`.`todo_type` = 7)) then `c`.`id` end)) AS `finishingCount` from (((`t_g_epi_isolation` `a` left join `t_g_epi_control` `c` on(((`a`.`account_code` = `c`.`isolation_code`) and (`c`.`isolate_district_code` is not null) and (`c`.`isolate_district_code` <> '') and (`c`.`isolation_code` is not null) and (`c`.`isolation_code` <> '') and (`c`.`isolate_account_id` is not null)))) left join `t_g_third_user_role_region` `d` on((`a`.`account_code` = `d`.`region_code`))) left join `t_g_third_user_info` `b` on((`b`.`id` = `d`.`user_id`))) where ((1 = 1) and (`a`.`level` = 4) and (`d`.`role_value` = 2) and (`d`.`region_level` = 7)) group by `a`.`account_code`,`a`.`account_name`,`b`.`id`,`b`.`real_name`,`a`.`p_id`,`a`.`level`;
-- 部门名称 --
UPDATE `t_g_third_user_info` SET dept_name = '其他';

-- 账号角色 --  
-- 核查账号
UPDATE t_g_third_user_info
SET 
account_auth = IFNULL(account_auth, 0) + 1,
account_auth_remark = CONCAT(IFNULL(account_auth_remark, ""), "|核查")
WHERE check_auth = 1 OR check_auth = 3;

-- 管控账号
UPDATE t_g_third_user_info
SET 
account_auth = IFNULL(account_auth, 0) + 2,
account_auth_remark = CONCAT(IFNULL(account_auth_remark, ""), "|管控")
WHERE check_auth = 2 OR check_auth = 3;

-- 核验账号
UPDATE t_g_third_user_info
SET 
account_auth = IFNULL(account_auth, 0) + 4,
account_auth_remark = CONCAT(IFNULL(account_auth_remark, ""), "|核验")
WHERE verificate_auth = 1 OR verificate_auth = 2;

-- 离锡审批账号
UPDATE t_g_third_user_info
SET 
account_auth = IFNULL(account_auth, 0) + 8,
account_auth_remark = CONCAT(IFNULL(account_auth_remark, ""), "|离锡审批")
WHERE cart_auth = 1 OR cart_auth = 2;

-- 账号权限 --
-- 账号人员查询权限
UPDATE t_g_third_user_info
SET 
func_auth = IFNULL(func_auth, 0) + 2,
func_auth_remark = CONCAT(IFNULL(func_auth_remark, ""), "|人员查询权限")
WHERE `role` = 'gaj' ;

-- 账号查看人员详情权限
UPDATE t_g_third_user_info
SET 
func_auth = IFNULL(func_auth, 0) + 4,
func_auth_remark = CONCAT(IFNULL(func_auth_remark, ""), "|查看人员详情权限")
WHERE can_read = 1;

-- 账号后管权限
UPDATE t_g_third_user_info
SET 
func_auth = IFNULL(func_auth, 0) + 8,
func_auth_remark = CONCAT(IFNULL(func_auth_remark, ""), "|后管权限")
WHERE back_manage = 1;

-- 账号角色区域 --
-- 核查账号角色区域
INSERT t_g_third_user_role_region (`id`, `user_id`,`role_value`,`role_type`,`region_level`, `region_code`,`region_name`,`district_code`,`district_name`,`streets_code`,`streets_name`,`community_code`,`community_name`,`isolation_district_code`,`isolation_district_name`,`isolation_std_code`,`isolation_std_name`) 
SELECT 
CONCAT(INSERT(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()) * 9, 4, 5, ''), LPAD(id, 9, '0'), LPAD((FLOOR(RAND() * 10000) | 0), 4, '0')) AS `id`,
id AS user_id,
1 AS role_value,
'EXAMINE' AS role_type,
CASE WHEN region_code = '320200' THEN 1 WHEN LENGTH(region_code) = 6 AND region_code <> '320200' THEN 2 WHEN LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) = '000' OR RIGHT(region_code, 3) = '999') THEN 3 ELSE 4 END AS region_level,
region_code,
CASE WHEN region_code = '320200' THEN '无锡市' WHEN LENGTH(region_code) = 6 AND region_code <> '320200' THEN district_name WHEN LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) = '000' OR RIGHT(region_code, 3) = '999') THEN streets_name ELSE community_name END AS region_name,
district_code,
district_name,
streets_code,
streets_name,
community_code,
community_name,
NULL AS isolation_district_code,
NULL AS isolation_district_name,
NULL AS isolation_std_code,
NULL AS isolation_std_name
FROM t_g_third_user_info WHERE check_auth = 1 OR check_auth = 3;

-- 管控账号角色区域
INSERT t_g_third_user_role_region (`id`, `user_id`,`role_value`,`role_type`,`region_level`, `region_code`,`region_name`,`district_code`,`district_name`,`streets_code`,`streets_name`,`community_code`,`community_name`,`isolation_district_code`,`isolation_district_name`,`isolation_std_code`,`isolation_std_name`) 
SELECT 
CONCAT(INSERT(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()) * 9, 4, 5, ''), LPAD(id, 9, '0'), LPAD((FLOOR(RAND() * 1000) | 0), 4, '0')) AS `id`,
id AS user_id,
2 AS role_value,
'CONTROL' AS role_type,
CASE 
WHEN org_auth = 1 AND region_code = '320200' THEN 1 
WHEN org_auth = 1 AND LENGTH(region_code) = 6 AND region_code <> '320200' THEN 2 
WHEN org_auth = 1 AND LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) = '000' OR RIGHT(region_code, 3) = '999') THEN 3 
WHEN org_auth = 1 AND LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) <> '000' AND RIGHT(region_code, 3) <> '999') AND control_auth = 2  THEN 4 
WHEN org_auth = 1 AND LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) <> '000' AND RIGHT(region_code, 3) <> '999') AND control_auth = 1 THEN 5 
WHEN org_auth = 2 AND control_auth = 2 THEN 6 
WHEN org_auth = 2 AND control_auth = 1 THEN 7 
ELSE 8 END AS region_level,
IF(org_auth = 2 AND control_auth = 2, district_code, region_code) AS region_code,
CASE 
WHEN org_auth = 1 AND region_code = '320200' THEN '无锡市' 
WHEN org_auth = 1 AND LENGTH(region_code) = 6 AND region_code <> '320200' THEN district_name 
WHEN org_auth = 1 AND LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) = '000' OR RIGHT(region_code, 3) = '999') THEN streets_name 
WHEN org_auth = 1 AND LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) <> '000' AND RIGHT(region_code, 3) <> '999') THEN community_name 
WHEN org_auth = 2 AND control_auth = 2 THEN district_name 
WHEN org_auth = 2 AND control_auth = 1 THEN isolation_name 
END AS region_name,
IF(org_auth = 2, NULL, district_code) AS district_code,
IF(org_auth = 2, NULL, district_name) AS district_name,
IF(org_auth = 2, NULL, streets_code) AS streets_code,
IF(org_auth = 2, NULL, streets_name) AS streets_name,
IF(org_auth = 2, NULL, community_code) AS community_code,
IF(org_auth = 2, NULL, community_name) AS community_name,
IF(org_auth = 2, district_code, NULL) AS isolation_district_code,
IF(org_auth = 2, district_name, NULL) AS isolation_district_name,
isolation_code AS isolation_std_code,
isolation_name AS isolation_std_name
FROM t_g_third_user_info WHERE check_auth = 2 OR check_auth = 3;

-- 核验账号角色区域
INSERT t_g_third_user_role_region (`id`, `user_id`,`role_value`,`role_type`,`region_level`, `region_code`,`region_name`,`district_code`,`district_name`,`streets_code`,`streets_name`,`community_code`,`community_name`,`isolation_district_code`,`isolation_district_name`,`isolation_std_code`,`isolation_std_name`) 
SELECT 
CONCAT(INSERT(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()) * 9, 4, 5, ''), LPAD(id, 9, '0'), LPAD((FLOOR(RAND() * 1000) | 0), 4, '0')) AS `id`,
id AS user_id,
4 AS role_value,
'VERIFICATION' AS role_type,
1 AS region_level,
'320200' AS region_code,
'无锡市' AS region_name,
NULL AS district_code,
NULL AS district_name,
NULL AS streets_code,
NULL AS streets_name,
NULL AS community_code,
NULL AS community_name,
NULL AS isolation_district_code,
NULL AS isolation_district_name,
NULL AS isolation_std_code,
NULL AS isolation_std_name
FROM t_g_third_user_info WHERE verificate_auth = 1 OR verificate_auth = 2;

-- 离锡审批账号角色区域
INSERT t_g_third_user_role_region (`id`, `user_id`,`role_value`,`role_type`,`region_level`, `region_code`,`region_name`,`district_code`,`district_name`,`streets_code`,`streets_name`,`community_code`,`community_name`,`isolation_district_code`,`isolation_district_name`,`isolation_std_code`,`isolation_std_name`) 
SELECT 
CONCAT(INSERT(UNIX_TIMESTAMP(CURRENT_TIMESTAMP()) * 9, 4, 5, ''), LPAD(id, 9, '0'), LPAD((FLOOR(RAND() * 1000) | 0), 4, '0')) AS `id`,
id AS user_id,
8 AS role_value,
'APPROVAL' AS role_type,
CASE WHEN region_code = '320200' THEN 1 WHEN LENGTH(region_code) = 6 AND region_code <> '320200' THEN 2 WHEN LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) = '000' OR RIGHT(region_code, 3) = '999') THEN 3 ELSE 4 END AS region_level,
region_code,
CASE WHEN region_code = '320200' THEN '无锡市' WHEN LENGTH(region_code) = 6 AND region_code <> '320200' THEN district_name WHEN LENGTH(region_code) = 12 AND (RIGHT(region_code, 3) = '000' OR RIGHT(region_code, 3) = '999') THEN streets_name ELSE community_name END AS region_name,
district_code,
district_name,
streets_code,
streets_name,
community_code,
community_name,
NULL AS isolation_district_code,
NULL AS isolation_district_name,
NULL AS isolation_std_code,
NULL AS isolation_std_name
FROM t_g_third_user_info WHERE cart_auth = 1 OR cart_auth = 2;

-- 后管权限系统角色分配 --
INSERT IGNORE INTO t_m_sys_user_role (user_id, role_id)
SELECT 
ui.id AS user_id, 
CASE WHEN rr.role_value = 1 THEN 110 WHEN rr.role_value = 2 THEN 111 WHEN rr.role_value = 4 THEN 112 WHEN rr.role_value = 8 THEN 113 END AS role_id
FROM t_g_third_user_info ui JOIN t_g_third_user_role_region rr ON  ui.id = rr.user_id
WHERE (ui.func_auth & 8);

-- 异常数据检查 --
SELECT 
* 
FROM t_g_third_user_role_region 
WHERE 
(region_code IS NULL OR region_name IS NULL) OR
(region_level = 2 AND (district_code IS NULL OR district_name IS NULL)) OR
(region_level = 3 AND (streets_code IS NULL OR streets_name IS NULL)) OR
((region_level = 4 OR region_level = 5 )AND (community_code IS NULL OR community_name IS NULL)) OR
(region_level = 6 AND (isolation_district_code IS NULL OR isolation_district_name IS NULL)) OR
(region_level = 7 AND (isolation_district_code IS NULL OR isolation_district_name IS NULL OR isolation_std_code IS NULL OR isolation_std_name IS NULL))
ORDER BY user_id;
