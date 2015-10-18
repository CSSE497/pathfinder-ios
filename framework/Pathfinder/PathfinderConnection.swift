//
//  PathfinderConnection.swift
//  Pathfinder
//
//  Created by Adam Michael on 10/18/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import Starscream

//// A PathfinderConnection handles communication with the Pathfinder backend. This class is not user-facing and does not need to be seen by client developers.
class PathfinderConnection {
  let pathfinderSocketUrl = "ws://localhost:9000/socket"

}

// MARK: - WebSocketDelegate
extension PathfinderConnection: WebSocketDelegate {

  func websocketDidConnect(socket: WebSocket) {

  }

  func websocketDidDisconnect(socket: WebSocket, error: NSError?) {

  }

  func websocketDidReceiveMessage(socket: WebSocket, text: String) {

  }

  func websocketDidReceiveData(socket: WebSocket, data: NSData) {

  }
}