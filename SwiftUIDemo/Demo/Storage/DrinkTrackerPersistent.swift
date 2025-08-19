import SwiftUI

/// # Persistent Drink Tracker
/// 
/// This example shows how to upgrade the original DrinkTracker from temporary @State
/// to persistent @AppStorage, so users don't lose their progress when closing the app.
///
/// ## Key Changes from Original:
/// - @State → @AppStorage for persistence
/// - Added daily goal tracking
/// - Reset functionality
/// - Progress visualization
/// - Automatic data restoration

struct DrinkTrackerPersistent: View {
    // Using @AppStorage instead of @State for persistence
    @AppStorage("waterCount") private var waterCount = 0
    @AppStorage("coffeeCount") private var coffeeCount = 0
    @AppStorage("beerCount") private var beerCount = 0
    @AppStorage("dailyWaterGoal") private var dailyWaterGoal = 8
    
    private var totalCount: Int {
        waterCount + coffeeCount + beerCount
    }
    
    private var waterProgress: Double {
        min(Double(waterCount) / Double(dailyWaterGoal), 1.0)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header with total count
                VStack {
                    Text("Total Drinks Today")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("\(totalCount)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Water Goal Progress
                VStack {
                    HStack {
                        Text("Water Goal Progress")
                            .font(.headline)
                        Spacer()
                        Text("\(waterCount)/\(dailyWaterGoal)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    ProgressView(value: waterProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 2)
                    
                    if waterCount >= dailyWaterGoal {
                        Text("🎉 Goal achieved!")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Drink Trackers
                VStack(spacing: 16) {
                    PersistentWaterTracker(count: $waterCount, goal: $dailyWaterGoal)
                    PersistentCoffeeTracker(count: $coffeeCount)
                    PersistentBeerTracker(count: $beerCount)
                }
                
                Spacer()
                
                // Reset Button
                Button("Reset All Counts") {
                    waterCount = 0
                    coffeeCount = 0
                    beerCount = 0
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                // Persistence Info
                Text("💾 Your progress is automatically saved!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Drink Tracker")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PersistentWaterTracker: View {
    @Binding var count: Int
    @Binding var goal: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("^[\(count) glass](inflect: true) of water")
                        .font(.headline)
                    
                    HStack {
                        Stepper("", value: $count, in: 0...20)
                            .labelsHidden()
                        
                        Spacer()
                        
                        // Quick add buttons
                        Button("+1") { count += 1 }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        
                        Button("+3") { count += 3 }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }
                }
                
                Spacer()
            }
            
            // Goal Setting
            HStack {
                Text("Daily Goal:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Stepper("\(goal) glasses", value: $goal, in: 1...15)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PersistentCoffeeTracker: View {
    @Binding var count: Int
    
    var body: some View {
        HStack {
            Image(systemName: "cup.and.saucer.fill")
                .foregroundStyle(.brown)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text("^[\(count) cup](inflect: true) of coffee")
                    .font(.headline)
                
                HStack {
                    Stepper("", value: $count, in: 0...10)
                        .labelsHidden()
                    
                    Spacer()
                    
                    if count >= 4 {
                        Text("☕️ That's a lot!")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.brown.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PersistentBeerTracker: View {
    @Binding var count: Int
    
    var body: some View {
        HStack {
            Image(systemName: "wineglass.fill")
                .foregroundStyle(.yellow)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text("^[\(count) glass](inflect: true) of beer")
                    .font(.headline)
                
                HStack {
                    Stepper("", value: $count, in: 0...5)
                        .labelsHidden()
                    
                    Spacer()
                    
                    if count > 0 {
                        Text("🍺 Cheers!")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.yellow.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Comparison view showing @State vs @AppStorage
struct StateVsAppStorageComparison: View {
    // Temporary storage (resets when view disappears)
    @State private var temporaryCount = 0
    
    // Persistent storage (survives app restarts)
    @AppStorage("persistentDemoCount") private var persistentCount = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("@State vs @AppStorage")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // @State Example
                VStack(spacing: 12) {
                    Text("@State (Temporary)")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    
                    Text("Count: \(temporaryCount)")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Button("-") { if temporaryCount > 0 { temporaryCount -= 1 } }
                            .buttonStyle(.bordered)
                        
                        Button("+") { temporaryCount += 1 }
                            .buttonStyle(.bordered)
                        
                        Button("Reset") { temporaryCount = 0 }
                            .buttonStyle(.bordered)
                    }
                    
                    Text("❌ Lost when app closes")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                .padding()
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // @AppStorage Example
                VStack(spacing: 12) {
                    Text("@AppStorage (Persistent)")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    Text("Count: \(persistentCount)")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Button("-") { if persistentCount > 0 { persistentCount -= 1 } }
                            .buttonStyle(.bordered)
                        
                        Button("+") { persistentCount += 1 }
                            .buttonStyle(.bordered)
                        
                        Button("Reset") { persistentCount = 0 }
                            .buttonStyle(.bordered)
                    }
                    
                    Text("✅ Survives app restarts")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
                VStack {
                    Text("💡 Test it out!")
                        .font(.headline)
                    
                    Text("Increment both counters, then close and reopen the app. The @AppStorage counter will remember its value!")
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

#Preview("Persistent Drink Tracker") {
    DrinkTrackerPersistent()
}

#Preview("State vs AppStorage") {
    StateVsAppStorageComparison()
}