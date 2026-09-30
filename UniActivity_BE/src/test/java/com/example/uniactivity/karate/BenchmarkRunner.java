package com.example.uniactivity.karate;

import com.intuit.karate.junit5.Karate;

class BenchmarkRunner {

    @Karate.Test
    Karate benchmarkCreateAndRegister() {
        return Karate.run("benchmark-create-and-register").relativeTo(getClass());
    }
}