package com.rebread.rebread.user;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum Role {

    CUSTOMER("ROLE_CUSTOMER", "고객"),
    OWNER("ROLE_OWNER", "점주"),
    ADMIN("ROLE_ADMIN", "관리자");

    private final String key;
    private final String title;
}