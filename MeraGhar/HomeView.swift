//
//  HomeView.swift
//  MeraGhar
//
//  Created by Yaduraj Singh on 05/10/25.
//

import SwiftUI

struct HomeView: View {
    @State private var devices: [SmartDevice] = [
        SmartDevice(name: "Fan", icon: "fan.fill", isOn: false, type: .fan)
    ]
    @State private var showingSettings = false
    @AppStorage("espIPAddress") private var espIPAddress: String = "10.37.55.116"
    @AppStorage("espPort") private var espPort: String = "80"
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.1, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerView
                        .padding(.top, 60)
                        .padding(.bottom, 30)
                    
                    // Single Device Card (Centered)
                    VStack {
                        ForEach($devices) { $device in
                            DeviceCard(device: $device, espIP: espIPAddress, espPort: espPort)
                                .frame(maxWidth: 200)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("MeraGhar")
                    .font(.system(size: 40, weight: .thin, design: .default))
                    .foregroundColor(.white)
                    .tracking(4)
                
                Text("Smart Home Control")
                    .font(.system(size: 14, weight: .light, design: .default))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
            }
            
            Spacer()
            
            // Settings button
            Button(action: {
                showingSettings = true
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .buttonStyle(GlassButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

struct DeviceCard: View {
    @Binding var device: SmartDevice
    let espIP: String
    let espPort: String
    @State private var isPressed = false
    @State private var isLoading = false
    
    var body: some View {
        Button(action: {
            sendCommandToESP()
        }) {
            ZStack {
                // Glass morphism background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        device.isOn ?
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(device.isOn ? 0.4 : 0.2),
                                        Color.white.opacity(device.isOn ? 0.2 : 0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: device.isOn ? Color.white.opacity(0.2) : Color.clear, radius: 20, x: 0, y: 10)
                
                // Content
                VStack(spacing: 20) {
                    // Icon with loading indicator
                    ZStack {
                        Circle()
                            .fill(
                                device.isOn ?
                                Color.white.opacity(0.3) :
                                Color.white.opacity(0.1)
                            )
                            .frame(width: 60, height: 60)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: device.icon)
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(device.isOn ? .white : .white.opacity(0.5))
                        }
                    }
                    
                    // Device name
                    Text(device.name)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .tracking(1)
                    
                    // Status
                    Text(device.isOn ? "ON" : "OFF")
                        .font(.system(size: 11, weight: .light, design: .default))
                        .foregroundColor(device.isOn ? .white.opacity(0.9) : .white.opacity(0.4))
                        .tracking(2)
                }
                .padding(.vertical, 30)
            }
        }
        .buttonStyle(GlassButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
    
    private func sendCommandToESP() {
        isLoading = true
        
        // Determine the endpoint based on current state
        let endpoint = device.isOn ? "off" : "on"
        let urlString = "http://\(espIP):\(espPort)/\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            isLoading = false
            return
        }
        
        print("📡 Sending request to: \(urlString)")
        
        // Create URL request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 Response status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        // Success - toggle the state with animation
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            device.isOn.toggle()
                        }
                        print("✅ Device \(device.isOn ? "ON" : "OFF") successfully")
                        
                        // Parse JSON response if available
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("📄 Response: \(json)")
                        }
                    } else {
                        print("⚠️ Unexpected status code: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
}

// Glass button style for modern iOS feel
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Smart Device Model
struct SmartDevice: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var isOn: Bool
    var type: DeviceType
}

enum DeviceType {
    case light
    case fan
    case switch_
    case outlet
}

#Preview {
    HomeView()
}
