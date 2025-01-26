//
//  UserPreference.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Foundation

public final class UserPreference {
    
    public static let shared = UserPreference()
    
    private init () {}
    
    public var userDefault = UserDefaults.standard
    
    public var likedVideoIds: [Int] {
        get {
            guard let data = self.userDefault.data(forKey: .likedVideoIds) else { return [] }
            do {
                let likedVideoIds = try JSONDecoder().decode([Int].self, from: data)
                return likedVideoIds
            } catch {
                
            }
            return []
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                self.userDefault.setValue(data, forKey: .likedVideoIds)
            } catch {
                
            }
        }
    }
    
    public var playbackQuality: VideoQuality {
        get {
            guard let data = self.userDefault.value(forKey: .playbackQuality) as? String else { return .hd }
            return VideoQuality(rawValue: data) ?? .hd
        }
        set {
            self.userDefault.setValue(newValue.rawValue, forKey: .playbackQuality)
        }
    }
    
    public var shuffleFeeds: Bool {
        get {
            guard let value = userDefault.value(forKey: .shuffleFeeds) as? Bool else { return false }
            return value
        }
        set {
            userDefault.set(newValue, forKey: .shuffleFeeds)
        }
    }
    
    public var simulateEmptyVideoList: Bool {
        get {
            guard let value = userDefault.value(forKey: .simulateEmptyVideoList) as? Bool else { return false }
            return value
        }
        set {
            userDefault.set(newValue, forKey: .simulateEmptyVideoList)
        }
    }
    
    public var simulateFetchError: Bool {
        get {
            guard let value = userDefault.value(forKey: .simulateFetchError) as? Bool else { return false }
            return value
        }
        set {
            userDefault.set(newValue, forKey: .simulateFetchError)
        }
    }
    
    public var useApiCall: Bool {
        get {
            guard let value = userDefault.value(forKey: .useApiCall) as? Bool else { return false }
            return value
        }
        set {
            userDefault.set(newValue, forKey: .useApiCall)
        }
    }
}

private extension String {
    static let likedVideoIds = "likedVideoIds"
}
