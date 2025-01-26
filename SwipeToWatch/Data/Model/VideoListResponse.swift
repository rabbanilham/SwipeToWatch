//
//  VideoListResponse.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Foundation

struct VideoListResponse: Codable {
    let nextPage: String?
    let page: Int?
    let perPage: Int?
    let totalResults: Int?
    let url: String?
    var videos: [Video]?
    
    init(nextPage: String? = nil, page: Int? = nil, perPage: Int? = nil, totalResults: Int? = nil, url: String? = nil, videos: [Video]? = nil) {
        self.nextPage = nextPage
        self.page = page
        self.perPage = perPage
        self.totalResults = totalResults
        self.url = url
        self.videos = videos
    }

    enum CodingKeys: String, CodingKey {
        case page
        case perPage
        case videos
        case totalResults
        case nextPage
        case url
    }
    
    mutating func addLikesToVideos() {
        for (index, video) in (videos ?? []).enumerated() {
            var newVideo = video
            newVideo.likes = Int.random(in: 1...999)
            videos?[index] = newVideo
        }
    }
}
