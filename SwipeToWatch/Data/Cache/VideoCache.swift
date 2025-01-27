//
//  VideoCache.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Foundation
import AVFoundation

/// Protocol defining the behavior of a video cache.
protocol VideoCacheType: AnyObject {
    // Returns the file URL of the video associated with a given URL
    func video(for url: URL) -> URL?
    
    // Inserts the video file into the cache for the specified URL
    func insertVideo(_ videoData: Data?, for url: URL)
    
    // Removes the video file for the specified URL from the cache
    func removeVideo(for url: URL)
    
    // Removes all videos from the cache
    func removeAllVideos()
}

/// Singleton class responsible for caching videos.
final class VideoCache {
    static let shared = VideoCache()
    
    private let fileManager = FileManager.default
    private let lock = NSLock()
    private let cacheDirectory: URL
    
    /// Initialize VideoCache with a dedicated cache directory
    init() {
        // Create a directory for video caching in the system's temporary directory
        let tempDir = NSTemporaryDirectory()
        cacheDirectory = URL(fileURLWithPath: tempDir).appendingPathComponent("VideoCache", isDirectory: true)
        
        // Ensure the directory exists
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }
}

// MARK: - VideoCacheType

extension VideoCache: VideoCacheType {
    /// Returns the local file URL for the cached video associated with the given URL
    func video(for url: URL) -> URL? {
        lock.lock(); defer { lock.unlock() }
        
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    /// Caches the video file data for the given URL
    func insertVideo(_ videoData: Data?, for url: URL) {
        guard let videoData = videoData else { return removeVideo(for: url) }
        
        lock.lock(); defer { lock.unlock() }
        
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        do {
            // Write the video data to the cache directory
            try videoData.write(to: fileURL)
        } catch {
            print("Failed to cache video: \(error)")
        }
    }
    
    /// Removes the cached video for the given URL
    func removeVideo(for url: URL) {
        lock.lock(); defer { lock.unlock() }
        
        let fileURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// Removes all cached videos
    func removeAllVideos() {
        lock.lock(); defer { lock.unlock() }
        
        do {
            let cachedFiles = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in cachedFiles {
                try fileManager.removeItem(at: file)
                print("Removed cache file at \(file)")
            }
        } catch {
            print("Failed to remove all videos: \(error)")
        }
    }
}

// MARK: - Convenience Subscript

extension VideoCache {
    subscript(_ key: URL) -> URL? {
        get {
            return video(for: key)
        }
        set {
            guard let newValue = newValue else {
                removeVideo(for: key)
                return
            }
            
            do {
                let data = try Data(contentsOf: newValue)
                insertVideo(data, for: key)
            } catch {
                print("Failed to cache video: \(error)")
            }
        }
    }
}
