import SwiftUI

/// # AppStorage Demo
/// 
/// @AppStorage provides automatic persistence for simple data types.
/// It's backed by UserDefaults and automatically updates the UI when values change.
///
/// ## Supported Types:
/// - Bool, Int, Double, String
/// - Data, URL
/// - RawRepresentable enums (String/Int backed)
/// 
/// ## Key Features:
/// - Automatic UI updates when values change
/// - Persistent across app launches
/// - Shared across the entire app
/// - No manual save/load required

struct AppStorageBasics: View {
    @AppStorage("username") private var username = ""
    
//    @AppStorage("age") private var age = 18
    @State private var age = 18
    
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = true
    @AppStorage("favoriteColor") private var favoriteColor = "Blue"
    @AppStorage("volume") private var volume = 0.5
    
    private let colors = ["Red", "Blue", "Green", "Purple", "Orange"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Types") {
                    // String
                    TextField("Username", text: $username)
                    
                    // Int with Stepper
                    Stepper("Age: \(age)", value: $age, in: 0...120)
                    
                    // Bool with Toggle
                    Toggle("Enable Notifications", isOn: $isNotificationsEnabled)
                    
                    // Double with Slider
                    VStack {
                        Text("Volume: \(volume, specifier: "%.2f")")
                        Slider(value: $volume, in: 0...1)
                    }
                }
                
                Section("Selection") {
                    Picker("Favorite Color", selection: $favoriteColor) {
                        ForEach(colors, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                }
                
                Section("Current Values") {
                    Text("Username: \(username.isEmpty ? "Not set" : username)")
                    Text("Age: \(age)")
                    Text("Notifications: \(isNotificationsEnabled ? "On" : "Off")")
                    Text("Volume: \(volume, specifier: "%.1f")")
                    Text("Favorite Color: \(favoriteColor)")
                }
                
                Section("Test Persistence") {
                    Text("💡 Close and reopen the app to see these values persist!")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("AppStorage Basics")
        }
    }
}

/// Demonstrating different data types with AppStorage
struct AppStorageDataTypes: View {
    @AppStorage("boolValue") private var boolValue = false
    @AppStorage("intValue") private var intValue = 42
    @AppStorage("doubleValue") private var doubleValue = 3.14159
    @AppStorage("stringValue") private var stringValue = "Hello, SwiftUI!"
    @AppStorage("urlValue") private var urlValue = URL(string: "https://apple.com")!
    
    var body: some View {
        NavigationStack {
            List {
                Section("Supported Data Types") {
                    VStack(alignment: .leading) {
                        Text("Bool")
                            .font(.headline)
                        Toggle("Boolean Value", isOn: $boolValue)
                        Text("Stored as: \(boolValue ? "true" : "false")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading) {
                        Text("Int")
                            .font(.headline)
                        Stepper("Integer: \(intValue)", value: $intValue)
                        Text("Stored as: \(intValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading) {
                        Text("Double")
                            .font(.headline)
                        Slider(value: $doubleValue, in: 0...10)
                        Text("Double: \(doubleValue, specifier: "%.3f")")
                        Text("Stored as: \(doubleValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading) {
                        Text("String")
                            .font(.headline)
                        TextField("Text Input", text: $stringValue)
                        Text("Stored as: \"\(stringValue)\"")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading) {
                        Text("URL")
                            .font(.headline)
                        Link("Visit: \(urlValue.absoluteString)", destination: urlValue)
                        Text("Stored as: \(urlValue.absoluteString)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Data Types")
        }
    }
}

/// Theme selection example with AppStorage
enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case auto = "auto"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Automatic"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
}

struct ThemeSelector: View {
    @AppStorage("selectedTheme") private var selectedTheme = AppTheme.auto
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Theme Selector")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Choose your preferred theme")
                    .foregroundStyle(.secondary)
                
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Image(systemName: theme == .light ? "sun.max" : 
                                            theme == .dark ? "moon" : "circle.lefthalf.fill")
                            Text(theme.displayName)
                        }
                        .tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                
                VStack {
                    Text("Current Theme: \(selectedTheme.displayName)")
                        .font(.headline)
                    
                    Text("This setting is automatically saved and will persist when you restart the app!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Theme Demo")
        }
        .preferredColorScheme(selectedTheme.colorScheme)
    }
}

/// Settings screen example showing practical AppStorage usage
struct SettingsScreen: View {
    @AppStorage("username") private var username = ""
    @AppStorage("emailNotifications") private var emailNotifications = true
    @AppStorage("pushNotifications") private var pushNotifications = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("textSize") private var textSize = 1.0
    @AppStorage("autoSave") private var autoSave = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Notifications") {
                    Toggle("Email Notifications", isOn: $emailNotifications)
                    Toggle("Push Notifications", isOn: $pushNotifications)
                    Toggle("Sound Effects", isOn: $soundEnabled)
                }
                
                Section("Accessibility") {
                    VStack {
                        HStack {
                            Text("Text Size")
                            Spacer()
                            Text(textSize == 0.8 ? "Small" : 
                                 textSize == 1.0 ? "Medium" : "Large")
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $textSize, in: 0.8...1.4, step: 0.2)
                    }
                }
                
                Section("Data") {
                    Toggle("Auto-save Documents", isOn: $autoSave)
                }
                
                Section("Preview") {
                    Text("This is how your text will look")
                        .font(.system(size: 16 * textSize))
                        .opacity(soundEnabled ? 1.0 : 0.7)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview("AppStorage Basics") {
    AppStorageBasics()
}

#Preview("Data Types") {
    AppStorageDataTypes()
}

#Preview("Theme Selector") {
    ThemeSelector()
}

#Preview("Settings Screen") {
    SettingsScreen()
}
