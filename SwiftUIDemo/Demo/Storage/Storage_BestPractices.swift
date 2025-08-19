import SwiftUI

/// # Storage Best Practices
/// 
/// This guide helps you choose the right storage solution for your app's needs
/// and provides best practices for implementation, performance, and security.

struct StorageBestPractices: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("When to Use Each Type", destination: WhenToUseGuide())
                    NavigationLink("Performance Considerations", destination: PerformanceGuide())
                    NavigationLink("Security Best Practices", destination: SecurityGuide())
                    NavigationLink("Common Mistakes", destination: CommonMistakes())
                    NavigationLink("Migration Strategies", destination: MigrationStrategies())
                }
            }
            .navigationTitle("Best Practices")
        }
    }
}

// MARK: - When to Use Guide

struct WhenToUseGuide: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Choosing the Right Storage Type")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                StorageDecisionCard(
                    title: "@State",
                    subtitle: "Temporary UI State",
                    description: "Perfect for temporary data that doesn't need to persist",
                    useCases: [
                        "Button press states",
                        "Text field input while editing", 
                        "Animation states",
                        "Loading indicators",
                        "Modal presentation states"
                    ],
                    pros: [
                        "Fast and lightweight",
                        "Automatic memory management",
                        "No persistence overhead"
                    ],
                    cons: [
                        "Lost when view disappears",
                        "Cannot survive app restarts"
                    ],
                    color: .orange
                )
                
                StorageDecisionCard(
                    title: "@AppStorage",
                    subtitle: "Simple Persistent Data",
                    description: "Ideal for user preferences and simple settings",
                    useCases: [
                        "User preferences (theme, notifications)",
                        "App settings and configuration",
                        "Simple counters or scores",
                        "Feature flags",
                        "Last used values"
                    ],
                    pros: [
                        "Automatic persistence",
                        "Synchronous access",
                        "Built-in type support",
                        "Automatic UI updates"
                    ],
                    cons: [
                        "Limited to simple types",
                        "App-wide scope only",
                        "No querying capabilities"
                    ],
                    color: .blue
                )
                
                StorageDecisionCard(
                    title: "@SceneStorage",
                    subtitle: "Window/Scene State",
                    description: "Best for preserving navigation and window-specific state",
                    useCases: [
                        "Navigation paths",
                        "Selected tabs",
                        "Scroll positions",
                        "Window-specific settings",
                        "Multi-window configurations"
                    ],
                    pros: [
                        "Per-scene isolation",
                        "Automatic state restoration",
                        "Multi-window support"
                    ],
                    cons: [
                        "Limited to simple types",
                        "Scene-specific only"
                    ],
                    color: .green
                )
                
                StorageDecisionCard(
                    title: "SwiftData",
                    subtitle: "Complex Relational Data",
                    description: "The right choice for complex data with relationships",
                    useCases: [
                        "User-generated content",
                        "Complex data relationships",
                        "Large datasets",
                        "Offline-first apps",
                        "Data that needs querying"
                    ],
                    pros: [
                        "Powerful querying",
                        "Relationships and constraints",
                        "Migration support",
                        "iCloud sync ready"
                    ],
                    cons: [
                        "Higher complexity",
                        "Larger binary size",
                        "Learning curve"
                    ],
                    color: .purple
                )
            }
            .padding()
        }
        .navigationTitle("When to Use Each Type")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StorageDecisionCard: View {
    let title: String
    let subtitle: String
    let description: String
    let useCases: [String]
    let pros: [String]
    let cons: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(color)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Text(description)
                .font(.body)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Use Cases:")
                    .font(.headline)
                
                ForEach(useCases, id: \.self) { useCase in
                    Label(useCase, systemImage: "checkmark")
                        .font(.caption)
                }
            }
            
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pros:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                    
                    ForEach(pros, id: \.self) { pro in
                        Label(pro, systemImage: "plus")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cons:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                    
                    ForEach(cons, id: \.self) { con in
                        Label(con, systemImage: "minus")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Performance Guide

struct PerformanceGuide: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Performance Best Practices")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                PerformanceTipCard(
                    title: "Choose the Right Storage Type",
                    tips: [
                        "Use @State for temporary data - it's the fastest",
                        "@AppStorage has minimal overhead for simple types",
                        "SwiftData is optimized for complex queries",
                        "Avoid over-engineering - simple solutions are often best"
                    ],
                    icon: "speedometer",
                    color: .blue
                )
                
                PerformanceTipCard(
                    title: "Minimize Data Size",
                    tips: [
                        "Store only what you need",
                        "Use appropriate data types (Int instead of String for numbers)",
                        "Consider data compression for large text",
                        "Remove unused properties from models"
                    ],
                    icon: "doc.zipper",
                    color: .green
                )
                
                PerformanceTipCard(
                    title: "Optimize SwiftData Usage",
                    tips: [
                        "Use @Query with predicates to limit data",
                        "Implement proper relationships to avoid data duplication",
                        "Use batch operations for multiple changes",
                        "Consider lazy loading for large datasets"
                    ],
                    icon: "cylinder.split.1x2",
                    color: .purple
                )
                
                PerformanceTipCard(
                    title: "Memory Management",
                    tips: [
                        "Don't store large objects in @State unnecessarily",
                        "Use weak references in callbacks to avoid retain cycles",
                        "Clean up observers and subscriptions",
                        "Release heavy resources when not needed"
                    ],
                    icon: "memorychip",
                    color: .orange
                )
            }
            .padding()
        }
        .navigationTitle("Performance Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PerformanceTipCard: View {
    let title: String
    let tips: [String]
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            ForEach(tips, id: \.self) { tip in
                Label(tip, systemImage: "lightbulb")
                    .font(.body)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Security Guide

struct SecurityGuide: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Security Best Practices")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                SecuritySection(
                    title: "Sensitive Data Protection",
                    items: [
                        "Never store passwords in UserDefaults or @AppStorage",
                        "Use Keychain for sensitive data (passwords, tokens)",
                        "Encrypt sensitive data before storing",
                        "Consider data classification (public, internal, sensitive)"
                    ],
                    icon: "lock.shield",
                    color: .red
                )
                
                SecuritySection(
                    title: "Data Validation",
                    items: [
                        "Always validate data when reading from storage",
                        "Handle corrupted data gracefully",
                        "Use type-safe storage methods",
                        "Implement data integrity checks"
                    ],
                    icon: "checkmark.shield",
                    color: .blue
                )
                
                SecuritySection(
                    title: "Access Control",
                    items: [
                        "Use appropriate file protection levels",
                        "Consider data access patterns",
                        "Implement user authentication where needed",
                        "Follow principle of least privilege"
                    ],
                    icon: "person.badge.key",
                    color: .green
                )
                
                Text("⚠️ Security Reminder")
                    .font(.headline)
                    .foregroundStyle(.orange)
                
                Text("UserDefaults and @AppStorage are NOT secure storage. They store data in plain text and can be easily accessed. For sensitive data, always use Keychain or encrypt the data before storage.")
                    .padding()
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
        .navigationTitle("Security Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SecuritySection: View {
    let title: String
    let items: [String]
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "shield.checkered")
                    .font(.body)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Common Mistakes

struct CommonMistakes: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Common Mistakes to Avoid")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                MistakeCard(
                    title: "Using Wrong Storage Type",
                    mistake: "Using @AppStorage for temporary UI state",
                    solution: "Use @State for temporary data that doesn't need persistence",
                    example: """
                    // ❌ Wrong
                    @AppStorage("isLoading") var isLoading = false
                    
                    // ✅ Correct  
                    @State private var isLoading = false
                    """,
                    severity: .medium
                )
                
                MistakeCard(
                    title: "Storing Sensitive Data Insecurely",
                    mistake: "Storing passwords or tokens in UserDefaults",
                    solution: "Use Keychain for sensitive data",
                    example: """
                    // ❌ Wrong
                    @AppStorage("password") var password = ""
                    
                    // ✅ Correct
                    // Use Keychain or secure storage
                    """,
                    severity: .high
                )
                
                MistakeCard(
                    title: "Not Handling Data Corruption",
                    mistake: "Assuming stored data is always valid",
                    solution: "Always validate and provide fallbacks",
                    example: """
                    // ❌ Wrong
                    let user = try! JSONDecoder().decode(User.self, from: data)
                    
                    // ✅ Correct
                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                    } catch {
                        // Handle error, use default values
                    }
                    """,
                    severity: .high
                )
                
                MistakeCard(
                    title: "Over-Engineering Simple Storage",
                    mistake: "Using SwiftData for simple preferences",
                    solution: "Start simple, upgrade when needed",
                    example: """
                    // ❌ Overkill for simple settings
                    @Model class UserSettings { var theme: String }
                    
                    // ✅ Simple and effective
                    @AppStorage("theme") var theme = "auto"
                    """,
                    severity: .low
                )
            }
            .padding()
        }
        .navigationTitle("Common Mistakes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MistakeCard: View {
    let title: String
    let mistake: String
    let solution: String
    let example: String
    let severity: Severity
    
    enum Severity {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return .yellow
            case .medium: return .orange
            case .high: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "exclamationmark.triangle"
            case .medium: return "exclamationmark.triangle.fill"
            case .high: return "xmark.octagon.fill"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: severity.icon)
                    .foregroundStyle(severity.color)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Problem:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
                
                Text(mistake)
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Solution:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
                
                Text(solution)
                    .font(.body)
            }
            
            if !example.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Example:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(example)
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .background(severity.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Migration Strategies

struct MigrationStrategies: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Data Migration Strategies")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("As your app evolves, you may need to migrate data between storage types or update data structures.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                MigrationStrategy(
                    title: "Version Your Data",
                    description: "Always include version information in stored data",
                    steps: [
                        "Add version field to your data models",
                        "Check version when reading data", 
                        "Implement migration logic for each version",
                        "Test migration paths thoroughly"
                    ]
                )
                
                MigrationStrategy(
                    title: "Gradual Migration",
                    description: "Migrate data gradually to avoid blocking the UI",
                    steps: [
                        "Detect old data format on app launch",
                        "Show migration progress to user",
                        "Migrate data in background",
                        "Fall back to old format if migration fails"
                    ]
                )
                
                MigrationStrategy(
                    title: "Backward Compatibility",
                    description: "Support multiple data formats during transition",
                    steps: [
                        "Read both old and new formats",
                        "Write in new format only",
                        "Remove old format support after several versions",
                        "Provide clear upgrade path for users"
                    ]
                )
                
                Text("💡 Pro Tip")
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Text("Always test your migration logic with real user data, not just test data. Users may have edge cases you haven't considered.")
                    .padding()
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding()
        }
        .navigationTitle("Migration Strategies")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MigrationStrategy: View {
    let title: String
    let description: String
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(step)
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StorageBestPractices()
}