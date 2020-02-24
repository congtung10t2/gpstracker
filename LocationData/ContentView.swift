//
//  ContentView.swift
//  LocationData
//
//  Created by iMac on 2/11/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import SwiftUI
import MapKit
import Firebase
struct ContentView: View {
  @State private var locationName: String = ""
  @State private var isUpdatingLocation: Bool = false
  @State private var dataSaved: Bool = true
  @State private var dataCancelled: Bool = false
  @State private var showingData: Bool = false
  @State private var hasRecorded: Bool = false
  var body: some View {
    
    HStack(alignment: .bottom){
      if self.isUpdatingLocation == false {
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
      }
      
      
      if self.isUpdatingLocation == true && dataSaved == false && dataCancelled == false {
        Button(action: {
          self.isUpdatingLocation = false
          LocationManager.shared.stopLocation()
          self.alert()
        }) {
          Image("ic-save-as")
        }.frame(width: 100, height: 100, alignment: .bottom).padding(.bottom, 30)
      }
//      if self.isUpdatingLocation == true {
//        Button(action: {
//          LocationManager.shared.stopLocation()
//          self.isUpdatingLocation = false
//        }) {
//          Image("ic-cancel")
//        }.frame(width: 100, height: 100, alignment: .bottom).padding(.bottom, 30)
//      }
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
        
        CoreDataManager.shared.save(name: text)
        self.dataSaved = true
      }
      if let controller = topMostViewController() {
        controller.dismiss(animated: true)
        self.dataCancelled = true
      }
    })
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
      showAlert(alert: alert)
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
      History().tabItem{
        
        Image(systemName: "doc.richtext")
        Text("History")
      }.tag(1)
      Clouds().tabItem {
        Image(systemName: "square.and.arrow.down.on.square.fill")
        Text("Clouds")
      }.tag(2)
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
            CoreDataManager.shared.fromCloudTab = false
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
struct Clouds: View {
@State private var showingData: Bool = false
@State var items: [StorageReference] = []
  var body: some View {
    NavigationView {
    List {
      ForEach(items, id: \.self) { data in
        VStack(alignment: .leading) {
//        Text(data.name).font(.system(size: 20))
//        Text(data.getDateAsString()).font(.system(size: 14)).foregroundColor(.gray)
          Text(data.name)
        }.onTapGesture(perform: {
          
          
          data.getData(maxSize: 10 * 1024 * 1024) { data, error in
            do {
              let decoder = JSONDecoder()
              let tracker = try decoder.decode(Tracker.self, from: data!)
              CoreDataManager.shared.fromCloudTab = true
              CoreDataManager.shared.locationShowing = tracker.toLocationModels()
              self.showingData = true
            } catch {
              
            }
            
          }
        }).sheet(isPresented: self.$showingData) {
          
          DataMap()
        }
      }
      }.onAppear(perform: {
        CoreDataManager.shared.getAllCloudsData { (value, error) in
          if let value = value {
            self.items = value
            print(value)
          }
        }
      })
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
      if CoreDataManager.shared.shouldShowUpload() {
        Button("Upload") {
          let tracker = Tracker(locations: CoreDataManager.shared.locationShowing)
          let loading = topMostViewController()?.showLoading()
          tracker.uploadToCloud() { (data, error) in
            if let loading = loading {
              topMostViewController()?.hideLoading(hud: loading)
            }
            if let error = error {
              self.alert(message: "Tải lên thất bại")
            } else {
              self.alert(message: "Tải lên thành công")
            }
            
          }
          self.presentationMode.wrappedValue.dismiss()
        }.position(x: UIScreen.main.bounds.width - 100, y: 30)
      }
      
    }
  }
  private func alert(message: String) {
    let alert = UIAlertController(title: "Trackers", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Đồng ý", style: .default) {  [unowned alert] _ in })
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {

      showAlert(alert: alert)
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
