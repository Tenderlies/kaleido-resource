ALTER TABLE `t_g_epi_info` ADD COLUMN `claim_status` tinyint(1) NULL DEFAULT 0 COMMENT '认领状态，0未认领，1已认领' AFTER `public_type`;

ALTER TABLE `t_g_epi_info` ADD COLUMN `claimer_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '认领人姓名' AFTER `claim_status`;

ALTER TABLE `t_g_epi_info` ADD COLUMN `claimer_phone` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '认领人手机' AFTER `claimer_name`;

CREATE DEFINER=`root`@`%` EVENT `flush_epi_claim` 
ON SCHEDULE EVERY 5 SECOND STARTS '2022-04-23 00:00:00' ON COMPLETION NOT PRESERVE ENABLE COMMENT '自动取消核查认领状态' DO BEGIN

INSERT INTO t_g_epi_assign_log (epi_id, type, reason, assigner, create_time)
SELECT id AS epi_id, 8 AS type, '系统取消认领' AS reason, '系统' AS assigner, NOW() AS create_time
FROM t_g_epi_info WHERE claim_status = 1 AND check_state = 1 AND TIMESTAMPDIFF(HOUR, update_time, NOW()) >= 2;

UPDATE t_g_epi_info 
SET claim_status = 0, claimer_name = NULL, claimer_phone = NULL 
WHERE claim_status = 1 AND check_state = 1 AND TIMESTAMPDIFF(HOUR, update_time, NOW()) >= 2;

END;