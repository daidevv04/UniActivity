package com.example.uniactivity.controller.admin;

import com.example.uniactivity.dto.activity.*;
import com.example.uniactivity.enums.ActivityScope;
import com.example.uniactivity.enums.ActivityStatus;
import com.example.uniactivity.service.ActivityService;
import com.example.uniactivity.service.AcademicYearService;
import com.example.uniactivity.service.FacultyService;
import com.example.uniactivity.service.FileUploadService;
import com.example.uniactivity.service.ScoringRulesService;
import com.example.uniactivity.service.SemesterService;
import com.example.uniactivity.service.StudentClassService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/activities")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;
    private final SemesterService semesterService;
    private final FacultyService facultyService;
    private final AcademicYearService academicYearService;
    private final StudentClassService studentClassService;
    private final ScoringRulesService scoringRulesService;
    private final FileUploadService fileUploadService;
    // ========== Activity REST API ==========

    @GetMapping("/api")
    @ResponseBody
    public Page<ActivityResponseDto> getAllActivities(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {
        return activityService.getAllActivitiesPaged(page, Math.min(size, 100));
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public ActivityResponseDto getActivityById(@PathVariable Long id) {
        return activityService.getActivityById(id);
    }

    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<ActivityResponseDto> createActivity(@Valid @RequestBody ActivityDto dto) {
        return ResponseEntity.ok(activityService.createActivity(dto));
    }

    @PutMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<ActivityResponseDto> updateActivity(@PathVariable Long id, @Valid @RequestBody ActivityDto dto) {
        return ResponseEntity.ok(activityService.updateActivity(id, dto));
    }

    @DeleteMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Void> deleteActivity(@PathVariable Long id) {
        activityService.deleteActivity(id);
        return ResponseEntity.ok().build();
    }

    // ========== Activity Slot REST API ==========

    @GetMapping("/api/{activityId}/slots")
    @ResponseBody
    public List<ActivitySlotResponseDto> getSlotsByActivity(@PathVariable Long activityId) {
        return activityService.getSlotsByActivity(activityId);
    }

    @PostMapping("/api/{activityId}/slots")
    @ResponseBody
    public ResponseEntity<ActivitySlotResponseDto> createSlot(@PathVariable Long activityId, @Valid @RequestBody ActivitySlotDto dto) {
        return ResponseEntity.ok(activityService.createSlot(activityId, dto));
    }

    @DeleteMapping("/api/slots/{slotId}")
    @ResponseBody
    public ResponseEntity<Void> deleteSlot(@PathVariable Long slotId) {
        activityService.deleteSlot(slotId);
        return ResponseEntity.ok().build();
    }

    // ========== Score Option REST API ==========

    @GetMapping("/api/{activityId}/score-options")
    @ResponseBody
    public List<ScoreOptionResponseDto> getScoreOptionsByActivity(@PathVariable Long activityId) {
        return activityService.getScoreOptionsByActivity(activityId);
    }

    @PostMapping("/api/{activityId}/score-options")
    @ResponseBody
    public ResponseEntity<ScoreOptionResponseDto> createScoreOption(@PathVariable Long activityId, @Valid @RequestBody ScoreOptionDto dto) {
        return ResponseEntity.ok(activityService.createScoreOption(activityId, dto));
    }

    @DeleteMapping("/api/score-options/{scoreOptionId}")
    @ResponseBody
    public ResponseEntity<Void> deleteScoreOption(@PathVariable Long scoreOptionId) {
        activityService.deleteScoreOption(scoreOptionId);
        return ResponseEntity.ok().build();
    }

    // Scoring rules API for React frontend
    @GetMapping("/api/scoring-rules")
    @ResponseBody
    public ResponseEntity<?> getScoringRules() {
        return ResponseEntity.ok(scoringRulesService.getScoringRules());
    }

    // Banner upload API
    @PostMapping("/api/upload-banner")
    @ResponseBody
    public ResponseEntity<Map<String, String>> uploadBanner(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "File không được để trống"));
        }

        try {
            String bannerUrl = fileUploadService
                    .uploadActivityImages(new MultipartFile[]{file})
                    .get(0);
            return ResponseEntity.ok(Map.of("bannerUrl", bannerUrl));
        } catch (IOException e) {
            return ResponseEntity.badRequest().body(Map.of("error", "Upload thất bại hoặc tệp không hợp lệ"));
        }
    }
}
