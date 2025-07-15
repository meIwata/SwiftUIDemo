import SwiftUI

struct VStack_Demo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 80){
            Text("Movies of the Year")
                .font(.headline)
            Text("Top picks from our collection")
                .font(.subheadline)
        }
    }
}

#Preview {
    VStack_Demo()
}
