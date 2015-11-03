# Pathfinder iOS Client Library

[![Build Status](https://travis-ci.org/CSSE497/pathfinder-ios.svg)](https://travis-ci.org/CSSE497/pathfinder-ios)

<img align="right" src="https://raw.githubusercontent.com/CSSE497/pathfinder-webclient/dev/app/assets/images/logo-small.png"/>

The Pathfinder iOS Client Library allows developers to easily integrate Pathfinder routing service in their iOS applications.

Pathfinder provides routing as a service, removing the need for developers to implement their own routing logistics. This SDK allows for iOS applications to act as commodities that need transportation or transportation providers. Additionally, there is support for viewing routes for sets of commodities and transportation providers.

To register your application to use Pathfinder, visit our website at [http://thepathfinder.xyz](http://thepathfinder.xyz).

To get up to speed on integrating Pathfinder in your iOS application, checkout the API documentation at [https://csse497.github.io/pathfinder-ios/index.html](https://csse497.github.io/pathfinder-ios/index.html).

## Getting started

Pathfinder is distributed through CocoaPods. To use Pathfinder in your application, add the following line to your Podfile:

```
pod "thepathfinder"
```


## Using Pathfinder

There are three primary ways for an application to interact with the Pathfinder service; as an observer, a transportation provider or a commodity transportation requester. In each case you will need to provider an application identifier and a set of user credentials. The application identifier can be obtained from the Pathfinder web portal when you register your application. The user credentials identifier the end user of your application.

All Pathfinder routes are calculated within "clusters". A cluster is just a container that logically distinguishes your data. For instance, you may wish to provide two services from your application that are routed independently. Your user credentials must have access to the cluster you are attempting to connect to.

```swift
let myAppId: String = 'application id from pathfinder web port'
let userCreds = fetchUserCreds()
let pathfinderRef = Pathfinder(applicationIdentifier: myAppId, userCredentials: userCreds)
```

### As an observer

If your application wants to display data regarding all (or some subset of) commodities, transportation providers and their routes for a cluster, you will want to do the following:

1. Obtain a cluster reference from the pathfinder object. The path specifies your cluster in the hierarchial sub-cluster tree. If no path is passed in, a reference to the top-level default cluster for the application is created.

    ```swift
    let cluster = pathfinderRef.cluster(path: "/USA/East/Boston")
    ```

2. Set your ViewController to be the cluster's delegate via the ClusterDelegate protocol.

    ```swift
    cluster.delegate = self
    ```

3. Connect your cluster to Pathfinder.

    ```swift
    cluster.connect()
    ```

4. Implement the `ClusterDelegate` protocol.

    ```swift
    extension ViewController: ClusterDelegate {
        func connected(cluster: Cluster) {
            cluster.transports().foreach { (t: Transport) -> Void in draw(t) }
            cluster.commodities().foreach { (c: Commodity) -> Void in draw(c) }
        }

        func clusterWasRouted(routes: [Route]) {
            clearOldRoutes()
            routes.foreach { (r: Route) -> Void in draw(r) }
        }

        ...
    }
    ```

Your ClusterDelegate will be notified whenever new commodities or transports appear, when transports move, when commodities are picked up, dropped off or cancelled and when routes are generated.

### As a transport

If your application logically represents a transportation provider, you will want to do the following:

1. Determine your transport's paremeters. Physical vehicles can be constained by many factors: seats, child seats, bike racks, limits on money that can be transported together, cabbages that can't ride with goats that can't ride with wolfs. Whatever the limiting factors are for your transport, create a dictionary of String -> Int that expresses them.

    ```swift
    parameters = [String:Int]()
    parameters['people'] = 4
    parameters['goats'] = 1
    parameters['pizzas'] = 25
    ```

2. Obtain a Transport reference for your application.

    ```swift
    let transport = pathfinder.defaultCluster().createTransport(parameters)
    ```

3. Set your ViewController to be the transport's delegate via the TransportDelegate protocol.

    ```swift
    transport.delegate = self
    ```

4. Connect your transport to Pathfinder

    ```swift
    transport.connect()
    ```

5. Implement the `TransportDelegate` protocol

    ```swift
    extension ViewController: TransportDelegate {
        func wasRouted(transport: Transport, route: Route) {
            drawRouteOnMyMap(route.coordinates())
            drawCommoditiesOnMyMap(route.commodities())
        }
    }
    ```

Your TransportDelegate will be notified whenever the transport is assigned a new route, its location updates or it goes offline.


### As a commodity transport requester

If your application requests commodities, you will want to do the following:

1. Determine the physical parameters that your commodity takes up. These parameters should match the constaints that are placed on the transports in the same cluster. Any parameters that are not set will be assumed to be zero.

    ```swift
    parameters = [String:Int]()
    parameters['people'] = 2
    ```

2. Initiate the request and obtain a commodity reference from the top-level Pathfinder object.

    ```swift
    let commodity = pathfinder.defaultCluster().createCommodity(
        start: startCoordinates, destination: endCoordinates, parameters: parameters)
    ```

3. Set your ViewController to be the commodity's delegate via the CommodityDelegate protocol.

    ```swift
        commodity.delegate = self
    ```

4. Implement the `CommodityDelegate` protocol.

    ```swift
    extension ViewController: CommodityDelegate {
        func connected(commodity: Commodity) {
            draw(commodity)
        }

        func wasRouted(commodity: Commodity, byTransport: Transport, onRoute: Route) {
            byTransport.delegate = self
            byTransport.connect()
            draw(onRoute)
        }

        ...
    }
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
