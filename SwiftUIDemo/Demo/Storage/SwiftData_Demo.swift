import SwiftUI
import SwiftData

/// # SwiftData Demo
/// 
/// SwiftData is Apple's modern database framework that replaces Core Data.
/// It provides a declarative API for data modeling and automatic persistence.
///
/// ## Key Features:
/// - Declarative data models using @Model
/// - Automatic database creation and migration
/// - Type-safe queries with @Query
/// - Relationships between entities
/// - Undo/Redo support
/// - iCloud sync capability
///
/// ## When to Use SwiftData:
/// - Complex data relationships
/// - Large datasets
/// - Need for queries and filtering
/// - Data that changes frequently
/// - Multi-user scenarios

// MARK: - Data Models

@Model
class Book {
    var title: String
    var author: String
    var publishedYear: Int
    var isRead: Bool
    var rating: Int?
    var notes: String
    var dateAdded: Date
    var genre: Genre
    
    // Relationship to reviews
    @Relationship(deleteRule: .cascade, inverse: \Review.book)
    var reviews: [Review] = []
    
    init(title: String, author: String, publishedYear: Int, genre: Genre = .fiction) {
        self.title = title
        self.author = author
        self.publishedYear = publishedYear
        self.isRead = false
        self.rating = nil
        self.notes = ""
        self.dateAdded = Date()
        self.genre = genre
    }
}

@Model
class Review {
    var content: String
    var rating: Int
    var reviewDate: Date
    var reviewer: String
    
    // Relationship back to book
    var book: Book?
    
    init(content: String, rating: Int, reviewer: String, book: Book? = nil) {
        self.content = content
        self.rating = rating
        self.reviewDate = Date()
        self.reviewer = reviewer
        self.book = book
    }
}

enum Genre: String, CaseIterable, Codable {
    case fiction = "Fiction"
    case nonFiction = "Non-Fiction"
    case mystery = "Mystery"
    case romance = "Romance"
    case sciFi = "Sci-Fi"
    case fantasy = "Fantasy"
    case biography = "Biography"
    case history = "History"
    
    var icon: String {
        switch self {
        case .fiction: return "book"
        case .nonFiction: return "book.closed"
        case .mystery: return "magnifyingglass"
        case .romance: return "heart"
        case .sciFi: return "globe"
        case .fantasy: return "wand.and.stars"
        case .biography: return "person"
        case .history: return "clock"
        }
    }
}

// MARK: - Main Views

struct SwiftDataDemo: View {
    var body: some View {
        BookLibraryApp()
            .modelContainer(for: [Book.self, Review.self])
    }
}

struct BookLibraryApp: View {
    @Query private var books: [Book]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddBook = false
    @State private var searchText = ""
    @State private var selectedGenre: Genre?
    
    private var filteredBooks: [Book] {
        var filtered = books
        
        if !searchText.isEmpty {
            filtered = filtered.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let selectedGenre = selectedGenre {
            filtered = filtered.filter { $0.genre == selectedGenre }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Stats Header
                LibraryStatsView(books: books)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("All") {
                            selectedGenre = nil
                        }
                        .buttonStyle(.bordered)
                        .tint(selectedGenre == nil ? .blue : .gray)
                        
                        ForEach(Genre.allCases, id: \.self) { genre in
                            Button(genre.rawValue) {
                                selectedGenre = genre == selectedGenre ? nil : genre
                            }
                            .buttonStyle(.bordered)
                            .tint(selectedGenre == genre ? .blue : .gray)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Books List
                List {
                    ForEach(filteredBooks) { book in
                        NavigationLink(destination: BookDetailView(book: book)) {
                            BookRowView(book: book)
                        }
                    }
                    .onDelete(perform: deleteBooks)
                }
                .searchable(text: $searchText, prompt: "Search books or authors")
                .listStyle(.plain)
            }
            .navigationTitle("My Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBook = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .secondaryAction) {
                    Button("Add Sample Data") {
                        addSampleBooks()
                    }
                }
            }
            .sheet(isPresented: $showingAddBook) {
                AddBookView()
            }
        }
    }
    
