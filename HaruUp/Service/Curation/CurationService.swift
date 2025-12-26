//
//  CurationService.swift
//  HaruUp
//
//  Created by 하다현 on 12/27/25.
//

import Foundation
import RxSwift

//final class CurationService {
//
//    // 스트리밍 방식으로 큐레이션 로그를 수신
//    func streamCurationLogs(curationData: CurationData) -> Observable<CurationStreamEvent> {
//        return Observable.create { observer in
//            guard let request = curationData.toCurationRequest() else {
//                observer.onError(NSError(domain: "CurationError", code: -1,
//                                         userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 큐레이션 데이터입니다."]))
//                return Disposables.create()
//            }
//
//            guard let url = URL(string: NetworkDefine.CurationAPI.initialCuration.url) else {
//                observer.onError(NSError(domain: "CurationError", code: -2,
//                                         userInfo: [NSLocalizedDescriptionKey: "잘못된 URL입니다."]))
//                return Disposables.create()
//            }
//
//            print("=== API 요청 시작 ===")
//                        print("URL: \(url.absoluteString)")
//
//            var urlRequest = URLRequest(url: url)
//            urlRequest.httpMethod = "POST"
//            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
//
//            // RefreshToken 가져오기
//            if let refreshToken = TokenStorageService.shared.getRefreshToken() {
//                urlRequest.setValue(refreshToken, forHTTPHeaderField: "jwt-token")
//                print("RefreshToken 설정 완료")
//            }
//
//            // 요청 바디 설정
////            do {
////                let jsonData = try JSONEncoder().encode(request)
////                urlRequest.httpBody = jsonData
////            } catch {
////                observer.onError(error)
//            //                return Disposables.create()
//            //            }
//            do {
//                let encoder = JSONEncoder()
//                encoder.outputFormatting = .prettyPrinted
//                let jsonData = try encoder.encode(request)
//                urlRequest.httpBody = jsonData
//
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print("=== 요청 바디 ===")
//                    print(jsonString)
//                }
//            } catch {
//                print("❌ JSON 인코딩 실패: \(error)")
//                observer.onError(error)
//                return Disposables.create()
//            }
//
//            let session = URLSession.shared
//            let task = session.dataTask(with: urlRequest) { data, response, error in
//                if let error = error {
//                    print("❌ 네트워크 에러: \(error.localizedDescription)")
//                    observer.onError(error)
//                    return
//                }
//
//                if let httpResponse = response as? HTTPURLResponse {
//                                    print("=== HTTP 응답 ===")
//                                    print("상태 코드: \(httpResponse.statusCode)")
//                                }
//
//                guard let data = data else {
//                    observer.onError(NSError(domain: "CurationError", code: -3,
//                                             userInfo: [NSLocalizedDescriptionKey: "데이터를 받지 못했습니다."]))
//                    return
//                }
//
//                // SSE 형식 파싱
//                let dataString = String(data: data, encoding: .utf8) ?? ""
//                print("=== 전체 응답 데이터 ===")
//                                print(dataString)
//                let events = dataString.components(separatedBy: "\n\n")
//
//                for event in events {
//                    if event.isEmpty { continue }
//
//                    // "data: " 접두사 제거
//                    let lines = event.components(separatedBy: "\n")
//                    for line in lines {
//                        if line.hasPrefix("data: ") {
//                            let jsonString = String(line.dropFirst(6))
//                            print("파싱할 JSON: \(jsonString)")
//
//                            // memberInterestIds가 있는지 확인 (최종 응답)
//                            if let jsonData = jsonString.data(using: .utf8) {
//                                // 먼저 최종 응답인지 확인
//                                if let finalResponse = try? JSONDecoder().decode(CurationResponse.self, from: jsonData) {
//                                    print("✅ 최종 응답 수신: \(finalResponse.memberInterestIds)")
//                                    observer.onNext(.completed(finalResponse.memberInterestIds))
//                                    observer.onCompleted()
//                                    return
//                                }
//
//                                // 로그 응답 파싱
//                                if let log = try? JSONDecoder().decode(CurationLog.self, from: jsonData) {
//                                    print("📝 로그 수신: \(log.step)")
//                                    observer.onNext(.log(log))
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//
//            task.resume()
//
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
//}

