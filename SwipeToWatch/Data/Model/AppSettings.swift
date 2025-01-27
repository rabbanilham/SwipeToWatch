//
//  AppSettings.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//


import UIKit

struct AppSettings {
    let description: String?
    let name: String
    let title: String
    
    init(name: String, title: String, description: String? = nil) {
        self.name = name
        self.title = title
        self.description = description
    }
    
    static func allSettings() -> [AppSettings] {
        return [
            .init(name: .clearCache, title: "Clear Cache", description: "Clear all video cache from the phone storage"),
//            .init(name: .preferredOrientation, title: "Preferred Orientation", description: "Only preferred orientation videos will be shown"),
            .init(name: .playbackQuality, title: "Playback Quality"),
            .init(name: .shuffleFeeds, title: "Shuffle Feeds", description: "Feeds will show in random sequence every time"),
            .init(name: .simulateEmptyVideoList, title: "Simulate Empty Video List", description: "No feeds will be shown, showcasing the empty state of feeds page"),
            .init(name: .simulateFetchDelay, title: "Simulate Fetch Delay", description: "Delay fetching videos result by 3 seconds"),
            .init(name: .simulateFetchError, title: "Simulate Fetch Error", description: "Test negative case while fetching feeds"),
            .init(name: .useApiCall, title: "Use API Call", description: "Hit the mock API, simulates API call to fetch feeds")
        ]
    }
}
