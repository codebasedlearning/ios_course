// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI

/*
 Here we have a similar structure to 'App' and 'body', but with 'View'. 'View' is the base protocol that all visible UI components conform to.
 
 SwiftUI builds its UI programmatically using a declarative syntax, i.e. instead of telling the system how to build and update the UI step by step (imperative), you just describe what the UI should look like for a given state.
 
 So while you could think of View as the “base” of all SwiftUI things, it’s not like an object-oriented base class. It’s more like:
 - A capability: “You can be rendered”
 - A contract: “Give me a 'body' and I’ll show you on screen”
 
 'VStack' stacks its children vertically. But on a language level this is a 'trailing closure/lambda syntax' returning a (combined) result-view, i.e. if the last parameter is a closure, you can pull it out of the parentheses. Inside the {} a view hierarchy is built, kind of like creating a virtual DOM or layout tree.
 
 'HStack' compose its children horizontally.
 
 We can also observe 'named parameters' and 'enums' (.large, .tint, .vertical, etc.).
 
 Finally, we have 'chaining', i.e. calling member functions chained on an instance.
 */

struct ContentView: View {
    var body: some View {
        VStack {                            // layout children vertically (V)
            Image(systemName: "globe")      // from "SF Symbols"-App
                .foregroundStyle(.orange)
                .font(.system(size: 48))    // or .imageScale
                .padding(10)                // some space around
            HStack {                        // layout children horizontally (H)
                Text("Hello, world!")
                    .font(.title3)
                    .padding(.trailing, 20)
                Image(systemName: "person.3.fill")
                    .imageScale(.large)
            }
        }
        .padding()
        .background(.gray.opacity(0.2))
        .border(Color.orange, width: 2)
    }
}

#Preview {
    ContentView()
}