final class CurationService {
    
    func streamCurationLogs(curationData: CurationData) -> Observable<CurationStreamEvent> {
        return Observable.create { observer in
            guard let request = curationData.toCurationRequest() else {
                observer.onError(NSError(domain: "CurationError", code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 큐레이션 데이터입니다."]))
                return Disposables.create()
            }
            
            guard let url = URL(string: NetworkDefine.CurationAPI.initialCuration.url) else {
                observer.onError(NSError(domain: "CurationError", code: -2,
                                         userInfo: [NSLocalizedDescriptionKey: "잘못된 URL입니다."]))
                return Disposables.create()
            }
            
            print("=== API 요청 시작 ===")
            print("URL: \(url.absoluteString)")
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            
            if let refreshToken = TokenStorageService.shared.getRefreshToken() {
                urlRequest.setValue(refreshToken, forHTTPHeaderField: "jwt-token")
                print("RefreshToken 설정 완료")
            }
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let jsonData = try encoder.encode(request)
                urlRequest.httpBody = jsonData
                
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("=== 요청 바디 ===")
                    print(jsonString)
                }
            } catch {
                print("❌ JSON 인코딩 실패: \(error)")
                observer.onError(error)
                return Disposables.create()
            }
            
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print("❌ 네트워크 에러: \(error.localizedDescription)")
                    observer.onError(error)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("=== HTTP 응답 ===")
                    print("상태 코드: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    observer.onError(NSError(domain: "CurationError", code: -3,
                                             userInfo: [NSLocalizedDescriptionKey: "데이터를 받지 못했습니다."]))
                    return
                }
                
                let dataString = String(data: data, encoding: .utf8) ?? ""
                print("=== 전체 응답 데이터 ===")
                print(dataString)
                
                // ✅ SSE 파싱 개선
                self.parseSSE(dataString: dataString, observer: observer)
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    // ✅ SSE 파싱 로직 분리
    private func parseSSE(dataString: String, observer: AnyObserver<CurationStreamEvent>) {
        let lines = dataString.components(separatedBy: "\n")
        var currentEvent: String?
        var currentData: String?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                // 빈 줄 = 이벤트 종료, 처리
                if let data = currentData {
                    processEvent(event: currentEvent, data: data, observer: observer)
                }
                currentEvent = nil
                currentData = nil
                continue
            }
            
            if trimmedLine.hasPrefix("event:") {
                currentEvent = String(trimmedLine.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                print("📌 이벤트 타입: \(currentEvent ?? "nil")")
            } else if trimmedLine.hasPrefix("data:") {
                let dataContent = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                currentData = dataContent
                print("📦 데이터: \(dataContent)")
            }
        }
        
        // 마지막 이벤트 처리 (빈 줄 없이 끝날 수 있음)
        if let data = currentData {
            processEvent(event: currentEvent, data: data, observer: observer)
        }
    }
    
    // ✅ 이벤트 처리
    private func processEvent(event: String?, data: String, observer: AnyObserver<CurationStreamEvent>) {
        guard let eventType = event else { return }
        
        switch eventType {
        case "connected":
            print("✅ 연결됨: \(data)")
            
        case "curation-log":
            // JSON 파싱
            if let jsonData = data.data(using: .utf8),
               let log = try? JSONDecoder().decode(CurationLog.self, from: jsonData) {
                print("📝 로그 수신: \(log.step)")
                observer.onNext(.log(log))
            } else {
                print("❌ 로그 파싱 실패: \(data)")
            }
            
        case "curation-complete":
            // 최종 응답
            if let jsonData = data.data(using: .utf8),
               let response = try? JSONDecoder().decode(CurationResponse.self, from: jsonData) {
                print("✅ 큐레이션 완료: \(response.memberInterestIds)")
                observer.onNext(.completed(response.memberInterestIds))
                observer.onCompleted()
            } else {
                print("❌ 완료 응답 파싱 실패: \(data)")
            }
            
        default:
            print("⚠️ 알 수 없는 이벤트 타입: \(eventType)")
        }
    }
}

 // 스트리밍 이벤트 타입
enum CurationStreamEvent {
    case log(CurationLog)
    case completed([Int])
}
