import SwiftUI
import Foundation

/// # Codable Storage Demo
/// 
/// When @AppStorage's built-in types aren't enough, you can store custom types
/// using Codable protocol with UserDefaults. This demo shows how to:
///
/// ## Techniques Covered:
/// - Creating Codable models
/// - Custom property wrappers for Codable storage
/// - Storing arrays and complex objects
/// - Error handling for corrupted data
/// - Migration strategies for data structure changes

// MARK: - Custom Types

struct UserProfile: Codable, Hashable {
    let id = UUID()
    var name: String
    var email: String
    var age: Int
    var preferences: UserPreferences
    var createdAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case name, email, age, preferences, createdAt
    }
    
    init(name: String, email: String, age: Int, preferences: UserPreferences = UserPreferences()) {
        self.name = name
        self.email = email
        self.age = age
        self.preferences = preferences
        self.createdAt = Date()
    }
}

struct UserPreferences: Codable, Hashable {
    var theme: Theme = .auto
    var notifications: NotificationSettings = NotificationSettings()
    var displayOptions: DisplayOptions = DisplayOptions()
}

enum Theme: String, Codable, CaseIterable {
    case light, dark, auto
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .auto: return "Automatic"
        }
    }
}

struct NotificationSettings: Codable, Hashable {
    var email: Bool = true
    var push: Bool = true
    var sound: Bool = true
}

struct DisplayOptions: Codable, Hashable {
    var fontSize: Double = 1.0
    var showLineNumbers: Bool = false
    var compactMode: Bool = false
}

struct TodoTask: Codable, Identifiable, Hashable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var createdAt: Date = Date()
    var dueDate: Date?
    
    private enum CodingKeys: String, CodingKey {
        case title, isCompleted, priority, createdAt, dueDate
    }
}

enum Priority: String, Codable, CaseIterable {
    case low, medium, high, urgent
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Custom Property Wrapper

@propertyWrapper
struct CodableAppStorage<T: Codable>: DynamicProperty {
    private let key: String
    private let defaultValue: T
    @State private var value: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        
        // Load initial value from UserDefaults
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(T.self, from: data) {
            self._value = State(initialValue: decoded)
        } else {
            self._value = State(initialValue: defaultValue)
        }
    }
    
    var wrappedValue: T {
        get { value }
        nonmutating set {
            value = newValue
            // Save to UserDefaults
            do {
                let encoded = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encoded, forKey: key)
            } catch {
                print("Failed to encode \(key): \(error)")
            }
        }
    }
    
    var projectedValue: Binding<T> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}

// MARK: - Views

struct CodableStorageDemo: View {
    @CodableAppStorage(key: "userProfile", defaultValue: UserProfile(name: "", email: "", age: 18))
    private var userProfile: UserProfile
    
    @CodableAppStorage(key: "taskList", defaultValue: [])
    private var tasks: [TodoTask]
    
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("User Profile") {
                    if userProfile.name.isEmpty {
                        Button("Create Profile") {
                            userProfile = UserProfile(
                                name: "John Doe",
                                email: "john@example.com",
                                age: 25
                            )
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        ProfileView(profile: $userProfile)
                    }
                }
                
                Section("Tasks (\(tasks.count))") {
                    if tasks.isEmpty {
                        Text("No tasks yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(tasks) { task in
                            TaskRowView(task: binding(for: task))
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    
                    Button("Add Task") {
                        showingAddTask = true
                    }
                }
                
                Section("Storage Info") {
                    StorageInfoView()
                }
            }
            .navigationTitle("Codable Storage")
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet { newTask in
                    tasks.append(newTask)
                }
            }
        }
    }
    
    private func binding(for task: TodoTask) -> Binding<TodoTask> {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            fatalError("Task not found")
        }
        return $tasks[index]
    }
    
    private func deleteTasks(offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

struct ProfileView: View {
    @Binding var profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(profile.name)
                    .font(.headline)
                Spacer()
                Text("Age: \(profile.age)")
                    .foregroundStyle(.secondary)
            }
            
            Text(profile.email)
                .foregroundStyle(.secondary)
            
            Text("Created: \(profile.createdAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button("Edit Profile") {
                // In a real app, you'd show an edit sheet
            }
            
            Button("Reset Profile", role: .destructive) {
                profile = UserProfile(name: "", email: "", age: 18)
            }
        }
    }
}

