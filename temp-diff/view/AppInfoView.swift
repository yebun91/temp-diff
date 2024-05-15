//
//  AppInfoView.swift
//  temp-diff
//
//  Created by 최유진 on 5/13/24.
//

import SwiftUI

struct AppInfoView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 30) {
            Text(NSLocalizedString("appName", comment: "앱 이름"))
                .font(.largeTitle)
                .fontWeight(.bold)
                
            Text("- 도움을 주신 분들 -")
                .font(.title)
                .multilineTextAlignment(.center)
            VStack(){
                Text("아이디어 제공: 박은빈")
                    .font(.body)
                    .multilineTextAlignment(.center)
                Text("어플제작 재촉 담당: 박정우")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            VStack {
                    Text("Data provided by  Weather")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    Link("Apple Weather Legal Attribution", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!)
                        .font(.body)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                }.padding()
            
            Button(action: {
              presentationMode.wrappedValue.dismiss()
            }) {
                Text(NSLocalizedString("close", comment: "닫기"))
                    .padding()
                    .background(Color("reverseText"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .foregroundColor(Color("text"))
    }
}

