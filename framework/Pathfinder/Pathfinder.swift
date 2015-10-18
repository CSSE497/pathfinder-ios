//
//  Pathfinder.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/15/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import Starscream

/**
A connection to the Pathfinder service, specific to one authenticated user belonging to a single application.
*/
public class Pathfinder {
  let appId: String
  let userCreds: String
  
  public init(appId: String, userCreds: String) {
    self.appId = appId
    self.userCreds = userCreds
  }
  
  public func defaultCluster(callback: (c: Cluster) -> Void) {
    
  }
  
  public func clusterById(id: Int, callback: (c: Cluster) -> Void) {
    
  }
  
  public func connectDeviceAsVehicle(c: Cluster, capacities: [String:Int], callback: (v: Vehicle) -> Void) {
    
  }
  
  public func requestCommodityTransit(c: Cluster, params: [String:Int], callback: (c: Commodity) -> Void) {
    
  }
}

// MARK: - WebSocketDelegate
extension Pathfinder: WebSocketDelegate {
  
  public func websocketDidConnect(socket: WebSocket) {
    
  }
  
  public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    
  }
  
  public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
    
  }
  
  public func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    
  }
}