// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct ArrayScreen: View {
    var body: some View {
        VStack(spacing: 5) {
            Divider()
            TicTacToeView()
            Spacer()
        }
    }
}

struct TicTacToeView: View {
    @State var board: [String] = Array(repeating: "0", count: 3*3)
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<9, id: \.self) { index in
                ZStack {
                    Rectangle()
                        .foregroundColor(.mint.opacity(0.8))
                        .frame(height: 120)
                        .cornerRadius(8)
                    Text(board[index])
                        .font(.system(size: 40))
                }
                .onTapGesture {
                    let n = (Int(board[index]) ?? 0)+1
                    board[index] = String(n)
                }
            }
        }
        .padding()
    }
}

/*
 board
  - @State is for data that changes and affects the UI.
  — board is dynamic, it changes when a user taps a cell, so marking it with @State triggers a UI update when the array is mutated.

 columns
  - is just a static layout configuration. It doesn’t change during the lifecycle of the view. There’s no need for SwiftUI to track it for invalidation and redraws.
  - Marking it with @State would be unnecessary overhead.
 
 grids
  - LazyVGrid pros:
     - Clean layout for grid-based UIs like a board game.
     - Flexibility: just define columns, and it figures out rows automatically.
     - Lazy rendering: only renders cells that are visible (handy if your grid was 100x100 instead of 3x3).
 
  - Nested ForEach
     - less elegant—especially for bigger grids. And it’s not lazy.

  - new Grid und GridRow
     - a bit more flexible for things like headers, see MemoryApp
 
 ids
  - When you use ForEach, SwiftUI needs a way to uniquely identify each item in the collection so it can:
     - Track changes efficiently
     - Animate updates
  - Looping over simple types like Int, String, etc., don’t come with a built-in identity, so you have to tell SwiftUI how to uniquely identify each item -> hence 'id: \.self'
  -  Implementing 'Identifiable' with a member 'id' is also sufficient.
 
 key path
   - A key path in Swift is a type-safe, compiler-checked reference to a property, like a pointer to a property.
   - \Type.property is a key path.
   - \.self is a special case where you’re telling Swift: Use the value itself as the identifier.
 */
