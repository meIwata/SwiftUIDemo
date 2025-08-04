import SwiftUI

struct SimpleAnimation: View {
    @State private var flag = false
    @State private var isPresented = false
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(.blue)
            .frame(width: flag ? 100 : 50, height: 50)
            .onTapGesture {
               // withAnimation{ // 有一個動畫
               // withAnimation (.spring){
              withAnimation (.linear(duration: 2)){
                    flag.toggle() // 觸發flag
                } completion: {
                    isPresented.toggle()
                }
            }
        
        /*這像是把樓拆掉重新裝潢一間房*/
//        if isPresented{
//            Text("Done").opacity(0) // 隱性id
//        } else{
//            Text("Done").opacity(1) // 隱性id
//        }
        
        /*這樣寫法是直接裝修房間，這樣寫法比較好*/
        Text("Done")
            .opacity(isPresented ? 1 : 0.2)
    }
}

#Preview("Explict") {
    SimpleAnimation()
}

struct ImplicitAnimation: View {
    @State private var flag = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(.blue)
            .frame(width: flag ? 150 : 50, height: 50)
            .opacity(flag ? 1 : 0.5)
            // Implicit Animation 隱性動畫
//            .animation(.default, value: flag)
            .animation(.spring(duration: 2), value: flag)
            .onTapGesture {
                flag.toggle() // 觸發flag，整個animation都會動起來
            }
    }
}

#Preview("Implicit") {
    ImplicitAnimation()
}

struct ScopedAnimation: View { // 區域範圍的動畫
    @State private var flag = false

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(.blue)
            .frame(width: flag ? 100 : 50, height: 50)
//            .animation(.linear){
//                $0.frame(width: flag ? 100 : 50, height: 50)
//            }
            // Scoped Animation
            .animation(.spring(duration: 2)) {
                $0.opacity(flag ? 1 : 0.1)
            }
            .onTapGesture {
                flag.toggle()
            }
    }
}

#Preview("Scoped") {
    ScopedAnimation()
}


struct AntiAnimation: View {
    @State private var flag = false

    var body: some View {
        let rect = RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(.blue)
            .onTapGesture {
                withAnimation(.none) {
                    flag.toggle()
                }
            }

        if flag {
            rect
                .frame(width: 100, height: 50)
        } else {
            rect
                .frame(width: 50, height: 50)
        }
    }
}

#Preview("AntiAnimation") {
    AntiAnimation()
}
