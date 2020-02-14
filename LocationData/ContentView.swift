//
//  ContentView.swift
//  LocationData
//
//  Created by iMac on 2/11/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import SwiftUI
import MapKit
struct ContentView: View {
  @State private var locationName: String = "" {
    didSet {
      LocationManager.shared.currentLocationName = self.locationName
    }
  }
  @State private var isUpdatingLocation: Bool = false
  @State private var dataSaved: Bool = true
  @State private var dataCancelled: Bool = false
  @State private var showingData: Bool = false
  @State private var hasRecorded: Bool = false
  var body: some View {
    
    VStack(alignment: .center){
      if self.isUpdatingLocation == false {
        Button(action: {
          LocationManager.shared.requestForLocation()
          LocationManager.shared.updatingLocation()
          self.isUpdatingLocation = true
          self.dataCancelled = false
          self.dataSaved = false
          self.hasRecorded = true
          CoreDataManager.shared.locationAdded = []
        }) {
          Text("Start update")
          
        }
        Divider().opacity(0)
      }
      if self.isUpdatingLocation == true {
        Button(action: {
          self.isUpdatingLocation = false
          LocationManager.shared.stopLocation()
        }) {
          Text("Stop/save as..")
        }
      }
      
      if self.isUpdatingLocation == false && self.dataSaved == false  && self.hasRecorded && self.dataCancelled == false{
        HStack(alignment: .top) {
          TextField("Nhập tên bản ghi", text: $locationName).frame(width: 150, height: 20, alignment: .leading)
          Button(action: {
            if(CoreDataManager.shared.save()) {
              self.dataSaved = true
            }
          }) {
            Text("Save")
          }.frame(width: 50, height: 20, alignment: .leading)
          Button(action: {
            CoreDataManager.shared.cancel()
            self.dataCancelled = true
          }) {
            Text("Cancel")
          }
        }
      }
      Divider().opacity(0)
      if self.dataSaved && self.hasRecorded {
        Button(action: {
          self.showingData = true
        }) {
          Text("Show data")
        }.sheet(isPresented: $showingData) {
          DataMap()
        }
      }
      
    }
  }
}
struct AllTabView: View {
  
  @State var selected = 0
  var body: some View {
    TabView(selection: $selected) {
      ContentView().tabItem{
        
        Image(systemName: "house.fill")
        Text("Home")
      }.tag(0)
      Text("show recent data").tabItem{
        
        Image(systemName: "doc.richtext")
        Text("History")
      }.tag(1)
    }
  }
}
struct AllTabViewView_Previews: PreviewProvider {
  static var previews: some View {
    AllTabView()
  }
}
struct DataMap: View {
  @Environment(\.presentationMode) var presentationMode
  @State private var centerCoordinate = LocationManager.shared.myLocation?.coordinate ?? CLLocationCoordinate2D()
  var body: some View {
    ZStack {
      MapView(centerCoordinate: $centerCoordinate)
        .edgesIgnoringSafeArea(.all)
      Circle()
        .fill(Color.blue)
        .opacity(0.3)
        .frame(width: 32, height: 32)
      Button("Dismiss") {
        self.presentationMode.wrappedValue.dismiss()
      }.position(x: 50, y:30)
    }
    
    
    
  }
  
}
