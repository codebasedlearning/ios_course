// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

/*
 This is the 'main' program. From here we build a 'scene', given by 'ContentView'.
 
 We want to collect 'Language Features'. Here we can see a _struct_ (value type) and some sort of (contractual) _inheritance_, which is actually a 'protocol' (something similar to an 'interface') with a _calculated property_ called 'body'. The {}-block is a short form of a getter. It's Swift syntax sugar that feels like markup but compiles into regular Swift function calls and value construction.
 
 You can always see a definition like 'App' with the context menu 'Jump to Definition'.
 */

import SwiftUI

@main
struct FirstApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
