import SwiftUI

struct PostListView: View {
    @State private var loadingState: LoadingState<[Post]> = .idle
    @State private var searchText = ""
    
    private var filteredPosts: [Post] {
        switch loadingState {
        case .loaded(let posts):
            if searchText.isEmpty {
                return posts
            } else {
                return posts.filter { post in
                    post.title.localizedCaseInsensitiveContains(searchText) ||
                    post.body.localizedCaseInsensitiveContains(searchText)
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
                        "Ready to Load Posts",
                        systemImage: "doc.text",
                        description: Text("Tap refresh to load posts")
                    )
                    
                case .loading:
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading posts...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case .loaded:
                    if filteredPosts.isEmpty && !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        List(filteredPosts) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostRowView(post: post)
                            }
                        }
                        .searchable(text: $searchText, prompt: "Search posts...")
                        .refreshable {
                            await loadPosts()
                        }
                    }
                    
                case .error(let error):
                    ContentUnavailableView(
                        "Error Loading Posts",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                }
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh", systemImage: "arrow.clockwise") {
                        Task {
                            await loadPosts()
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .task {
                if case .idle = loadingState {
                    await loadPosts()
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
    private func loadPosts() async {
        loadingState = .loading
        
        do {
            let posts = try await NetworkManager.shared.fetchPosts()
            loadingState = .loaded(posts)
        } catch {
            loadingState = .error(error)
            print("Failed to load posts: \(error)")
        }
    }
}

struct PostRowView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(post.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            
            HStack {
                Text("User \(post.userId)")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                Text("Post #\(post.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PostDetailView: View {
    let post: Post
    @State private var commentsState: LoadingState<[Comment]> = .idle
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("User \(post.userId)")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Text("Post #\(post.id)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(post.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(post.body)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comments")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    switch commentsState {
                    case .idle, .loading:
                        ForEach(0..<3, id: \.self) { _ in
                            CommentPlaceholderView()
                        }
                        
                    case .loaded(let comments):
                        if comments.isEmpty {
                            ContentUnavailableView(
                                "No Comments",
                                systemImage: "bubble.left",
                                description: Text("This post has no comments yet")
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(comments) { comment in
                                    CommentView(comment: comment)
                                }
                            }
                        }
                        
                    case .error(let error):
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundStyle(.orange)
                            Text("Failed to load comments")
                                .font(.headline)
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadComments()
        }
        .refreshable {
            await loadComments()
        }
    }
    
    @MainActor
    private func loadComments() async {
        commentsState = .loading
        
        do {
            let comments = try await NetworkManager.shared.fetchComments(for: post.id)
            commentsState = .loaded(comments)
        } catch {
            commentsState = .error(error)
            print("Failed to load comments: \(error)")
        }
    }
}

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(comment.email)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            
            Text(comment.body)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct CommentPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.3))
                    .frame(width: 120, height: 16)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.3))
                    .frame(width: 80, height: 12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.3))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(.secondary.opacity(0.3))
                    .frame(width: 200, height: 14)
            }
        }
        .padding()
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .redacted(reason: .placeholder)
    }
}

#Preview("Post List") {
    PostListView()
}

#Preview("Post Detail") {
    NavigationStack {
        PostDetailView(post: Post(
            userId: 1,
            id: 1,
            title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
            body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
        ))
    }
}