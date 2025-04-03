// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct LayoutsScreen: View {
    var body: some View {
        VStack(spacing: 5) {
            Divider()
            HStacksBlock()
            VStacksBlock()
            ZStacksBlock()
            AlignmentBlock()
            Spacer()
        }
    }
}

struct HStacksBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– HStacks –").asLine
            HStack(spacing:0) {
                Text("text")
                    .background(.gray.opacity(0.8))
                Text("with padding in a")
                    .padding(5)
                    .background(.gray.opacity(0.6))
                Text("HStack (spacing 0)")
                    .background(.gray.opacity(0.4))
            }
            HStack(spacing:5) {
                Text("text").background(.gray.opacity(0.8))
                Text("with padding in a").padding(5).background(.gray.opacity(0.6))
                Text("HStack (spacing 5)").background(.gray.opacity(0.4))
            }
            HStack(alignment: .bottom, spacing:5) {
                Text("text").background(.gray.opacity(0.8))
                Text("with padding in a").padding(5).background(.gray.opacity(0.6))
                Text("HStack (sp. 5, bottom)").background(.gray.opacity(0.4))
            }
        }
    }
}

struct VStacksBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– VStacks –").asLine
            HStack {
                VStack {
                    Text("text")
                    Text("second line")
                }.background(.gray.opacity(0.8))
                VStack {
                    Text("text")
                    Text("second line")
                }.padding(5).background(.gray.opacity(0.6))
                VStack(alignment: .trailing) {
                    Text("text")
                    Text("alignment trailing")
                }.background(.gray.opacity(0.4))
            }
        }
    }
}

extension View {
    func indexed(index: String) -> some View {
        ZStack {
            self
            Text(index).font(.footnote).offset(x:9,y:5)
        }
    }
}

struct ZStacksBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– ZStacks –").asLine
            ZStack {
                Text("12345 -------- abcde")
                Text("67890").offset(y:2)
            }.padding(.vertical, 10).background(.gray.opacity(0.8))
            HStack {
                Spacer()
                Text("a*b :=")
                Text("a").indexed(index: "i")
                Text("b").indexed(index: "i")
                Spacer()
            }.padding(.top, 10).background(.gray.opacity(0.6))
            ZStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                Text("Favorite")
            }.padding(5).background(.gray.opacity(0.6))
       }
    }
}

struct AlignmentBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– Alignments –").asLine// frame(maxWidth: .infinity).background(.orange.opacity(0.8))
            HStack(alignment: .bottom) { // relative to the largest child
                Spacer()
                Color.red.frame(width: 10, height: 10)
                Spacer()
                Color.green.frame(width: 10, height: 20)
                Spacer()
                Color.blue.frame(width: 10, height: 30)
                Spacer()
            }.background(.gray.opacity(0.4))
            HStack(alignment: .bottom) {
                Spacer()
                Color.red.frame(width: 10, height: 10)
                Spacer()
                Color.green.frame(width: 10, height: 20)
                Spacer()
                Color.blue.frame(width: 10, height: 30)
                Spacer()
            }.frame(height: 40) // alignment centered
            .background(.gray.opacity(0.4))
            HStack(alignment: .top) {
                Spacer()
                Color.red.frame(width: 10, height: 10)
                Spacer()
                Color.green.frame(width: 10, height: 20)
                Spacer()
                Color.blue.frame(width: 10, height: 30)
                Spacer()
            }.frame(height: 40, alignment: .bottom)
            .background(.gray.opacity(0.6))
        }
    }
}
