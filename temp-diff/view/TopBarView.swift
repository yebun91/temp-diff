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
    @EnvironmentObject var locationDataManager: LocationDataManager
    @State private var showingInfoModal = false
    
    var body: some View {
        HStack {
            Button(action: {
                showingInfoModal = true
            }) {
                Image("info-icon")
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
            if let locationName = locationDataManager.locationName {
                Text(locationName)
                    .foregroundColor(Color("text"))
            } else {
                Text("Location not available")
                    .foregroundColor(Color("text"))
            }
            Spacer()
            IconButtonView(imageName: "location-dot-solid")
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
            // 사용자가 사용자가 해당 앱에 대해 '접근 허용'이라는 권한을 설정했는지를 확인하는 조건문
            if locationDataManager.getAuthorizationStatus() == .authorizedWhenInUse || locationDataManager.getAuthorizationStatus() == .authorizedAlways {
                Task {
                    // 위치 데이터 가져옴
                    locationDataManager.requestLocation()
                }
            } else {
                showSettingsAlert = true
            }
   
        }) {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("text"))
                .frame(width: 30, height: 30)
        }
//        .background(showSettingsAlert ? SettingsLauncher() : nil) 
        // 사용자가 위치정보를 허용하지 않았을 경우 설정화면으로 이동시킴
        .onChange(of: showSettingsAlert) { newValue in
            if newValue {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                showSettingsAlert = false // 상태 리셋
            }
        }
    }
}


//struct SettingsLauncher: UIViewControllerRepresentable {
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        // This function doesn't need to do anything for an alert.
//    }
//    
//    typealias UIViewControllerType = UIViewController
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let alert = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                // If general settings page opens (URL scheme is available in iOS 8 and later.)
//                UIApplication.shared.open(url)
//            }
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        
//        let viewController = UIViewController()
//        viewController.view.isHidden = true
//        DispatchQueue.main.async {
//            viewController.present(alert, animated: true, completion: nil)
//        }
//        
//        return viewController
//    }
//}
