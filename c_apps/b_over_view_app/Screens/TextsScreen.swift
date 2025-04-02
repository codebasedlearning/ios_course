// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

struct TextsScreen: View {
    var body: some View {
        VStack(spacing: 5) {
            Divider()
            FontsBlock()
            WeightsBlock()
            ShortsBlock()
            ColoredBlock()
            MultilinesBlock()
            MiscTextsBlock()
            GeometryReaderBlock()
            Spacer()
        }
    }
}

struct FontsBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– Fonts –").asLine
            HStack(alignment: .bottom) {
                Spacer()
                Text("largeTitle").font(.largeTitle).border(Color.red)
                Text("title").font(.title).border(Color.red)
                Text("title2").font(.title2).border(Color.red)
                Text("title3").font(.title3).border(Color.red)
                Text("callout").font(.callout).border(Color.red)
                Spacer()
            }.background(.gray.opacity(0.2))
            HStack(alignment: .bottom) {
                Spacer()
                Text("headline").font(.headline).border(Color.red)
                Text("subheadline").font(.subheadline).border(Color.red)
                Text("body").font(.body).border(Color.red)
                Text("footnote").font(.footnote).border(Color.red)
                Text("caption").font(.caption).border(Color.red)
                Text("caption2").font(.caption2).border(Color.red)
                Spacer()
            }.background(.gray.opacity(0.4))
            HStack(alignment: .bottom) {
                Spacer()
                Text("16BoldRounded").font(.system(size: 16, weight: .bold, design: .rounded))
                Text("BodyRegularSerif").font(.system(.body, design: .serif, weight: .regular))
                Spacer()
            }.background(.gray.opacity(0.6))
            HStack(alignment: .bottom) {
                Spacer()
                Text("largeTitle").font(.largeTitle)
                Text("this is title3, same baseline").font(.title3).baselineOffset(5).offset(x:-67)
                Spacer()
            }.background(.gray.opacity(0.8))
        }
    }
}

struct WeightsBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– Weights –").asLine
            HStack(alignment: .bottom) {
                Spacer()
                Text("Std")
                Text("black").fontWeight(.black)
                Text("heavy").fontWeight(.heavy)
                Text("bold").fontWeight(.bold)
                Text("semibold").fontWeight(.semibold)
                Spacer()
            }.background(.gray.opacity(0.2))
            HStack(alignment: .bottom) {
                Spacer()
                Text("medium").fontWeight(.medium)
                Text("regular").fontWeight(.regular)
                Text("light").fontWeight(.light)
                Text("thin").fontWeight(.thin)
                Text("ultraLight").fontWeight(.ultraLight)
                Spacer()
            }.background(.gray.opacity(0.4))
        }
    }
}

struct ShortsBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– Shorts –").asLine
            HStack(alignment: .bottom) {
                Spacer()
                Text("Std")
                Text("bold").bold()
                Text("italic").italic()
                Text("strike").strikethrough()
                Text("underline").underline()
                Spacer()
            }.background(.gray.opacity(0.2))
        }
    }
}

struct ColoredBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– Colors / Styles –").asLine
            HStack(alignment: .bottom) {
                Spacer()
                Text("Std")
                Text("Color").foregroundColor(.red)
                Text("Background").background(.green.opacity(0.3))
                Text("Style").foregroundStyle(.red)
                Text("Gradient").foregroundStyle(LinearGradient(gradient: Gradient(colors: [.red, .green]), startPoint: .leading, endPoint: .trailing))
                Spacer()
            }.background(.gray.opacity(0.2))
        }
    }
}

struct MultilinesBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– Multilines –").asLine
            HStack(alignment: .bottom) {
                Spacer()
                Text("This is a very long text that might not fit in one line.")
                    .lineLimit(2).multilineTextAlignment(.center)
                    .truncationMode(.head)
                Text("This is a very long text that might not fit in one line.")
                    .lineLimit(2).minimumScaleFactor(0.5).multilineTextAlignment(.center)
                Spacer()
            }.background(.gray.opacity(0.2))
        }
    }
}

struct MiscTextsBlock: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("– Misc –").asLine
            HStack(alignment: .bottom) {
                Spacer()
                Spacer()
                Text("Text")
                    .background(Color.blue) // order padding - background
                    .padding(5)
                    .foregroundColor(.white)
                //.clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .red, radius: 5, x: 0, y: 2)
                Spacer()
                Text("Text")
                    .padding(5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .red, radius: 5, x: 0, y: 2)
                Spacer()
                Text("With Overlay").padding(5).overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
    
                )
                Spacer()
            }
            .padding(5)
            .background(.gray.opacity(0.2))//.padding(5)
        }
    }
}
struct GeometryReaderBlock: View {
    var body: some View {
        /*
         from doc:
         When using GeometryReader in SwiftUI, content might not appear centered as expected
         because GeometryReader takes up all available space, but does not automatically center its content.
         Instead, the content alignment depends on how it is configured within the GeometryReader.
         If no explicit alignment is specified for the views inside the GeometryReader,
         they will start from the top leading corner (top-left for left-to-right languages).
         */
        VStack(spacing: 5) {
            Text("– GeometryReader –").asLine
            GeometryReader() { geo in
                let sz = (geo.size.width, geo.size.height)
                ZStack {
                    HStack(alignment: .top, spacing:0) {
                        Spacer().frame(width: sz.0*0.15)
                        Color.red.frame(width: sz.0*0.1, height: sz.1*0.4)
                        Spacer().frame(width: sz.0*0.2)
                        Color.green.frame(width: sz.0*0.1, height: sz.1*0.6)
                        Spacer().frame(width: sz.0*0.2)
                        Color.blue.frame(width: sz.0*0.1, height: sz.1*0.8)
                        Spacer().frame(width: sz.0*0.15)
                    }.frame(width: sz.0, height: sz.1, alignment: .top)
                    HStack(alignment: .bottom, spacing:0) {
                        Text("15%").frame(width: sz.0*0.15).background(.orange.opacity(0.3))
                        Text("10%").frame(width: sz.0*0.10).background(.mint.opacity(0.5)).offset(y:5)
                        Text("20%").frame(width: sz.0*0.20, alignment: .trailing).background(.orange.opacity(0.3))
                        Text("10%").frame(width: sz.0*0.10).background(.mint.opacity(0.5)).offset(y:5)
                        Text("20%").frame(width: sz.0*0.20, alignment: .leading).background(.orange.opacity(0.3))
                        Text("10%").frame(width: sz.0*0.10).background(.mint.opacity(0.5)).offset(y:5)
                        Text("15%").frame(width: sz.0*0.15).background(.orange.opacity(0.3))
                    }.frame(width: sz.0, height: sz.1, alignment: .bottom)
                }
            }.frame(height: 50)
                .border(Color.black, width: 3)
                .background(.gray.opacity(0.3))
        }
    }
}
