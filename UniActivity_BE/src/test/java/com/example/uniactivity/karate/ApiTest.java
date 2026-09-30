package com.example.uniactivity.karate;

import com.intuit.karate.junit5.Karate;

class ApiTest {

    @Karate.Test
    Karate testApi() {
        return Karate.run("auth", "profile", "admin-catalog", "admin-users", "activities", "manager", "student", "evidence")
                .relativeTo(getClass());
    }
}
