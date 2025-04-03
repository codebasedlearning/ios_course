//
//  ContentView.swift
//  c_connect_four_app
//
//  Created by Alexander Voss on 02.04.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ConnectFourView()
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
    }
}

#Preview {
    ContentView()
}


//enum Player: String {
//    case red = "x"
//    case o = "o"
//    case none = ""
//}

 struct ConnectFourView: View {
     private let rows = 6
     private let columns = 7

     @State private var board: [[Player?]] = Array(repeating: Array(repeating: nil, count: 7), count: 6)
     @State private var currentPlayer: Player = .red
     @State private var winner: Player? = nil

     var body: some View {
         VStack {
             Text("winner")
                 .font(.title)
                 .padding()

             Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                 ForEach(0..<rows) { row in
                     GridRow {
                         ForEach(0..<columns) { column in
                             Circle()
                                 .fill(colorFor(row: row, column: column))
                                 .frame(width: 40, height: 40)
                                 .onTapGesture {
                                     dropDisc(in: column)
                                 }
                         }
                     }
                 }
             }
             .padding()

             Button("Reset") {
                 resetGame()
             }
             .padding()
         }
     }

     private var winnerText: String {
         if let winner = winner {
             return "\(winner.rawValue.capitalized) wins!"
         } else {
             return "\(currentPlayer.rawValue.capitalized)'s turn"
         }
     }

     private func dropDisc(in column: Int) {
         guard winner == nil else { return }
         for row in (0..<rows).reversed() {
             if board[row][column] == nil {
                 board[row][column] = currentPlayer
                 if checkWin(row: row, column: column, player: currentPlayer) {
                     winner = currentPlayer
                 } else {
                     currentPlayer.toggle()
                 }
                 break
             }
         }
     }

     private func colorFor(row: Int, column: Int) -> Color {
         switch board[row][column] {
         case .red: return .red
         case .yellow: return .yellow
         case .none: return .gray.opacity(0.3)
         }
     }

     private func resetGame() {
         board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
         currentPlayer = .red
         winner = nil
     }

     private func checkWin(row: Int, column: Int, player: Player) -> Bool {
         let directions = [(0,1), (1,0), (1,1), (1,-1)]
         for (dx, dy) in directions {
             var count = 1
             count += countDirection(row: row, column: column, dx: dx, dy: dy, player: player)
             count += countDirection(row: row, column: column, dx: -dx, dy: -dy, player: player)
             if count >= 4 { return true }
         }
         return false
     }

     private func countDirection(row: Int, column: Int, dx: Int, dy: Int, player: Player) -> Int {
         var x = row + dx
         var y = column + dy
         var count = 0
         while x >= 0 && x < rows && y >= 0 && y < columns && board[x][y] == player {
             count += 1
             x += dx
             y += dy
         }
         return count
     }
 }

 enum Player: String {
     case red, yellow

     mutating func toggle() {
         self = (self == .red) ? .yellow : .red
     }
 }

 struct ConnectFourView_Previews: PreviewProvider {
     static var previews: some View {
         ConnectFourView()
     }
 }


