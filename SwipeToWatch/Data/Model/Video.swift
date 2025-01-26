//
//  Video.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Foundation

// MARK: - Video

struct Video: Codable {
    let duration: Int?
    let height: Int?
    let id: Int?
    let image: String?
    var likes: Int? // additional
    let tags: [String]?
    let url: String?
    let user: User?
    let videoFiles: [VideoFile]?
    let videoPictures: [VideoPicture]?
    let width: Int?
    
    init(duration: Int? = nil, height: Int? = nil, id: Int? = nil, image: String? = nil, likes: Int? = nil, tags: [String]? = nil, url: String? = nil, user: User? = nil, videoFiles: [VideoFile]? = nil, videoPictures: [VideoPicture]? = nil, width: Int? = nil) {
        self.duration = duration
        self.height = height
        self.id = id
        self.image = image
        self.likes = likes
        self.tags = tags
        self.url = url
        self.user = user
        self.videoFiles = videoFiles
        self.videoPictures = videoPictures
        self.width = width
    }

    enum CodingKeys: String, CodingKey {
        case id, width, height, duration, tags, url, image, user, likes
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
}

// MARK: - VideoFile

struct VideoFile: Codable {
    let fileType: FileType?
    let height: Int?
    let id: Int?
    let link: String?
    let fps: Double?
    let quality: String?
    let size: Int?
    let width: Int?

    enum CodingKeys: String, CodingKey {
        case id, quality, width, height, fps, link, size
        case fileType = "file_type"
    }
}

// MARK: - FileType

enum FileType: String, Codable {
    case videoMp4 = "video/mp4"
}

// MARK: - VideoPicture

public enum VideoQuality: String, Codable {
    case hd = "hd"
    case sd = "sd"
    case uhd = "uhd"
}

// MARK: - VideoPicture

struct VideoPicture: Codable {
    let id, nr: Int?
    let picture: String?
}
