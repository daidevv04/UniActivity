# UniActivity Project Hardening and Quality Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the remaining database-query bottlenecks and schema drift, make production configuration safe, improve frontend reliability/accessibility/performance, and enforce all checks in CI.

**Architecture:** Keep the existing Spring Boot layered architecture and React/Vite SPA. Replace per-row activity statistics queries with one aggregate query, make Flyway the sole schema authority, isolate environment-specific configuration, consolidate HTTP access behind one client, and introduce focused frontend unit/E2E tests. Each task is independently reviewable and should be committed separately.

**Tech Stack:** Java 21, Spring Boot 3.5, Spring Data JPA, Flyway, MySQL 8, JUnit 5, Mockito, React 19, Vite 7, Vitest, Testing Library, Playwright, ESLint, GitHub Actions.

## Global Constraints

- Preserve all existing API URLs and response payloads unless a task explicitly states otherwise.
- Do not weaken JWT, role, class-scope, OTP, upload, QR, or score-integrity checks.
- Use Flyway as the only production schema migration mechanism; keep `ddl-auto=validate`.
- Add regression tests before production-code changes.
- Run the full backend and frontend verification suites before merging each subsystem.
- Do not commit `.env`, credentials, generated `target/`, `dist/`, Playwright reports, or test videos.

---

## Delivery order

1. Tasks 1–3: backend query and production configuration.
2. Task 4: canonical Flyway schema.
3. Tasks 5–8: frontend correctness, accessibility, and performance.
4. Tasks 9–10: automated tests and CI enforcement.

Tasks 1 and 2 may be implemented together. Task 4 must be reviewed separately because it changes database bootstrap behavior. Tasks 5–8 can be merged independently after Task 5 establishes the shared HTTP client.

---

### Task 1: Batch activity statistics and eliminate the remaining N+1 queries

**Files:**
- Modify: `UniActivity_BE/src/main/java/com/example/uniactivity/repository/ActivitySlotRepository.java`
- Modify: `UniActivity_BE/src/main/java/com/example/uniactivity/repository/ActivityRegistrationRepository.java`
- Modify: `UniActivity_BE/src/main/java/com/example/uniactivity/service/ActivityService.java`
- Create: `UniActivity_BE/src/test/java/com/example/uniactivity/service/ActivityServiceQueryBatchingTest.java`

**Interfaces:**
- Produces: `ActivitySlotRepository.ActivitySlotTotals#getActivityId/getMaxSlots/getRegisteredCount`.
- Produces: `ActivityRegistrationRepository.ActivityAttendanceTotal#getActivityId/getCheckedInCount`.
- Produces: private `ActivityService.enrichActivitiesWithStats(List<ActivityResponseDto>, List<Activity>)`.
- Preserves: existing `ActivityResponseDto` JSON fields.

- [ ] **Step 1: Write a failing batching test**

Create a Mockito test with three activities. Stub the aggregate repository methods once, call `getAllActivities()`, and verify that neither `findByActivityId` nor `countByActivityAndStatus` is invoked per activity:

