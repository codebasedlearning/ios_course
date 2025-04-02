// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


/* Work in progress... */


/// generic function with type constraints
func genAdd<T: AdditiveArithmetic>(_ a: T, _ b: T) -> T { return a+b }

/// generic class (or struct)
class SimpleStack<Element> {
    var items: [Element] = []
    func push(_ item: Element) { items.append(item) }
    func pop() -> Element { return items.removeLast() }
}

/// a 'generic' stack 'interface'; different syntax
protocol Stack {
    associatedtype Item
    func push(_ item: Item)
    func pop() -> Item
}

/// specific Int-implementation; Item is deduced from the code
class IntStack: Stack {
    var items: [Int] = []
    func push(_ item: Int) { items.append(item) }
    func pop() -> Int { return items.removeLast() }
}

/// generic implementation; either Item is defined or deduced
class ArrayStack<Element>: Stack {
    typealias Item = Element                // we could omit this (replace Item with Element)
    
    var items: [Item] = []
    func push(_ item: Item) { items.append(item) }
    func pop() -> Item { return items.removeLast() }
}

/**
 Generic structs and classes in Swift behave very similarly to generics in other object-oriented languages like Java, C#, or C++ in the sense that you can parameterize types and constrain them.
 
 Note, however, generics are monomorphized (compile-time specialization), like C++, unlike Java. Java and C# use type erasure.
 */
func usingGenerics() {
    introduce(topic: "Generics")
    
    print(" 1| 3+4=\(genAdd(3,4)), 3.5+4.0=\(genAdd(3.5,4.0))")
    
    let dblStack = SimpleStack<Double>()
    dblStack.push(3.5)
    dblStack.push(4.0)
    print(" 2| pop=\(dblStack.pop())")

    let charStack = SimpleStack<Character>()
    charStack.push("A")
    charStack.push("B")
    print(" 3| pop=\(charStack.pop())")
    
    let strStack = ArrayStack<String>()
    strStack.push("HiHo")
    strStack.push("Ahoi")
    print(" 4| pop=\(strStack.pop())")

}


//----------------------


/// simple renderable thing
protocol Renderable {
    func render() -> String
}

/// UI text
struct Text: Renderable {
    let content: String
    func render() -> String { return "Text '\(content)'" }
}

/// UI Button
struct Button: Renderable {
    let label: String
    func render() -> String { return "Button ['\(label)']" }
}

/// Function creating either a text or a button, depending on some condition. It works, but to the cost of type erasure, i.e. it is simply a Renderable thing and uses dynamic dispatch (runtime polymorphism, virtual functions) to resolve render() at runtime. Moreover, it has no associated type, otherwise it won't work (see Parser below).
func makeWidget() -> Renderable {
    if Bool.random() {
        return Text(content: "Hi")
    } else {
        return Button(label: "Click")
    }
}

/// Here 'some Renderable' is an opaque return type, returning a (specific) Renderable, but not telling which one. It allows SwiftUI to return complex view hierarchies without exposing their types (can be messy). It avoids runtime overhead while keeping type safety and performance.
struct ContainerView: Renderable {
    var body: some Renderable {
        Text(content: "Hello from inside!")
    }

    func render() -> String {
        "Container(\(body.render()))"
    }
}

/**
 Work with opaque return type.
 */
func usingSomePartI() {
    introduce(topic: "'Some' Part I")
    
    print(" 1| render widget: \(makeWidget().render())")
    
    let view = ContainerView()
    print(" 2| render view: \(view.render())")
}

/*
 Work in progress. The upper example 'Renderable' has no associated type - that makes things easier. So we do the same for a protocoll with associated type.
 */

/// simple Parser, parse anything from string to 'Output'-type
protocol Parser {
    associatedtype Output
    func parse(_ input: String) -> Output
}

/// parse Ints
struct IntParser: Parser {
    func parse(_ input: String) -> Int { return Int(input) ?? 0 }
}

/// parse booleans
struct BoolParser: Parser {
    func parse(_ input: String) -> Bool { return input.lowercased() == "true" }
}


// func readDBFieldAndParse(with parser: Parser) { }   // associated type is missing

func readDBFieldAndParse(with parser: any Parser) {
    // field is of 'type' 'Any', but it is a wrapper, not a runtime type
    let field = parser.parse("123")
    print(" 1| parser: \(field), \(type(of: field))")
}

func usingSomePartII() {
    introduce(topic: "'Some' Part II")
    
    readDBFieldAndParse(with: IntParser())
    // ...
}


//----------------------


usingGenerics()
usingSomePartI()
usingSomePartII()


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
