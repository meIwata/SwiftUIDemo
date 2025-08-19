//
//  Books_Demo.swift
//  SwiftUIDemo
//
//  Created by Guest User on 2025/8/19.
//
import SwiftData
import SwiftUI

@Model
class SwiftBook{
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

struct Books_Demo: View {
    @Query var books: [SwiftBook]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
       NavigationStack {
            List(books){ book in
                Text("Books: \(book.name)")
            }
            .toolbar{
                ToolbarItem{
                    Button("Add Sample Books"){
                        addSampleBooks()
                    }
                }
            }
        }
    }
    
    func addSampleBooks(){
        let books: [SwiftBook]=[
            SwiftBook(name: "SwiftUI"),
            SwiftBook(name: "Swift"),
            SwiftBook(name: "Concurrency")
        ]
        for book in books {
            modelContext.insert(book)
        }
    }
}

#Preview {
    Books_Demo()
        .modelContainer(for: SwiftBook.self)
}
