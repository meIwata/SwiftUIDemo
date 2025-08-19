import SwiftUI

struct WeatherView: View {
    @State private var searchText = ""
    @State private var searchResults: [GeocodingResult] = []
    @State private var selectedLocation: GeocodingResult?
    @State private var weatherState: LoadingState<WeatherResponse> = .idle
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                searchSection
                
                if !searchResults.isEmpty && selectedLocation == nil {
                    cityResultsList
                } else {
                    weatherContent
                }
                
                Spacer()
            }
            .navigationTitle("Weather")
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                
                if newValue.isEmpty {
                    searchResults = []
                    selectedLocation = nil
                    weatherState = .idle
                } else if newValue.count >= 2 {
                    searchTask = Task {
                        try? await Task.sleep(for: .milliseconds(500))
                        
                        if !Task.isCancelled {
                            await searchCities()
                        }
                    }
                }
            }
        }
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search for a city...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        Task {
                            await searchCities()
                        }
                    }
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        searchResults = []
                        selectedLocation = nil
                        weatherState = .idle
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
            
            Text("🌍 Powered by Open-Meteo (No API key required)")
                .font(.caption)
                .foregroundStyle(.green)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    private var cityResultsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select a location:")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(searchResults, id: \.name) { city in
                        CityResultRow(city: city) {
                            selectedLocation = city
                            searchResults = []
                            Task {
                                await loadWeather(for: city)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var weatherContent: some View {
        switch weatherState {
        case .idle:
            ContentUnavailableView(
                "Search for Weather",
                systemImage: "cloud.sun",
                description: Text("Enter a city name to get current weather data")
            )
            
        case .loading:
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading weather data...")
                    .foregroundStyle(.secondary)
                
                if let location = selectedLocation {
                    Text("for \(location.displayName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .loaded(let weather):
            ScrollView {
                WeatherDetailView(weather: weather, location: selectedLocation)
            }
            
        case .error(let error):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                
                Text("Weather Unavailable")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                if let location = selectedLocation {
                    Button("Try Again") {
                        Task {
                            await loadWeather(for: location)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
    
    @MainActor
    private func searchCities() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        do {
            searchResults = try await NetworkManager.shared.searchCities(query: searchText)
        } catch {
            print("Failed to search cities: \(error)")
            searchResults = []
        }
    }
    
    @MainActor
    private func loadWeather(for location: GeocodingResult) async {
        weatherState = .loading
        
        do {
            let weather = try await NetworkManager.shared.fetchWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )
            weatherState = .loaded(weather)
        } catch {
            weatherState = .error(error)
            print("Failed to load weather: \(error)")
        }
    }
}

struct CityResultRow: View {
    let city: GeocodingResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(city.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct WeatherDetailView: View {
    let weather: WeatherResponse
    let location: GeocodingResult?
    
    var body: some View {
        VStack(spacing: 24) {
            locationHeader
            mainWeatherCard
            detailsGrid
            sunTimesCard
        }
        .padding()
    }
    
    private var locationHeader: some View {
        VStack(spacing: 4) {
            Text(location?.name ?? "Location")
                .font(.title)
                .fontWeight(.bold)
            
            if let location = location {
                Text(location.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var mainWeatherCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(weather.current.temperature2m))°C")
                        .font(.system(size: 48, weight: .thin))
                    
                    Text("Feels like \(Int(weather.current.apparentTemperature))°C")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: weatherIcon(for: weather.current.weatherCode))
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    
                    Text(weatherDescription(for: weather.current.weatherCode))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
            
            if let maxTemp = weather.daily.temperature2mMax.first,
               let minTemp = weather.daily.temperature2mMin.first {
                HStack {
                    VStack {
                        Text("Min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(minTemp))°")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Max")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Int(maxTemp))°")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var detailsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            WeatherMetricCard(
                title: "Humidity",
                value: "\(weather.current.relativeHumidity2m)%",
                icon: "drop"
            )
            
            WeatherMetricCard(
                title: "Wind Speed",
                value: "\(String(format: "%.1f", weather.current.windSpeed10m)) km/h",
                icon: "wind"
            )
            
            WeatherMetricCard(
                title: "Wind Direction",
                value: "\(weather.current.windDirection10m)°",
                icon: "location.north"
            )
            
            WeatherMetricCard(
                title: "Coordinates",
                value: "\(String(format: "%.2f", weather.latitude)), \(String(format: "%.2f", weather.longitude))",
                icon: "location"
            )
        }
    }
    
    @ViewBuilder
    private var sunTimesCard: some View {
        if let sunrise = weather.daily.sunrise.first,
           let sunset = weather.daily.sunset.first {
            HStack {
                VStack {
                    Image(systemName: "sunrise")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text("Sunrise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTime(sunrise))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "sunset")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text("Sunset")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTime(sunset))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func formatTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: date)
    }
    
    private func weatherIcon(for code: Int) -> String {
        switch code {
        case 0: return "sun.max"
        case 1, 2, 3: return "cloud.sun"
        case 45, 48: return "cloud.fog"
        case 51, 53, 55, 56, 57: return "cloud.drizzle"
        case 61, 63, 65, 66, 67: return "cloud.rain"
        case 71, 73, 75, 77: return "cloud.snow"
        case 80, 81, 82: return "cloud.heavyrain"
        case 85, 86: return "cloud.snow"
        case 95, 96, 99: return "cloud.bolt"
        default: return "cloud"
        }
    }
    
    private func weatherDescription(for code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45: return "Fog"
        case 48: return "Depositing rime fog"
        case 51: return "Light drizzle"
        case 53: return "Moderate drizzle"
        case 55: return "Dense drizzle"
        case 56: return "Light freezing drizzle"
        case 57: return "Dense freezing drizzle"
        case 61: return "Slight rain"
        case 63: return "Moderate rain"
        case 65: return "Heavy rain"
        case 66: return "Light freezing rain"
        case 67: return "Heavy freezing rain"
        case 71: return "Slight snow"
        case 73: return "Moderate snow"
        case 75: return "Heavy snow"
        case 77: return "Snow grains"
        case 80: return "Slight rain showers"
        case 81: return "Moderate rain showers"
        case 82: return "Violent rain showers"
        case 85: return "Slight snow showers"
        case 86: return "Heavy snow showers"
        case 95: return "Thunderstorm"
        case 96: return "Thunderstorm with slight hail"
        case 99: return "Thunderstorm with heavy hail"
        default: return "Unknown"
        }
    }
}

struct WeatherMetricCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview("Weather View") {
    WeatherView()
}

#Preview("Weather Detail") {
    ScrollView {
        WeatherDetailView(
            weather: WeatherResponse(
                latitude: 51.5074,
                longitude: -0.1278,
                timezone: "Europe/London",
                current: CurrentWeather(
                    time: "2024-01-01T12:00",
                    temperature2m: 15.0,
                    relativeHumidity2m: 65,
                    apparentTemperature: 17.0,
                    weatherCode: 1,
                    windSpeed10m: 10.5,
                    windDirection10m: 180
                ),
                daily: DailyWeather(
                    time: ["2024-01-01"],
                    temperature2mMax: [18.0],
                    temperature2mMin: [8.0],
                    sunrise: ["2024-01-01T07:30:00"],
                    sunset: ["2024-01-01T16:45:00"]
                )
            ),
            location: GeocodingResult(
                name: "London",
                latitude: 51.5074,
                longitude: -0.1278,
                country: "United Kingdom",
                admin1: "England"
            )
        )
    }
}