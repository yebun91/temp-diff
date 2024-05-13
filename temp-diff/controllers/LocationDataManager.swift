//
//  LocationDataManager.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import CoreLocation
import Foundation

// 위치 데이터를 관리하고, 위치 서비스에 관련된 권한을 처리하는 데 사용됨.
class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    // 사용자로부터 위치 서비스에 대한 권한이 어떻게 설정되었는지를 나타냅니다. 예를 들어, 사용자가 위치 서비스를 허용했는지, 거부했는지 등의 상태를 저장합니다.
    @Published var authorizationStatus: CLAuthorizationStatus?
    // 기본적으로 세팅된 경도 위도 값.
    @Published var latitude: Double = 35.118889
    @Published var longitude: Double = 126.874133
    
    weak var weatherKitManager: WeatherKitManager?
    var locationManager = CLLocationManager()
    
    // 사용자의 마지막 위치를 저장하거나 불러올 수 있는 computed property를 추가합니다.
    var lastLocation: CLLocationCoordinate2D {
        get {
            let latitude = UserDefaults.standard.double(forKey: "latitude")
            let longitude = UserDefaults.standard.double(forKey: "longitude")
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            UserDefaults.standard.set(newValue.latitude, forKey: "latitude")
            UserDefaults.standard.set(newValue.longitude, forKey: "longitude")
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        
        // 초기화될 때 마지막 위치를 불러옵니다.
        let location = self.lastLocation
        self.latitude = location.latitude
        self.longitude = location.longitude
    }
    
    //locationManagerDidChangeAuthorization(_:) 함수는 CLLocationManagerDelegate 프로토콜의 일부로, 위치 관리자(CLLocationManager)의 권한 상태가 변경될 때마다 자동으로 호출됩니다. 이 함수는 직접 호출하는 것이 아니라 위치 관리자에 의해 자동으로 실행됩니다. 위치 관리자의 권한 상태가 변경되는 경우에는 다음과 같습니다:
    // 앱이 처음 위치 서비스를 요청할 때: 사용자가 위치 서비스 권한을 부여하거나 거부할 때 이 메소드가 호출됩니다.
    // 앱의 위치 서비스 권한이 변경될 때: 사용자가 설정에서 앱의 위치 서비스 권한을 수정할 때 이 메소드가 호출됩니다.
    // 앱이 재시작될 때: 앱이 시작될 때 위치 서비스의 현재 권한 상태에 따라 이 메소드가 호출될 수 있습니다.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            // 권한이 부여되었을 때 위치 업데이트를 요청합니다.
            locationManager.requestLocation()
        case .restricted:
            // 위치 서비스에 대한 접근이 제한된 상태입니다.
            authorizationStatus = .restricted
        case .denied:
            // 사용자가 위치 서비스에 대한 접근을 거부한 상태입니다.
            authorizationStatus = .denied
        case .notDetermined:
            // 사용자가 아직 위치 서비스에 대한 권한을 설정하지 않은 상태입니다.
            // manager.requestWhenInUseAuthorization()를 호출하여 위치 서비스 권한을 요청합니다.
            authorizationStatus = .notDetermined
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            
            // 위치가 업데이트되면 UserDefaults에 저장합니다.
            self.lastLocation = location.coordinate
            
            Task {
                await weatherKitManager?.getWeathersFromYesterdayToTomorrow(latitude: self.latitude, longitude: self.longitude)
            }
            // 위치 데이터가 업데이트 된 후, 위치 이름을 가져오기 위해 fetchLocationName을 호출합니다.
            NotificationCenter.default.post(name: NSNotification.Name("LocationUpdated"), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
