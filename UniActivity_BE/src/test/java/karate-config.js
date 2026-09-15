function fn() {
  var suffix = java.lang.System.currentTimeMillis().toString();
  var values = {
    baseUrl: karate.properties['baseUrl'] || 'http://127.0.0.1:8080',
    admin: { username: 'admin', password: 'admin123' },
    test: {
      suffix: suffix,
      password: 'Karate123@',
      resetPassword: 'Karate456@',
      studentAEmail: 'karate-a-' + suffix + '@example.test',
      studentBEmail: 'karate-b-' + suffix + '@example.test'
    }
  };
  var setup = karate.callSingle('classpath:com/example/uniactivity/karate/helpers/setup.feature', values);
  return { config: values, baseUrl: values.baseUrl, admin: values.admin, test: values.test, fixture: setup.fixture };
}
