//
//  DateHelper.swift
//  HaruUp
//
//  Created by 조영현 on 1/2/26.
//

import Foundation

final class DateHelper {
    // 인스턴스 생성을 막음 (선택 사항)
    private init() {}
    
    // 포맷터를 static 프로퍼티로 선언하여 재사용 (성능 최적화)
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter
    }()
    
    // static 함수로 변경 -> DateHelper.stringToDate(...) 로 바로 사용 가능
    static func stringToDate(_ dateString: String) -> Date? {
        return dateFormatter.date(from: dateString)
    }
    
    static func dateToString(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    static func getDayString(from dateString: String) -> String {
        guard let date = stringToDate(dateString) else { return "" }
        return getDayString(from: date)
    }
    
    static func getDayString(from date: Date) -> String {
        return dayFormatter.string(from: date)
    }
}
