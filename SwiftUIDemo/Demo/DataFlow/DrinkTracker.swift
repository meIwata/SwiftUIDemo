import SwiftUI

struct DrinkTracker: View { // struct 預設為 internal，可以寫成internal struct
    // stored properties
    @State private var waterCount: Int = 0 // var 變量用小駝峯命名規則
    @State private var coffeeCount: Int = 0
    @State private var beerCount: Int = 0

    
    private var totalCount: Int {
        // 每一次都做計算
        waterCount + coffeeCount + beerCount
    }

    var body: some View { // 先看body，some View 是 View的子類
        // let _ = Self._printChanges(); // 在console (CMD + shift + y ，可以打開console) 看看有沒有印出，一種除錯（debug）技巧
        VStack { // 垂直
            // computer properties
            Text("Total number of drinks: \(totalCount)")
            WaterTracker(count: $waterCount)
            CoffeeTracker(count: $coffeeCount)
            BeerTracker(count: $beerCount)
            Spacer() // 把資料置頂排列
        }
        .padding()
    }
}

struct WaterTracker2: View {
    @State var count: Int = 0 // @State 代表狀態的根源

    var body: some View {
        HStack {
            Text("^[\(count) glass](inflect: true) of water")
            Stepper("", value: $count) // Stepper就是＋－計算，Stepper也有連動的用法，會同步count的值
        }
        .padding()
    }
}

struct WaterTracker: View {
    @Binding var count: Int // @Binding 可以把外面的值同步到裡面

    var body: some View {
        let _ = Self._printChanges();
        HStack {
            Text("^[\(count) glass](inflect: true) of water")
            Stepper("", value: $count)
        }
        .padding()
    }
}

struct CoffeeTracker: View {
    @Binding var count: Int

    var body: some View {
        HStack {
            Text("^[\(count) cup](inflect: true) of coffee")
            Stepper("", value: $count)
        }
        .padding()
    }
}

struct BeerTracker: View {
    @Binding var count: Int

    var body: some View {
        HStack {
            Text("^[\(count) glass](inflect: true) of beer")
            Stepper("", value: $count)
        }
        .padding()
    }
}

struct DrinkView: View {
    private let symbolName: String = "cup.and.saucer"

    var body: some View {
        Image(systemName: symbolName)
            .imageScale(.large)
            .font(.title)
            .foregroundStyle(.blue)
    }
}

#Preview("Drink") {
    DrinkView()
}

#Preview("Water Tracker") {
    WaterTracker2()
}

#Preview("Drink Tracker") {
    DrinkTracker()
}
