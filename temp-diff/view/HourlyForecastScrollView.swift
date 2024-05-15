//
//  HourlyForecastScrollView.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import Foundation
import SwiftUI

/**
 시간별 예보를 표시하는 스크롤 뷰
 */
struct HourlyForecastScrollView: View {
    @EnvironmentObject var weatherKitManager: WeatherKitManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                let sortedKeys = Array(weatherKitManager.weatherInfo.keys).sorted().suffix(24)
                ForEach(Array(sortedKeys.enumerated()), id: \.element) { index, hour in
                    let weathersInfo = weatherKitManager.weatherInfo
                    if let weatherToday = weathersInfo[hour] {
                        // 소수점자리 반올림 한 온도로 변경
                        let temp = weatherToday.temperature.value.rounded()
                        
                        // "16:00" 형태의 시간을 얻기 위해
                        let hourOnly = weatherKitManager.hourString(from: weatherToday.date)
                        
                        // 어제와 오늘의 온도차를 가져옴
                        let feelTempString = weatherKitManager.calculateFeelTemp(index: index, sortedKeys: Array(weatherKitManager.weatherInfo.keys).sorted())
                        
                        let weather = weatherKitManager.getWeatherIconForCondition(condition: weatherToday.condition)
                        
                        HourlyForecastView(hour: hourOnly, temp: "\(String(format: "%.0f", temp))°C", feelTemp: feelTempString, weather: weather)
                    }
                }
            }
        }
    }
}

/**
 시간별 예보 항목을 정의하는 별도의 뷰
 */
struct HourlyForecastView: View {
    let hour: String
    let temp: String
    let feelTemp: String
    let weather: String
    
    var body: some View {

        VStack{
            Spacer()
            Text(hour)
                .fontWeight(.semibold)
                .foregroundColor(Color("reverseText"))
            Spacer()
            VStack{
                Image("\(weather)")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("text"))
                    .frame(width: 20, height: 20)
                Text(feelTemp).font(.system(size: 30)).foregroundColor(Color("reverseText"))
                Text(temp)
                    .foregroundColor(Color("reverseText"))
                
            }.frame(maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center)
            .padding(2)
        }.frame(width: 65, height: 150)
            .padding(2)
            .background(Color("custom-white"))
            .cornerRadius(10)
    }
}