```java
@ExtendWith(MockitoExtension.class)
class ActivityServiceQueryBatchingTest {
    @Mock ActivityRepository activityRepository;
    @Mock ActivitySlotRepository activitySlotRepository;
    @Mock ActivityRegistrationRepository activityRegistrationRepository;
    @Mock ActivityMapper activityMapper;
    @Mock ScoreOptionRepository scoreOptionRepository;
    @Mock SemesterRepository semesterRepository;
    @Mock FacultyRepository facultyRepository;
    @Mock AcademicYearRepository academicYearRepository;
    @Mock StudentClassRepository studentClassRepository;
    @Mock UserRepository userRepository;
    @Mock NotificationService notificationService;
    @Mock SseEmitterService sseEmitterService;
    @Mock TransactionTemplate transactionTemplate;
    @InjectMocks ActivityService service;

    @Test
    void getAllActivitiesLoadsStatisticsInTwoBatchQueries() {
        Activity first = new Activity();
        first.setId(1L);
        Activity second = new Activity();
        second.setId(2L);
        ActivityResponseDto firstDto = new ActivityResponseDto();
        ActivityResponseDto secondDto = new ActivityResponseDto();

        ActivitySlotRepository.ActivitySlotTotals firstSlots = mock(ActivitySlotRepository.ActivitySlotTotals.class);
        when(firstSlots.getActivityId()).thenReturn(1L);
        when(firstSlots.getMaxSlots()).thenReturn(20L);
        when(firstSlots.getRegisteredCount()).thenReturn(7L);
        ActivitySlotRepository.ActivitySlotTotals secondSlots = mock(ActivitySlotRepository.ActivitySlotTotals.class);
        when(secondSlots.getActivityId()).thenReturn(2L);
        when(secondSlots.getMaxSlots()).thenReturn(30L);
        when(secondSlots.getRegisteredCount()).thenReturn(9L);
        ActivityRegistrationRepository.ActivityAttendanceTotal firstAttendance = mock(ActivityRegistrationRepository.ActivityAttendanceTotal.class);
        when(firstAttendance.getActivityId()).thenReturn(1L);
        when(firstAttendance.getCheckedInCount()).thenReturn(3L);
        ActivityRegistrationRepository.ActivityAttendanceTotal secondAttendance = mock(ActivityRegistrationRepository.ActivityAttendanceTotal.class);
        when(secondAttendance.getActivityId()).thenReturn(2L);
        when(secondAttendance.getCheckedInCount()).thenReturn(4L);

        when(activityRepository.findAllWithDetailsOrderByCreatedAtDesc())
                .thenReturn(List.of(first, second));
        when(activityMapper.toResponseDto(first)).thenReturn(firstDto);
        when(activityMapper.toResponseDto(second)).thenReturn(secondDto);
        when(activitySlotRepository.sumTotalsByActivityIds(List.of(1L, 2L)))
                .thenReturn(List.of(firstSlots, secondSlots));
        when(activityRegistrationRepository.countAttendanceByActivityIds(
                List.of(1L, 2L), RegistrationStatus.ATTENDED))
                .thenReturn(List.of(firstAttendance, secondAttendance));

        List<ActivityResponseDto> result = service.getAllActivities();

        assertThat(result.get(0).getMaxSlots()).isEqualTo(20);
        assertThat(result.get(0).getRegisteredCount()).isEqualTo(7);
        assertThat(result.get(0).getCheckedInCount()).isEqualTo(3);
        verify(activitySlotRepository, never()).findByActivityId(anyLong());
        verify(activityRegistrationRepository, never()).countByActivityAndStatus(any(), any());
    }
}
```

- [ ] **Step 2: Run the test and confirm the current implementation fails**

Run:

```bash
cd UniActivity_BE
./mvnw -Dtest=ActivityServiceQueryBatchingTest test
```

Expected: FAIL because the aggregate repository methods do not exist and the current service performs per-activity calls.

- [ ] **Step 3: Add aggregate projections and queries**

Add to `ActivitySlotRepository`:

```java
interface ActivitySlotTotals {
    Long getActivityId();
    Long getMaxSlots();
    Long getRegisteredCount();
}

@Query("""
    select s.activity.id as activityId,
           coalesce(sum(s.maxQuantity), 0) as maxSlots,
           coalesce(sum(s.currentQuantity), 0) as registeredCount
    from ActivitySlot s
    where s.activity.id in :activityIds
    group by s.activity.id
    """)
List<ActivitySlotTotals> sumTotalsByActivityIds(@Param("activityIds") Collection<Long> activityIds);
```

Add to `ActivityRegistrationRepository`:

```java
interface ActivityAttendanceTotal {
    Long getActivityId();
    Long getCheckedInCount();
}

@Query("""
    select r.activity.id as activityId, count(r.id) as checkedInCount
    from ActivityRegistration r
    where r.activity.id in :activityIds and r.status = :status
    group by r.activity.id
    """)
List<ActivityAttendanceTotal> countAttendanceByActivityIds(
        @Param("activityIds") Collection<Long> activityIds,
        @Param("status") RegistrationStatus status);
```

- [ ] **Step 4: Replace per-activity enrichment with batch maps**

In `ActivityService`, map all entities to DTOs first, then make exactly two aggregate calls. Empty input must return immediately to avoid an invalid `IN ()` query:

```java
private List<ActivityResponseDto> mapActivitiesWithStats(List<Activity> activities) {
    if (activities.isEmpty()) {
        return List.of();
    }

    List<Long> ids = activities.stream().map(Activity::getId).toList();
    Map<Long, ActivitySlotRepository.ActivitySlotTotals> slotsByActivity =
            activitySlotRepository.sumTotalsByActivityIds(ids).stream()
                    .collect(Collectors.toMap(
                            ActivitySlotRepository.ActivitySlotTotals::getActivityId,
                            Function.identity()));
    Map<Long, Long> attendanceByActivity =
            activityRegistrationRepository.countAttendanceByActivityIds(ids, RegistrationStatus.ATTENDED)
                    .stream()
                    .collect(Collectors.toMap(
                            ActivityRegistrationRepository.ActivityAttendanceTotal::getActivityId,
                            ActivityRegistrationRepository.ActivityAttendanceTotal::getCheckedInCount));

    return activities.stream().map(activity -> {
        ActivityResponseDto dto = activityMapper.toResponseDto(activity);
        var totals = slotsByActivity.get(activity.getId());
        dto.setMaxSlots(totals == null ? 0 : Math.toIntExact(totals.getMaxSlots()));
        dto.setRegisteredCount(totals == null ? 0 : Math.toIntExact(totals.getRegisteredCount()));
        dto.setCheckedInCount(Math.toIntExact(attendanceByActivity.getOrDefault(activity.getId(), 0L)));
        dto.setIsDeadlinePassed(activity.getRegistrationDeadline() != null
                && activity.getRegistrationDeadline().isBefore(LocalDateTime.now()));
        dto.setIsEnded(activity.getEndTime() != null
                && activity.getEndTime().isBefore(LocalDateTime.now()));
        return dto;
    }).toList();
}
```

