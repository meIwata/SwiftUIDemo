import SwiftUI
import Observation

struct Counter: View {
    @Binding var count: Int // 負責顯示與修改父 View 提供的 count
    

    var body: some View {
        let _ = Self._printChanges()
        Text("Counter: \(count)")
        Button("Reset") {
            count = 0
        }
    }
}

struct ModelCounter: View { // 這個 View 直接持有一個 Model 實例
    var model: Model // 傳 reference（傳址）

    var body: some View {
        @Bindable var model = model
        
        Button("Set to 100") {
            model.count = 100 // 按下按鈕時，把 model.count 直接設為 100
        }
        
        TextField(text: $model.name){
            Text("Enter name")
        }
        .multilineTextAlignment(.center) // 置中
        .background(.red)
    }
}

struct CounterView: View {
    @State var model = Model()

    var body: some View {
        Button("Increment \(model.count)") { // model 預設是0
            model.count += 1
        }
        
        Text("Name: \(model.name)")

        Divider() // 分隔線

        Counter(count: $model.count) // 加上$變成binding

        Divider()

        ModelCounter(model: model) // model 是 reference。如果你在 ModelCounter 裡改了 model.count，外部那個 model.count 也會被改變
    }
}

@Observable // 右鍵可以expand marco
class Model { // class 宣告出來之後，你可以用 Model() 產生「物件」
    var count: Int = 0
    var name: String = "" // 新增一個字串屬性
}

#Preview {
    CounterView()
        .font(.largeTitle)
}
