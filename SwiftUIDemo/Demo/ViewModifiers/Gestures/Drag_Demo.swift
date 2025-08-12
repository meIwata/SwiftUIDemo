import SwiftUI

struct Drag_Demo: View {
    @State private var position = CGSize.zero         // Final position (saved)
    @State private var dragOffset = CGSize.zero       // Offset during drag

    var body: some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            .offset(x: position.width + dragOffset.width,
                    y: position.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
//                        position.width += value.translation.width
//                        position.height += value.translation.height
                        withAnimation(.linear(duration: 1)){
                            dragOffset = .zero
                        }
                    }
            )
            .animation(.spring(), value: position)
    }
}

#Preview {
    Drag_Demo()
}
