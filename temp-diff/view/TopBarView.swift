//
//  TopBarView.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import Foundation
import SwiftUI
import CoreLocation

/**
 상단 바를 정의하는 별도의 뷰
 */
struct TopBarView: View {
    @State private var locationName = "Loading..."
    @EnvironmentObject var locationDataManager: LocationDataManager
    @Binding var showingInfoModal: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                showingInfoModal = true
            }) {
                Image(systemName: "info-icon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("text"))
                    .frame(width: 30, height: 30)
                    .fullScreenCover(isPresented: $showingInfoModal, content: {
                        AppInfoView()
                    })
            }
            Spacer()
            Text(locationName)
                .foregroundColor(Color("text"))
            Spacer()
            IconButtonView(imageName: "location-dot-solid")
        }
        .onAppear {
            // 위치 데이터가 업데이트 될 때마다 fetchLocationName를 호출
            NotificationCenter.default.addObserver(forName: Notification.Name("LocationUpdated"), object: nil, queue: .main) { _ in
                Task {
                    await fetchLocationName()
                }
            }
        }
        // 화면이 사라지게 되면 구독 취소
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("LocationUpdated"), object: nil)
        }
        
    }
    func fetchLocationName() async {
        let location = CLLocation(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
        
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                print("No valid placemarks found.")
                return
            }
            
            locationName = placemark.subLocality ?? "Unknown Location"
        } catch {
            print("Unable to reverse geocode the given location. Error: \(error)")
        }
    }
}


/**
 아이콘 버튼을 정의하는 별도의 뷰
 */
struct IconButtonView: View {
    @EnvironmentObject var weatherKitManager: WeatherKitManager
    @EnvironmentObject var locationDataManager: LocationDataManager
    
    @State private var showSettingsAlert = false
    
    let imageName: String
    
    var body: some View {
        Button(action: {
            // 로케이션 버튼을 클릭했을 경우
            if imageName == "location-dot-solid" {
                // 사용자가 사용자가 해당 앱에 대해 '앱 사용 중에만 위치 접근 허용'이라는 권한을 설정했는지를 확인하는 조건문
                if locationDataManager.authorizationStatus == .authorizedWhenInUse {
                    Task {
                        await weatherKitManager.getWeathersFromYesterdayToTomorrow(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                    }
                } else {
                    showSettingsAlert = false
                    showSettingsAlert = true
                    // SwiftUI가 이 변화를 감지하고 관련된 View를 업데이트하도록 먼저 showSettingsAlert = false로 설정함으로써 상태를 변경하고, 바로 다음 줄에서 showSettingsAlert = true로 다시 설정하여 실제로 원하는 상태(경고창을 표시하는 상태)로 만듦.
                }
            }
        }) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("text"))
                .frame(width: 30, height: 30)
        }
        .background(showSettingsAlert ? SettingsLauncher() : nil) // 사용자가 위치정보를 허용하지 않았을 경우 설정화면으로 이동시킴
    }
}


struct SettingsLauncher: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // This function doesn't need to do anything for an alert.
    }
    
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        let alert = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                // If general settings page opens (URL scheme is available in iOS 8 and later.)
                UIApplication.shared.open(url)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        let viewController = UIViewController()
        viewController.view.isHidden = true
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
        
        return viewController
    }
}