Use this method from `getAllActivities()` and the paged/list variants. For `Page<ActivityResponseDto>`, batch-enrich `page.getContent()` and return `new PageImpl<>(dtos, pageable, page.getTotalElements())`.

- [ ] **Step 5: Push activity visibility filtering into the database**

Add a repository query accepting the student's class, faculty, and academic-year IDs, using `exists` against `ActivitySlot`. Return only visible activities instead of loading every activity and calling `isActivityVisibleToStudent` in Java. Preserve the current slot matching rule: each non-null slot dimension must match.

Add a service test verifying that `getVisibleActivitiesForStudent` calls the scoped repository method and never calls `activitySlotRepository.findByActivityId` for visibility filtering.

- [ ] **Step 6: Run focused and full backend tests**

Run:

```bash
cd UniActivity_BE
./mvnw -Dtest=ActivityServiceQueryBatchingTest,ActivityVisibilityScopeTest test
./mvnw test
```

Expected: focused tests PASS; full suite reports `0` failures and `0` errors.

- [ ] **Step 7: Commit**

```bash
git add UniActivity_BE/src/main/java/com/example/uniactivity/repository/ActivitySlotRepository.java UniActivity_BE/src/main/java/com/example/uniactivity/repository/ActivityRegistrationRepository.java UniActivity_BE/src/main/java/com/example/uniactivity/repository/ActivityRepository.java UniActivity_BE/src/main/java/com/example/uniactivity/service/ActivityService.java UniActivity_BE/src/test/java/com/example/uniactivity/service/ActivityServiceQueryBatchingTest.java
git commit -m "perf: batch activity statistics queries"
```

---

### Task 2: Add pagination and query limits to remaining unbounded list endpoints

**Files:**
- Modify: repositories returning unbounded activity, request, registration, notification, class, faculty, semester, and user lists under `UniActivity_BE/src/main/java/com/example/uniactivity/repository/`
- Modify: matching controllers under `UniActivity_BE/src/main/java/com/example/uniactivity/controller/`
- Modify: matching frontend list pages under `UniActivity_FE/src/pages/`
- Create: `UniActivity_BE/src/test/java/com/example/uniactivity/controller/PaginationContractTest.java`

**Interfaces:**
- Consumes: Spring `Pageable` and `Page<T>`.
- Produces: `{content,totalElements,totalPages,number,size}` for list endpoints.
- Preserves: temporary `page=0&size=20` defaults so existing callers continue working.

- [ ] **Step 1: Inventory all unbounded endpoint-to-repository paths**

Run:

```bash
rg -n "List<|findAll\(" UniActivity_BE/src/main/java/com/example/uniactivity/controller UniActivity_BE/src/main/java/com/example/uniactivity/service
```

Create a checklist in the commit message or PR description. Exclude small reference tables only when an explicit maximum is enforced by the domain.

- [ ] **Step 2: Write API contract tests**

For each user-facing list family, add MockMvc assertions that default pagination is bounded and `size` is capped at 100:

```java
mockMvc.perform(get("/manager/api/point-requests")
        .param("page", "0")
        .param("size", "500")
        .with(user(managerDetails)))
    .andExpect(status().isOk())
    .andExpect(jsonPath("$.size").value(100))
    .andExpect(jsonPath("$.content").isArray());
```

- [ ] **Step 3: Add a shared page-request factory**

Create `controller/support/PageRequests.java`:

```java
public final class PageRequests {
    private static final int MAX_SIZE = 100;

    private PageRequests() {}

    public static Pageable of(int page, int size, Sort sort) {
        return PageRequest.of(Math.max(page, 0), Math.clamp(size, 1, MAX_SIZE), sort);
    }
}
```

Use stable sorts ending in `id DESC` to prevent duplicate/missing rows between pages.

