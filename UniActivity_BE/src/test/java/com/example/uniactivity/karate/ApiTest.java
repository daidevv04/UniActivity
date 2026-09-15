package com.example.uniactivity.karate;

import com.intuit.karate.junit5.Karate;

class ApiTest {

    @Karate.Test
    Karate testApi() {
        return Karate.run("auth", "admin-catalog", "admin-users", "activities", "student")
                .relativeTo(getClass());
    }
}
