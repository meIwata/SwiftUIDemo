import SwiftUI

struct NetworkingDemo: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            UserListView()
                .tabItem {
                    Label("Users", systemImage: "person.3")
                }
                .tag(0)
            
            PostListView()
                .tabItem {
                    Label("Posts", systemImage: "doc.text")
                }
                .tag(1)
            
            WeatherView()
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun")
                }
                .tag(2)
            
            NetworkingLessonView()
                .tabItem {
                    Label("Lesson", systemImage: "book")
                }
                .tag(3)
        }
    }
}

struct NetworkingLessonView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    lessonHeader
                    
                    conceptsSection
                    
                    codeExamplesSection
                    
                    bestPracticesSection
                    
                    exercisesSection
                }
                .padding()
            }
            .navigationTitle("Networking Lesson")
        }
    }
    
    private var lessonHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📱 SwiftUI Networking with URLSession")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Learn modern networking in Swift using async/await, error handling, and SwiftUI integration")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Label("60 minutes", systemImage: "clock")
                Spacer()
                Label("Intermediate", systemImage: "star.fill")
            }
            .font(.caption)
            .foregroundStyle(.blue)
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var conceptsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Key Concepts")
                .font(.headline)
            
            VStack(spacing: 12) {
                ConceptCard(
                    title: "URLSession",
                    description: "Apple's networking API for HTTP requests",
                    example: "URLSession.shared.data(from: url)"
                )
                
                ConceptCard(
                    title: "Async/Await",
                    description: "Modern Swift concurrency for asynchronous operations",
                    example: "try await fetchData()"
                )
                
                ConceptCard(
                    title: "Error Handling",
                    description: "Try/catch blocks for robust error management",
                    example: "do { ... } catch { ... }"
                )
                
                ConceptCard(
                    title: "Codable",
                    description: "Swift protocol for JSON encoding/decoding",
                    example: "struct User: Codable { ... }"
                )
            }
        }
    }
    
    private var codeExamplesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💻 Code Examples")
                .font(.headline)
            
            VStack(spacing: 16) {
                CodeExampleCard(
                    title: "Basic Fetch",
                    code: """
                    func fetchUsers() async throws -> [User] {
                        let url = URL(string: "https://api.example.com/users")!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        return try JSONDecoder().decode([User].self, from: data)
                    }
                    """
                )
                
                CodeExampleCard(
                    title: "SwiftUI Integration",
                    code: """
                    @State private var users: [User] = []
                    @State private var isLoading = false
                    
                    .task {
                        isLoading = true
                        do {
                            users = try await fetchUsers()
                        } catch {
                            print("Error: \\(error)")
                        }
                        isLoading = false
                    }
                    """
                )
                
                CodeExampleCard(
                    title: "Generic Network Manager",
                    code: """
                    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
                        let (data, response) = try await URLSession.shared.data(from: url)
                        
                        guard let httpResponse = response as? HTTPURLResponse,
                              200...299 ~= httpResponse.statusCode else {
                            throw NetworkError.serverError
                        }
                        
                        return try JSONDecoder().decode(type, from: data)
                    }
                    """
                )
            }
        }
    }
    
    private var bestPracticesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("✅ Best Practices")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                BestPracticeItem(text: "Always handle errors gracefully with try/catch")
                BestPracticeItem(text: "Use @MainActor for UI updates from async contexts")
                BestPracticeItem(text: "Implement loading states for better UX")
                BestPracticeItem(text: "Cache network responses when appropriate")
                BestPracticeItem(text: "Use generic functions for code reusability")
                BestPracticeItem(text: "Validate HTTP status codes before processing")
                BestPracticeItem(text: "Implement request cancellation for search")
                BestPracticeItem(text: "Never expose API keys in client code")
            }
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎓 Exercises")
                .font(.headline)
            
            VStack(spacing: 12) {
                ExerciseCard(
                    title: "Beginner",
                    description: "Modify the weather app to show temperature in Fahrenheit",
                    difficulty: .beginner
                )
                
                ExerciseCard(
                    title: "Intermediate",
                    description: "Add POST request functionality to create new posts",
                    difficulty: .intermediate
                )
                
                ExerciseCard(
                    title: "Advanced",
                    description: "Implement offline caching with Core Data persistence",
                    difficulty: .advanced
                )
            }
        }
    }
}

struct ConceptCard: View {
    let title: String
    let description: String
    let example: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(example)
                .font(.caption)
                .fontDesign(.monospaced)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CodeExampleCard: View {
    let title: String
    let code: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .padding()
                    .background(.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

struct BestPracticeItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ExerciseCard: View {
    let title: String
    let description: String
    let difficulty: Difficulty
    
    enum Difficulty {
        case beginner, intermediate, advanced
        
        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
        
        var text: String {
            switch self {
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(difficulty.text)
                    .font(.caption)
                    .foregroundStyle(difficulty.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(difficulty.color.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview("Networking Demo") {
    NetworkingDemo()
}

#Preview("Lesson View") {
    NetworkingLessonView()
}