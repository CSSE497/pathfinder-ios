//
//  RouteAction.swift
//  Pathfinder
//
//  Created by Adam Michael on 11/1/15.
//  Copyright © 2015 Pathfinder. All rights reserved.
//

import Foundation
import CoreLocation

/// A data object containing a commodity, a location and a field indicating pickup or dropoff.
public class RouteAction {

  // MARK: - Enums -

  /// The possible actions that can be performed on commodities by transports.
  public enum Action : CustomStringConvertible {
    case Start
    case Pickup
    case Dropoff

    public var description: String {
      switch self {
      case .Start: return "Start"
      case .Pickup: return "Pickup"
      case .Dropoff: return "Dropoff"
      }
    }
  }

  // MARK: - Instance Variables -

  /// Whether the action is a pickup or dropoff.
  public let action: Action

  /// The commodity that is picked up or dropped off.
  public var commodity: Commodity?

  /// The location where the action is to occur.
  public let location: CLLocationCoordinate2D

  init(action: Action, location: CLLocationCoordinate2D) {
    self.action = action
    self.location = location
  }

  init(action: Action, commodity: Commodity, location: CLLocationCoordinate2D) {
    self.action = action
    self.commodity = commodity
    self.location = location
  }

  class func parse(message: NSDictionary) -> RouteAction? {
    if let actionString = message["action"] as? String {
      let latitude = message["latitude"] as! Double
      let longitude = message["longitude"] as! Double
      let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      print("Attempting to parse RouteAction at location \(location)")
      if actionString == "start" {
        return RouteAction(action: Action.Start, location: location)
      } else if actionString == "pickup" {
        if let commodity = Commodity.parse(message["commodity"] as! NSDictionary) {
          print("Parsed commodity with status \(commodity.status)")
//          if commodity.status == Commodity.Status.Waiting {
            // TODO: Fix this.
            return RouteAction(action: Action.Pickup, commodity: commodity, location: location)
//          }
        }
      } else if actionString == "dropoff" {
        if let commodity = Commodity.parse(message["commodity"] as! NSDictionary) {
          print("Parsed commodity with status \(commodity.status)")
//          if commodity.status == Commodity.Status.Waiting || commodity.status == Commodity.Status.PickedUp {
            // TODO: Fix this
            return RouteAction(action: Action.Dropoff, commodity: commodity, location: location)
//          }
        }
      }
    }
    print("Failed to parse RouteAction: \(message)")
    return nil
  }
}