package com.rebread.common;

import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Getter
@MappedSuperclass // 이 클래스를 상속하는 엔티티는 아래 필드들을 컬럼으로 인식합니다.
@EntityListeners(AuditingEntityListener.class) // Auditing 기능을 엔티티에 적용합니다.
public abstract class BaseTimeEntity {
    @CreatedDate // 엔티티가 생성되어 저장될 때 시간이 자동 저장됩니다.
    private LocalDateTime createdAt;

    @LastModifiedDate // 조회한 엔티티의 값을 변경할 때 시간이 자동 저장됩니다.
    private LocalDateTime updatedAt;
}