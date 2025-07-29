import SwiftUI

struct NavigationStack_Demo: View {
    var body: some View {
        NavigationStack { // 外面包一層NavigationStack
            List {
                NavigationLink(value: 1) { // 連結
                    Text("Show Detail")
                }
                NavigationLink(value: 2) {
                    Text("Show Mailbox 📬")
                }
                NavigationLink(value: 3) {
                    Text("Show Sport 🚴🏻")
                }
                NavigationLink(value: 4) {
                    Text("Show Animal 🐯")
                }
                NavigationLink(value: 5) {
                    Text("Show Food 🍔")
                }
                
            }
            .navigationTitle("Actions")
            .navigationDestination(for: Int.self) { value in
                if value == 1 {
                    VStack {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 60)) // 指定圖片大小
                            .foregroundColor(.blue)  // 改顏色
                        Text("Detail View")
                    }
                } else if value == 2 {
                    HStack{
                        Text("寄信")
                        Image(systemName: "envelope.badge.person.crop")
                            .font(.system(size: 60)) // 指定圖片大小
                            .foregroundColor(.green)  // 改顏色
                    }
                    
                    
                } else if value == 3 {
                    Text("🐒🦘🦛 動物園")
                } else {
                    Text("雜項")
                }
            }
        }
    }
}

#Preview("Navigation") {
    NavigationStack_Demo()
}

/// Navigation Path
struct NavigationStack_Demo2: View {
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                NavigationLink(value: "Detail") {
                    Text("Show Detail")
                }
            }
            .navigationTitle("Actions")
            .navigationDestination(for: String.self) { value in
                VStack {
                    Text("Detail View")

                    Button("Push") {
                        path.append("Detail")
                    }

                    if path.count >= 3 {
                        Button("Pop to root") {
                            path = []
                        }
                    }
                }
            }
        }
    }
}

#Preview("NavigationPath") {
    NavigationStack_Demo2()
}
