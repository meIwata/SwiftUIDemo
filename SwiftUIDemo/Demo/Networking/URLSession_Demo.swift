import SwiftUI

// 1. URLSession
// 2. Error Handling (do-catch)
// 3. Swift Concurrency (async / await)
// 4. Task
// 5. @MainActor
// 6. Codable
// 7. JSONDecoder

struct URLSession_Demo: View {
    // State to hold our data
    @State private var joke = "Tap to load a joke"
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the joke
            Text(joke)
                .padding()
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            
            // Button to fetch data
            Button("Fetch Joke") {
                // Call our async function
                Task {
                    await loadJoke()
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .navigationTitle("URLSession Demo")
    }
    
    // Simple async function to fetch data
    @MainActor
    private func loadJoke() async {
        isLoading = true
        
        do {
            // 1. Create URL
            let url = URL(string: "https://official-joke-api.appspot.com/random_joke")!
            
            // 2. Fetch data using URLSession
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 3. Decode JSON
            let jokeData = try JSONDecoder().decode(JokeResponse.self, from: data)
            
            // 4. Update UI
            joke = "\(jokeData.setup)\n\n\(jokeData.punchline)"
            
        } catch {
            // Handle errors
            joke = "Failed to load joke: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// Simple model for our data
struct JokeResponse: Codable {
    let setup: String    // Joke setup
    let punchline: String // Joke punchline
}

#Preview {
    NavigationStack {
        URLSession_Demo()
    }
}
