//
//  SettingsView.swift
//  MeraGhar
//
//  Created by Yaduraj Singh on 05/10/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("espIPAddress") private var espIPAddress: String = "10.37.55.116"
    @AppStorage("espPort") private var espPort: String = "80"
    @AppStorage("autoConnect") private var autoConnect: Bool = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    
    @State private var showingSaveConfirmation = false
    
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
                    
                    // Settings sections
                    VStack(spacing: 20) {
                        // ESP Configuration Section
                        settingsSection(title: "ESP Configuration") {
                            VStack(spacing: 16) {
                                SettingsTextField(
                                    title: "IP Address",
                                    placeholder: "192.168.1.100",
                                    text: $espIPAddress,
                                    icon: "network"
                                )
                                
                                SettingsTextField(
                                    title: "Port",
                                    placeholder: "80",
                                    text: $espPort,
                                    icon: "number"
                                )
                            }
                        }
                        
                        // Connection Section
                        settingsSection(title: "Connection") {
                            VStack(spacing: 16) {
                                SettingsToggle(
                                    title: "Auto Connect",
                                    subtitle: "Connect automatically on app launch",
                                    isOn: $autoConnect,
                                    icon: "bolt.fill"
                                )
                            }
                        }
                        
                        // Notifications Section
                        settingsSection(title: "Notifications") {
                            VStack(spacing: 16) {
                                SettingsToggle(
                                    title: "Enable Notifications",
                                    subtitle: "Get alerts for device status",
                                    isOn: $notificationsEnabled,
                                    icon: "bell.fill"
                                )
                            }
                        }
                        
                        // Test Connection Button
                        testConnectionButton
                        
                        // App Info
                        appInfoSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            
            // Save confirmation overlay
            if showingSaveConfirmation {
                saveConfirmationOverlay
            }
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.system(size: 40, weight: .thin, design: .default))
                    .foregroundColor(.white)
                    .tracking(4)
                
                Text("Configure your smart home")
                    .font(.system(size: 14, weight: .light, design: .default))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
            }
            
            Spacer()
            
            // Close button
            Button(action: {
                dismiss()
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
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .buttonStyle(GlassButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .default))
                .foregroundColor(.white.opacity(0.5))
                .tracking(2)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
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
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                content()
                    .padding(20)
            }
        }
    }
    
    private var testConnectionButton: some View {
        Button(action: {
            testConnection()
        }) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 16, weight: .light))
                
                Text("Test Connection")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .tracking(1)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(GlassButtonStyle())
        .padding(.top, 10)
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 8) {
            Text("MeraGhar v1.0")
                .font(.system(size: 12, weight: .light, design: .default))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1)
            
            Text("Smart Home Automation")
                .font(.system(size: 10, weight: .ultraLight, design: .default))
                .foregroundColor(.white.opacity(0.3))
                .tracking(2)
        }
        .padding(.top, 30)
    }
    
    private var saveConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text("Settings Saved")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .tracking(1)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .transition(.opacity)
    }
    
    private func testConnection() {
        // TODO: Implement actual ESP connection test
        let urlString = "http://\(espIPAddress):\(espPort)/status"
        print("Testing connection to: \(urlString)")
        
        // Show confirmation
        withAnimation {
            showingSaveConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSaveConfirmation = false
            }
        }
    }
}

// Settings Text Field Component
struct SettingsTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1)
            }
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 16, weight: .light))
                }
                .font(.system(size: 16, weight: .light, design: .default))
                .foregroundColor(.white)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .autocapitalization(.none)
                .keyboardType(icon == "number" ? .numberPad : .default)
        }
    }
}

// Settings Toggle Component
struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .tracking(0.5)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .light, design: .default))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(0.5)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.white.opacity(0.8))
        }
    }
}

// Custom placeholder modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    SettingsView()
}