struct TaskRowView: View {
    @Binding var task: TodoTask
    
    var body: some View {
        HStack {
            Button {
                task.isCompleted.toggle()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                HStack {
                    Text(task.priority.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(task.priority.color.opacity(0.2))
                        .foregroundStyle(task.priority.color)
                        .clipShape(Capsule())
                    
                    if let dueDate = task.dueDate {
                        Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var priority = Priority.medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    let onSave: (TodoTask) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $title)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.displayName)
                                .tag(priority)
                        }
                    }
                }
                
                Section("Due Date") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newTask = TodoTask(
                            title: title,
                            priority: priority,
                            dueDate: hasDueDate ? dueDate : nil
                        )
                        onSave(newTask)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct StorageInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Custom Types", systemImage: "doc.text")
                .font(.headline)
            
            Text("Using Codable protocol to store complex data structures")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Label("Automatic Persistence", systemImage: "icloud")
                .font(.headline)
            
            Text("Data is automatically saved and restored across app launches")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Label("Type Safety", systemImage: "checkmark.shield")
                .font(.headline)
            
            Text("Compile-time type checking with runtime error handling")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Advanced example showing data migration
struct MigrationExample: View {
    // Version 1 of user settings
    struct UserSettingsV1: Codable {
        var username: String
        var darkMode: Bool
    }
    
    // Version 2 with additional fields
    struct UserSettingsV2: Codable {
        var username: String
        var theme: Theme  // Replaced darkMode
        var notifications: Bool = true  // New field
        var version: Int = 2  // Version tracking
        
        // Migration from V1
        init(from v1: UserSettingsV1) {
            self.username = v1.username
            self.theme = v1.darkMode ? .dark : .light
            self.notifications = true
            self.version = 2
        }
    }
    
    @State private var settings: UserSettingsV2?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Data Migration Example")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let settings = settings {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username: \(settings.username)")
                        Text("Theme: \(settings.theme.displayName)")
                        Text("Notifications: \(settings.notifications ? "On" : "Off")")
                        Text("Version: \(settings.version)")
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text("No settings found")
                        .foregroundStyle(.secondary)
                }
                
                Button("Create V1 Settings") {
                    let v1Settings = UserSettingsV1(username: "TestUser", darkMode: true)
                    if let data = try? JSONEncoder().encode(v1Settings) {
                        UserDefaults.standard.set(data, forKey: "migrationExample")
                        loadSettings()
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Migrate to V2") {
                    loadAndMigrateSettings()
                }
                .buttonStyle(.borderedProminent)
                
                Text("This demonstrates how to handle data structure changes over time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Migration Demo")
            .onAppear {
                loadSettings()
            }
        }
    }
    
    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: "migrationExample") else { return }
        
        // Try V2 first
        if let v2Settings = try? JSONDecoder().decode(UserSettingsV2.self, from: data) {
            settings = v2Settings
        }
    }
    
    private func loadAndMigrateSettings() {
        guard let data = UserDefaults.standard.data(forKey: "migrationExample") else { return }
        
        // Try V2 first
        if let v2Settings = try? JSONDecoder().decode(UserSettingsV2.self, from: data) {
            settings = v2Settings
            return
        }
        
        // Try V1 and migrate
        if let v1Settings = try? JSONDecoder().decode(UserSettingsV1.self, from: data) {
            let migratedSettings = UserSettingsV2(from: v1Settings)
            
            // Save migrated version
            if let newData = try? JSONEncoder().encode(migratedSettings) {
                UserDefaults.standard.set(newData, forKey: "migrationExample")
                settings = migratedSettings
            }
        }
    }
}

#Preview("Codable Storage") {
    CodableStorageDemo()
}

#Preview("Migration Example") {
    MigrationExample()
}