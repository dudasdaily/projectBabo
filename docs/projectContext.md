프로젝트 요약 및 최종 설계안
프로젝트명: 마감 할인 빵집 플랫폼 (기부 기능 특화)

백엔드: Spring Boot

1. 최종 데이터베이스 스키마 (MySQL)
SQL

CREATE DATABASE IF NOT EXISTS rebread_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rebread_db;

-- 1. 사용자 (USER)
CREATE TABLE `user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `phone_number` VARCHAR(20) NOT NULL UNIQUE,
  `role` VARCHAR(20) NOT NULL COMMENT 'CUSTOMER, OWNER, ADMIN',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB;

-- 2. 빵집 (STORE)
CREATE TABLE `store` (
  `store_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `latitude` DECIMAL(10, 8) NOT NULL,
  `longitude` DECIMAL(11, 8) NOT NULL,
  `phone_number` VARCHAR(20) NULL,
  `description` TEXT NULL,
  `status` VARCHAR(20) NOT NULL COMMENT 'PENDING, APPROVED, REJECTED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`store_id`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. 상품 (PRODUCT)
CREATE TABLE `product` (
  `product_id` BIGINT NOT NULL AUTO_INCREMENT,
  `store_id` BIGINT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `original_price` INT NOT NULL,
  `discount_price` INT NOT NULL,
  `quantity` INT NOT NULL,
  `description` TEXT NULL,
  `pickup_start_at` DATETIME NOT NULL,
  `pickup_end_at` DATETIME NOT NULL,
  `status` VARCHAR(20) NOT NULL COMMENT 'ON_SALE, SOLD_OUT',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. 주문 (ORDERS)
CREATE TABLE `orders` (
  `order_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `product_id` BIGINT NOT NULL,
  `pickup_code` VARCHAR(50) NOT NULL UNIQUE,
  `scheduled_pickup_at` DATETIME NOT NULL,
  `total_price` INT NOT NULL,
  `donation_amount` INT NOT NULL,
  `status` VARCHAR(20) NOT NULL COMMENT 'PAID, COMPLETED, CANCELLED',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` DATETIME NULL,
  PRIMARY KEY (`order_id`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `product`(`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. 리뷰 (REVIEW)
CREATE TABLE `review` (
  `review_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `store_id` BIGINT NOT NULL,
  `order_id` BIGINT NOT NULL UNIQUE,
  `rating` TINYINT NOT NULL,
  `content` TEXT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`) ON DELETE CASCADE,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. 가게별 월간 기부 통계 (STORE_DONATION_STATS)
CREATE TABLE `store_donation_stats` (
  `stat_id` BIGINT NOT NULL AUTO_INCREMENT,
  `store_id` BIGINT NOT NULL,
  `year_month` VARCHAR(7) NOT NULL,
  `donation_rate` TINYINT NOT NULL,
  `total_sales` BIGINT NOT NULL DEFAULT 0,
  `total_donation` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`stat_id`),
  UNIQUE KEY `store_year_month_UNIQUE` (`store_id`, `year_month`),
  FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. 전체 기부금 관리 (DONATION_POOL)
CREATE TABLE `donation_pool` (
  `pool_id` BIGINT NOT NULL AUTO_INCREMENT,
  `total_amount` BIGINT NOT NULL,
  `updated_at` DATETIME NOT NULL,
  PRIMARY KEY (`pool_id`)
) ENGINE=InnoDB;

-- 8. 기부금 집행 내역 (DONATION_HISTORY)
CREATE TABLE `donation_history` (
  `history_id` BIGINT NOT NULL AUTO_INCREMENT,
  `amount` BIGINT NOT NULL,
  `recipient` VARCHAR(100) NOT NULL,
  `donated_at` DATETIME NOT NULL,
  `notes` TEXT NULL,
  PRIMARY KEY (`history_id`)
) ENGINE=InnoDB;

-- 9. 즐겨찾기 (FAVORITE)
CREATE TABLE `favorite` (
  `favorite_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `store_id` BIGINT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`favorite_id`),
  UNIQUE KEY `user_store_UNIQUE` (`user_id`, `store_id`),
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. 채팅방 (CHAT_ROOM)
CREATE TABLE `chat_room` (
  `chat_room_id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL UNIQUE,
  `user_id` BIGINT NOT NULL,
  `store_id` BIGINT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_room_id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 11. 채팅 메시지 (CHAT_MESSAGE)
CREATE TABLE `chat_message` (
  `chat_message_id` BIGINT NOT NULL AUTO_INCREMENT,
  `chat_room_id` BIGINT NOT NULL,
  `sender_id` BIGINT NOT NULL,
  `message` TEXT NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `sent_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_message_id`),
  FOREIGN KEY (`chat_room_id`) REFERENCES `chat_room`(`chat_room_id`) ON DELETE CASCADE,
  FOREIGN KEY (`sender_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

2. 핵심 기능 요구사항
기부 기능:

상품 등록 시 최소 30% 할인율 강제.

점주는 월별로 판매 수익금의 기부율(%)을 설정 가능.

가게 목록 조회 시, '이달의 기부율 높은 가게'와 '이달의 기부액 높은 가게'를 최상단에 고정 노출.

즐겨찾기 기능:

고객은 원하는 가게를 즐겨찾기(찜) 할 수 있음.

채팅 기능:

고객과 점주는 주문에 대해 1:1 채팅을 할 수 있음.