//
//  FeedsViewModel.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Foundation

@MainActor
class FeedsViewModel: ObservableObject {
    @Published var videos = [Video]()
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchVideos() async {
        isLoading = true
        errorMessage = nil
        let simulateError = UserPreference.shared.simulateFetchError
        
        if UserPreference.shared.useApiCall {
            do {
                let data = try await APIService.shared.networkRequest(
                    endUrl: "videos\(simulateError ? "123" : "")", // purposefully use random path to simulate error if needed
                    type: [Video].self,
                    method: .get
                )
                var videosResponse = VideoListResponse(videos: data)
                videosResponse.addLikesToVideos()
                var videoList = videosResponse.videos ?? []
                if UserPreference.shared.shuffleFeeds {
                    videoList = videoList.shuffled()
                }
                if UserPreference.shared.simulateEmptyVideoList {
                    videoList = []
                }
                isLoading = false
                videos = videoList
                errorMessage = nil
            } catch {
                errorMessage = "Error: \(error)"
                isLoading = false
            }
        } else {
            do {
                let fileName = "video_response\(simulateError ? "123" : "")" // purposefully use random path to simulate error if needed
                guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                    isLoading = false
                    errorMessage = "JSON file not found"
                    return
                }
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                var videosResponse = try decoder.decode(VideoListResponse.self, from: data)
                videosResponse.addLikesToVideos()
                var videoList = videosResponse.videos ?? []
                if UserPreference.shared.shuffleFeeds {
                    videoList = videosResponse.videos?.shuffled() ?? []
                }
                if UserPreference.shared.simulateEmptyVideoList {
                    videoList = []
                }
                videos = videoList
                isLoading = false
                errorMessage = nil
            } catch {
                errorMessage = "Error decoding JSON: \(error)"
                isLoading = false
            }
        }
    }
    
    func toggleLikeVideo(_ video: Video) {
        guard let videoId = video.id else { return }
        if UserPreference.shared.likedVideoIds.contains(videoId) {
            UserPreference.shared.likedVideoIds.removeAll(where: { $0 == videoId })
        } else {
            UserPreference.shared.likedVideoIds.append(videoId)
        }
    }
}
