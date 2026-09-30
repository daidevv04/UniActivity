SET NAMES utf8mb4;
USE uni_activitydb;

-- ============ 1. MẬT KHAẨU TÀI KHOẢN ============
UPDATE users SET password_hash='$2a$10$XFJEnoICc9eGUdZciVHLkunQkt636MkBJiVC7OAbfuJEMPtOqAMmO',
    status='ACTIVE', provider='LOCAL', email_verified=TRUE, token_version=token_version+1
WHERE username='admin';

UPDATE users SET password_hash='$2a$10$ufwKcNUviVwKRVSNIg/IFOGe2uZOCI3t6MYhXc.RYVU1Ud1aDaLNi',
    status='ACTIVE', provider='LOCAL', email_verified=TRUE, token_version=token_version+1
WHERE username IN ('20000001','20000002');

UPDATE users SET password_hash='$2a$10$XP6frhDpCdBzJNHSFFccXeEL3JWzdVoGQxQoBQQR1EhR4qEoiFA9u',
    status='ACTIVE', provider='LOCAL', email_verified=TRUE, token_version=token_version+1
WHERE username IN ('10000001','10000002','10000003');

-- ============ 2. TÀI KHOẢN MỚI ============
SET @class1 := (SELECT id FROM classes WHERE code='CNTT-K45A' LIMIT 1);
SET @class2 := (SELECT id FROM classes WHERE code='CNTT-K45B' LIMIT 1);

INSERT IGNORE INTO users (username,password_hash,full_name,email,phone,role,class_id,status,provider,email_verified,token_version,created_at)
VALUES ('20000003','$2a$10$ufwKcNUviVwKRVSNIg/IFOGe2uZOCI3t6MYhXc.RYVU1Ud1aDaLNi','Phạm Văn Quản',
        'manager3@uni.edu.vn','0987654323','MANAGER',@class1,'ACTIVE','LOCAL',TRUE,0,NOW()),
       ('10000004','$2a$10$XP6frhDpCdBzJNHSFFccXeEL3JWzdVoGQxQoBQQR1EhR4qEoiFA9u','Đỗ Thị Dung',
        'student4@uni.edu.vn','0912345681','STUDENT',@class1,'ACTIVE','LOCAL',TRUE,0,NOW()),
       ('10000005','$2a$10$XP6frhDpCdBzJNHSFFccXeEL3JWzdVoGQxQoBQQR1EhR4qEoiFA9u','Hoàng Văn Hải',
        'student5@uni.edu.vn','0912345682','STUDENT',@class2,'ACTIVE','LOCAL',TRUE,0,NOW());

-- ============ 3. HOẠT ĐỘNG MẪU ============
SET @sem   := (SELECT id FROM semesters WHERE is_current = 1 LIMIT 1);
SET @admin := (SELECT id FROM users WHERE username='admin' LIMIT 1);

SET @a1 := (SELECT id FROM activities WHERE name='Hội trại tân sinh viên 2026' LIMIT 1);
INSERT INTO activities (name,description,banner_url,location,latitude,longitude,checkin_radius,start_time,end_time,registration_deadline,status,scope,semester_id,created_by,created_at)
SELECT 'Hội trại tân sinh viên 2026','Hoạt động chào đón tân sinh viên do Đoàn trường tổ chức.',NULL,
       'Sân vận động Đại học Quy Nhơn',13.771100,109.221000,200,
       DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 33 HOUR), DATE_ADD(NOW(), INTERVAL 20 HOUR),
       'OPEN','SCHOOL',@sem,@admin,NOW()
FROM DUAL WHERE @a1 IS NULL;

SET @a2 := (SELECT id FROM activities WHERE name='Ngày hội hiến máu nhân đạo' LIMIT 1);
INSERT INTO activities (name,description,banner_url,location,latitude,longitude,checkin_radius,start_time,end_time,registration_deadline,status,scope,semester_id,created_by,created_at)
SELECT 'Ngày hội hiến máu nhân đạo','Hiến máu nhân đạo phối hợp Bệnh viện Đa khoa tỉnh.',NULL,
       'Nhà văn hóa sinh viên',13.770500,109.220000,200,
       DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 6 HOUR), DATE_SUB(NOW(), INTERVAL 2 HOUR),
       'OPEN','SCHOOL',@sem,@admin,NOW()
FROM DUAL WHERE @a2 IS NULL;

SET @a3 := (SELECT id FROM activities WHERE name='Cuộc thi Ý tưởng khởi nghiệp 2026' LIMIT 1);
INSERT INTO activities (name,description,banner_url,location,latitude,longitude,checkin_radius,start_time,end_time,registration_deadline,status,scope,semester_id,created_by,created_at)
SELECT 'Cuộc thi Ý tưởng khởi nghiệp 2026','Sân chơi khởi nghiệp dành cho sinh viên toàn trường.',NULL,
       'Hội trường A',NULL,NULL,NULL,
       DATE_ADD(NOW(), INTERVAL 10 DAY), DATE_ADD(NOW(), INTERVAL 11 DAY), DATE_ADD(NOW(), INTERVAL 7 DAY),
       'DRAFT','SCHOOL',@sem,@admin,NOW()
FROM DUAL WHERE @a3 IS NULL;

SET @a1 := (SELECT id FROM activities WHERE name='Hội trại tân sinh viên 2026' LIMIT 1);
SET @a2 := (SELECT id FROM activities WHERE name='Ngày hội hiến máu nhân đạo' LIMIT 1);

