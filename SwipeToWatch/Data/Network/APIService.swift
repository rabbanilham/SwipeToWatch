//
//  APIService.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 26/01/2025.
//

import Alamofire
import Foundation

class APIService {
    static let shared = APIService()
    static let baseUrl = "https://6794514b5eae7e5c4d9128d9.mockapi.io/v1/"
    
    private init() {}
    
    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 600
        configuration.timeoutIntervalForRequest = 600
        
        return Session(configuration: configuration, eventMonitors: [NetworkLogger()])
    }()
    
    func networkRequest<T: Codable>(
        baseUrl: String = APIService.baseUrl,
        endUrl: String,
        type: T.Type,
        headers: [String: String] = [:],
        parameters: [String: Any]? = nil,
        method: HTTPMethod,
        completion: @escaping (T?, Error?) -> Void
    ) {
        let fullUrl = "\(baseUrl)\(endUrl)"
        
        let finalHeaders: HTTPHeaders = {
            var finalHeaders = HTTPHeaders(headers)
            
            return finalHeaders
        }()

        sessionManager.request(
            fullUrl,
            method: method,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: finalHeaders
        )
        .validate(statusCode: 200...599)
        .responseDecodable(of: T.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func networkRequest<T: Codable>(
        baseUrl: String = APIService.baseUrl,
        endUrl: String,
        type: T.Type,
        headers: [String: String] = [:],
        parameters: [String: Any]? = nil,
        method: HTTPMethod
    ) async throws -> T {
        let fullUrl = "\(baseUrl)\(endUrl)"
        
        let finalHeaders: HTTPHeaders = {
            var finalHeaders = HTTPHeaders(headers)
            return finalHeaders
        }()
        
        return try await withCheckedThrowingContinuation { continuation in
            sessionManager.request(
                fullUrl,
                method: method,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: finalHeaders
            )
            .validate(statusCode: 200...599)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
