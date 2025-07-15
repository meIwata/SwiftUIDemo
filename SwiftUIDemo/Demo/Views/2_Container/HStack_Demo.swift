import SwiftUI

struct HStack_Demo: View {
    var body: some View {
//        HStack(alignment: .center, spacing: 8) {
//
//        }
        
        HStack(alignment: .top, spacing: 80){
            Image(systemName: "star")
                .foregroundStyle(.yellow)
            Text("Favorites")
        }
    }
}

#Preview {
    HStack_Demo()
}
