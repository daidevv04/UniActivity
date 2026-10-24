package com.example.uniactivity.karate;

import com.intuit.karate.junit5.Karate;

/**
 * Chạy 50 test case API (10 feature) trong MỘT lượt để karate-summary.html gộp đủ 10 feature.
 * Yêu cầu backend tại http://127.0.0.1:8080 (đổi bằng -DbaseUrl=...).
 * Chạy lẻ một feature: -Dfeature=student
 * Báo cáo: target/karate-reports/karate-summary.html
 */
class ApiTest {

    private static final String BASE = "classpath:com/example/uniactivity/karate/";

    private static final String[] FEATURES = {
            BASE + "auth.feature",
            BASE + "profile.feature",
            BASE + "admin-catalog.feature",
            BASE + "admin-users.feature",
            BASE + "activities.feature",
            BASE + "student.feature",
            BASE + "evidence.feature",
            BASE + "manager.feature",
            BASE + "sse.feature",
            BASE + "report.feature"
    };

    @Karate.Test
    Karate all() {
        String only = System.getProperty("feature");
        if (only != null && !only.isBlank()) {
            return Karate.run(BASE + only.trim() + ".feature");
        }
        return Karate.run(FEATURES);
    }
}
