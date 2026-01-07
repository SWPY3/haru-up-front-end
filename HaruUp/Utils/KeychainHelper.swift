//
//  KeychainHelper.swift
//  HaruUp
//
//  Created by 하다현 on 1/7/26.
//

import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    // 저장
    func save(token: String, forKey key: String) {
        // 1. 데이터를 Data 타입으로 변환
        guard let data = token.data(using: .utf8) else { return }
        
        // 2. 기존 데이터가 있다면 삭제 (중복 방지)
        delete(forKey: key)
        
        // 3. 쿼리 생성
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword, // 아이템 클래스
            kSecAttrAccount as String: key,                // 식별자 (Key)
            kSecValueData as String: data                  // 저장할 값
        ]
        
        // 4. 저장 수행
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("❌ Keychain 저장 실패: \(status)")
        }
    }
    
    // 조회
    func read(forKey key: String) -> String? {
        // 1. 조회 쿼리 생성
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,  // 데이터 반환 요청
            kSecMatchLimit as String: kSecMatchLimitOne // 중복 시 하나만 반환
        ]
        
        var dataTypeRef: AnyObject?
        // 2. 조회 수행
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    // 삭제
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
