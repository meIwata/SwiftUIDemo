import SwiftUI

struct ZStack_Demo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.pink.opacity(0.5))
            Image(systemName: "star")
                .foregroundStyle(.green)
        }
        
        ZStack {
            Circle()
                .fill(.blue)
            Image(systemName: "heart")
                .foregroundStyle(.yellow)
        }
        
        ZStack {
            Image("pencake")
                .resizable()
                .scaledToFit()
                .cornerRadius(15) // 添加圓角
            Image(systemName: "dog.fill")
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    ZStack_Demo()
//        .frame(width: 48)
        .frame(width: 60, height: 60)
}
