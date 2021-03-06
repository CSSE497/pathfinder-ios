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

  // This is a hack.
  var commodityStatuses = Dictionary<Int, Commodity.Status>()

  var transportRouteSubscribers: [Int:Transport]
  var clusterRouteSubscribers: [String:Cluster]

  let pathfinderSocketUrl: String!
  let pathfinderSocket: WebSocket
  let applicationIdentifier: String

  var queuedMessages = [[String:NSObject]]()

  let onConnectFn: String -> Void
  var onAuthenticateFn: (Bool -> Void)?
  var connected = false
  var authenticated: Bool = false

  init(applicationIdentifier: String, onConnectFn: (String) -> Void) {
    pathfinderSocketUrl = "wss://api.thepathfinder.xyz/socket?AppId=\(applicationIdentifier)"
    print("PathfinderConnection created, attempting to connect to \(pathfinderSocketUrl)")
    pathfinderSocket = WebSocket(url: NSURL(string: pathfinderSocketUrl)!)
    self.applicationIdentifier = applicationIdentifier
    self.onConnectFn = onConnectFn

    self.applicationFns = [ApplicationFn]()
    self.clusterFns = [ClusterFn]()
    self.commodityFns = [CommodityFn]()
    self.transportFns = [TransportFn]()

    self.transportRouteSubscribers = [Int:Transport]()
    self.clusterRouteSubscribers = [String:Cluster]()

    pathfinderSocket.delegate = self
    pathfinderSocket.connect()
  }

  func getClusterById(id: String, callback: ClusterFn) {
    clusterFns.append(callback)
    writeData([
      "message": "Read",
      "model": "Cluster",
      "id": id
    ])
  }

  func create(transport: Transport, callback: TransportFn) {
    transportFns.append(callback)
    writeData([
      "message": "Create",
      "model": "Transport",
      "value": [
        "latitude": transport.location!.latitude,
        "longitude": transport.location!.longitude,
        "metadata": transport.metadata!,
        "clusterId": transport.cluster.id
      ]
    ])
  }

  func create(commodity: Commodity, callback: CommodityFn) {
    commodityFns.append(callback)
    writeData([
      "message": "Create",
      "model": "Commodity",
      "value": [
        "startLatitude": commodity.start!.latitude,
        "startLongitude": commodity.start!.longitude,
        "endLatitude": commodity.destination!.latitude,
        "endLongitude": commodity.destination!.longitude,
        "status": commodity.status.description,
        "metadata": commodity.metadata!,
        "clusterId": commodity.cluster.id
      ]
    ])
  }

  func update(transport: Transport, callback: TransportFn) {
    transportFns.append(callback)
    writeData([
      "message": "Update",
      "model": "Transport",
      "id": transport.id!,
      "value": [
        "latitude": transport.location!.latitude,
        "longitude": transport.location!.longitude,
        "status": transport.status.description
      ]
    ])
  }

  func update(commodity: Commodity, callback: CommodityFn) {
    commodityFns.append(callback)
    if (commodity.transport != nil) {
      writeData([
        "message": "Update",
        "model": "Commodity",
        "id": commodity.id!,
        "value": [
          "status": commodity.status.description,
          "transportId": commodity.transport!.id!
        ]
      ])
    } else {
      writeData([
        "message": "Update",
        "model": "Commodity",
        "id": commodity.id!,
        "value": [
          "status": commodity.status.description
        ]
      ])
    }

  }

  func subscribe(cluster: Cluster) {
    clusterRouteSubscribers[cluster.id] = cluster
    writeData([
      "message": "RouteSubscribe",
      "model": "Cluster",
      "id": cluster.id
    ])
  }

  func subscribe(transport: Transport) {
    transportRouteSubscribers[transport.id!] = transport
    writeData([
      "message": "RouteSubscribe",
      "model": "Transport",
      "id": transport.id!
    ])
  }

  func unsubscribe(transport: Transport) {
    writeData([
      "message": "Unsubscribe",
      "model": "Transport",
      "id": transport.id!
      ])
  }

  func subscribe(commodity: Commodity) {
    writeData([
      "message": "Subscribe",
      "model": "Commodity",
      "id": commodity.id!
    ])
  }

  func authenticate(onAuthenticateFn: (Bool) -> Void) {
    self.onAuthenticateFn = onAuthenticateFn
    writeDataNow(["message": "Authenticate"])
  }

  func writeData(data: [String:NSObject]) {
    if connected == true && authenticated == true {
      writeDataNow(data)
    } else {
      print("Waiting to send message: \(data)")
      queuedMessages.append(data)
    }
  }

  func writeDataNow(data: [String:NSObject]) {
    print("Sending message: \(data)")
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
      print("PathfinderConnection handling ApplicationResponse")
      applicationFns.removeFirst()(applicationResponse)
    } else if let clusterResponse: ClusterResponse = ClusterResponse.parse(message) {
      print("PathfinderConnection handling ClusterResponse")
      clusterFns.removeFirst()(clusterResponse)
    } else if let transportResponse: TransportResponse = TransportResponse.parse(message) {
      print("PathfinderConnection handling TransportResponse")
      transportFns.removeFirst()(transportResponse)
    } else if let commodityResponse: CommodityResponse = CommodityResponse.parse(message) {
      print("PathfinderConnection handling CommodityResponse")
      commodityStatuses[commodityResponse.id] = commodityResponse.status
      commodityFns.removeFirst()(commodityResponse)
    } else if let clusterRoutedResponse = ClusterRoutedResponse.parse(message) {
      print("PathfinderConnection handling ClusterRoutedResponse")
      let cluster = clusterRouteSubscribers[clusterRoutedResponse.id]
      cluster?.routes = clusterRoutedResponse.routes
      cluster?.delegate?.clusterWasRouted(clusterRoutedResponse.routes)
    } else if let transportRoutedResponse = TransportRoutedResponse.parse(message) {
      print("PathfinderConnection handling TransportRoutedResponse")
      let transport = transportRouteSubscribers[transportRoutedResponse.route.transport.id!]
      transport?.route = transportRoutedResponse.route
      transport?.delegate?.wasRouted(transportRoutedResponse.route, transport: transport!)
    } else if message["message"] as! String == "ConnectionId" {
      print("PathfinderConnection handling ConnectionId response")
      onConnectFn(message["id"] as! String)
    } else if message["message"] as! String == "Authenticated" {
      print("PathfinderConnection handling Authenticated response")
      self.authenticated = true
      onAuthenticateFn?(true)
      queuedMessages.forEach {  (data: [String:NSObject]) -> Void in
        writeData(data)
      }
      queuedMessages = [[String:NSObject]]()
    } else if message["message"] as! String == "Error" && message["error"] is String && message["error"]!.hasPrefix("Connection refused") {
      onAuthenticateFn?(false)
    } else {
      print("PathfinderConnection handling unparseable message: \(message)")
    }
  }
}

// MARK: - WebSocketDelegate
extension PathfinderConnection: WebSocketDelegate {

  func websocketDidConnect(socket: WebSocket) {
    print("PathfinderConnection received connect from \(socket)")
    connected = true
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