- [ ] **Step 4: Convert repository/service/controller methods one endpoint family at a time**

Use `Page<T>` repositories and map entities to DTOs inside the service. Do not return JPA entities. Update frontend pages to read `data.content` and render pagination from `totalPages`/`number`.

- [ ] **Step 5: Verify and commit**

```bash
cd UniActivity_BE
./mvnw -Dtest=PaginationContractTest test
./mvnw test
cd ../UniActivity_FE
npm run lint
npm run build
git add UniActivity_BE/src UniActivity_FE/src
git commit -m "perf: bound list endpoints with pagination"
```

Expected: all commands exit `0`; ESLint has no newly introduced warnings.

---

### Task 3: Split local and production configuration and disable unsafe ORM defaults

**Files:**
- Modify: `UniActivity_BE/src/main/resources/application.properties`
- Create: `UniActivity_BE/src/main/resources/application-local.properties`
- Create: `UniActivity_BE/src/main/resources/application-prod.properties`
- Modify: `UniActivity_BE/src/main/java/com/example/uniactivity/config/SecurityConfig.java`
- Modify: `UniActivity_BE/.env.example`
- Create: `UniActivity_BE/src/test/java/com/example/uniactivity/config/ProductionConfigurationTest.java`

**Interfaces:**
- Produces properties `app.frontend.url`, `app.cors.allowed-origins`, and `app.oauth.google.redirect-uri`.
- Production requires environment variables `FRONTEND_URL`, `CORS_ALLOWED_ORIGINS`, and `GOOGLE_REDIRECT_URI`.

- [ ] **Step 1: Write a production configuration test**

Use `ApplicationContextRunner` or a focused configuration test to verify multiple comma-separated origins are bound, and assert the production resource contains:

```properties
spring.jpa.show-sql=false
spring.jpa.open-in-view=false
spring.thymeleaf.check-template-location=false
```

- [ ] **Step 2: Run the test and confirm it fails**

```bash
cd UniActivity_BE
./mvnw -Dtest=ProductionConfigurationTest test
```

Expected: FAIL because origins are hardcoded and the production profile does not exist.

- [ ] **Step 3: Move local-only values into `application-local.properties`**

```properties
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.thymeleaf.cache=false
app.frontend.url=http://localhost:5173
app.cors.allowed-origins=http://localhost:5173
spring.security.oauth2.client.registration.google.redirect-uri=http://localhost:8080/login/oauth2/code/google
```

Keep shared datasource/JWT/QR/mail settings in `application.properties`, all backed by environment variables.

- [ ] **Step 4: Add production settings**

```properties
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=false
spring.jpa.open-in-view=false
spring.thymeleaf.cache=true
spring.thymeleaf.check-template-location=false
app.frontend.url=${FRONTEND_URL}
app.cors.allowed-origins=${CORS_ALLOWED_ORIGINS}
spring.security.oauth2.client.registration.google.redirect-uri=${GOOGLE_REDIRECT_URI}
server.forward-headers-strategy=framework
server.servlet.session.cookie.secure=true
server.servlet.session.cookie.http-only=true
```

- [ ] **Step 5: Bind CORS origins instead of hardcoding them**

```java
@ConfigurationProperties(prefix = "app.cors")
public record CorsProperties(List<String> allowedOrigins) {}
```

Inject `CorsProperties` into `SecurityConfig` and use `configuration.setAllowedOrigins(properties.allowedOrigins())`. Keep credentials enabled only for exact configured origins; never use `*` with credentials.

- [ ] **Step 6: Update `.env.example`, verify, and commit**

Document names only, with non-secret examples:

```dotenv
SPRING_PROFILES_ACTIVE=local
FRONTEND_URL=https://activity.example.edu.vn
CORS_ALLOWED_ORIGINS=https://activity.example.edu.vn
GOOGLE_REDIRECT_URI=https://api.activity.example.edu.vn/login/oauth2/code/google
```

Run:

```bash
cd UniActivity_BE
./mvnw -Dtest=ProductionConfigurationTest,SecretSeparationValidatorTest test
./mvnw test
git add src/main/resources src/main/java/com/example/uniactivity/config .env.example src/test/java/com/example/uniactivity/config/ProductionConfigurationTest.java
git commit -m "config: isolate production runtime settings"
```

---

### Task 4: Make Flyway the canonical schema source for both fresh and existing MySQL databases

**Files:**
- Create: `UniActivity_BE/src/main/resources/db/migration/V1__baseline_schema.sql`
- Modify: `UniActivity_BE/src/main/resources/db/migration/V2__security_integrity_constraints.sql`
- Modify: `database_schema.sql`
- Create: `UniActivity_BE/src/test/java/com/example/uniactivity/migration/FreshMySqlMigrationTest.java`
- Modify: `UniActivity_BE/pom.xml`
- Modify: `docs/account-code-migration-runbook.md`

