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
  typealias ApplicationFn = (ApplicationResponse) -> Void
  typealias ClusterFn = (ClusterResponse) -> Void
  typealias CommodityFn = (CommodityResponse) -> Void
  typealias VehicleFn = (VehicleResponse) -> Void

  var applicationFns: [ApplicationFn]
  var clusterFns: [ClusterFn]
  var commodityFns: [CommodityFn]
  var vehicleFns: [VehicleFn]


  let pathfinderSocketUrl = "ws://108.59.85.151/socket"
  let pathfinderSocket: WebSocket
  let applicationIdentifier: String

  init(applicationIdentifier: String) {
    print("PathfinderConnection created, attempting to connect")
    pathfinderSocket = WebSocket(url: NSURL(string: pathfinderSocketUrl)!)
    self.applicationIdentifier = applicationIdentifier

    self.applicationFns = [ApplicationFn]()
    self.clusterFns = [ClusterFn]()
    self.commodityFns = [CommodityFn]()
    self.vehicleFns = [VehicleFn]()


    pathfinderSocket.delegate = self
    pathfinderSocket.connect()
  }

  func getDefaultCluster(callback: (resp: ApplicationResponse) -> Void) {
    applicationFns.append(callback)
    writeData([ "getClusters": [ "id": applicationIdentifier ] ])
  }

  func getClusterById(id: Int, callback: (resp: ClusterResponse) -> Void) {
    clusterFns.append(callback)
    writeData([
      "read": [
        "model": "Cluster",
        "id": id
      ]
    ])
  }

  func writeData(data: [String:NSDictionary]) {
    do {
      let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 0))
      let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
      pathfinderSocket.writeString(jsonString! as String)
    } catch {
      print(error)
    }
  }

  func handle(message message: NSDictionary) {
    if let applicationResponse: ApplicationResponse = ApplicationResponse.parse(message) {
      applicationFns.removeFirst()(applicationResponse)
    } else if let clusterResponse: ClusterResponse = ClusterResponse.parse(message) {
      clusterFns.removeFirst()(clusterResponse)
    } else if let commodityResponse: CommodityResponse = CommodityResponse.parse(message) {
      commodityFns.removeFirst()(commodityResponse)
    } else if let vehicleResponse: VehicleResponse = VehicleResponse.parse(message) {
      vehicleFns.removeFirst()(vehicleResponse)
    } else {
      print("PathfinderConnection received unparseable message: \(message)")
    }
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
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers)
      handle(message: json as! NSDictionary)
    } catch {
      print(error)
    }
  }

  func websocketDidReceiveData(socket: WebSocket, data: NSData) {
    print("PathfinderConnection received data from \(socket): \(data)")
  }
}