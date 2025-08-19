import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let decodedData = try JSONDecoder().decode(type, from: data)
                return decodedData
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            print("Network error: \(error)")
            throw NetworkError.unknown
        }
    }
    
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
            throw NetworkError.invalidURL
        }
        return try await fetch([User].self, from: url)
    }
    
    func fetchPosts() async throws -> [Post] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            throw NetworkError.invalidURL
        }
        return try await fetch([Post].self, from: url)
    }
    
    func fetchComments(for postId: Int) async throws -> [Comment] {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(postId)/comments") else {
            throw NetworkError.invalidURL
        }
        return try await fetch([Comment].self, from: url)
    }
    
    func searchCities(query: String) async throws -> [GeocodingResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encodedQuery)&count=5&language=en&format=json") else {
            throw NetworkError.invalidURL
        }
        
        let response = try await fetch(GeocodingResponse.self, from: url)
        return response.results ?? []
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto&forecast_days=1")!
        
        return try await fetch(WeatherResponse.self, from: url)
    }
}

extension NetworkManager {
    func loadData<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        Task {
            do {
                let data = try await fetch(type, from: url)
                await MainActor.run {
                    completion(.success(data))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}