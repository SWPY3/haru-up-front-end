//
//  CurationService.swift
//  HaruUp
//
//  Created by 하다현 on 12/27/25.
//


/// MARL: Alamofire 유무에 따른 구분
//// MARK: - SSE 처리를 위한 Delegate 클래스
//// 이 클래스가 데이터가 '조각(Chunk)'으로 들어올 때마다 반응합니다.
//final class StreamSessionDelegate: NSObject, URLSessionDataDelegate {
//    
//    private let observer: AnyObserver<CurationStreamEvent>
//    private var buffer = "" // 끊겨서 들어오는 데이터를 이어 붙이기 위한 버퍼
//    
//    init(observer: AnyObserver<CurationStreamEvent>) {
//        self.observer = observer
//    }
//    
//    // 1. 데이터 수신 (여러 번 호출됨)
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        guard let chunk = String(data: data, encoding: .utf8) else { return }
//        
//        // 버퍼에 새로운 데이터 추가
//        buffer += chunk
//        
//        // 줄바꿈(\n)을 기준으로 메시지 분리 및 처리
//        processBuffer()
//    }
//    
//    // 2. 완료 또는 에러 처리
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        if let error = error {
//            // 취소 에러는 무시하거나 완료 처리
//            if (error as NSError).code == NSURLErrorCancelled {
//                observer.onCompleted()
//            } else {
//                print("❌ 스트림 에러: \(error.localizedDescription)")
//                observer.onError(error)
//            }
//        } else {
//            // 정상 종료
//            observer.onCompleted()
//        }
//    }
//    
//    // MARK: - 파싱 로직
//    private func processBuffer() {
//        // SSE는 보통 \n\n으로 이벤트를 구분하지만, 여기서는 라인별 처리를 하셨으므로 \n 기준 처리
//        while let range = buffer.range(of: "\n") {
//            let line = String(buffer[..<range.lowerBound])
//            buffer.removeSubrange(..<range.upperBound) // 처리한 부분 버퍼에서 제거
//            
//            parseLine(line)
//        }
//    }
//    
//    private func parseLine(_ line: String) {
//        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
//        if trimmedLine.isEmpty { return }
//        
//        if trimmedLine.hasPrefix("event:") {
//            // 이벤트 타입 저장 로직 (필요시 상태 관리를 위해 변수에 저장해야 함)
//            // 현재 구조상 data 라인과 event 라인이 순서대로 온다고 가정하고
//            // 간단하게 data 라인에서 처리하거나, 상태 변수를 둬야 합니다.
//            // *단순화를 위해 여기서는 data 파싱에 집중하거나, 기존 로직처럼 상태 변수를 클래스 내에 둬야 합니다.*
//            self.lastEvent = String(trimmedLine.dropFirst(6)).trimmingCharacters(in: .whitespaces)
//            
//        } else if trimmedLine.hasPrefix("data:") {
//            let dataContent = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
//            
//            // 저장해둔 이벤트 타입과 함께 처리
//            if let event = self.lastEvent {
//                processEvent(event: event, data: dataContent)
//            }
//            // 데이터 처리 후 이벤트 초기화 (SSE 스펙에 따라 다름, 보통 한 쌍)
//            self.lastEvent = nil
//        }
//    }
//    
//    private var lastEvent: String? // event: 와 data: 가 나눠져서 들어오므로 상태 저장 필요
//    
//    private func processEvent(event: String, data: String) {
//        switch event {
//        case "connected":
//            print("✅ 연결됨")
//            
//        case "curation-log":
//            if let jsonData = data.data(using: .utf8),
//               let log = try? JSONDecoder().decode(CurationLog.self, from: jsonData) {
//                print("📝 로그: \(log.step)")
//                observer.onNext(.log(log))
//            }
//            
//        case "curation-complete":
//            if let jsonData = data.data(using: .utf8),
//               let response = try? JSONDecoder().decode(CurationResponse.self, from: jsonData) {
//                print("🏁 완료: \(response.memberInterestIds)")
//                observer.onNext(.completed(response.memberInterestIds))
//                observer.onCompleted() // 스트림 종료
//            }
//            
//        default:
//            break
//        }
//    }
//}

import Foundation
import RxSwift
import Alamofire

final class CurationService {
    
    func streamCurationLogs(curationData: CurationData) -> Observable<CurationStreamEvent> {
        return Observable.create { observer in
            
            // 1. 요청 데이터 준비
            guard let requestBody = curationData.toCurationRequest() else {
                observer.onError(NSError(domain: "CurationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "유효하지 않은 데이터"]))
                return Disposables.create()
            }
            
            guard let url = URL(string: NetworkDefine.CurationAPI.initialCuration.url) else {
                observer.onError(NSError(domain: "CurationError", code: -2, userInfo: [NSLocalizedDescriptionKey: "잘못된 URL"]))
                return Disposables.create()
            }
            
            // 2. 헤더 설정
            var headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Accept": "text/event-stream" // SSE 필수 헤더
            ]
            
            if let refreshToken = TokenStorageService.shared.getRefreshToken() {
                headers.add(name: "jwt-token", value: refreshToken)
            }
            
            // 3. 스트리밍 데이터 처리를 위한 변수
            var buffer = "" // 끊겨서 오는 데이터를 이어 붙이기 위한 버퍼
            var lastEvent: String? // 현재 처리 중인 이벤트 타입 (event: ...)
            
            print("=== Alamofire SSE 요청 시작 ===")
            
            // 4. Alamofire Stream Request 요청
            // 주의: 일반 request가 아니라 streamRequest를 사용해야 합니다.
            let request = AF.streamRequest(
                url,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder.default, // Encodable 객체를 바로 JSON으로 변환
                headers: headers
            )
            .responseStreamString { stream in
                switch stream.event {
                case .stream(let result):
                    switch result {
                    case .success(let dataString):
                        // 5. 데이터 수신 (Chunk 단위)
                        buffer += dataString
                        
                        // 버퍼 파싱 로직 (이전과 동일한 원리)
                        while let range = buffer.range(of: "\n") {
                            let line = String(buffer[..<range.lowerBound])
                            buffer.removeSubrange(..<range.upperBound)
                            self.parseLine(line: line, lastEvent: &lastEvent, observer: observer)
                        }
                        
                    case .failure(let error):
                        print("❌ 스트리밍 중 에러: \(error)")
                        observer.onError(error)
                    }
                    
                case .complete(let completion):
                    // 6. 연결 종료
                    if let error = completion.error {
                        print("❌ 요청 실패: \(error)")
                        observer.onError(error)
                    } else {
                        print("✅ 요청 정상 종료")
                        observer.onCompleted()
                    }
                }
            }
            
            // 7. 구독 해제 시 요청 취소
            return Disposables.create {
                print("=== 요청 취소 ===")
                request.cancel()
            }
        }
    }
    
    // MARK: - 파싱 로직 (내부 함수로 분리)
    private func parseLine(line: String, lastEvent: inout String?, observer: AnyObserver<CurationStreamEvent>) {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        if trimmedLine.isEmpty { return }
        
        if trimmedLine.hasPrefix("event:") {
            lastEvent = String(trimmedLine.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            
        } else if trimmedLine.hasPrefix("data:") {
            let dataContent = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            
            if let event = lastEvent {
                processEvent(event: event, data: dataContent, observer: observer)
            }
            // SSE 스펙상 보통 한 쌍이므로 초기화 (필요에 따라 조정)
            lastEvent = nil
        }
    }
    
    private func processEvent(event: String, data: String, observer: AnyObserver<CurationStreamEvent>) {
        switch event {
        case "connected":
            print("✅ SSE 연결 성공")
            
        case "curation-log":
            if let jsonData = data.data(using: .utf8),
               let log = try? JSONDecoder().decode(CurationLog.self, from: jsonData) {
                print("📝 로그: \(log.step)")
                observer.onNext(.log(log))
            }
            
        case "curation-complete":
            if let jsonData = data.data(using: .utf8),
               let response = try? JSONDecoder().decode(CurationResponse.self, from: jsonData) {
                print("🏁 완료 응답: \(response.memberInterestIds)")
                observer.onNext(.completed(response.memberInterestIds))
                // 여기서 onCompleted()를 호출하면 스트림이 닫힘.
                // Alamofire .complete 이벤트에서 처리해도 되지만, 비즈니스 로직상 여기가 끝이라면 여기서 호출.
                observer.onCompleted()
            }
            
        default:
            break
        }
    }
}

 // 스트리밍 이벤트 타입
enum CurationStreamEvent {
    case log(CurationLog)
    case completed([Int])
}
