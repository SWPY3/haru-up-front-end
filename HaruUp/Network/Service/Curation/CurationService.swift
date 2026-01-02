//
//  CurationService.swift
//  HaruUp
//
//  Created by 하다현 on 12/27/25.
//

import Foundation
import RxSwift
import Alamofire

// 스트리밍 이벤트 타입
enum CurationStreamEvent {
   case log(CurationLog)
   case completed([Int])
}

final class CurationService {
    
    // JSONDecoder는 비용이 크므로 재사용
    private let decoder = JSONDecoder()
    
    func streamCurationLogs(curationData: CurationData) -> Observable<CurationStreamEvent> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            // 1. 요청 검증
            guard let requestBody = curationData.toCurationRequest(),
                  let url = URL(string: NetworkDefine.CurationAPI.initialCuration.url) else {
                observer.onError(NSError(domain: "CurationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "요청 데이터 오류"]))
                return Disposables.create()
            }
            
            // 2. 헤더 설정
            var headers: HTTPHeaders = [
                "Content-Type": "application/json",
                "Accept": "text/event-stream"
            ]
            if let refreshToken = TokenStorageService.shared.getRefreshToken() {
                headers.add(name: "jwt-token", value: refreshToken)
            }
            
            // 3. 상태 관리 변수
            var buffer = ""
            var lastEvent: String?
            // 비즈니스 로직상 완료(curation-complete)를 받았는지 체크
            var isLogicallyCompleted = false
            
            print("📡 SSE 연결 시작: \(url.absoluteString)")
            
            // 4. 요청 시작
            let request = AF.streamRequest(
                url,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder.default,
                headers: headers
            )
            .responseStreamString { stream in
                switch stream.event {
                case .stream(let result):
                    switch result {
                    case .success(let dataString):
                        // 데이터를 버퍼에 쌓고 파싱 시도
                        buffer += dataString
                        self.processBuffer(buffer: &buffer, lastEvent: &lastEvent, observer: observer) { completed in
                            isLogicallyCompleted = completed
                        }
                        
                    case .failure(let error):
                        print("❌ 스트림 에러: \(error)")
                        observer.onError(error)
                    }
                    
                case .complete(let completion):
                    // 5. 연결 종료 처리
                    if let error = completion.error {
                        // 네트워크 에러로 끊긴 경우
                        observer.onError(error)
                    } else {
                        // 네트워크는 정상 종료되었으나, 'curation-complete' 이벤트를 못 받고 끊긴 경우 방어 로직
                        if !isLogicallyCompleted {
                            print("⚠️ 스트림이 닫혔으나 완료 이벤트를 받지 못했습니다.")
                            // 필요 시 에러로 처리하거나, 그대로 종료
                            observer.onCompleted()
                        } else {
                            print("✅ 스트림 정상 종료")
                            observer.onCompleted() // Observable 종료
                        }
                    }
                }
            }
            
            return Disposables.create {
                print("👋 스트림 구독 해제 (요청 취소)")
                request.cancel()
            }
        }
    }
    
    // MARK: - Helper Methods (파싱 로직 분리)
    
    /// 버퍼에 쌓인 문자열을 줄 단위로 쪼개서 처리
    private func processBuffer(
        buffer: inout String,
        lastEvent: inout String?,
        observer: AnyObserver<CurationStreamEvent>,
        onComplete: (Bool) -> Void
    ) {
        while let range = buffer.range(of: "\n") {
            let line = String(buffer[..<range.lowerBound])
            buffer.removeSubrange(..<range.upperBound) // 처리한 부분 제거
            
            parseLine(line: line, lastEvent: &lastEvent, observer: observer, onComplete: onComplete)
        }
    }
    
    /// 한 줄을 분석하여 event와 data를 분리
    private func parseLine(
        line: String,
        lastEvent: inout String?,
        observer: AnyObserver<CurationStreamEvent>,
        onComplete: (Bool) -> Void
    ) {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        if trimmedLine.isEmpty { return }
        
        if trimmedLine.hasPrefix("event:") {
            lastEvent = String(trimmedLine.dropFirst(6)).trimmingCharacters(in: .whitespaces)
        } else if trimmedLine.hasPrefix("data:") {
            let dataContent = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            if let event = lastEvent {
                handleEvent(event: event, data: dataContent, observer: observer, onComplete: onComplete)
            }
            lastEvent = nil // 이벤트/데이터 쌍 처리 후 초기화
        }
    }
    
    /// 실제 이벤트에 따른 동작 처리
    private func handleEvent(
        event: String,
        data: String,
        observer: AnyObserver<CurationStreamEvent>,
        onComplete: (Bool) -> Void
    ) {
        guard let jsonData = data.data(using: .utf8) else { return }
        
        debugPrint(event)
        debugPrint(data)
        
        switch event {
        case "connected":
            print("🔗 SSE Connected")
            
        case "curation-log":
            if let log = try? decoder.decode(CurationLog.self, from: jsonData) {
                observer.onNext(.log(log))
            }
            
        case "done":
            if let response = try? decoder.decode(CurationResponse.self, from: jsonData) {
                print("🎉 큐레이션 완료! 결과 ID: \(response.memberInterestIds)")
                
                // 1. 완료 데이터(Event)를 방출
                observer.onNext(.completed(response.memberInterestIds))
                
                // 2. 논리적 완료 플래그 설정
                onComplete(true)
                
                // 3. (선택사항) 여기서 바로 onCompleted를 호출해도 되지만,
                //    보통 서버가 이 메시지를 보낸 후 연결을 끊으므로 .complete 핸들러에서 처리해도 됩니다.
                //    즉시 종료를 원하면 아래 주석 해제

                // observer.onCompleted()
            }
            
        default:
            break
        }
    }
}
