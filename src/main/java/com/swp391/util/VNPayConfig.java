/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.swp391.util;

import jakarta.servlet.http.HttpServletRequest;
import java.nio.charset.StandardCharsets;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 *
 * @author admin
 */
public class VNPayConfig {
    
    // Đường dẫn cổng thanh toán VNPay Sandbox
    public static final String vnp_PayUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    
    // Đường dẫn đón khách quay về sau khi thanh toán xong
    public static final String vnp_ReturnUrl = "http://localhost:9999/vnpay-return";
    
    // Bộ khóa kết nối
    public static final String vnp_TmnCode = "4ZIHQ1V3";
    public static final String vnp_HashSecret = "CPJYLUARZNXOPSXYGVEBIRYWNHQAMVVA";
    
    // Thuật toán băm chữ ký bảo mật HMAC-SHA512
    public static String hmacSHA512(final String key, final String data){
        try{
            if(key == null || data == null){
                throw new NullPointerException();
            }
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes(StandardCharsets.UTF_8);
            final SecretKeySpec secretKey = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKey);
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8); 
            byte[] result = hmac512.doFinal(dataBytes); //64 con số byte âm dương
            //đổi từng số sang hệ 16 (Hex: gồm 0-9 và a-f)
            StringBuilder sb = new StringBuilder(2 * result.length);
            for(byte b : result){
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        }
        catch(Exception ex){
            return "";
        }
    }
    
    // Lấy địa chỉ IP của khách hàng
    public static String getIpAddress(HttpServletRequest request){
        String ipAddress = request.getHeader("X-FORWARDED-FOR");
        if(ipAddress == null){
            ipAddress = request.getRemoteAddr();
        }
        return ipAddress;
    }       
}
