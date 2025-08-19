//
//  StudentsView.swift
//  SwiftUIDemo
//
//  Created by Harry Ng on 8/18/25.
//

import SwiftUI

struct StudentsView: View {
    @State var students: [Student] = []

    var body: some View {
        List(students) {
            Text("Name: \($0.name)")
        }
        .task {
            await loadStudents()
        }
    }

    func loadStudents() async {
        do {
            // 1. URL
            guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else {
                return // early return
            }

            // 2. URLSession get students from server
            let (data, _) = try await URLSession.shared.data(from: url)

            // 3. Decode json
            let students = try JSONDecoder().decode([Student].self, from: data)

            // 4. Display in UI
            self.students = students
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct Student: Codable, Identifiable {
    var id: Int
    var name: String
}

#Preview {
    StudentsView()
}
