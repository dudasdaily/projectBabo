-- 데이터베이스 생성 (이미 존재하면 건너뛰기)
CREATE DATABASE IF NOT EXISTS rebread_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 생성한 데이터베이스 사용
USE rebread_db;

-- -----------------------------------------------------
-- 1. 사용자 (USER)
-- -----------------------------------------------------
CREATE TABLE `user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '사용자 고유 ID',
  `email` VARCHAR(255) NOT NULL COMMENT '로그인 이메일',
  `password` VARCHAR(255) NOT NULL COMMENT '해싱된 비밀번호',
  `name` VARCHAR(50) NOT NULL COMMENT '사용자 이름',
  `phone_number` VARCHAR(20) NOT NULL COMMENT '휴대폰 번호',
  `role` VARCHAR(20) NOT NULL COMMENT '사용자 역할 (CUSTOMER, OWNER, ADMIN)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE,
  UNIQUE INDEX `phone_number_UNIQUE` (`phone_number` ASC) VISIBLE)
ENGINE = InnoDB
COMMENT = '사용자 정보';


-- -----------------------------------------------------
-- 2. 빵집 (STORE)
-- -----------------------------------------------------
CREATE TABLE `store` (
  `store_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '빵집 고유 ID',
  `user_id` BIGINT NOT NULL COMMENT '점주 ID (USER 테이블 FK)',
  `name` VARCHAR(100) NOT NULL COMMENT '빵집 이름',
  `address` VARCHAR(255) NOT NULL COMMENT '빵집 주소',
  `latitude` DECIMAL(10, 8) NOT NULL COMMENT '위도 (지도 표시용)',
  `longitude` DECIMAL(11, 8) NOT NULL COMMENT '경도 (지도 표시용)',
  `phone_number` VARCHAR(20) NULL COMMENT '빵집 연락처',
  `description` TEXT NULL COMMENT '빵집 상세 설명',
  `status` VARCHAR(20) NOT NULL COMMENT '빵집 상태 (PENDING, APPROVED, REJECTED)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
  PRIMARY KEY (`store_id`),
  INDEX `fk_store_user_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `fk_store_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '빵집 정보';


