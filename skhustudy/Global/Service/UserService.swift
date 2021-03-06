//
//  UserService.swift
//  SKHUStudy
//
//  Created by Hee Jae Kim on 2020/05/12.
//  Copyright © 2020 anniversary. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

struct UserService {
    
    private init() {}
    
    static let shared = UserService()
    
    // MARK: - 회원가입
    
    func sendEmail(_ email: String, _ text: String, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = APIConstants.SendEmail
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body : Parameters = [
            "email" : email,
            "myName" : "StudyTogether",
            "subject" : "이메일 인증",
            "text" : text
        ]
        
        AF.request(URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseData{
            response in
            
            switch response.result {
                
            case .success:
                // parameter 위치
                if let _ = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            completion(.success("이메일 전송 성공"))
                        case 409:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default: break
                        }
                    }
                }
                break
                
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
    // MARK: - register(sign up)
    
    func regitser(email: String, password: String, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = APIConstants.Register
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body : Parameters = [
            "email" : email,
            "password" : password
        ]
        
        AF.request(URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseData {
            response in
            
            switch response.result {
                
            case .success:
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            do{
                                let decoder = JSONDecoder()
                                let result = try
                                    decoder.decode(Response.self, from: value)
                                
                                completion(.success(result))
                            } catch {
                                completion(.pathErr)
                            }
                        case 409:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
    // MARK: - Login & out
    
    func login(email: String, password: String, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = APIConstants.Login
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body : Parameters = [
            "email" : email,
            "password" : password
        ]
        
        AF.request(URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseData {
            response in
            
            switch response.result {
                
            case .success:
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            do{
                                let decoder = JSONDecoder()
                                let result = try
                                    decoder.decode(Response.self, from: value)
                                
                                completion(.success(result))
                            } catch {
                                completion(.pathErr)
                            }
                        case 409:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
    func logout(token: String, completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = APIConstants.Logout
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body : Parameters = [
            "token" : token
        ]
        
        AF.request(URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseData {
            response in
            
            switch response.result {
                
            case .success:
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            do{
                                let decoder = JSONDecoder()
                                let result = try
                                    decoder.decode(Response.self, from: value)
                                
                                completion(.success(result))
                            } catch {
                                completion(.pathErr)
                            }
                        case 409:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
    // MARK: - User Information
    
    func getUserInfo(_ userID:String,completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = APIConstants.GetUserInfo
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let param :Parameters = [
            "token": KeychainWrapper.standard.string(forKey: "token"),
            "userID": userID
        ]
        
        AF.request(URL, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseData {
            response in
            
            switch response.result {
                
            case .success:
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            do{
                                let decoder = JSONDecoder()
                                let result = try
                                    decoder.decode(User.self, from: value)
                                
                                completion(.success(result))
                            } catch {
                                completion(.pathErr)
                            }
                        case 409:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
    // MARK: - User Study Information
    
    func getUserStudyInfo(completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let token = KeychainWrapper.standard.string(forKey: "token") ?? ""
        let userID = KeychainWrapper.standard.string(forKey: "userID") ?? ""
        
        let URL = APIConstants.GetUserStudyInfo + "?token=" + token + "&userID=" + userID
        print(URL)
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData {
            response in
            
            switch response.result {
                
            case .success:
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            do{
                                let decoder = JSONDecoder()
                                let result = try
                                    decoder.decode(StudyList.self, from: value)
                                
                                completion(.success(result))
                            } catch {
                                completion(.pathErr)
                            }
                        case 409:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
    // MARK: - Get Category
    func getCategory(completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = APIConstants.GetCategory
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData{
            response in
            
            switch response.result {
                
            case .success:
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            if let rawJSON = try? JSONSerialization.jsonObject(with: value),
                                let json = rawJSON as? [String: Any],
                                let resultsArray = json["data"] as? [[String: Any]]{
                                let categories = resultsArray.compactMap {Category(dictionary: $0)}
                                completion(.success(categories))
                            }
                            
                        case 409:
                            completion(.pathErr)
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
                
                
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
            
        }
    }
    
    // MARK: - Modify User Info
    func modifyUserInfo(token: String, age: Int, gender: Int, nickname: String, introduceMe: String, location: String, pickURL: String, category: [String],completion: @escaping (NetworkResult<Any>) -> Void) {
        
        let URL = APIConstants.ModifyUserInfo
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let body: Parameters
        if category.isEmpty {
            body = [
                "token": token,
                "age": age,
                "sex": gender,
                "nickName": nickname,
                "content": introduceMe,
                "location": location,
                "image": pickURL,
            ]
        } else {
            body = [
                "token": token,
                "age": age,
                "sex": gender,
                "nickName": nickname,
                "content": introduceMe,
                "location": location,
                "image": pickURL,
                "category": category
            ]
        }
        
        AF.request(URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).responseData {
            response in
            
            switch response.result {
                
            case .success:
                if let value = response.value {
                    if let status = response.response?.statusCode {
                        switch status {
                        case 200:
                            do{
                                let decoder = JSONDecoder()
                                let result = try
                                    decoder.decode(User.self, from: value)
                                print("---수정 후----")
                                print(result)
                                completion(.success(result))
                            } catch {
                                completion(.pathErr)
                            }
                        case 409:
                            completion(.pathErr)
                            
                        case 500:
                            completion(.serverErr)
                        default:
                            break
                        }
                    }
                }
                break
            case .failure(let err):
                print(err.localizedDescription)
                completion(.networkFail)
            }
        }
    }
    
}
