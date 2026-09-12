package com.example.uniactivity.exception;

import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.context.request.async.AsyncRequestNotUsableException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void authorizationReturns403() {
        assertEquals(HttpStatus.FORBIDDEN,
                handler.handleAuthorization(new AuthorizationException("forbidden"))
                        .getStatusCode());
    }

    @Test
    void conflictReturns409() {
        assertEquals(HttpStatus.CONFLICT,
                handler.handleConflict(new ConflictException("conflict")).getStatusCode());
        assertEquals(HttpStatus.CONFLICT,
                handler.handleDataIntegrity(
                                new DataIntegrityViolationException("duplicate internal value"))
                        .getStatusCode());
    }

    @Test
    void validationReturns400() {
        assertEquals(HttpStatus.BAD_REQUEST,
                handler.handleValidation(new ValidationException("invalid")).getStatusCode());
    }

    @Test
    void wrappedIOExceptionReturns500WithoutLeakingDetails() throws Exception {
        var response = handler.handleGeneral(
                new IllegalStateException("wrapper", new IOException("secret path")),
                new MockHttpServletResponse());

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertEquals("Lỗi hệ thống, vui lòng thử lại sau", response.getBody().getMessage());
    }

    @Test
    void alreadyCommittedResponseIsNotWrittenAgain() throws Exception {
        MockHttpServletResponse committed = new MockHttpServletResponse();
        committed.setCommitted(true);

        assertDoesNotThrow(() -> handler.handleGeneral(
                new IllegalStateException("after commit"), committed));
        assertEquals(0, committed.getContentAsByteArray().length);
    }

    @Test
    void missingStaticResourceReturns404() {
        assertEquals(HttpStatus.NOT_FOUND,
                handler.handleNoResource(
                                new NoResourceFoundException(HttpMethod.GET, "/uploads/x.jpg"))
                        .getStatusCode());
    }

    @Test
    void wrongHttpMethodReturns405() {
        assertEquals(HttpStatus.METHOD_NOT_ALLOWED,
                handler.handleMethodNotAllowed(
                                new HttpRequestMethodNotSupportedException("GET"))
                        .getStatusCode());
    }

    @Test
    void invalidParameterTypeReturns400() {
        assertEquals(HttpStatus.BAD_REQUEST,
                handler.handleTypeMismatch(new MethodArgumentTypeMismatchException(
                                "list", Long.class, "id", null, new NumberFormatException("list")))
                        .getStatusCode());
    }

    @Test
    void asyncDisconnectDoesNotBuildAnotherResponse() {
        assertDoesNotThrow(() -> handler.handleAsyncDisconnect(
                new AsyncRequestNotUsableException("client disconnected")));
    }
}
