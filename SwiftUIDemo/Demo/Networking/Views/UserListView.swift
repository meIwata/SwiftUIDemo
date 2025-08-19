import SwiftUI

struct UserListView: View {
    @State private var loadingState: LoadingState<[User]> = .idle
    @State private var searchText = ""
    
    private var filteredUsers: [User] {
        switch loadingState {
        case .loaded(let users):
            if searchText.isEmpty {
                return users
            } else {
                return users.filter { user in
                    user.name.localizedCaseInsensitiveContains(searchText) ||
                    user.email.localizedCaseInsensitiveContains(searchText) ||
                    user.username.localizedCaseInsensitiveContains(searchText)
                }
            }
        default:
            return []
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch loadingState {
                case .idle:
                    ContentUnavailableView(
                        "Ready to Load",
                        systemImage: "person.3",
                        description: Text("Tap refresh to load users")
                    )
                    
                case .loading:
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading users...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .loaded:
                    if filteredUsers.isEmpty && !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        List(filteredUsers) { user in
                            UserRowView(user: user)
                        }
                        .searchable(text: $searchText, prompt: "Search users...")
                        .refreshable {
                            await loadUsers()
                        }
                    }
                    
                case .error(let error):
                    ContentUnavailableView(
                        "Error Loading Users",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task {
                            await loadUsers()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .task {
                if case .idle = loadingState {
                    await loadUsers()
                }
            }
        }
    }
    
    private var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }
    
    @MainActor
    private func loadUsers() async {
        loadingState = .loading
        
        do {
            let users = try await NetworkManager.shared.fetchUsers()
            loadingState = .loaded(users)
        } catch {
            loadingState = .error(error)
            print("Failed to load users: \(error)")
        }
    }
}

struct UserRowView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.headline)
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "envelope")
                        .foregroundStyle(.blue)
                        .font(.caption)
                    Text(user.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            HStack {
                Label(user.address.city, systemImage: "location")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if !user.website.isEmpty {
                    Label(user.website, systemImage: "globe")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview("User List") {
    UserListView()
}

#Preview("User Row") {
    List {
        UserRowView(user: User(
            id: 1,
            name: "Leanne Graham",
            username: "Bret",
            email: "sincere@april.biz",
            phone: "1-770-736-8031 x56442",
            website: "hildegard.org",
            address: Address(
                street: "Kulas Light",
                suite: "Apt. 556",
                city: "Gwenborough",
                zipcode: "92998-3874",
                geo: Geo(lat: "-37.3159", lng: "81.1496")
            ),
            company: Company(
                name: "Romaguera-Crona",
                catchPhrase: "Multi-layered client-server neural-net",
                bs: "harness real-time e-markets"
            )
        ))
    }
}