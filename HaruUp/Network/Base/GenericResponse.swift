//
//  GenericResponse.swift
//  HaruUp
//
//  Created by 하다현 on 12/11/25.
//

import Foundation


struct GenericResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    
}