    private func deleteBooks(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredBooks[index])
            }
        }
    }
    
    private func addSampleBooks() {
        let sampleBooks = [
            Book(title: "The Swift Programming Language", author: "Apple Inc.", publishedYear: 2014, genre: .nonFiction),
            Book(title: "Clean Code", author: "Robert C. Martin", publishedYear: 2008, genre: .nonFiction),
            Book(title: "The Hobbit", author: "J.R.R. Tolkien", publishedYear: 1937, genre: .fantasy),
            Book(title: "1984", author: "George Orwell", publishedYear: 1949, genre: .fiction),
            Book(title: "Dune", author: "Frank Herbert", publishedYear: 1965, genre: .sciFi)
        ]
        
        for book in sampleBooks {
            modelContext.insert(book)
        }
    }
}

struct LibraryStatsView: View {
    let books: [Book]
    
    private var totalBooks: Int { books.count }
    private var readBooks: Int { books.filter(\.isRead).count }
    private var averageRating: Double {
        let ratedBooks = books.compactMap(\.rating)
        guard !ratedBooks.isEmpty else { return 0 }
        return Double(ratedBooks.reduce(0, +)) / Double(ratedBooks.count)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            StatView(title: "Total", value: "\(totalBooks)", color: .blue)
            StatView(title: "Read", value: "\(readBooks)", color: .green)
            StatView(title: "Rating", value: String(format: "%.1f", averageRating), color: .orange)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct StatView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack {
            Image(systemName: book.genre.icon)
                .foregroundStyle(book.genre == .fiction ? .blue : .green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(book.genre.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.gray.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Text("\(book.publishedYear)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if book.isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    
                    if let rating = book.rating {
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct BookDetailView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddReview = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Book Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("by \(book.author)")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Label(book.genre.rawValue, systemImage: book.genre.icon)
                        Spacer()
                        Text("\(book.publishedYear)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                
                Divider()
                
                // Reading Status
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reading Status")
                        .font(.headline)
                    
                    Toggle("Mark as Read", isOn: $book.isRead)
                    
                    if book.isRead {
                        VStack(alignment: .leading) {
                            Text("Rating")
                                .font(.subheadline)
                            
                            HStack {
                                ForEach(1...5, id: \.self) { star in
                                    Button {
                                        book.rating = star
                                    } label: {
                                        Image(systemName: star <= (book.rating ?? 0) ? "star.fill" : "star")
                                            .foregroundStyle(.yellow)
                                    }
                                }
                                
                                if let rating = book.rating {
                                    Text("(\(rating)/5)")
                                        .foregroundStyle(.secondary)
                                        .padding(.leading)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    
                    TextField("Add your notes...", text: $book.notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                Divider()
                
                // Reviews
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Reviews (\(book.reviews.count))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Add Review") {
                            showingAddReview = true
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if book.reviews.isEmpty {
                        Text("No reviews yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(book.reviews, id: \.reviewDate) { review in
                            ReviewView(review: review)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddReview) {
            AddReviewView(book: book)
        }
    }
}

struct ReviewView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.reviewer)
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Text(review.content)
                .font(.body)
            
            Text(review.reviewDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct AddBookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var publishedYear = Calendar.current.component(.year, from: Date())
    @State private var genre = Genre.fiction
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Book Details") {
                    TextField("Title", text: $title)
                    TextField("Author", text: $author)
                    
                    Picker("Published Year", selection: $publishedYear) {
                        ForEach(1900...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    
                    Picker("Genre", selection: $genre) {
                        ForEach(Genre.allCases, id: \.self) { genre in
                            Label(genre.rawValue, systemImage: genre.icon)
                                .tag(genre)
                        }
                    }
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newBook = Book(
                            title: title,
                            author: author,
                            publishedYear: publishedYear,
                            genre: genre
                        )
                        modelContext.insert(newBook)
                        dismiss()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
        }
    }
}

struct AddReviewView: View {
    let book: Book
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var content = ""
    @State private var rating = 5
    @State private var reviewer = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Review Details") {
                    TextField("Reviewer Name", text: $reviewer)
                    
                    VStack(alignment: .leading) {
                        Text("Rating: \(rating)/5")
                        
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    rating = star
                                } label: {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .foregroundStyle(.yellow)
                                }
                            }
                        }
                    }
                    
                    TextField("Review", text: $content, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle("Add Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newReview = Review(
                            content: content,
                            rating: rating,
                            reviewer: reviewer,
                            book: book
                        )
                        modelContext.insert(newReview)
                        dismiss()
                    }
                    .disabled(content.isEmpty || reviewer.isEmpty)
                }
            }
        }
    }
}

#Preview {
    SwiftDataDemo()
}