-- ============ 4. SLOT THEO LỚP ============
INSERT INTO activity_slots (activity_id,faculty_id,academic_year_id,class_id,max_quantity,current_quantity,version)
SELECT @a1,NULL,NULL,@class1,50,2,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM activity_slots s WHERE s.activity_id=@a1 AND s.class_id=@class1);

INSERT INTO activity_slots (activity_id,faculty_id,academic_year_id,class_id,max_quantity,current_quantity,version)
SELECT @a2,NULL,NULL,@class1,30,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM activity_slots s WHERE s.activity_id=@a2 AND s.class_id=@class1);

SET @slot1 := (SELECT id FROM activity_slots WHERE activity_id=@a1 AND class_id=@class1 LIMIT 1);
SET @slot2 := (SELECT id FROM activity_slots WHERE activity_id=@a2 AND class_id=@class1 LIMIT 1);

-- ============ 5. MỤC ĐIỂM ============
INSERT INTO score_options (activity_id,name,score_category,score_value,description)
SELECT @a1,'Tham gia hoạt động','THAMGIA',5,'Điểm cộng khi tham gia và check-in hoạt động' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM score_options so WHERE so.activity_id=@a1 AND so.name='Tham gia hoạt động');

INSERT INTO score_options (activity_id,name,score_category,score_value,description)
SELECT @a2,'Tham gia hiến máu','THAMGIA',8,'Điểm cộng cho sinh viên tham gia hiến máu' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM score_options so WHERE so.activity_id=@a2 AND so.name='Tham gia hiến máu');

SET @opt1 := (SELECT id FROM score_options WHERE activity_id=@a1 AND name='Tham gia hoạt động' LIMIT 1);
SET @opt2 := (SELECT id FROM score_options WHERE activity_id=@a2 AND name='Tham gia hiến máu' LIMIT 1);

-- ============ 6. ĐĂNG KÝ MẪU ============
SET @s1 := (SELECT id FROM users WHERE username='10000001' LIMIT 1);
SET @s2 := (SELECT id FROM users WHERE username='10000002' LIMIT 1);
SET @s3 := (SELECT id FROM users WHERE username='10000003' LIMIT 1);
SET @s4 := (SELECT id FROM users WHERE username='10000004' LIMIT 1);

-- s1: đã đăng ký A1, chưa điểm danh
INSERT IGNORE INTO activity_registrations
    (student_id,activity_id,activity_slot_id,score_option_id,registered_at,status,attendance_confirmed,confirmed_at,notes,evidence_url,is_approved,rejection_reason)
VALUES (@s1,@a1,@slot1,@opt1,DATE_SUB(NOW(), INTERVAL 2 DAY),'REGISTERED',FALSE,NULL,NULL,NULL,NULL,NULL);

-- s2: đã điểm danh A2, đã nộp minh chứng, chờ Manager duyệt
INSERT IGNORE INTO activity_registrations
    (student_id,activity_id,activity_slot_id,score_option_id,registered_at,status,attendance_confirmed,confirmed_at,notes,evidence_url,is_approved,rejection_reason)
VALUES (@s2,@a2,@slot2,@opt2,DATE_SUB(NOW(), INTERVAL 3 DAY),'ATTENDED',TRUE,DATE_SUB(NOW(), INTERVAL 1 HOUR),
        'Sinh viên tham gia đúng giờ','/uploads/evidence/demo-evidence.png',NULL,NULL);

-- s3: đã đăng ký A2, chờ Manager điểm danh thủ công
INSERT IGNORE INTO activity_registrations
    (student_id,activity_id,activity_slot_id,score_option_id,registered_at,status,attendance_confirmed,confirmed_at,notes,evidence_url,is_approved,rejection_reason)
VALUES (@s3,@a2,@slot2,@opt2,DATE_SUB(NOW(), INTERVAL 1 DAY),'REGISTERED',FALSE,NULL,NULL,NULL,NULL,NULL);

-- s4: đăng ký A1 (hoạt động còn hạn đăng ký)
INSERT IGNORE INTO activity_registrations
    (student_id,activity_id,activity_slot_id,score_option_id,registered_at,status,attendance_confirmed,confirmed_at,notes,evidence_url,is_approved,rejection_reason)
VALUES (@s4,@a1,@slot1,@opt1,DATE_SUB(NOW(), INTERVAL 1 DAY),'REGISTERED',FALSE,NULL,NULL,NULL,NULL,NULL);

-- ============ 7. ĐIỂM RÈN LUYỆN MẪU ============
INSERT IGNORE INTO student_training_points (student_id,semester_id,total_score,classification,status)
VALUES (@s2,@sem,8,'Trung bình','DRAFT');

SET @stp := (SELECT id FROM student_training_points WHERE student_id=@s2 AND semester_id=@sem LIMIT 1);
INSERT IGNORE INTO training_point_details
    (student_training_point_id,criteria_code,score,source_type,reference_id,source_key,description,created_at)
VALUES (@stp,'THAMGIA',8,'AUTO_ACTIVITY',@a2,CONCAT('AUTO_ACTIVITY:',@a2),'Điểm hoạt động Ngày hội hiến máu nhân đạo',NOW());

SELECT 'users' AS tbl, COUNT(*) AS n FROM users
UNION ALL SELECT 'activities', COUNT(*) FROM activities
UNION ALL SELECT 'activity_slots', COUNT(*) FROM activity_slots
UNION ALL SELECT 'score_options', COUNT(*) FROM score_options
UNION ALL SELECT 'activity_registrations', COUNT(*) FROM activity_registrations
UNION ALL SELECT 'training_point_details', COUNT(*) FROM training_point_details;