//
//  SplashScreenView.swift
//  MeraGhar
//
//  Created by Yaduraj Singh on 05/10/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Minimalist house icon
                    ZStack {
                        // Simple house outline
                        Image(systemName: "house")
                            .font(.system(size: 80, weight: .ultraLight))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(scale)
                    
                    // App name with elegant typography
                    Text("MeraGhar")
                        .font(.system(size: 36, weight: .thin, design: .default))
                        .foregroundColor(.white)
                        .tracking(8)
                        .opacity(opacity)
                    
                    // Subtle tagline
                    Text("Smart Living")
                        .font(.system(size: 12, weight: .ultraLight, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(4)
                        .opacity(opacity)
                        .padding(.top, 4)
                }
            }
            .onAppear {
                // Smooth animations
                withAnimation(.easeIn(duration: 1.0)) {
                    opacity = 1.0
                }
                
                withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                    scale = 1.0
                }
                
                // Navigate to main view after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
