import SwiftUI

// 自訂 Environment key 的新寫法
extension EnvironmentValues {
    @Entry var count = 0 // @Entry 會自動幫你產生 EnvironmentKey 和 getter/setter
}

private struct InternalView: View {
    @Environment(\.count) private var count // 這個 View 用 @Environment(\.count) 取得 Environment 中的 count 值

    var body: some View {
        Text("Environment: \(count)")
    }
}

struct Environment_Demo: View {
    var body: some View {
        InternalView()
            .environment(\.count, 100) // .environment(\.count, 100) 這行，把 count 這個 Environment key 設成 100，傳到子 View。
    }
}

#Preview {
    Environment_Demo() // 預覽畫面，顯示效果
}
