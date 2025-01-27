//
//  SettingsViewModel.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 26/01/2025.
//

import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    func handleChangeSettings(name: String, to value: Any) {
        switch name {
        case .playbackQuality:
            if let playbackQuality = value as? VideoQuality {
                UserPreference.shared.playbackQuality = playbackQuality
            }
            
        case .shuffleFeeds:
            if let shuffleFeeds = value as? Bool {
                UserPreference.shared.shuffleFeeds = shuffleFeeds
            }
            
        case .simulateEmptyVideoList:
            if let simulateEmptyVideoList = value as? Bool {
                UserPreference.shared.simulateEmptyVideoList = simulateEmptyVideoList
            }
            
        case .simulateFetchDelay:
            if let simulateFetchDelay = value as? Bool {
                UserPreference.shared.simulateFetchDelay = simulateFetchDelay
            }
            
        case .simulateFetchError:
            if let simulateFetchError = value as? Bool {
                UserPreference.shared.simulateFetchError = simulateFetchError
            }
            
        case .useApiCall:
            if let useApiCall = value as? Bool {
                UserPreference.shared.useApiCall = useApiCall
            }
            
        default:
            break
        }
    }
    
    func clearVideoCache() {
        VideoCache.shared.removeAllVideos()
    }
}

