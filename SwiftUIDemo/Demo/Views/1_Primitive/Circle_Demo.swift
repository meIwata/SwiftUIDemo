import SwiftUI

struct Circle_Demo: View {
    var body: some View {
        Circle()
            .fill(Color.yellow)

        Circle()
            .frame(width: 50, height: 50)

        Circle()
            .stroke(Color.red, lineWidth: 12)
    }
}

#Preview {
    Circle_Demo()
        .padding()
}
