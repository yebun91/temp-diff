//
//  AdView.swift
//  Temp diff
//
//  Created by 최유진 on 5/11/24.
//

import SwiftUI
import GoogleMobileAds

struct AdView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        
        // 광고 아이디 변경
        banner.adUnitID = "ca-app-pub-3042544566315852/7100925233"
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            banner.rootViewController = scene.windows.first?.rootViewController
        }
        
        let request = GADRequest()
        banner.load(request)
        
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
    }
}
