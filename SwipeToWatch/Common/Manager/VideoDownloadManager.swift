//
//  VideoDownloadManager.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 27/01/2025.
//

import Foundation

final class VideoDownloadManager {
    static let shared = VideoDownloadManager()
    
    private let queue: OperationQueue
    private let videoCache = VideoCache.shared
    
    private init() {
        queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
    }
    
    func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        let operation = BlockOperation { [weak self] in
            guard let self = self else { return }
            
            if let cachedVideoURL = self.videoCache.video(for: url) {
                DispatchQueue.main.async {
                    completion(cachedVideoURL)
                }
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Video download failed: \(String(describing: error))")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                self.videoCache.insertVideo(data, for: url)
                
                let cachedURL = self.videoCache.video(for: url)
                DispatchQueue.main.async {
                    completion(cachedURL)
                }
            }.resume()
        }
        
        queue.addOperation(operation)
    }
}
