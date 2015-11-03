//
//  ApplicationResponse.swift
//  Pathfinder
//
//  Created by Adam Michael on 11/1/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation

class ApplicationResponse {
  let defaultId: Int
  let clusterIds: [Int]

  class func parse(message: NSDictionary) -> ApplicationResponse? {
    if let value: NSDictionary = message["applicationCluster"] as? NSDictionary {
      let clusterId = value["clusterId"] as! Int
      return ApplicationResponse(defaultId: clusterId, clusterIds: [Int]())
    }
    return nil
  }

  init(defaultId: Int, clusterIds: [Int]) {
    self.defaultId = defaultId
    self.clusterIds = clusterIds
  }
}