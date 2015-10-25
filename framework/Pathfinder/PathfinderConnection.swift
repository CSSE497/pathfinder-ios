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
  let pathfinderSocketUrl = "ws://108.59.85.151/socket"
  let pathfinderSocket: WebSocket

  init(applicationIdentifier: String) {
    print("PathfinderConnection created, attempting to connect")
    pathfinderSocket = WebSocket(url: NSURL(string: pathfinderSocketUrl)!)
    pathfinderSocket.delegate = self
    pathfinderSocket.connect()
  }


}

// MARK: - WebSocketDelegate
extension PathfinderConnection: WebSocketDelegate {

  func websocketDidConnect(socket: WebSocket) {
    print("PathfinderConnection received connect from \(socket)")

  }

  func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    print("PathfinderConnection received disconnect from \(socket): \(error)")

  }

  func websocketDidReceiveMessage(socket: WebSocket, text: String) {
    print("PathfinderConnection received message from \(socket): \(text)")

  }

  func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    print("PathfinderConnection received data from \(socket): \(data)")
  }
}