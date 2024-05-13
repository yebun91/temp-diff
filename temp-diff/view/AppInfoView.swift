import SwiftUI

struct AppInfoView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("앱 정보")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("이 앱은 SwiftUI로 제작되었습니다.\nAPI 도움을 주신 분들: ...\n기타 등등")
                .font(.body)
                .multilineTextAlignment(.center)
            
            Button(action: {
              presentationMode.wrappedValue.dismiss()
            }) {
                Text("닫기")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
