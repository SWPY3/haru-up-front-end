////
////  MemberAPIProtocol.swift
////  HaruUp
////
////  Created by 하다현 on 12/16/25.
////
//
//
//import Foundation
//import RxSwift
//
//protocol MemberAPIProtocol {
//    func checkNicknameDuplicate(_ nickname: String, refreshToken: String) -> Single<GenericResponse<EmptyResponseData>>
//    func createDefaultProfile(request: DefaultProfileRequest, refreshToken: String) -> Single<GenericResponse<EmptyResponseData>>
//}
//
//struct DefaultProfileRequest {
//    let id: Int               // 회원 id
//    let characterImgRef: Int  // 0 or 1
//    let name: String          // 닉네임
//    let description: String   // 설명(지금은 닉네임과 같게 또는 빈 문자열)
//}
//
//typealias NicknameDuplicateResponse = GenericResponse<EmptyResponseData>
//typealias DefaultProfileResponse = GenericResponse<EmptyResponseData>
//
//final class MemberAPI: MemberAPIProtocol {
//    private let apiClient: APIClient
//    
//    init(apiClient: APIClient = .shared) {
//        self.apiClient = apiClient
//    }
//    
//    func checkNicknameDuplicate(_ nickname: String, refreshToken: String) -> Single<NicknameDuplicateResponse> {
//        let headers = ["jwt-token": refreshToken]
//        let params: [String: Any] = ["nickName": nickname]
//        
//        return apiClient.request(
//            endpoint: "/member/profile/nickName_duplicate_check",
//            method: .POST,
//            parameters: params,
//            headers: headers
//        )
//    }
//    
//    func createDefaultProfile(request: DefaultProfileRequest, refreshToken: String) -> Single<DefaultProfileResponse> {
//        let headers = ["jwt-token": refreshToken]
//        let params: [String: Any] = [
//            "id": request.id,
//            "characterImgRef": request.characterImgRef,
//            "name": request.name,
//            "description": request.description
//        ]
//        
//        return apiClient.request(
//            endpoint: "/member/profile/default_profile",
//            method: .POST,
//            parameters: params,
//            headers: headers
//        )
//    }
//}
