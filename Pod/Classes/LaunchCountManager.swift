//
//  LaunchCountManager.swift
//  Vibalarm
//
//  Created by ryutamaki on 2015/10/06.
//  Copyright © 2015年 ryutamaki. All rights reserved.
//

import UIKit

class LaunchCountManager: NSObject {

    static private let VERSIONS: String = "versions"

    static let sharedManager: LaunchCountManager = LaunchCountManager()

    static func launch() {
        LaunchCountManager.sharedManager.launch()
    }

    //MARK: - Instance
    private var defaults: NSUserDefaults
    internal private(set) var versions: [String]

    override init() {
        self.defaults = NSUserDefaults.standardUserDefaults()
        self.versions = (self.defaults.arrayForKey(LaunchCountManager.VERSIONS) as? [String]) ?? Array()

        super.init()
    }

    internal func launch() {
        if let currentVersion = self.currentVersion() {

            // first, count up
            var count: Int = self.defaults.integerForKey(currentVersion)
            self.defaults.setInteger(++count, forKey: currentVersion)
            // second, check is first time
            if self.isFirstLaunchForCurrentVersion() {
                self.versions.append(currentVersion)
                self.defaults.setObject(self.versions, forKey: LaunchCountManager.VERSIONS)
            }

            // last, you should synchronize
            self.defaults.synchronize()
        }
    }

    internal func isFirstLaunchForAllVersions() -> Bool {
        var totalLaunchCount: Int = 0
        for version in self.versions {
            totalLaunchCount += self.launchCountForVersion(version)
            if totalLaunchCount > 1 {
                return false
            }
        }
        return true
    }

    internal func isFirstLaunchForCurrentVersion() -> Bool {
        if let currentVersion = self.currentVersion() {
            return self.isFirstLaunchForVersion(currentVersion)
        }
        return true
    }

    internal func isFirstLaunchForVersion(version: String) -> Bool {
        return self.launchCountForVersion(version) == 1 ? true : false
    }


    internal func launchCountForCurrentVersion() -> Int {
        if let currentVersion = self.currentVersion() {
            return self.launchCountForVersion(currentVersion)
        }
        return 0
    }

    internal func launchCountForVersion(version: String) -> Int {
        return self.defaults.integerForKey(version) ?? 0
    }

    internal func currentVersion() -> String? {
        if let infoDictionary = NSBundle.mainBundle().infoDictionary {
            if let shortVersionString = infoDictionary["CFBundleShortVersionString"] {
                return shortVersionString as? String
            }
        }
        return nil
    }
}
