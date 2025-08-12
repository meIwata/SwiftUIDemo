import SwiftUI

struct Tap_Demo: View {
    @State private var isTapped: Bool = false
    @State private var isClicked: Bool = false
    @State private var inputText: String = ""

    var body: some View {
        VStack {
            Image("pencake")
                .resizable()
                .scaledToFit()
                .frame(width: isTapped ? 300 : 200)
                .animation(.default, value: isTapped)
                .onTapGesture(count: 2) {
                    isTapped.toggle()
                }
                .opacity(isClicked ?  0.5 : 1)
                .onLongPressGesture {
                    isClicked = true // 這裡設為true的話，狀態永遠就是true了，但這裡用true也可以，因為下面點選完成之後，狀態又改成false
//                    isClicked.toggle()
                    print("長按")
                }

            // 長按後顯示輸入框
            if isClicked {
                VStack {
                    Text("請輸入文字：")
                    TextField("輸入...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button("完成") {
                        isClicked = false
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .transition(.scale)
            }
        }
        .animation(.default, value: isClicked)
    }
}
        
//            .onTapGesture(count: 1, perform: {
//                isTapped.toggle()
//            })
//        
//            .onTapGesture(perform: {
//                isTapped.toggle()
//            })
//        
//            .onTapGesture {
//                isTapped.toggle()
//            }
            
            // .onTapGesture() {
                // withAnimation{ // 加上動畫
               // isTapped.toggle() // 綁定上面的isTapped: Bool = false
                //}
            //}


#Preview("Tap to zoom") {
    Tap_Demo()
}

#Preview("Zoomable") {
    Image("pencake")
        .resizable()
        .scaledToFit()
        .rounded()
        .frame(width: 200)
        .zoomable()
}
