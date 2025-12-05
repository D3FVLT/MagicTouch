import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                Divider()
                touchZonesSection
                Divider()
                zoneThresholdsSection
                Divider()
                advancedSection
                Divider()
                actionsSection
            }
            .padding(24)
        }
        .frame(minWidth: 480, minHeight: 550)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("MagicTouch")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("Customize your Magic Mouse touch events")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $settings.isEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .scaleEffect(1.2)
        }
    }
    
    private var touchZonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Touch Zone Actions", systemImage: "hand.point.up.left.fill")
                .font(.headline)
            
            touchZoneVisualizer
            
            VStack(spacing: 12) {
                actionPicker(title: "Left Zone", icon: "arrow.left.circle.fill", color: .blue, action: $settings.leftTapAction)
                actionPicker(title: "Right Zone", icon: "arrow.right.circle.fill", color: .orange, action: $settings.rightTapAction)
            }
        }
    }
    
    private var touchZoneVisualizer: some View {
        ZStack {
            HStack(spacing: 0) {
                Color.blue.opacity(0.25)
                Color.orange.opacity(0.25)
            }
            
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 2)
                    .position(x: geometry.size.width * CGFloat(settings.leftZoneThreshold), y: geometry.size.height / 2)
            }
            
            HStack {
                VStack(spacing: 4) {
                    Text("Left")
                        .font(.system(size: 13, weight: .semibold))
                    Text(settings.leftTapAction.description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 4) {
                    Text("Right")
                        .font(.system(size: 13, weight: .semibold))
                    Text(settings.rightTapAction.description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .drawingGroup()
    }
    
    private func actionPicker(title: String, icon: String, color: Color, action: Binding<TapAction>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .frame(width: 100, alignment: .leading)
            
            Picker("", selection: action) {
                ForEach(TapAction.allCases, id: \.self) { tapAction in
                    Text(tapAction.description).tag(tapAction)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 150)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var zoneThresholdsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Zone Boundary", systemImage: "slider.horizontal.3")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Split position:")
                    Spacer()
                    Text("\(Int(settings.leftZoneThreshold * 100))%")
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                
                HStack(spacing: 12) {
                    Text("Left")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Slider(value: $settings.leftZoneThreshold, in: 0.2...0.8, step: 0.05)
                    
                    Text("Right")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding(16)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var advancedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Advanced", systemImage: "gearshape.2.fill")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $settings.launchAtLogin) {
                    VStack(alignment: .leading) {
                        Text("Launch at Login")
                        Text("Start MagicTouch automatically when you log in")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                Toggle(isOn: $settings.includeBuiltInTrackpad) {
                    VStack(alignment: .leading) {
                        Text("Include Built-in Trackpad")
                        Text("Also handle touch events from MacBook trackpad")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Tap Sensitivity")
                        Spacer()
                        Text("\(Int(settings.tapSensitivity * 1000))ms")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $settings.tapSensitivity, in: 0.1...0.5, step: 0.05)
                    
                    Text("Maximum duration for a touch to be registered as a tap")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var actionsSection: some View {
        HStack {
            Button(action: { showingResetAlert = true }) {
                Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
            }
            .alert("Reset Settings?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) { settings.resetToDefaults() }
            } message: {
                Text("This will reset all settings to their default values.")
            }
            
            Spacer()
            
            Button(action: checkAccessibility) {
                Label("Check Accessibility", systemImage: "lock.shield")
            }
        }
    }
    
    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if trusted {
            let alert = NSAlert()
            alert.messageText = "Accessibility Access Granted"
            alert.informativeText = "MagicTouch has the necessary permissions to generate click events."
            alert.alertStyle = .informational
            alert.runModal()
        }
    }
}
