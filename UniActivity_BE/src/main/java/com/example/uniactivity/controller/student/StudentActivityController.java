package com.example.uniactivity.controller.student;

import com.example.uniactivity.entity.*;
import com.example.uniactivity.repository.ActivityRegistrationRepository;
import com.example.uniactivity.repository.UserRepository;
import com.example.uniactivity.security.CustomUserDetails;
import com.example.uniactivity.service.ActivityService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Controller for student activities list and registration management
 */
@Controller
@RequestMapping("/student")
@RequiredArgsConstructor
public class StudentActivityController {

    private final ActivityService activityService;
    private final ActivityRegistrationRepository activityRegistrationRepository;
    private final UserRepository userRepository;
    @PostMapping("/api/activities/{activityId}/register")
    @ResponseBody
    public ResponseEntity<?> registerActivity(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable Long activityId) {
        User currentUser = userRepository.findById(userDetails.getUser().getId())
                .orElse(userDetails.getUser());
        Map<String, Object> result =
                activityService.registerStudentForActivity(currentUser, activityId);
        return ResponseEntity.ok(result);
    }

    @DeleteMapping("/api/activities/{activityId}/register")
    @ResponseBody
    public ResponseEntity<?> cancelRegistration(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable Long activityId) {
        User currentUser = userRepository.findById(userDetails.getUser().getId())
                .orElse(userDetails.getUser());
        Map<String, Object> result =
                activityService.cancelStudentRegistration(currentUser, activityId);
        return ResponseEntity.ok(result);
    }

}