**Interfaces:**
- Produces: a fresh empty MySQL 8 database that can migrate from V1 through V6.
- Preserves: `baseline-on-migrate=true` and `baseline-version=1` for existing non-empty databases.

- [ ] **Step 1: Add a failing Testcontainers migration test**

Add test-scoped Testcontainers MySQL dependencies and create a test which starts `mysql:8.4`, runs Flyway against an empty database, then verifies required tables and final constraints:

```java
@Testcontainers(disabledWithoutDocker = true)
class FreshMySqlMigrationTest {
    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.4");

    @Test
    void emptyDatabaseMigratesThroughLatestVersion() throws Exception {
        Flyway flyway = Flyway.configure()
                .dataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword())
                .locations("classpath:db/migration")
                .load();

        MigrateResult result = flyway.migrate();

        assertThat(result.success).isTrue();
        assertThat(result.targetSchemaVersion).hasToString("6");
        assertColumn("classes", "join_code", 6, false);
        assertConstraintExists("classes", "uk_classes_join_code");
        assertConstraintExists("users", "chk_users_non_admin_account_code");
    }
}
```

- [ ] **Step 2: Confirm the empty-database test fails**

```bash
cd UniActivity_BE
./mvnw -Dtest=FreshMySqlMigrationTest test
```

Expected: FAIL because there is no V1 migration creating the base tables.

- [ ] **Step 3: Create V1 from the base schema**

Copy only DDL needed before V2 from `database_schema.sql`. Remove `CREATE DATABASE`, `USE`, sample users, password hashes, and all seed data. Ensure every FK referenced by V2–V6 exists. V1 must represent the historical pre-V2 schema so later migrations remain valid; do not prematurely add V2–V6 columns or constraints.

- [ ] **Step 4: Turn the root SQL file into an explicit development-only pointer**

Replace `database_schema.sql` with comments that direct users to run Flyway through the application. Do not maintain a second copy of schema DDL:

```sql
-- Canonical schema: UniActivity_BE/src/main/resources/db/migration/
-- Start the Spring Boot application with an empty database; Flyway applies V1+.
-- This file intentionally contains no DDL or credentials.
```

- [ ] **Step 5: Test both fresh and baselined upgrade paths**

Add a second Testcontainers case that creates a minimal legacy V1 schema without `flyway_schema_history`, invokes Flyway with baseline version 1, and verifies V2–V6 complete without rerunning V1.

- [ ] **Step 6: Verify and commit**

```bash
cd UniActivity_BE
./mvnw -Dtest=FreshMySqlMigrationTest,V4__normalize_non_admin_account_codesTest,V5__enforce_non_admin_account_codesTest,V6__normalize_class_join_codesTest test
./mvnw test
git add pom.xml src/main/resources/db/migration src/test/java/com/example/uniactivity/migration ../../database_schema.sql ../../docs/account-code-migration-runbook.md
git commit -m "db: make flyway schema bootstrap canonical"
```

---

### Task 5: Consolidate authentication and HTTP error handling behind one explicit client

**Files:**
- Modify: `UniActivity_FE/src/utils/api.js`
- Delete: `UniActivity_FE/src/utils/fetchInterceptor.js`
- Modify: `UniActivity_FE/src/main.jsx`
- Modify: all files under `UniActivity_FE/src/` that call same-origin `fetch`
- Create: `UniActivity_FE/src/utils/api.test.js`

**Interfaces:**
- Produces: `apiFetch(url, options) -> Promise<Response>`.
- Produces: `fetchJson(url, options) -> Promise<unknown>` throwing `ApiError`.
- Produces: `ApiError { status, message, payload }`.

- [ ] **Step 1: Install and configure Vitest for utility tests**

Add scripts:

```json
"test": "vitest run",
"test:watch": "vitest"
```

Add `vitest` and `jsdom` as dev dependencies and set `test.environment = 'jsdom'` in `vite.config.js`.

- [ ] **Step 2: Write failing refresh, concurrency, and error tests**

Cover these exact cases:

- Bearer token is attached to same-origin protected requests.
- External URLs are untouched.
- Ten simultaneous 401 responses trigger exactly one refresh request.
- All ten requests retry with the new token.
- Refresh failure clears storage and rejects with `ApiError`; it does not silently return the original 401.
- `fetchJson` preserves backend `error` or `message` text and status.

- [ ] **Step 3: Run tests and confirm failure**

