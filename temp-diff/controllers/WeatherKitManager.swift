//
//  WeatherKitManager.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import WeatherKit
import CoreLocation

@MainActor class WeatherKitManager: ObservableObject {
    @Published var weatherInfo : [String: HourWeather] = [:] {
        didSet {
            updateTemp()
        }
    }
    @Published var isLoading = false
    
    func updateTemp() {
        Task {
            self.objectWillChange.send()
        }
    }
    @Published var feelTemperature: String = ""
    
    /**
     어제부터 내일까지의 날씨 데이터를 api로 불러옴
     */
    func getWeathersFromYesterdayToTomorrow(location: CLLocation) async {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: +1, to: now)!
        
        do {
            isLoading = true
            let apiData = try await Task.detached(priority: .userInitiated) {
                return try await WeatherService.shared.weather(for: location, including: .hourly(startDate: yesterday, endDate: tomorrow))
                
            }.value
            
            weatherInfo.removeAll() // weatherInfo 초기화 함.
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH"
            
            for hourWeather in apiData {
                let hourWeatherDateString = formatter.string(from: hourWeather.date)
                weatherInfo[hourWeatherDateString] = hourWeather
            }
            isLoading = false
            
        } catch {
            fatalError("\(error)")
        }
    }
    
    /**
     온도 데이터만 가져옴
     */
    func getTemp(day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH"
        let dayformat = formatter.string(from: day)
        if let temperature = weatherInfo[dayformat]?.temperature {
            let roundedTemp = temperature.value.rounded()
            return String(format: "%.0f", roundedTemp)
        } else {
            return "Loading Weather Data"
        }
    }
    
    /**
     지정한 시간의 날씨 데이터 가져옴
     */
    func getWeathers(day: Date) -> HourWeather? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH"
        let dayformat = formatter.string(from: day)
        if let weathers = weatherInfo[dayformat] {
            return weathers
        } else {
            return nil
        }
    }
    
    /**
     Date에서 현재 시간을 16:00 과 같은 형태로 가져옴
     */
    func hourString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    /**
     어제와 오늘의 온도차를 가져옴
     */
    func calculateFeelTemp(index: Int, sortedKeys: [String]) -> String {
        if index < sortedKeys.count - 24,
           let weatherToday = weatherInfo[sortedKeys[index + 24]],
           let weatherYesterday = weatherInfo[sortedKeys[index]] {
            let tempToday = weatherToday.temperature.value.rounded()
            let tempYesterday = weatherYesterday.temperature.value.rounded()
            let feelTemp = tempToday - tempYesterday
            // 양수일 때 "+" 기호를 붙여줍니다.
            let format = feelTemp > 0 ? "+%.0f" : "%.0f"
            
            return String(format: format, feelTemp)
        }
        return "0"
    }
    
    /**
     날씨 상태에 따른 아이콘 변경
     */
    func getWeatherIconForCondition(condition: WeatherCondition?) -> String {
        guard let condition = condition else { return "clear" }
        switch condition {
        case .blowingDust:
            return "wind"
        case .blizzard:
            return "snow"
        case .blowingSnow:
            return "snow"
        case .breezy:
            return "clear"
        case .clear:
            return "clear"
        case .cloudy:
            return "cloud"
        case .drizzle:
            return "rain"
        case .flurries:
            return "cloud_snow"
        case .foggy:
            return "clear"
        case .freezingDrizzle:
            return "rain"
        case .freezingRain:
            return "rain"
        case .frigid:
            return "clear"
        case .hail:
            return "cloud_snow"
        case .haze:
            return "clear"
        case .heavyRain:
            return "rain"
        case .heavySnow:
            return "snow"
        case .hot:
            return "clear"
        case .hurricane:
            return "wind"
        case .isolatedThunderstorms:
            return "cloud_lighltning"
        case .mostlyClear:
            return "clear"
        case .mostlyCloudy:
            return "sun_cloudy"
        case .partlyCloudy:
            return "sun_cloudy"
        case .rain:
            return "rain"
        case .scatteredThunderstorms:
            return "cloud_lighltning"
        case .sleet:
            return "cloud_snow"
        case .smoky:
            return "clear"
        case .snow:
            return "snow"
        case .strongStorms:
            return "cloud_lighltning"
        case .sunFlurries:
            return "snow"
        case .sunShowers:
            return "rain"
        case .thunderstorms:
            return "cloud_lighltning"
        case .tropicalStorm:
            return "cloud_lighltning"
        case .windy:
            return "wind"
        case .wintryMix:
            return "snow"
        @unknown default:
            return "clear"
        }
    }
}
