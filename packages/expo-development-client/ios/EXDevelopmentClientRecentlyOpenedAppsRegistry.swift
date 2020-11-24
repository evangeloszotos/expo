// Copyright 2015-present 650 Industries. All rights reserved.

import Foundation

let RECENTLY_OPENED_APPS_REGISTRY_KEY = "expo.developmentclient.recentlyopenedapps"

let TIME_TO_REMOVE = 60 * 60 * 24 * 3 // 3 days

@objc(EXDevelopmentClientRecentlyOpenedAppsRegistry)
public class EXDevelopmentClientRecentlyOpenedAppsRegistry : NSObject {
  private var appRegistry: [String: Any] {
    get {
      return UserDefaults.standard.dictionary(forKey: RECENTLY_OPENED_APPS_REGISTRY_KEY) ?? [String: Any]()
    }
    set (newAppRegistry) {
      UserDefaults.standard.set(newAppRegistry, forKey: RECENTLY_OPENED_APPS_REGISTRY_KEY)
    }
  }
  
  @objc
  public func appWasOpend(_ url: String, name: String?) {
    var registry = appRegistry
    var appEntry: [String: Any] = ["timestamp": getCurrentTimestamp()]
    if name != nil {
      appEntry["name"] = name
    }
    registry[url] = appEntry;
    appRegistry = registry
  }
  
  @objc
  public func recentlyOpenedApps() -> [String: Any] {
    var toRemove = [String]()
    var result = [String: Any]()
    var registry = appRegistry
    
    (registry as! [String: [String: Any]]).forEach { (url: String, appEntry: [String: Any]) in
      if getCurrentTimestamp() - (appEntry["timestamp"] as! Int64) > TIME_TO_REMOVE {
        toRemove.append(url)
        return
      }
      
      result[url] = appEntry["name"] ?? (NSNull() as Any)
    }
    
    if toRemove.count != 0 {
      toRemove.forEach { (url) in
        registry.removeValue(forKey: url)
      }
    }
        
    return result
  }
  
  private func getCurrentTimestamp() -> Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000);
  }
}
