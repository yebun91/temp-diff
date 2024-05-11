//
//  WeatherIndicatorView.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import Foundation
import SwiftUI

/**
 날씨 지표(바람, 습도, 강수량 등)를 표시하는 별도의 뷰
 */
struct WeatherIndicatorView: View {
    @EnvironmentObject var weatherKitManager: WeatherKitManager
    
    var body: some View {
        let weathers = weatherKitManager.getWeathers(day: Date())
        let humidity = Int((weathers?.humidity ?? 0.0) * 100)
        let wind = Int(round((weathers?.wind.speed ?? Measurement(value: 0, unit: UnitSpeed.kilometersPerHour)).value))
        
        let precipitation = weathers?.precipitationAmount ?? Measurement(value: 0, unit: UnitLength.millimeters)

        HStack{
            WeatherIndicatorItemView(name: NSLocalizedString("Wind", comment: "은빈이의"), text: "\(wind)km/h").frame(maxWidth: .infinity)
            Spacer()
            WeatherIndicatorItemView(name: NSLocalizedString("Humidity", comment: "아이디어로"), text: "\(humidity)%").frame(maxWidth: .infinity)
            Spacer()
            WeatherIndicatorItemView(name: NSLocalizedString("Rainfall", comment: "앱을 제작함"), text: "\(precipitation)").frame(maxWidth: .infinity)
        }
        Divider().frame(height: 2).background(Color("text")).padding(.bottom)
        
    }
}

/**
 날씨 지표 항목을 정의하는 별도의 뷰
 */
struct WeatherIndicatorItemView: View {
    let name: String
    let text: String
    
    var body: some View {
        VStack{
            Text(name)
                .fontWeight(.bold)
                .foregroundColor(Color("text"))
            Text(text)
                .foregroundColor(Color("text"))
        }.padding()
    }
}
