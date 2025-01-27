//
//  UserPreference.swift
//  SwipeToWatch
//
//  Created by Bagas Ilham on 25/01/2025.
//

import Foundation

public final class UserPreference {
    // MARK: - Singleton -
    public static let shared = UserPreference()
    
    // MARK: - Private Init -
    
    private init () {}
    
    // MARK: - UserDefaults -
    
    public var userDefault = UserDefaults.standard
    
    // MARK: - Preference Properties -
    
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
    
    public var simulateFetchDelay: Bool {
        get {
            guard let value = userDefault.value(forKey: .simulateFetchDelay) as? Bool else { return false }
            return value
        }
        set {
            userDefault.set(newValue, forKey: .simulateFetchDelay)
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

// MARK: - Preference Keys -

private extension String {
    static let likedVideoIds = "likedVideoIds"
}