```bash
cd UniActivity_FE
npm test -- src/utils/api.test.js
```

Expected: FAIL because behavior is split between two clients and `ApiError/fetchJson` do not exist.

- [ ] **Step 4: Implement one client without patching `window.fetch`**

Keep `originalFetch` module-local, use a single module-level refresh promise, and always clear it in `finally`:

```js
export class ApiError extends Error {
  constructor(status, message, payload = null) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.payload = payload
  }
}

let refreshPromise = null

async function getFreshAccessToken() {
  if (!refreshPromise) {
    refreshPromise = refreshAccessToken().finally(() => {
      refreshPromise = null
    })
  }
  return refreshPromise
}

export async function fetchJson(url, options = {}) {
  const response = await apiFetch(url, options)
  const payload = response.status === 204 ? null : await response.json().catch(() => null)
  if (!response.ok) {
    throw new ApiError(response.status, payload?.error || payload?.message || `HTTP ${response.status}`, payload)
  }
  return payload
}
```

- [ ] **Step 5: Replace raw same-origin calls incrementally**

Import `apiFetch` for blob/image responses and `fetchJson` for JSON. External Nominatim requests must continue using native `fetch`. Remove the side-effect import from `main.jsx` and delete `fetchInterceptor.js` only after `rg -n "fetch\(" src` shows that remaining raw calls are public auth or external URLs.

- [ ] **Step 6: Verify and commit**

```bash
cd UniActivity_FE
npm test
npm run lint
npm run build
git add package.json package-lock.json vite.config.js src
git commit -m "refactor: consolidate authenticated API requests"
```

---

### Task 6: Fix React hook dependency warnings and stale pagination updates

**Files:**
- Modify: `UniActivity_FE/src/pages/admin/ActivityList.jsx`
- Modify: `UniActivity_FE/src/pages/admin/UserList.jsx`
- Modify: `UniActivity_FE/src/pages/manager/ActivityDetail.jsx`
- Modify: `UniActivity_FE/src/pages/student/Checkin.jsx`
- Create: `UniActivity_FE/src/pages/manager/ActivityDetail.test.jsx`

**Interfaces:**
- Preserves: existing page behavior and endpoint contracts.
- Produces: stable callbacks whose dependency arrays are exhaustive.

- [ ] **Step 1: Write a stale-page regression test**

Render `ActivityDetail` at page 0, trigger navigation to page 1, dispatch `activity-registration-update`, and assert the refresh request still includes `page=1&size=20`.

- [ ] **Step 2: Run test and confirm failure**

```bash
cd UniActivity_FE
npm test -- src/pages/manager/ActivityDetail.test.jsx
```

- [ ] **Step 3: Stabilize the four callbacks**

Wrap `fetchData` in `useCallback` and include every referenced primitive dependency. For `ActivityDetail`, remove the default argument that closes over `regPage`:

```js
const fetchData = useCallback(async (page) => {
  const requestedPage = page ?? regPage
  // request requestedPage
}, [activityId, regPage])
```

Where an effect must run only when a selected ID changes, move the request body into the effect instead of suppressing `exhaustive-deps`. Do not disable the lint rule.

- [ ] **Step 4: Verify zero ESLint warnings and commit**

```bash
cd UniActivity_FE
npm test -- src/pages/manager/ActivityDetail.test.jsx
npm run lint -- --max-warnings=0
npm run build
git add src/pages
git commit -m "fix: remove stale React hook closures"
```

---

### Task 7: Apply accessible dialog, form, tabs, toast, focus, and motion patterns

**Files:**
- Create: `UniActivity_FE/src/components/common/Modal.jsx`
- Create: `UniActivity_FE/src/components/common/ToastRegion.jsx`
- Modify: `UniActivity_FE/src/pages/AuthPage.jsx`
- Modify: `UniActivity_FE/src/pages/ForgotPasswordModal.jsx`
- Modify: modal and icon-button call sites under `UniActivity_FE/src/`
- Modify: `UniActivity_FE/src/index.css`
- Create: `UniActivity_FE/src/pages/ForgotPasswordModal.test.jsx`

**Interfaces:**
- Produces: `<Modal open onClose labelledBy initialFocusRef>`.
- Produces: `<ToastRegion toast>` with polite/assertive live regions.
- Preserves: visual layout and dark mode.

- [ ] **Step 1: Add Testing Library and jest-dom**

Install `@testing-library/react`, `@testing-library/user-event`, and `@testing-library/jest-dom` as dev dependencies. Add a Vitest setup file importing `@testing-library/jest-dom/vitest`.

- [ ] **Step 2: Write failing accessibility interaction tests**

Test that the forgot-password dialog:

