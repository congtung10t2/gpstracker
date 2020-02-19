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
  @State private var locationName: String = ""
  @State private var isUpdatingLocation: Bool = false
  @State private var dataSaved: Bool = true
  @State private var dataCancelled: Bool = false
  @State private var showingData: Bool = false
  @State private var hasRecorded: Bool = false
  var body: some View {
    
    HStack(alignment: .bottom){
      
      Button(action: {
        LocationManager.shared.stopLocation()
        LocationManager.shared.requestForLocation()
        LocationManager.shared.updatingLocation()
        self.isUpdatingLocation = true
        self.dataCancelled = false
        self.dataSaved = false
        self.hasRecorded = true
        CoreDataManager.shared.locationAdded = []
      }) {
        Image("ic-play")
        
      }.frame(width: 100, height: 100, alignment: .bottom).padding(.bottom, 30)
      
      if self.isUpdatingLocation == true && dataSaved == false && dataCancelled == false {
        Button(action: {
          self.alert()
        }) {
          Image("ic-save-as")
        }.frame(width: 100, height: 100, alignment: .bottom).padding(.bottom, 30)
      }
      if self.isUpdatingLocation == true {
        Button(action: {
          LocationManager.shared.stopLocation()
          self.isUpdatingLocation = false
        }) {
          Image("ic-cancel")
        }.frame(width: 100, height: 100, alignment: .bottom).padding(.bottom, 30)
      }
      
      //      if self.isUpdatingLocation == false && self.dataSaved == false  && self.hasRecorded && self.dataCancelled == false{
      //        HStack(alignment: .top) {
      //          TextField("Nhập tên bản ghi", text: $locationName).frame(width: 150, height: 20, alignment: .leading)
      //          Button(action: {
      //            if(CoreDataManager.shared.save(name: self.locationName)) {
      //              self.dataSaved = true
      //            }
      //          }) {
      //            Text("Save")
      //          }.frame(width: 50, height: 20, alignment: .leading)
      //          Button(action: {
      //            CoreDataManager.shared.cancel()
      //            self.dataCancelled = true
      //          }) {
      //            Text("Cancel")
      //          }
      //        }
      //      }
      //      Divider().opacity(0)
      if self.dataSaved && self.hasRecorded {
        Button(action: {
          self.showingData = true
        }) {
          Image("ic-play-list")
        }.sheet(isPresented: $showingData) {
          DataMap()
        }.frame(width: 100, height: 100, alignment: .bottom).padding(.bottom, 30)
      }
      
    }
  }
  private func alert() {
    let alert = UIAlertController(title: "GPS Tracker", message: "", preferredStyle: .alert)
    alert.addTextField() { textField in
      textField.placeholder = "Nhập tên bản ghi"
      
    }
    alert.addAction(UIAlertAction(title: "Đồng ý", style: .default) {  [unowned alert] _ in
      let answer = alert.textFields![0]
      if let text = answer.text {
        
        LocationManager.shared.stopLocation()
        CoreDataManager.shared.save(name: text)
        self.dataSaved = true
      }
      if let controller = topMostViewController() {
        controller.dismiss(animated: true)
        self.dataCancelled = true
      }
    })
    
    alert.addAction(UIAlertAction(title: "Huỷ bỏ", style: .cancel) { _ in
      if let controller = topMostViewController() {
        controller.dismiss(animated: true)
      }
    })
    showAlert(alert: alert)
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
      History().tabItem{
        
        Image(systemName: "doc.richtext")
        Text("History")
      }.tag(1)
    }
  }
}
struct History: View {
  @State private var showingData: Bool = false
  @State var items: [LocationModel] = []
  var body: some View {
    NavigationView {
      List {
        ForEach(items, id: \.self) { data in
          VStack(alignment: .leading) {
            Text(data.name).font(.system(size: 20))
            Text(data.getDateAsString()).font(.system(size: 14)).foregroundColor(.gray)
          }.onTapGesture(perform: {
            CoreDataManager.shared.locationShowing = CoreDataManager.shared.getDataByName(name: data.name)
            self.showingData = true
          }).sheet(isPresented: self.$showingData) {
            
            DataMap()
          }
        }.onDelete(perform: delete)
      }.onAppear(perform: {
        self.items = CoreDataManager.shared.getDataByName()
      })
      
    }.navigationBarTitle("Recent data")
  }
  func delete(at offsets: IndexSet) {
    for ind in offsets {
      let name = items[ind].name
      CoreDataManager.shared.removeDataByName(name: name)
    }
    items.remove(atOffsets: offsets)
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
      Button("Upload") {
        let tracker = Tracker(locations: CoreDataManager.shared.locationShowing)
        tracker.uploadToCloud()
        self.presentationMode.wrappedValue.dismiss()
      }.position(x: UIScreen.main.bounds.width - 100, y: 30)
    }
  }
  
}
func showAlert(alert: UIAlertController) {
  if let controller = topMostViewController() {
    controller.present(alert, animated: true)
  }
}

private func keyWindow() -> UIWindow? {
  return UIApplication.shared.connectedScenes
    .filter {$0.activationState == .foregroundActive}
    .compactMap {$0 as? UIWindowScene}
    .first?.windows.filter {$0.isKeyWindow}.first
}

private func topMostViewController() -> UIViewController? {
  guard let rootController = keyWindow()?.rootViewController else {
    return nil
  }
  return topMostViewController(for: rootController)
}

private func topMostViewController(for controller: UIViewController) -> UIViewController {
  if let presentedController = controller.presentedViewController {
    return topMostViewController(for: presentedController)
  } else if let navigationController = controller as? UINavigationController {
    guard let topController = navigationController.topViewController else {
      return navigationController
    }
    return topMostViewController(for: topController)
  } else if let tabController = controller as? UITabBarController {
    guard let topController = tabController.selectedViewController else {
      return tabController
    }
    return topMostViewController(for: topController)
  }
  return controller
}
