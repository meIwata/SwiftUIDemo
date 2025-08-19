import SwiftUI

/// # Storage in SwiftUI
/// 
/// This lesson introduces different types of storage available in SwiftUI apps.
/// Understanding when and how to use each type is crucial for building robust applications.
///
/// ## Storage Types Overview:
/// 
/// **@State** - Temporary storage (lost when app closes)
/// - Perfect for: UI state, temporary values, local component state
/// - Lifecycle: Lives only while the view exists
/// - Example: Button press count, text field input, toggle state
///
/// **@AppStorage** - Persistent storage across app launches
/// - Perfect for: User preferences, settings, simple data
/// - Lifecycle: Persists until app is deleted or manually cleared
/// - Example: Theme preference, user settings, last selected tab
///
/// **@SceneStorage** - Persistent storage per app scene/window
/// - Perfect for: Navigation state, window-specific settings
/// - Lifecycle: Persists per scene, restored when scene is recreated
/// - Example: Navigation path, selected tab, scroll position
///
/// **SwiftData/Core Data** - Full database storage
/// - Perfect for: Complex data relationships, large datasets
/// - Lifecycle: Fully persistent database with relationships
/// - Example: User profiles, shopping lists, photo galleries

struct StorageComparison: View {
    @State private var temporaryCounter = 0
    // UserDefaults.standard
    @AppStorage("persistentCounter") private var persistentCounter = 0
    @SceneStorage("sceneCounter") private var sceneCounter = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Storage Types Comparison")
                    .font(.title)
                    .fontWeight(.bold)

                Divider()
                
                // Temporary Storage (@State)
                VStack {
                    Text("@State (Temporary)")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    
                    Text("Count: \(temporaryCounter)")
                        .font(.title2)
                    
                    Button("Increment Temporary") {
                        temporaryCounter += 1
                    }
                    .buttonStyle(.bordered)
                    
                    Text("⚠️ Lost when app closes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Persistent Storage (@AppStorage)
                VStack {
                    Text("@AppStorage (Persistent)")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    Text("Count: \(persistentCounter)")
                        .font(.title2)
                    
                    Button("Increment Persistent") {
                        persistentCounter += 1
                    }
                    .buttonStyle(.bordered)
                    
                    Text("✅ Survives app restarts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Scene Storage (@SceneStorage)
                VStack {
                    Text("@SceneStorage (Scene Persistent)")
                        .font(.headline)
                        .foregroundStyle(.green)
                    
                    Text("Count: \(sceneCounter)")
                        .font(.title2)
                    
                    Button("Increment Scene") {
                        print("scene")
                        sceneCounter += 1
                    }
                    .buttonStyle(.bordered)
                    .onChange(of: sceneCounter) { oldValue, newValue in
                        print("sceneCounter \(oldValue) > \(newValue)")
                    } //@SceneStorage 這裡有問題，不能使用
                    
                    Text("🔄 Restored per app scene")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Try this:")
                        .font(.headline)
                    
                    Text("• Increment all counters")
                    Text("• Close and reopen the app")
                    Text("• Notice which values persist")
                    Text("• The temporary counter resets to 0")
                    Text("• The persistent counters remember their values")
                }
                .padding()
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}

/// Example showing the lifecycle differences
struct StorageLifecycleDemo: View {
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Storage Lifecycle")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                StorageRow(
                    title: "@State",
                    description: "Temporary - resets when view disappears",
                    color: .orange,
                    icon: "clock"
                )
                
                StorageRow(
                    title: "@AppStorage",
                    description: "App-wide - persists across app launches",
                    color: .blue,
                    icon: "iphone"
                )
                
                StorageRow(
                    title: "@SceneStorage",
                    description: "Scene-specific - restores window state",
                    color: .green,
                    icon: "rectangle.on.rectangle"
                )
                
                StorageRow(
                    title: "SwiftData",
                    description: "Database - complex relationships & queries",
                    color: .purple,
                    icon: "cylinder"
                )
            }
            
            Spacer()
            
            Button("Learn More About Each Type") {
                showingAlert = true
            }
            .buttonStyle(.borderedProminent)
            .alert("Next Steps", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text("Check out the other Storage demo files to see each type in action!")
            }
        }
        .padding()
    }
}

struct StorageRow: View {
    let title: String
    let description: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(color)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("Storage Comparison") {
    StorageComparison()
}

#Preview("Lifecycle Demo") {
    StorageLifecycleDemo()
}
