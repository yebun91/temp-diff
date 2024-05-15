//
//  LocationDataManager.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import CoreLocation

// 위치 데이터를 관리하고, 위치 서비스에 관련된 권한을 처리하는 데 사용됨.
class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var locationName: String?
    @Published var isLoading = false
    
    var locationManager: CLLocationManager
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        loadLocationFromUserDefaults()
    }
    
    func requestLocation() {
        isLoading = true
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else {
            manager.requestWhenInUseAuthorization()
            isLoading = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.currentLocation = location
        isLoading = false
        
        // 위치 이름을 가져오기 위한 지오코더 사용
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                self.locationName = placemark.subLocality ?? "Unknown"
                self.saveLocationToUserDefaults(location, name: self.locationName)
            } else {
                self.saveLocationToUserDefaults(location, name: "Unknown")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
        isLoading = false
    }
    
    private func saveLocationToUserDefaults(_ location: CLLocation, name: String?) {
        do {
            let locationData = try NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false)
            UserDefaults.standard.set(locationData, forKey: "savedLocation")
            UserDefaults.standard.set(name, forKey: "savedLocationName")
        } catch {
            print("위치 데이터를 저장하는데 실패했습니다: \(error.localizedDescription)")
        }
    }
    
    private func loadLocationFromUserDefaults() {
        guard let locationData = UserDefaults.standard.data(forKey: "savedLocation"),
              let savedLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: locationData) else { return }
        self.currentLocation = savedLocation
        self.locationName = UserDefaults.standard.string(forKey: "savedLocationName")
    }
    
    /**
     현재 위치에 대한 이름정보 가져옴
     */
    func fetchLocationName(location: CLLocation) async {
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                print("No valid placemarks found.")
                return
            }
            
            DispatchQueue.main.async {
                self.locationName = placemark.subLocality ?? "Unknown Location"
            }
        } catch {
            print("Unable to reverse geocode the given location. Error: \(error)")
        }
    }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return self.locationManager.authorizationStatus
    }
}
