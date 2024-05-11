//
//  ContentView.swift
//  temp-diff
//
//  Created by 최유진 on 5/11/24.
//
import SwiftUI

struct ContentView: View {
    
    @StateObject var weatherKitManager = WeatherKitManager()
    @StateObject var locationDataManager = LocationDataManager()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                TopBarView()
                CurrentTempView()
                WeatherIndicatorView()
                HourlyForecastScrollView()
                AdView().frame(height: 60)
            }.padding()

            if weatherKitManager.isLoading {
                // 로딩 화면 구현
                Color.black.opacity(0.5)
                    .ignoresSafeArea() // 화면 전체를 덮습니다.
                Text("Loading...")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 사용자가 앱을 시작할 때와 앱으로 다시 돌아올 때 모두 최신 날씨 정보를 불러옴.
        .onAppear {
            Task {
                await weatherKitManager.getWeathersFromYesterdayToTomorrow(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
                     }
                 }
        .task{
            locationDataManager.weatherKitManager = weatherKitManager // 인스턴스를 공유합니다.
            await weatherKitManager.getWeathersFromYesterdayToTomorrow(latitude: locationDataManager.latitude, longitude: locationDataManager.longitude)
        }
        .environmentObject(weatherKitManager)
        .environmentObject(locationDataManager)
        .background(Color("backgraund"))
        
    }
}

#Preview {
    ContentView()
}
