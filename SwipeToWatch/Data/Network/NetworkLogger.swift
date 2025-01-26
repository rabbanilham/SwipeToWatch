//
//  NetworkLogger.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 26/01/2025.
//


import Alamofire

final class NetworkLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        let allHeaders = request.request.flatMap { $0.allHTTPHeaderFields.map { $0.description } } ?? "None"
        let body = request.request.flatMap { $0.httpBody.map { String(decoding: $0, as: UTF8.self) } } ?? "None"
        let message = """
            Request Started: \(request)
            Headers: \(allHeaders)
            Body Data: \(body)
            """
        print(message)
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: AFDataResponse<Value>) {
        let message = """
            Response Received: \(response.debugDescription)
            """
        print(message)
    }
}