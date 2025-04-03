//
//  ContentView.swift
//  c_memory_app
//
//  Created by Alexander Voss on 02.04.25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MemoryCardGameView()
    }
}


struct MemoryCardGameView: View {
    private let emojis = ["🍎", "🍌", "🍓", "🍇", "🍉", "🍍", "🥝", "🍒"]
    @State private var cards: [Card] = []
    @State private var firstFlipped: Int? = nil
    @State private var matchedPairs = 0

    var body: some View {
        VStack {
            Text("Memory Match")
                .font(.largeTitle)
                .padding()

            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(0..<4) { row in
                    GridRow {
                        ForEach(0..<4) { col in
                            let index = row * 4 + col
                            if index < cards.count {
                                CardView(card: cards[index])
                                    .onTapGesture {
                                        flipCard(at: index)
                                    }
                            } else {
                                Color.clear.frame(width: 60, height: 80)
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
        .onAppear(perform: resetGame)
    }

    private func flipCard(at index: Int) {
        guard !cards[index].isMatched && !cards[index].isFaceUp else { return }

        cards[index].isFaceUp = true

        if let first = firstFlipped {
            if cards[first].emoji == cards[index].emoji {
                cards[first].isMatched = true
                cards[index].isMatched = true
                matchedPairs += 1
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    cards[first].isFaceUp = false
                    cards[index].isFaceUp = false
                }
            }
            firstFlipped = nil
        } else {
            firstFlipped = index
        }
    }

    private func resetGame() {
        var paired = (emojis + emojis).shuffled()
        cards = paired.map { Card(emoji: $0) }
        firstFlipped = nil
        matchedPairs = 0
    }
}

struct Card {
    let emoji: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .frame(width: 60, height: 80)
                Text(card.emoji)
                    .font(.largeTitle)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: 60, height: 80)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: card.isFaceUp)
    }
}

struct MemoryCardGameView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryCardGameView()
    }
}
