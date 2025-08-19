# 📱 SwiftUI Networking Lesson Plan (1 Hour)
## Topic: URLSession, Async/Await, and API Integration

## 🎯 Learning Objectives
By the end of this lesson, students will:
1. Understand URLSession basics and how to make HTTP requests
2. Master async/await syntax in Swift
3. Handle errors with try/catch blocks
4. Parse JSON data using Codable
5. Display API data in SwiftUI views
6. Implement loading states and error handling in UI

## 📚 Lesson Structure

### **Part 1: Introduction (10 minutes)**
#### 1.1 Overview of Networking in iOS
- What is URLSession?
- HTTP methods (GET, POST)
- RESTful APIs basics
- JSON data format

#### 1.2 Modern Swift Concurrency
- Evolution from callbacks to async/await
- Benefits of async/await pattern
- Introduction to structured concurrency

### **Part 2: Core Concepts (15 minutes)**
#### 2.1 URLSession Basics
```swift
// Simple GET request structure
let url = URL(string: "https://api.example.com/data")!
let (data, response) = try await URLSession.shared.data(from: url)
```

#### 2.2 Async/Await Syntax
- `async` functions
- `await` keyword
- `Task` for async context in SwiftUI

#### 2.3 Error Handling with Try/Catch
```swift
do {
    let data = try await fetchData()
} catch {
    print("Error: \(error)")
}
```

### **Part 3: Hands-on Implementation (25 minutes)**

#### 3.1 Project Setup
Create a new group `Networking` in the Demo folder with:
- `NetworkManager.swift` - Centralized networking logic
- `UserListView.swift` - Display list of users from API
- `PostDetailView.swift` - Show post details with comments
- `WeatherView.swift` - Real-time weather data display

#### 3.2 Build Components

