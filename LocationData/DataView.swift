//
//  DataView.swift
//  LocationData
//
//  Created by iMac on 2/14/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import SwiftUI
import MapKit
struct DataView: View {
  var body: some View {
    MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate))
  }
}

struct DataView_Previews: PreviewProvider {
  static var previews: some View {
    DataView()
  }
}
struct MapView: UIViewRepresentable {
  
  @Binding var centerCoordinate: CLLocationCoordinate2D
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.addOverlay(addPolyline())
    return mapView
  }
  
  func updateUIView(_ view: MKMapView, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  func addPolyline() -> MKPolyline {
    var locations = CoreDataManager.shared.locationAdded.map { CLLocationCoordinate2D(latitude: $0.locationModel.lat, longitude: $0.locationModel.lng) }
    return MKPolyline(coordinates: &locations, count: locations.count)
    
  }
  
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
      self.parent = parent
    }
  }
}
extension MKPointAnnotation {
  static var example: MKPointAnnotation {
    let annotation = MKPointAnnotation()
    annotation.title = "London"
    annotation.subtitle = "Home to the 2012 Summer Olympics."
    annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
    return annotation
  }
}
