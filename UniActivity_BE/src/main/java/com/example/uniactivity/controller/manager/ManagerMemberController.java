package com.example.uniactivity.controller.manager;

import com.example.uniactivity.entity.ClassJoinRequest;
import com.example.uniactivity.entity.StudentClass;
import com.example.uniactivity.entity.User;
import com.example.uniactivity.repository.UserRepository;
import com.example.uniactivity.security.CustomUserDetails;
import com.example.uniactivity.service.ClassJoinRequestService;
import com.example.uniactivity.service.ManagerScopeAuthorizationService;
import com.example.uniactivity.service.NotificationService;
import com.example.uniactivity.service.StudentClassService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Controller for managing class members and join requests
 */
@Controller
@RequestMapping("/manager")
@RequiredArgsConstructor
public class ManagerMemberController {

    private final UserRepository userRepository;
    private final ClassJoinRequestService classJoinRequestService;
    private final NotificationService notificationService;
    private final ManagerScopeAuthorizationService managerScopeAuthorizationService;
    private final StudentClassService studentClassService;
    // ========== API ==========

    @PostMapping("/api/join-requests/{id}/approve")
    @ResponseBody
    public ResponseEntity<?> approveJoinRequest(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        classJoinRequestService.approveRequest(id, userDetails.getUser());
        return ResponseEntity.ok(Map.of("message", "Đã duyệt yêu cầu"));
    }

    @PostMapping("/api/join-requests/{id}/reject")
    @ResponseBody
    public ResponseEntity<?> rejectJoinRequest(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        classJoinRequestService.rejectRequest(id, userDetails.getUser());
        return ResponseEntity.ok(Map.of("message", "Đã từ chối yêu cầu"));
    }

    @DeleteMapping("/api/members/{userId}")
    @ResponseBody
    public ResponseEntity<?> removeMember(
            @PathVariable Long userId,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        User member = managerScopeAuthorizationService
                .requireStudent(userDetails.getUser(), userId);
        StudentClass studentClass = member.getStudentClass();
        String className = studentClass.getName();
        member.setStudentClass(null);
        userRepository.save(member);
        notificationService.notifyRemovedFromClass(member, className);
        classJoinRequestService.sendDashboardUpdateToClassManagers(studentClass);
        return ResponseEntity.ok(Map.of("message", "Đã xóa khỏi lớp"));
    }

    @PostMapping("/api/regenerate-join-code")
    @ResponseBody
    public ResponseEntity<?> regenerateJoinCode(@AuthenticationPrincipal CustomUserDetails userDetails) {
        StudentClass studentClass = managerScopeAuthorizationService
                .requireManagedClass(userDetails.getUser());
        String newCode = studentClassService.regenerateJoinCode(studentClass.getId()).getJoinCode();
        return ResponseEntity.ok(Map.of(
            "message", "Đã tạo mã tham gia mới",
            "joinCode", newCode
        ));
    }

}