**Component 1: Basic API Call**
- Use JSONPlaceholder API (https://jsonplaceholder.typicode.com)
- Fetch and display users list
- Model: `User` (id, name, email, username)

**Component 2: Master-Detail Pattern**
- List of posts
- Tap to see post details with comments
- Models: `Post`, `Comment`

**Component 3: Real API Integration**
- Weather API (Open-Meteo - no API key required)
- Search functionality with city lookup
- Loading states
- Error handling UI

#### 3.3 Key Features to Implement
```swift
// Network Manager with generic fetch
class NetworkManager {
    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
}

// Loading states enum
enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

// SwiftUI View with async task
.task {
    await loadData()
}
```

### **Part 4: Advanced Topics (8 minutes)**
#### 4.1 Best Practices
- URL configuration and environment management
- Caching strategies
- Network connectivity checking
- Request cancellation

#### 4.2 Performance Considerations
- Image loading and caching
- Pagination for large datasets
- Debouncing search requests

### **Part 5: Q&A and Wrap-up (2 minutes)**
- Review key concepts
- Common pitfalls and solutions
- Resources for further learning

## 🛠️ Files Created

### File Structure:
```
SwiftUIDemo/Demo/Networking/
├── Models/
│   ├── User.swift
│   ├── Post.swift
│   └── Weather.swift
├── Services/
│   └── NetworkManager.swift
├── Views/
│   ├── UserListView.swift
│   ├── PostDetailView.swift
│   └── WeatherView.swift
└── NetworkingDemo.swift (Main entry point)
```

## 💻 Code Examples

### 1. Simple Async Function
```swift
func fetchUsers() async throws -> [User] {
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([User].self, from: data)
}
```

### 2. SwiftUI Integration
```swift
@State private var users: [User] = []
@State private var isLoading = false
@State private var errorMessage: String?

.task {
    isLoading = true
    do {
        users = try await fetchUsers()
    } catch {
        errorMessage = error.localizedDescription
    }
    isLoading = false
}
```

### 3. Generic Network Layer
```swift
protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
}
```

## 📝 Teaching Tips
1. Start with a working example, then break it down
2. Use playground for quick experiments
3. Show common errors and how to debug them
4. Emphasize the importance of error handling
5. Demonstrate with real APIs for engagement

## 🎓 Assessment Ideas
- Have students modify the weather app to show wind direction
- Challenge: Add POST request to create a new post
- Bonus: Implement offline caching

## 🌐 APIs Used in This Lesson

### 1. JSONPlaceholder (Free Testing API)
- **Base URL**: `https://jsonplaceholder.typicode.com`
- **Endpoints**:
  - `/users` - List of users
  - `/posts` - List of posts
  - `/posts/{id}/comments` - Comments for a post
- **Benefits**: No API key required, stable, designed for learning

### 2. Open-Meteo Weather API (Free, No API Key)
- **Base URL**: `https://api.open-meteo.com/v1/forecast`
- **Geocoding**: `https://geocoding-api.open-meteo.com/v1/search`
- **Benefits**: 
  - Completely free
  - No registration required
  - Real weather data
  - European-based reliable service

## 🔧 Key Features Implemented

### NetworkManager (Generic Service Layer)
- **Generic fetch function** with proper error handling
- **Custom NetworkError enum** with localized descriptions
- **LoadingState enum** for UI state management
- **Specialized methods** for different APIs
- **Async/await throughout** with proper error propagation

### UserListView (Basic Networking)
- **Async data loading** with `.task` modifier
- **Search functionality** with real-time filtering
- **Pull-to-refresh** support
- **Loading states** with proper UI feedback
- **Error handling** with ContentUnavailableView

### PostDetailView (Master-Detail Pattern)
- **Navigation from list to detail**
- **Async comment loading** for selected post
- **Placeholder views** during loading
- **Proper error states** and retry functionality
- **Modern SwiftUI navigation** with NavigationStack

### WeatherView (Advanced Features)
- **Two-step API workflow**: City search → Weather data
- **Debounced search** (500ms delay) with task cancellation
- **Real-time weather data** from Open-Meteo
- **Rich weather UI** with icons and detailed metrics
- **Error handling** with retry functionality
- **Search-as-you-type** with minimum 2 character threshold

### NetworkingDemo (Interactive Lesson Hub)
- **TabView interface** connecting all components
- **Interactive lesson content** with code examples
- **Best practices guide** with practical tips
- **Exercise suggestions** for different skill levels
- **Concept explanations** with visual examples

## ✅ Best Practices Covered

### Error Handling
- Always handle errors gracefully with try/catch
- Use custom error types for better UX
- Implement proper loading and error states
- Provide retry mechanisms for failed requests

### Performance
- Use debouncing for search functionality
- Implement task cancellation to prevent memory leaks
- Cache network responses when appropriate
- Use generic functions for code reusability

### Security
- Never expose API keys in client code
- Validate HTTP status codes before processing
- Use HTTPS for all network requests
- Implement proper timeout configurations

### SwiftUI Integration
- Use @MainActor for UI updates from async contexts
- Implement comprehensive loading states
- Use .task modifier for async operations in views
- Handle view lifecycle properly with task cancellation

## 🎯 Learning Outcomes

After completing this lesson, students will have:

1. **Built 3 working networking examples** with different complexity levels
2. **Implemented modern async/await patterns** throughout
3. **Created reusable networking components** they can use in future projects
4. **Learned professional error handling** techniques
5. **Experienced real API integration** without setup barriers
6. **Understood SwiftUI networking patterns** and best practices

## 📚 Additional Resources

### Documentation
- [Apple URLSession Documentation](https://developer.apple.com/documentation/foundation/urlsession)
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [JSONPlaceholder API Guide](https://jsonplaceholder.typicode.com/guide/)
- [Open-Meteo API Documentation](https://open-meteo.com/en/docs)

### Practice APIs (No API Key Required)
- **JSONPlaceholder**: Testing and prototyping
- **Open-Meteo**: Weather data
- **REST Countries**: Country information
- **Cat Facts API**: Fun facts for practice
- **Dog API**: Random dog images

This lesson provides a comprehensive introduction to networking in SwiftUI while building practical, reusable components that students can reference and extend in their future projects.