- Has role `dialog`, `aria-modal=true`, and an accessible name.
- Moves focus to the email field on open.
- Closes on Escape.
- Traps Tab/Shift+Tab inside the dialog.
- Restores focus to the opener on close.
- Exposes the close and password-visibility buttons by accessible name.
- Associates every label with an input.
- Announces errors through an alert/live region.

- [ ] **Step 3: Implement shared accessible primitives**

`Modal` must render via `createPortal`, save `document.activeElement`, focus `initialFocusRef` or the first focusable element, trap Tab, handle Escape, set `role="dialog"`, `aria-modal="true"`, and restore focus during cleanup.

`ToastRegion` must use `role="status" aria-live="polite"` for success/info and `role="alert"` for errors.

- [ ] **Step 4: Fix form metadata and icon buttons**

For every form control add stable `id`, `name`, `htmlFor`, appropriate `type`, `inputMode`, `autoComplete`, and `spellCheck={false}` for email/code fields. Add explicit `aria-label` to icon-only buttons and `aria-hidden="true"` to decorative Material Symbols.

- [ ] **Step 5: Correct auth tab semantics and focus styling**

Use `role="tablist"`, `role="tab"`, `aria-selected`, `aria-controls`, keyboard ArrowLeft/ArrowRight behavior, and `role="tabpanel"`. Replace `focus:outline-none` with `focus-visible` rings. Replace `transition-all` with explicit color, opacity, transform, or shadow transitions.

- [ ] **Step 6: Honor reduced motion globally**

Add:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    scroll-behavior: auto !important;
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

- [ ] **Step 7: Verify and commit**

```bash
cd UniActivity_FE
npm test
npm run lint -- --max-warnings=0
npm run build
git add package.json package-lock.json vite.config.js src
git commit -m "a11y: add accessible dialogs forms and feedback"
```

---

### Task 8: Reduce frontend asset and route chunk size

**Files:**
- Replace: `UniActivity_FE/src/assets/img/banner_QNU.jpg`
- Create: `UniActivity_FE/src/assets/img/banner_QNU-1280.avif`
- Create: `UniActivity_FE/src/assets/img/banner_QNU-1920.avif`
- Modify: components rendering the banner
- Split: `UniActivity_FE/src/pages/student/Checkin.jsx`
- Split: `UniActivity_FE/src/pages/student/Dashboard.jsx`
- Modify: `UniActivity_FE/vite.config.js`
- Create: `UniActivity_FE/scripts/check-bundle-budget.mjs`
- Modify: `UniActivity_FE/package.json`

**Interfaces:**
- Produces lazy `QrScanner`, `DashboardCharts`, and modal components.
- Adds script `npm run check:bundle`.

- [ ] **Step 1: Add a failing bundle-budget check**

The script must parse `dist/.vite/manifest.json` and fail when:

- Any non-vendor route JS chunk exceeds 250 KiB uncompressed.
- Any raster image exceeds 500 KiB.
- Initial entry JS exceeds 300 KiB.

Add `build.manifest = true` and run `npm run build && npm run check:bundle`. Expected: FAIL on the current banner and large route chunks.

- [ ] **Step 2: Generate responsive image assets**

Convert the banner to 1280 px and 1920 px AVIF/WebP variants with quality 70–80. Render with `<picture>`, explicit `width`/`height`, and `fetchPriority="high"` only when above the fold. Do not lazy-load the hero; lazy-load below-fold images.

- [ ] **Step 3: Split QR and chart code at interaction boundaries**

Move camera enumeration and `html5-qrcode` import into `QrScanner.jsx`, loaded with `lazy(() => import(...))` only when the scanner opens. Move Recharts dashboards into lazy chart modules. Extract check-in form, evidence form, and modal sections so each file has one responsibility.

- [ ] **Step 4: Add deliberate vendor chunking only after lazy splits**

Configure Rollup manual chunks for `recharts`, `html5-qrcode`, and `qrcode` packages. Do not create one catch-all vendor chunk.

- [ ] **Step 5: Verify budgets and commit**

```bash
cd UniActivity_FE
npm run build
npm run check:bundle
npm run lint -- --max-warnings=0
npm test
git add package.json vite.config.js scripts src
git commit -m "perf: reduce frontend route and image payloads"
```

Expected: all bundle thresholds pass and no route loses functionality.

---

### Task 9: Add critical frontend E2E coverage

**Files:**
- Modify: `UniActivity_FE/package.json`
- Create: `UniActivity_FE/playwright.config.js`
- Create: `UniActivity_FE/e2e/auth.spec.js`
- Create: `UniActivity_FE/e2e/student-registration.spec.js`
- Create: `UniActivity_FE/e2e/manager-review.spec.js`
- Create: `UniActivity_FE/e2e/accessibility.spec.js`
- Modify: `.gitignore`

