//
//  SwipeToWatchTests.swift
//  SwipeToWatchTests
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Alamofire
import XCTest
@testable import SwipeToWatch

@MainActor
final class FeedsViewModelTests: XCTestCase {
    private var viewModel: FeedsViewModel!
    private var mockUserPreference: UserPreference!
    private var mockAPIService: APIService!
    
    override func setUp() {
        super.setUp()
        viewModel = FeedsViewModel()
        mockUserPreference = UserPreference.shared
        mockAPIService = APIService.shared
    }
    
    override func tearDown() {
        viewModel = nil
        mockUserPreference = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func testFetchVideos_withApiCall() async {
        // Arrange
        mockUserPreference.useApiCall = true
        mockUserPreference.shuffleFeeds = false
        mockUserPreference.simulateFetchError = false
        
        // Act
        await viewModel.fetchVideos()
        
        // Assert
        XCTAssertEqual(viewModel.videos.count, 20)
        XCTAssertEqual(viewModel.videos.first?.id, 5896379)
    }
    
    func testFetchVideos_withJsonFile() async {
        // Arrange
        mockUserPreference.useApiCall = false
        mockUserPreference.shuffleFeeds = false
        mockUserPreference.simulateFetchError = false
        
        // Act
        await viewModel.fetchVideos()
        
        // Assert
        XCTAssertEqual(viewModel.videos.count, 80)
        XCTAssertEqual(viewModel.videos.first?.id, 3571264)
    }
    
    func testFetchVideos_withApiError() async {
        // Arrange
        mockUserPreference.useApiCall = true
        mockUserPreference.simulateFetchError = true
        
        // Act
        await viewModel.fetchVideos()
        
        // Assert
        XCTAssertEqual(viewModel.videos.count, 0)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testFetchVideos_withJsonError() async {
        // Arrange
        mockUserPreference.useApiCall = false
        mockUserPreference.simulateFetchError = true
        
        // Act
        await viewModel.fetchVideos()
        
        // Assert
        XCTAssertEqual(viewModel.videos.count, 0)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testToggleLikeVideo() {
        // Arrange
        let video = Video(duration: 16, id: 1, likes: 100)
        let videoId = video.id ?? 0
        viewModel.videos = [video]
        
        // Act to like
        viewModel.toggleLikeVideo(video)
        
        // Assert
        XCTAssertTrue(mockUserPreference.likedVideoIds.contains(videoId))
        XCTAssertEqual(mockUserPreference.likedVideoIds.count, 1)
        
        // Act again to unlike
        viewModel.toggleLikeVideo(video)
        
        // Assert
        XCTAssertFalse(mockUserPreference.likedVideoIds.contains(videoId))
        XCTAssertEqual(mockUserPreference.likedVideoIds.count, 0)
    }
}
