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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                TopBarView()
                CurrentTempView()
                WeatherIndicatorView()
                HourlyForecastScrollView()
                AdView().frame(height: 60)
            }.padding()

            if weatherKitManager.isLoading || locationDataManager.isLoading {
                // 로딩 화면 구현
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                Text("Loading...")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 사용자가 앱을 시작할 때와 앱으로 다시 돌아올 때 모두 최신 날씨 정보를 불러옴.
        .onAppear {
            Task {
                await fetchInitialData()
            }
        }
        // currentLocation 값이 변경되었을 때 날씨데이터, 지역명데이터를 불러옴
        .onChange(of:locationDataManager.currentLocation, perform: {
            newLocation in Task {
                if let location = newLocation {
                    await weatherKitManager.getWeathersFromYesterdayToTomorrow(location: location)
                    locationDataManager.fetchLocationName(location: location)
                }
            }
        })
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                fetchWeatherData()
            }
        }
        .background(Color("backgraund"))
        .environmentObject(weatherKitManager)
        .environmentObject(locationDataManager)
    }
    
    private func fetchInitialData() async {
        if let location = locationDataManager.currentLocation {
            // 이미 위치 데이터가 있는 경우
            await weatherKitManager.getWeathersFromYesterdayToTomorrow(location: location)
        } else {
            // 위치 데이터가 없는 경우 위치 권한 요청 및 위치 데이터 가져오기
            locationDataManager.requestLocation()
        }
    }
    
    // 화면이 꺼졌다가 다시 켜졌을 때 
    private func fetchWeatherData() {
        if let location = locationDataManager.currentLocation {
            Task {
                await weatherKitManager.getWeathersFromYesterdayToTomorrow(location: location)
            }
        }
    }
}

#Preview {
    ContentView()
}
