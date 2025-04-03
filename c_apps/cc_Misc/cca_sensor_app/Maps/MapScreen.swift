// (C) 2024 A.Voß, a.voss@fh-aachen.de, ios@codebasedlearning.dev

import SwiftUI
import MapKit

struct MapScreen: View {
    // for start/stop updatingLocation
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var locationManager = LocationManager() // before: @StateObject
    
    let coordsITC = CLLocationCoordinate2D(latitude: 50.778899, longitude: 6.059341)
    let coordsAachen = CLLocationCoordinate2D(latitude: 50.7753, longitude: 6.0839)
    
    // camera pos is not always != 0, so we keep the last pos
    @State private var cameraPos: MapCameraPosition
    @State private var coordsLast: CLLocationCoordinate2D
    
    // from start to heart
    @State private var coordsStart: CLLocationCoordinate2D?
    @State private var coordsHeart: CLLocationCoordinate2D?
    @State private var route: MKRoute?
    
    // which marker is set
    @State private var isHeartMode: Bool = true
    
    init() {
        // start with Aachen region
        let region = MKCoordinateRegion(
            center: coordsAachen,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        cameraPos = MapCameraPosition.region(region)
        coordsLast = coordsAachen
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing:0) {
                Divider()
                HeaderText(text: "Straight to the Heart")
                    .padding(.bottom, 5)
                
                // we need a map reader to convert screen coords to map
                MapReader{ reader in
                    Map(position: $cameraPos) {
                        // some markers on the map, could be anything
                        Marker("ITC", coordinate: coordsITC).tint(.blue)
                        // show our settings
                        if let coordsHeart {
                            Marker("Heart", systemImage: "heart", coordinate: coordsHeart).tint(.red)
                        }
                        if let coordsStart {
                            Marker("Start", systemImage: "pin", coordinate: coordsStart).tint(.green)
                        }
                        if let route {
                            MapPolyline(route)
                                .stroke(.red, lineWidth: 5)
                        }
                    }
                    // different styles, also a lot of points of interest
                    .mapStyle(.hybrid(pointsOfInterest: .including(.cafe)))
                    // .ignoresSafeArea()
                    // there are predefined controls, but some of theme are not always visible
                    .mapControls {
                        MapCompass()
                        MapScaleView()
                        MapUserLocationButton()
                    }
                    .onMapCameraChange { context in
                        coordsLast = context.region.center
                    }
                    .safeAreaInset(edge: .bottom) {
                        ZStack(alignment: .bottom) {
                            LocationAndRouteView(
                                isHeartMode: isHeartMode,
                                isRouteDisabled: coordsStart==nil || coordsHeart==nil
                            ) { // locationAction:
                                if let userLocation = locationManager.userLocation {
                                    // not optimal, I like to reuse the current resolution... tbd
                                    let region = MKCoordinateRegion(
                                        center: userLocation,
                                        latitudinalMeters: 1000, longitudinalMeters: 1000)
                                    cameraPos = MapCameraPosition.region(region)
                                    if isHeartMode {
                                        coordsHeart = userLocation
                                        isHeartMode = false
                                    } else {
                                        coordsStart = userLocation
                                    }
                                } else {
                                    // location not set, just init
                                    locationManager.initLocation()
                                }
                            } routeAction: {
                                calcRoute()
                            }
                            GPSView(coords: coordsLast)
                        }
                    }
                    .onTapGesture(perform: { screenCoord in
                        let coords = reader.convert(screenCoord, from: .local)
                        if isHeartMode {
                            coordsHeart = coords
                            isHeartMode = false
                        } else {
                            coordsStart = coords
                        }
                        route = nil
                    })
                }
                ControlView(isHeartMode: $isHeartMode) {
                    route = nil
                    coordsHeart = nil
                    coordsStart = nil
                    isHeartMode = true
                }
            }
        }
        // ask user
        .onAppear {
            locationManager.requestPermission()
        }
        // start or stop sensors
        .onChange(of: scenePhase) { oldState, newState in
            if newState == .active {
                locationManager.startUpdatingLocation()
            } else {
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func calcRoute() {
        guard let coordsStart else { return }
        guard let coordsHeart else { return }
        
        let placeStart = MKPlacemark(coordinate: coordsStart)
        let itemStart = MKMapItem(placemark: placeStart)
        let placeHeart = MKPlacemark(coordinate: coordsHeart)
        let itemHeart = MKMapItem(placemark: placeHeart)
        
        let request = MKDirections.Request()
        request.source = itemStart
        request.destination = itemHeart
        request.requestsAlternateRoutes = false
        request.transportType = .any  // no bike avail... :-(
        
        // unit of asynchronous work
        Task {
            let directions = MKDirections(request: request)
            let results = try await directions.calculate() // it needs some time, so wait for it
            let routes = results.routes
            route = routes.first // nil if collection is empty
        }
    }
}

struct LocationAndRouteView: View {
    var isHeartMode: Bool
    var isRouteDisabled: Bool
    
    var locationAction: () -> Void
    var routeAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: locationAction) {
                Image(systemName: "location.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(isHeartMode ? Color.red : Color.green)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            Button(action: routeAction) {
                //let isDisabled = coordsStart==nil || coordsHeart==nil
                Image(systemName: "car")
                    .foregroundColor(.white)
                    .padding()
                    .background(isRouteDisabled ? Color.clear : Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .disabled(isRouteDisabled)
            }
            
        }.padding(10)
    }
}

struct GPSView: View {
    let coords: CLLocationCoordinate2D?
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text("Lat. \(coords?.latitude ?? 0)")
                    .font(.footnote).foregroundStyle(.white)
                Text("Lon. \(coords?.longitude ?? 0)")
                    .font(.footnote).foregroundStyle(.white)
            }
        }.padding(5)
    }
}

struct ControlView: View {
    @Binding var isHeartMode: Bool
    var clearAction: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isHeartMode ? "heart" : "pin")
                .foregroundColor(.white)
                .padding()
                .background(isHeartMode ? Color.red : Color.green)
                .clipShape(Circle())
                .scaleEffect(0.7, anchor: .center) // instead of .imageScale(.small)
                .frame(height: UIFont.preferredFont(forTextStyle:.footnote).lineHeight)
            Toggle(isOn: $isHeartMode) { }
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .red))
            Spacer()
            Button("Clear", action: clearAction)
                .padding(5)
        }.padding(5)
    }
}

#Preview {
    MapScreen()
}
