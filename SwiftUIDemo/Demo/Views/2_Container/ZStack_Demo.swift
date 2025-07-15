import SwiftUI

struct ZStack_Demo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.pink)
            Image(systemName: "star")
                .foregroundStyle(.green)
        }
        
        ZStack {
            Circle()
                .fill(.blue)
            Image(systemName: "heart")
                .foregroundStyle(.yellow)
        }
    }
}

#Preview {
    ZStack_Demo()
        .frame(width: 48, height: 48)
}
