# Pathfinder iOS Client Library

The Pathfinder iOS Client Library allows developers to easily integrate Pathfinder routing service in their iOS applications.

Pathfinder provides routing as a service, removing the need for developers to implement their own routing logistics. This SDK allows for iOS applications to act as commodities that need transportation or vehicles that provide transportation. Additionally, there is support for viewing routes for sets of commodities and vehicles.

## Getting started

Pathfinder is distributed through CocoaPods. To use Pathfinder in your application, add the following line to your Podfile:

```
pod "Pathfinder"
```

## Using Pathfinder

There are three primary ways for an application to interact with the Pathfinder service; as an observer, a vehicle driver or a commodity transportation requester. In each case you will need to provider an application identifier and a set of user credentials. The application identifier can be obtained from the Pathfinder web portal when you register your application. The user credentials identifier the end user of your application.

All Pathfinder routes are calculated within "clusters". A cluster is just a container that logically distinguishes your data. For instance, you may wish to provide two services from your application that are routed independently. Your user credentials must have access to the cluster you are attempting to connect to.

```swift
let myAppId: String = 'application id from pathfinder web port'
let userCreds = fetchUserCreds()
let pathfinderRef = Pathfinder(applicationIdentifier: myAppId, userCredentials: userCreds)
```

### As an observer

If your application wants to display data regarding all (or some subset of) commodities, vehicles and their routes for a cluster, you will want to do the following:

1. Obtain a cluster reference from the pathfinder object.

    ```swift
    pathfinderRef.defaultCluster { (cluster: Cluster) -> Void in
        self.cluster = cluster
    }
    ```

2. Set your ViewController to be the cluster's delegate via the ClusterDelegate protocol.

    ```swift
    self.cluster.delegate = self
    ```

Your ClusterDelegate will be notified whenever new commodities or vehicles appear, when vehicles move, when commodities are picked up, dropped off or cancelled and when routes are generated.

### As a vehicle driver

If your application logically represents a vehicle driver, you will want to do the following:

1. Determine your vehicle's paremeters. Physical vehicles can be constained by many factors: seats, child seats, bike racks, limits on money that can be transported together, cabbages that can't ride with goats that can't ride with wolfs. Whatever the limiting factors are for your vehicle, create a dictionary of String -> Int that expresses them.

    ```swift
    parameters = [String:Int]()
    parameters['people'] = 4
    parameters['goats'] = 1
    parameters['pizzas'] = 25
    ```

2. Obtain a Vehicle reference for your application.

    ```swift
    pathfinder.connectDeviceAsVehicle(cluster: self.cluster, parameterCapacities: parameters) { (v: Vehicle) -> Void in
        self.vehicle = v
    }
    ```

3. Set your ViewController to be the vehicle's delegate via the VehicleDelegate protocol.

    ```swift
    self.vehicle.delegate = self
    ```

Your VehicleDelegate will be notified whenever the vehicle is assigned a new route, its location updates or it goes offline.


### As a commodity transport requester

If your application requests commodities, you will want to do the following:

1. Determine the physical parameters that your commodity takes up. These parameters should match the constaints that are placed on the vehicles in the same cluster. Any parameters that are not set will be assumed to be zero.

    ```swift
    parameters = [String:Int]()
    parameters['people'] = 2
    ```

2. Initiate the request and obtain a commodity reference from the top-level Pathfinder object.

    ```swift
    pathfinder.requestCommodityTransit(cluster: self.cluster, start: startCoordinates, destination: endCoordinates, parameters: parameters) { (c: Commodity) -> Void in
        self.commodity = c
    }
    ```

3. Set your ViewController to be the commodity's delegate via the CommodityDelegate protocol.

    ```swift
    self.commodity.delegate = self
    ```

Your CommodityDelegate will be notified whenever the commodity is assigned to a route or its pickup/dropoff/cancel status changes.

## Contributing

Pathfinder is an open source project that welcomes community contributions.

### Setting up a development environment

Clone the repository as

```
git clone https://github.com/csse497/pathfinder-ios
```

The framework can be build either through XCode 7 or with the command

```
xcodebuild -workspace framework/Pathfinder.xcworkspace -scheme Pathfinder -sdk iphonesimulator -configuration RELEASE
```

## License

[MIT](https://raw.githubusercontent.com/CSSE497/pathfinder-ios/master/LICENSE).