**Interfaces:**
- Adds `npm run test:e2e` and `npm run test:e2e:ci`.
- Consumes: a test-profile backend and deterministic seed/setup API available only in tests.

- [ ] **Step 1: Install Playwright and add scripts**

```json
"test:e2e": "playwright test",
"test:e2e:ci": "playwright test --reporter=line"
```

Configure Playwright to start the H2-backed Spring Boot test server and Vite dev server, use Chromium, retain traces only on first retry, and forbid focused tests in CI.

- [ ] **Step 2: Add failing auth and authorization journeys**

Cover local student/manager/admin login, refresh after an injected expired access token, logout revocation, role redirect, and denial when a manager opens another class's resource.

- [ ] **Step 3: Add student and manager business journeys**

Cover class join, activity registration/cancellation, evidence upload, manager approval/rejection, score appearance, and a check-in failure with an invalid/expired QR. Mock camera hardware only at the browser media API boundary.

- [ ] **Step 4: Add automated accessibility smoke tests**

Install `@axe-core/playwright`. Run `axe` on login, each role dashboard, forgot-password dialog, activity detail, and check-in dialog. Fail on serious and critical violations.

- [ ] **Step 5: Verify and commit**

```bash
cd UniActivity_FE
npm run test:e2e:ci
git add package.json package-lock.json playwright.config.js e2e ../.gitignore
git commit -m "test: cover critical user journeys with playwright"
```

---

### Task 10: Enforce build, tests, audit, and bundle budgets in GitHub Actions

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `.github/dependabot.yml`
- Modify: `README.md`

**Interfaces:**
- Produces required jobs `backend`, `frontend`, and `e2e`.
- E2E depends on successful backend/frontend jobs.

- [ ] **Step 1: Create the backend CI job**

Use Ubuntu, Temurin Java 21, Maven cache, and run:

```bash
cd UniActivity_BE
./mvnw --batch-mode --no-transfer-progress test
```

Upload Surefire and Karate reports on failure.

- [ ] **Step 2: Create the frontend CI job**

Use Node 22 with npm cache and run:

```bash
cd UniActivity_FE
npm ci
npm audit --omit=dev --audit-level=high
npm test
npm run lint -- --max-warnings=0
npm run build
npm run check:bundle
```

- [ ] **Step 3: Create the E2E job**

Install only Chromium with Playwright system dependencies, run `npm run test:e2e:ci`, and upload traces/screenshots only on failure.

- [ ] **Step 4: Add dependency update policy**

Configure monthly Maven, npm, and GitHub Actions updates with a maximum of five open PRs per ecosystem. Group patch/minor development dependencies; do not automatically group Spring Boot or React major versions.

- [ ] **Step 5: Document local parity commands and commit**

Add a README section containing the same commands CI runs. Validate workflow YAML with the available local validator or GitHub Actions language tooling, then run the complete command set locally.

```bash
git add .github README.md
git commit -m "ci: enforce backend frontend and e2e quality gates"
```

---

## Final release verification

- [ ] Run backend tests: `cd UniActivity_BE && ./mvnw test` — expected `0` failures and `0` errors.
- [ ] Run frontend unit tests: `cd UniActivity_FE && npm test` — expected all tests PASS.
- [ ] Run strict lint: `npm run lint -- --max-warnings=0` — expected exit code `0` and no warnings.
- [ ] Run production build and budget: `npm run build && npm run check:bundle` — expected both commands exit `0`.
- [ ] Run E2E: `npm run test:e2e:ci` — expected all critical journeys PASS.
- [ ] Run runtime dependency audit: `npm audit --omit=dev --audit-level=high` — expected no high/critical vulnerabilities.
- [ ] Review `git diff --check` — expected no whitespace errors.
- [ ] Confirm `git status --short` contains only intended files.
- [ ] Deploy first to staging with the production profile and run a Flyway backup/restore rehearsal before production migration.

## Definition of done

- Activity list query count is constant with respect to number of returned activities, excluding result-row transfer.
- All user-facing list endpoints are bounded and stable-sorted.
- Production starts only with explicit frontend/CORS/OAuth environment values.
- Empty and existing MySQL databases both reach Flyway V6 successfully.
- No global `window.fetch` monkey patch or duplicate refresh implementation remains.
- ESLint reports zero warnings.
- Serious/critical axe violations are zero on critical screens.
- Bundle budgets pass.
- Backend, unit, integration, E2E, audit, and build checks are enforced in CI.
