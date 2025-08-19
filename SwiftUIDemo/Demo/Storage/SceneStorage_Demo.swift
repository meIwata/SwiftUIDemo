import SwiftUI

/// # SceneStorage Demo
/// 
/// @SceneStorage preserves state per app scene/window. Unlike @AppStorage which is app-wide,
/// @SceneStorage maintains separate state for each window or scene instance.
///
/// ## Key Features:
/// - State preserved per scene/window
/// - Automatic restoration when scene is recreated
/// - Perfect for navigation state, selected tabs, scroll positions
/// - Different from @AppStorage - each window has its own state
///
/// ## Use Cases:
/// - Navigation paths and selected items
/// - Tab selection and view state
/// - Scroll positions and UI configuration
/// - Window-specific user preferences

struct SceneStorageNavigation: View {
    @SceneStorage("selectedTab") private var selectedTab = 0
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First Tab - Navigation Demo
            NavigationStack(path: $navigationPath) {
                SceneStorageNavigationHome()
                    .navigationDestination(for: String.self) { destination in
                        SceneStorageDetailView(item: destination)
                    }
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            // Second Tab - Settings
            SceneStorageSettings()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(1)
            
            // Third Tab - Profile
            SceneStorageProfile()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(2)
        }
    }
}

struct SceneStorageNavigationHome: View {
    let items = ["Photos", "Documents", "Downloads", "Music", "Videos"]
    
    var body: some View {
        List {
            Section("Navigation Demo") {
                Text("Navigate to any item, then close and reopen the app. Your navigation state will be restored!")
                    .foregroundStyle(.secondary)
            }
            
            Section("Items") {
                ForEach(items, id: \.self) { item in
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: iconFor(item))
                                .foregroundStyle(.blue)
                            Text(item)
                        }
                    }
                }
            }
        }
        .navigationTitle("Scene Storage Demo")
    }
    
    private func iconFor(_ item: String) -> String {
        switch item {
        case "Photos": return "photo"
        case "Documents": return "doc"
        case "Downloads": return "arrow.down.circle"
        case "Music": return "music.note"
        case "Videos": return "video"
        default: return "folder"
        }
    }
}

struct SceneStorageDetailView: View {
    let item: String
    @SceneStorage("detailScrollPosition") private var scrollPosition: Double = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: iconFor(item))
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    Text(item)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("This is the detail view for \(item)")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    ForEach(0..<20, id: \.self) { index in
                        VStack {
                            Text("Section \(index + 1)")
                                .font(.headline)
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                                .padding()
                                .background(.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .id(index)
                    }
                }
                .padding()
            }
            .navigationTitle(item)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if scrollPosition > 0 {
                    proxy.scrollTo(Int(scrollPosition), anchor: .top)
                }
            }
            .onDisappear {
                // In a real app, you'd track scroll position
                // This is simplified for demo purposes
            }
        }
    }
    
    private func iconFor(_ item: String) -> String {
        switch item {
        case "Photos": return "photo"
        case "Documents": return "doc"
        case "Downloads": return "arrow.down.circle"
        case "Music": return "music.note"
        case "Videos": return "video"
        default: return "folder"
        }
    }
}

struct SceneStorageSettings: View {
    @SceneStorage("darkMode") private var darkModeEnabled = false
    @SceneStorage("fontSize") private var fontSize = 1.0
    @SceneStorage("notificationsEnabled") private var notificationsEnabled = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    
                    VStack {
                        HStack {
                            Text("Font Size")
                            Spacer()
                            Text("\(fontSize, specifier: "%.1f")x")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $fontSize, in: 0.8...2.0, step: 0.1)
                    }
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section("Scene Storage Info") {
                    Text("These settings are saved per window/scene. If you open multiple windows, each can have different settings!")
                        .foregroundStyle(.secondary)
                }
                
                Section("Preview") {
                    Text("Sample text with current settings")
                        .font(.system(size: 16 * fontSize))
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}

struct SceneStorageProfile: View {
    @SceneStorage("profileViewMode") private var viewMode = "grid"
    @SceneStorage("selectedProfileTab") private var selectedProfileTab = 0
    
    private let viewModes = ["grid", "list"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("View Mode", selection: $viewMode) {
                    Text("Grid").tag("grid")
                    Text("List").tag("list")
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedProfileTab) {
                    ProfileContentView(mode: viewMode, content: "Posts")
                        .tag(0)
                    
                    ProfileContentView(mode: viewMode, content: "Photos")
                        .tag(1)
                    
                    ProfileContentView(mode: viewMode, content: "Videos")
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileContentView: View {
    let mode: String
    let content: String
    
    var body: some View {
        VStack {
            Text("\(content) View")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
            
            Text("Displaying in \(mode) mode")
                .foregroundStyle(.secondary)
            
            if mode == "grid" {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                    ForEach(1...12, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                Text("\(index)")
                                    .font(.headline)
                            }
                    }
                }
                .padding()
            } else {
                List(1...12, id: \.self) { index in
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.opacity(0.3))
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("\(content) Item \(index)")
                                .font(.headline)
                            Text("Description for item \(index)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Spacer()
        }
    }
}

/// Demonstrates the difference between AppStorage and SceneStorage
struct AppStorageVsSceneStorage: View {
    @AppStorage("appWideCounter") private var appWideCounter = 0
    @SceneStorage("sceneCounter") private var sceneCounter = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("AppStorage vs SceneStorage")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // AppStorage Example
                VStack(spacing: 12) {
                    Text("@AppStorage")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    Text("App-wide Counter: \(appWideCounter)")
                        .font(.title3)
                    
                    Button("Increment App Counter") {
                        appWideCounter += 1
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Text("Shared across all windows/scenes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // SceneStorage Example
                VStack(spacing: 12) {
                    Text("@SceneStorage")
                        .font(.title2)
                        .foregroundStyle(.green)
                    
                    Text("Scene Counter: \(sceneCounter)")
                        .font(.title3)
                    
                    Button("Increment Scene Counter") {
                        sceneCounter += 1
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    Text("Unique per window/scene")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
                VStack {
                    Text("💡 Multi-Window Test")
                        .font(.headline)
                    
                    Text("On iPad/Mac: Open multiple windows and see how each scene maintains its own counter while the app counter is shared!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .navigationTitle("Storage Comparison")
        }
    }
}

#Preview("Scene Storage Navigation") {
    SceneStorageNavigation()
}

#Preview("AppStorage vs SceneStorage") {
    AppStorageVsSceneStorage()
}