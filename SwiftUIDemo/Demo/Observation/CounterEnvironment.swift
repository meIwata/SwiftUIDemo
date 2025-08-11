import SwiftUI
import Observation

@Observable // 加上 @Observable，這個 class 的屬性變化會自動被監聽，驅動 SwiftUI View 更新
class CounterModel {
    // 兩個屬性：text（字串）和 count（整數）
    var text: String = "Hello, World!"
    var count: Int = 0
    
    func test(){
        var text: String = "" // 有佔記憶體
        text = "ABC"
        if text == ""{
            
        }
       
        var text2: String? = nil // 空的，沒有佔記憶體。 String?是代表這個型別是Optional（可選型別）
        // Optional 是一種「有值或沒值」的包裝型別
        
        text2 = "ABC"
        if text2 == nil {
            
        }
        if let text2 = text2 {
            
        }
        
    }
}

struct BindableCounter: View {
    @Bindable var model: CounterModel // 這個 model 會在 View 內部被雙向綁定（可即時更新、可寫入）

    var body: some View {
        TextField("", text: $model.text) // 直接用 $model.text 綁定到 TextField，當使用者輸入文字時，model.text 會即時更新
            .padding()
    }
}

struct CounterEnvironment: View {
    @Environment(CounterModel.self) private var model // 從 SwiftUI 的 Environment 取得 CounterModel 實例

    var body: some View {
        @Bindable var model = model // 將 Environment 取得的 model 變成 bindable，這樣就可以直接在 View 內容裡對 model 屬性做資料綁定和修改

        TextField("", text: $model.text) // TextField 可以直接雙向綁定 model.text
            .padding()

        Text("Counter: \(model.count)")

        Button("Increment") { // Button 可以直接修改 model.count，Text 也會同步更新
            model.count += 1
        }
    }
}

#Preview {
    CounterEnvironment()
        .font(.largeTitle)
        .environment(CounterModel()) // 把一個 CounterModel 實例注入到 Environment，讓 CounterEnvironment 能取用
}
