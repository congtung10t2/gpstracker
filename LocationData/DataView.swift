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
    let overlays = mapView.overlays
    mapView.removeOverlays(overlays)
    mapView.delegate = context.coordinator
    let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
    let first = CoreDataManager.shared.locationShowing.first
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: first!.lat, longitude: first!.lng), span: span)
    mapView.setRegion(region, animated: true)
    let polyline  = addPolyline()
  
    mapView.addOverlay(polyline)
    return mapView
  }
  
  func updateUIView(_ view: MKMapView, context: Context) {
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  func addPolyline() -> MKPolyline {
    var locations = CoreDataManager.shared.locationShowing.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lng) }

    return MKPolyline(coordinates: locations, count: locations.count)
    
  }
  
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
      self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer! {
      if(overlay is MKPolyline) {
        let polylineRender = MKPolylineRenderer(overlay: overlay)
        polylineRender.strokeColor = UIColor.red.withAlphaComponent(0.8)
        return polylineRender
      }
      return nil
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
