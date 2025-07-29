import SwiftUI

struct Popover_Demo: View {
    @State private var isShowing = false
    @State private var isShowingCover = false

    var body: some View {
        /// Refer to the examples in ``VStack_Demo``
        VStack {
            Button {
                isShowing = true
            } label: {
                Text("Show Popover")
            }
            
            Button {
                isShowingCover = true
            } label: {
                Text("Show Cover")
            }
        }
        
        .popover(
            isPresented: $isShowing,
            attachmentAnchor: .point(.top),
            arrowEdge: .bottom
        ) {
            Text("😎😎😎")
                .padding()
                .presentationCompactAdaptation(.none) // 取消會跳出一個版面
        }
        
        .fullScreenCover(isPresented: $isShowingCover){
            Image(systemName: "star.fill")
            Button {
                isShowingCover = false
            } label: {
                Text("Hide Cover")
            }
        }
    }
}

#Preview {
    Popover_Demo()
}
