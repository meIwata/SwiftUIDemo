import SwiftUI

struct Button_Demo: View {
    @State private var isChanged = false
    var body: some View {
        Button {
            // save book to favorites
            print("Button tapped: \(isChanged)")
            isChanged.toggle() // .toogle會自動切換布林值
            
        } label: {
            Label("Add to Favorites", systemImage: isChanged ? "heart" : "heart.fill")
                .foregroundStyle(.black)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct CustomButton: View{
    @State private var isPressed = false
    var body: some View{
        Button {
            print("Button tapped: \(isPressed)")
            isPressed.toggle() // .toogle會自動切換布林值
        } label: {
            Text("Tap me")
                .font(.title)
                .foregroundStyle(isPressed ? .green : .red )
            
        }

    }
}

#Preview {
    CustomButton()
}

#Preview {
    Button_Demo()
}
