// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

// a line comment

/*
 * Block comment, can be /* nested */
 */


//----------------------


/*
 You don’t traditionally define a main function like you do in some other languages. Instead, Swift uses a special file named 'main.swift' as the entry point for the program (there are more options, but not today).
 It is executed from start to end.
 */

print("Welcome to Swift!")                  // print function
print("-----------------"); print()         // semicolons for multiple separate statements

print(" 1| A single line.")                 // number '1|' helps to associate output with code line

print(" 2| More text", terminator: "")      // call with second parameter for end-of-line-string
print(" - rest of line.")

print(" 3| Expressions: 42+1=\(42+1)")      // string interpolation: \(expression)


//----------------------


/*
 Usually we do not have 'free code', but our code snippets are organised into functions that are called at the end. This is how we encapsulate specific features that we want to discuss.
 */

func readFromConsole() {
    introduce(topic: "Variables")
    
    print(" 1| What’s your name? ", terminator: "")

    let name = readLine() ?? "-"            // forget 'let' and '??' for now
    print(" 2| Hi '\(name)', nice to have you here!")
}

readFromConsole()


//----------------------


/// print helper function at the end
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