-- -----------------------------------------------------
-- 3. 상품 (PRODUCT)
-- -----------------------------------------------------
CREATE TABLE `product` (
  `product_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '상품 고유 ID',
  `store_id` BIGINT NOT NULL COMMENT '빵집 ID (STORE 테이블 FK)',
  `name` VARCHAR(100) NOT NULL COMMENT '상품명 (예: 오늘의 마감빵 세트)',
  `original_price` INT NOT NULL COMMENT '정상가 (필수)',
  `discount_price` INT NOT NULL COMMENT '할인가',
  `quantity` INT NOT NULL COMMENT '판매 수량',
  `description` TEXT NULL COMMENT '상품 상세 설명',
  `pickup_start_at` DATETIME NOT NULL COMMENT '픽업 시작 시간',
  `pickup_end_at` DATETIME NOT NULL COMMENT '픽업 종료 시간',
  `status` VARCHAR(20) NOT NULL COMMENT '판매 상태 (ON_SALE, SOLD_OUT)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
  PRIMARY KEY (`product_id`),
  INDEX `fk_product_store_idx` (`store_id` ASC) VISIBLE,
  CONSTRAINT `fk_product_store`
    FOREIGN KEY (`store_id`)
    REFERENCES `store` (`store_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '판매 상품 정보';


-- -----------------------------------------------------
-- 4. 주문 (ORDERS)
-- -----------------------------------------------------
CREATE TABLE `orders` (
  `order_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '주문 고유 ID',
  `user_id` BIGINT NOT NULL COMMENT '주문한 고객 ID (USER 테이블 FK)',
  `product_id` BIGINT NOT NULL COMMENT '주문한 상품 ID (PRODUCT 테이블 FK)',
  `pickup_code` VARCHAR(50) NOT NULL COMMENT '픽업 시 확인할 고유 코드',
  `scheduled_pickup_at` DATETIME NOT NULL COMMENT '고객이 지정한 픽업 예정 시간',
  `total_price` INT NOT NULL COMMENT '최종 결제 금액',
  `donation_amount` INT NOT NULL COMMENT '해당 주문으로 발생한 기부 금액',
  `status` VARCHAR(20) NOT NULL COMMENT '주문 상태 (PAID, COMPLETED, CANCELLED)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '주문(결제) 일시',
  `completed_at` DATETIME NULL COMMENT '픽업 완료 일시',
  PRIMARY KEY (`order_id`),
  UNIQUE INDEX `pickup_code_UNIQUE` (`pickup_code` ASC) VISIBLE,
  INDEX `fk_orders_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_orders_product_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_orders_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_product`
    FOREIGN KEY (`product_id`)
    REFERENCES `product` (`product_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '주문 내역';


-- -----------------------------------------------------
-- 5. 리뷰 (REVIEW)
-- -----------------------------------------------------
CREATE TABLE `review` (
  `review_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '리뷰 고유 ID',
  `user_id` BIGINT NOT NULL COMMENT '작성자 ID (USER 테이블 FK)',
  `store_id` BIGINT NOT NULL COMMENT '리뷰 대상 빵집 ID (STORE 테이블 FK)',
  `order_id` BIGINT NOT NULL COMMENT '관련 주문 ID (ORDERS 테이블 FK)',
  `rating` TINYINT NOT NULL COMMENT '별점 (1~5)',
  `content` TEXT NULL COMMENT '리뷰 내용',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
  PRIMARY KEY (`review_id`),
  UNIQUE INDEX `order_id_UNIQUE` (`order_id` ASC) VISIBLE COMMENT '주문 당 1개의 리뷰만 작성 가능',
  INDEX `fk_review_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_review_store_idx` (`store_id` ASC) VISIBLE,
  CONSTRAINT `fk_review_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_review_store`
    FOREIGN KEY (`store_id`)
    REFERENCES `store` (`store_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_review_order`
    FOREIGN KEY (`order_id`)
    REFERENCES `orders` (`order_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '가게 리뷰';


-- -----------------------------------------------------
-- 6. 가게별 월간 기부 통계 (STORE_DONATION_STATS)
-- -----------------------------------------------------
CREATE TABLE `store_donation_stats` (
  `stat_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '통계 고유 ID',
  `store_id` BIGINT NOT NULL COMMENT '가게 ID (STORE 테이블 FK)',
  `year_month` VARCHAR(7) NOT NULL COMMENT '통계 연월 (예: 2025-07)',
  `donation_rate` TINYINT NOT NULL COMMENT '사장님이 설정한 월별 기부율 (%)',
  `total_sales` BIGINT NOT NULL DEFAULT 0 COMMENT '해당 월 총매출액',
  `total_donation` BIGINT NOT NULL DEFAULT 0 COMMENT '해당 월 누적 기부액',
  PRIMARY KEY (`stat_id`),
  UNIQUE INDEX `store_year_month_UNIQUE` (`store_id` ASC, `year_month` ASC) VISIBLE,
  CONSTRAINT `fk_stats_store`
    FOREIGN KEY (`store_id`)
    REFERENCES `store` (`store_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '가게별 월간 기부 통계';


-- -----------------------------------------------------
-- 7. 전체 기부금 관리 (DONATION_POOL)
-- -----------------------------------------------------
CREATE TABLE `donation_pool` (
  `pool_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '기부금 풀 ID',
  `total_amount` BIGINT NOT NULL COMMENT '현재까지 누적된 전체 기부금',
  `updated_at` DATETIME NOT NULL COMMENT '최종 업데이트 일시',
  PRIMARY KEY (`pool_id`))
ENGINE = InnoDB
COMMENT = '전체 누적 기부금 관리';


-- -----------------------------------------------------
-- 8. 기부금 집행 내역 (DONATION_HISTORY)
-- -----------------------------------------------------
CREATE TABLE `donation_history` (
  `history_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '집행 내역 ID',
  `amount` BIGINT NOT NULL COMMENT '집행한 기부 금액',
  `recipient` VARCHAR(100) NOT NULL COMMENT '기부처 (예: 기아대책)',
  `donated_at` DATETIME NOT NULL COMMENT '집행 일시',
  `notes` TEXT NULL COMMENT '증빙 자료 링크 등 비고',
  PRIMARY KEY (`history_id`))
ENGINE = InnoDB
COMMENT = '기부금 집행 내역';


-- -----------------------------------------------------
-- 9. 즐겨찾기 (FAVORITE)
-- -----------------------------------------------------
CREATE TABLE `favorite` (
  `favorite_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '즐겨찾기 고유 ID',
  `user_id` BIGINT NOT NULL COMMENT '사용자 ID (USER 테이블 FK)',
  `store_id` BIGINT NOT NULL COMMENT '가게 ID (STORE 테이블 FK)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '즐겨찾기 추가 일시',
  PRIMARY KEY (`favorite_id`),
  UNIQUE INDEX `user_store_UNIQUE` (`user_id` ASC, `store_id` ASC) VISIBLE COMMENT '한 사용자는 한 가게를 한 번만 즐겨찾기 가능',
  INDEX `fk_favorite_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_favorite_store_idx` (`store_id` ASC) VISIBLE,
  CONSTRAINT `fk_favorite_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_favorite_store`
    FOREIGN KEY (`store_id`)
    REFERENCES `store` (`store_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '사용자별 즐겨찾기 가게';


-- -----------------------------------------------------
-- 10. 채팅방 (CHAT_ROOM)
-- -----------------------------------------------------
CREATE TABLE `chat_room` (
  `chat_room_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '채팅방 고유 ID',
  `order_id` BIGINT NOT NULL COMMENT '연관된 주문 ID (ORDERS 테이블 FK)',
  `user_id` BIGINT NOT NULL COMMENT '고객 ID (USER 테이블 FK)',
  `store_id` BIGINT NOT NULL COMMENT '가게 ID (STORE 테이블 FK)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '채팅방 생성 일시',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '마지막 메시지 시간 (정렬용)',
  PRIMARY KEY (`chat_room_id`),
  UNIQUE INDEX `order_id_UNIQUE` (`order_id` ASC) VISIBLE COMMENT '주문 당 1개의 채팅방만 생성 가능',
  INDEX `fk_chatroom_order_idx` (`order_id` ASC) VISIBLE,
  INDEX `fk_chatroom_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_chatroom_store_idx` (`store_id` ASC) VISIBLE,
  CONSTRAINT `fk_chatroom_order`
    FOREIGN KEY (`order_id`)
    REFERENCES `orders` (`order_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_chatroom_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_chatroom_store`
    FOREIGN KEY (`store_id`)
    REFERENCES `store` (`store_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '주문 기반 채팅방';


-- -----------------------------------------------------
-- 11. 채팅 메시지 (CHAT_MESSAGE)
-- -----------------------------------------------------
CREATE TABLE `chat_message` (
  `chat_message_id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '채팅 메시지 고유 ID',
  `chat_room_id` BIGINT NOT NULL COMMENT '채팅방 ID (CHAT_ROOM 테이블 FK)',
  `sender_id` BIGINT NOT NULL COMMENT '발신자 ID (USER 테이블 FK, 고객 또는 점주)',
  `message` TEXT NOT NULL COMMENT '메시지 내용',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '수신자 읽음 여부 (0: 안읽음, 1: 읽음)',
  `sent_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '메시지 발신 일시',
  PRIMARY KEY (`chat_message_id`),
  INDEX `fk_chatmessage_chatroom_idx` (`chat_room_id` ASC) VISIBLE,
  INDEX `fk_chatmessage_sender_idx` (`sender_id` ASC) VISIBLE,
  CONSTRAINT `fk_chatmessage_chatroom`
    FOREIGN KEY (`chat_room_id`)
    REFERENCES `chat_room` (`chat_room_id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_chatmessage_sender`
    FOREIGN KEY (`sender_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE CASCADE ON UPDATE CASCADE)
ENGINE = InnoDB
COMMENT = '채팅 메시지 내역';