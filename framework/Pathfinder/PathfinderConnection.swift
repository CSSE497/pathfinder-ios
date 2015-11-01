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
  typealias TransportFn = (TransportResponse) -> Void

  var applicationFns: [ApplicationFn]
  var clusterFns: [ClusterFn]
  var commodityFns: [CommodityFn]
  var transportFns: [TransportFn]

  var transportRouteSubscribers: [Int:Transport]

  let pathfinderSocketUrl = "ws://104.197.63.127:9000/socket"
  let pathfinderSocket: WebSocket
  let applicationIdentifier: String

  var queuedMessages = [[String:NSDictionary]]()

  var connected = false

  init(applicationIdentifier: String) {
    print("PathfinderConnection created, attempting to connect to \(pathfinderSocketUrl)")
    pathfinderSocket = WebSocket(url: NSURL(string: pathfinderSocketUrl)!)
    self.applicationIdentifier = applicationIdentifier

    self.applicationFns = [ApplicationFn]()
    self.clusterFns = [ClusterFn]()
    self.commodityFns = [CommodityFn]()
    self.transportFns = [TransportFn]()

    self.transportRouteSubscribers = [Int:Transport]()

    pathfinderSocket.delegate = self
    pathfinderSocket.connect()
  }

  func getDefaultCluster(callback: ApplicationFn) {
    applicationFns.append(callback)
    writeData([ "getApplicationCluster": [ "id": applicationIdentifier ] ])
  }

  func getClusterById(id: Int, callback: ClusterFn) {
    clusterFns.append(callback)
    writeData([
      "read": [
        "model": "Cluster",
        "id": id
      ]
    ])
  }

  func create(transport: Transport, callback: TransportFn) {
    transportFns.append(callback)
    writeData([
      "create": [
        "model": "Transport",
        "value": [
          "latitude": transport.location!.latitude,
          "longitude": transport.location!.longitude,
          "capacity": transport.capacities.first!.1,
          "clusterId": transport.cluster.id!
        ]
      ]
    ])
  }

  func update(transport: Transport, callback: TransportFn) {
    transportFns.append(callback)
    writeData([
      "update": [
        "model": "Transport",
        "id": transport.id!,
        "value": [
          "latitude": transport.location!.latitude,
          "longitude": transport.location!.longitude
        ]
      ]
    ])
  }

  func subscribe(transport: Transport) {
    transportRouteSubscribers[transport.id!] = transport
    writeData([
      "routeSubscribe": [
        "model": "Transport",
        "id": transport.id!
      ]
    ])
  }

  func writeData(data: [String:NSDictionary]) {
    if connected == true {
      print("Sending message: \(data)")
      do {
        let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(rawValue: 0))
        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
        pathfinderSocket.writeString(jsonString! as String)
      } catch {
        print(error)
      }
    } else {
      print("Waiting to send message: \(data)")
      queuedMessages.append(data)
    }
  }

  func handle(message message: NSDictionary) {
    if let applicationResponse: ApplicationResponse = ApplicationResponse.parse(message) {
      applicationFns.removeFirst()(applicationResponse)
    } else if let clusterResponse: ClusterResponse = ClusterResponse.parse(message) {
      clusterFns.removeFirst()(clusterResponse)
    } else if let transportResponse: TransportResponse = TransportResponse.parse(message) {
      transportFns.removeFirst()(transportResponse)
    } else if let commodityResponse: CommodityResponse = CommodityResponse.parse(message) {
      commodityFns.removeFirst()(commodityResponse)
    } else if let routedResponse = RoutedResponse.parse(message) {
      let transport = transportRouteSubscribers[routedResponse.route.transport.id!]
      transport?.route = routedResponse.route
      transport?.delegate?.wasRouted(routedResponse.route, transport: transport!)
    } else {
      print("PathfinderConnection received unparseable message: \(message)")
    }
  }
}

// MARK: - WebSocketDelegate
extension PathfinderConnection: WebSocketDelegate {

  func websocketDidConnect(socket: WebSocket) {
    print("PathfinderConnection received connect from \(socket)")
    connected = true
    queuedMessages.forEach {  (data: [String:NSDictionary]) -> Void in
      writeData(data)
    }
    queuedMessages = [[String:NSDictionary]]()
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