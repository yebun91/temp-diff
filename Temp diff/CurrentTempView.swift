//
//  CurrentTempView.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import Foundation
import SwiftUI
import WeatherKit

/**
 현재 온도를 표시하는 별도의 뷰
 */
struct CurrentTempView: View {
    @EnvironmentObject var weatherKitManager: WeatherKitManager
    
    var body: some View {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let todayTemp = Int(weatherKitManager.getTemp(day: today)) ?? 0
        let yesterdayTemp = Int(weatherKitManager.getTemp(day: yesterday)) ?? 0
        let tempDifference =  todayTemp - yesterdayTemp
        
        let weather = weatherKitManager.getWeatherIconForCondition(condition: weatherKitManager.getWeathers(day: today)?.condition)
        
        Divider().frame(height: 2).background(Color("text"))
        VStack(){
            Image("\(weather)")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("text"))
                .frame(width: 60, height: 60)
            VStack(spacing: -20){
                Text(NSLocalizedString("TempDifference", comment: "어제와 오늘의 온도차"))
                    .font(.system(size: 20))
                    .foregroundColor(Color("text"))
                Text("\(tempDifference > 0 ? "+\(tempDifference)" : "\(tempDifference)")")
                    .font(.system(size: 130))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("text"))

            }.frame(maxWidth: .infinity, alignment: .center)
            
            HStack{
                Text(NSLocalizedString("NowTemp", comment: "현재 온도"))
                    .foregroundColor(Color("text"))
                    .font(.system(size: 20))
                Text("\(todayTemp)°C")
                    .foregroundColor(Color("text"))
                    .font(.system(size: 30))
            }.frame(maxWidth: .infinity, alignment: .center)
            
        }
        .frame(maxHeight: .infinity)
    }
}
