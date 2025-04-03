// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

// import the Foundation framework, which provides essential classes and functionalities that are not part of the core Swift language
import Foundation


//----------------------


/**
 Also a docstring (less common).

 Swift is strongly typed, i.e. the type of every variable is known at compile time and the compiler checks the types of variables and expressions to ensure they are used correctly.
 
 Type inference allows the compiler to deduce the type of a variable from the context, e.g. at initialization.
 
 'var' means 'mutable', i.e. non-const
  - You can reassign the variable.
  - You can mutate it if it’s a struct or class that allows mutation.
 
 'let' means const
  - You can’t reassign the variable.
  - For structs, it’s fully immutable.
  - For classes, the reference is fixed, but the object can still change.
  - Swift doesn’t do const fields like C++ — immutability depends on value vs reference types.

 Excluded
  - Float - similar to Double
 */
func declaringVariables() {
    introduce(topic: "Variables")
    
    var n = 23                              // variable of type Int, type inference from right side
    var m: Int = 24                         // type Int is explicitly given (type annotation)
    
    print(" 1| n=\(n), m=\(m), type:\(type(of:n))")

    n = 42                                  // 'var': n,m mutable
    m += 1
    print(" 2| n=\(n), m=\(m)")

    var k: Int                              // ok, but you cannot use it (missing initialization)
    // print(" 3| k=\(k)")
    k = 99
    print(" 3| k=\(k)")                     // now you can use it

    print("---")

    var s = "Hi"                            // type String
    s += "!!!"                              // mutable
    print(" 4| s='\(s)', count:\(s.count), type:\(type(of:s))")

    let ls = """
    multiline string
        second line
    third line
    """
    print(" 5| ls='\(ls)', type:\(type(of:ls))")

    print("---")

    let pi = 3.14                           // 'let': can only be initialized once (const)
    print(" 6| pi=\(pi), type:\(type(of:pi))")
    // pi = 42.5                            // does not work

    print("---")

    let b = true                            // type Bool, also 'false'
    print(" 7| b=\(b), type:\(type(of:b))")
    
    print("---")

    let a = [1,2,3]                          // an Array<Int> with literal
    print(" 8| b=\(a), type:\(type(of:a))")
    
    let abc:Set<Character> = ["a","b","c"]  // a Set<Character>, no literal
    print(" 9| b=\(abc), type:\(type(of:abc))")
    
    let digits = [1: "one", 2: "two"]       // a Dictionary<Int, String> with literal
    print("10| b=\(digits), type:\(type(of:digits))")
    
    print("---")

    let openRange = 1..<10                  // open range of ints from 1 to 10 (excl.)
    print("11| openRange=\(openRange), type:\(type(of:openRange))")
    let closedRange = 5...8                 // closed range of ints from 5 to 8 (incl.)
    print("12| closedRange=\(closedRange), type:\(type(of:closedRange))")
    
    print("---")
        
    let http404Error = (404, "Not Found")   // a tuple
    print("13| http404Error=\(http404Error)")
    print("14| .0=\(http404Error.0), .1=\(http404Error.1)")
    
    let (status, description) = http404Error // deconstruction
    print("15| status=\(status), description=\(description)")

    let http200Status = (statusCode: 200, description: "OK")
    print("16| statusCode=\(http200Status.statusCode), description=\(http200Status.description)")
}


//----------------------


/**
 Working with optional, nil-coalescing operators and optional binding.
 
 A problem in many programming languages that use references are those that are not initialised or point to nothing, aka Null, nullptr, nil, None, etc.
 
 Basically the idea is to distinguish between situations where a reference can be nil (null) and those where it cannot. And most importantly, not at runtime, but at compile time.
 So there are types that are always initialised and types that can be 'nil' in swift, called 'optionals' (the ? after the type). Compare this with Java, C# or Kotlin, for instance.
 */
func workingWithOptionals() {
    introduce(topic: "Optionals")

    let s42 = Int("42")                     // can be an int or nil (aka null,0)
    print(" 1| type s42:\(type(of:s42))")
    // print("    s42=\(s42)")              // this gives a warning printing an optional

    // optional, i.e. value or nil, but we need to work with...

    // nil-coalescing-operator '??', i.e. take value of variable (s42) if not nil, otherwise the value (-1)
    let n = s42 ?? -1                       // n is not optional anymore
    
    print(" 2| n=\(n), type:\(type(of:n)), s42:\(s42 ?? -1)")
    
    // declaring an optional with '?'
    var code: Int? = 404
    print(" 3| code:\(code ?? -1), type:\(type(of:code))")
    // [...]
    code = nil
    print(" 4| code:\(code ?? -1)")
    // [...]
    code = 23
    // 'if' with optional binding, inside 'rc' is not optional anymore
    if let rc = code {
        print(" 5| rc=\(rc)")
    }

    // using optionals with '.?'
    let s:String? = "Hi"
    print(" 6| s:'\(s ?? "-")', count:\(s?.count ?? -1), type:\(type(of:s))")

    // you can force unwrapping with '!'... be sure about that!
    print(" 7| s!:'\(s!)'")
    
    var a: Array<Int>? = nil
    print(" 8| a:\(a ?? []), count:\(a?.count ?? -1), type:\(type(of:a))")
    a = [1,2,3]
    print(" 9| a:\(a ?? [])")
}


//----------------------


/**
 Basic string ops.
 
 Multiline string literal includes all of the lines between its opening and closing quotation marks (without the lines with the quotation marks) and without the leading whitespace
 
 Note, that the index does not have to be a simple int. Because of character encoding, indexing a string is a bit tedious.
 The reason ist, that a string is not just a collection of bytes or Unicode scalars — it’s a collection of grapheme clusters, which can vary wildly in length and encoding.
 
 Excluded
  - string! type
 */

func workingWithStrings() {
    introduce(topic: "Strings")

    let text = "Hello, Swift World!"
    print(" 1| text='\(text)'")

    print(" 2| empty? \(text.isEmpty), count:\(text.count)")

    print(" 3| +:'\(text + "!!")'")

    print(" 4| prefix:'\(text.prefix(5))', suffix:'\(text.suffix(6))'")

    print(" 5| uppercased:'\(text.uppercased())', lowercased:'\(text.lowercased())'")
 
    let trimmed = ("  "+text+"  \n").trimmingCharacters(in: .whitespacesAndNewlines)
    print(" 6| trimmed: '\(trimmed)'")

    let answer = text.contains("Swift") ? "Yes" : "No"
    print(" 7| contains 'Swift'? \(answer)")

    // extended grapheme clusters, be careful with indices and lengths (see Café)
    let exclamationMark: Character = "!"
    let s1 = "HiHo" + String(exclamationMark)
    let s2 = "Cafe" + "\u{301}"
    print(" 8| s1='\(s1)', count:\(s1.count)," +
             " s2='\(s2)', count:\(s2.count)")

    print("---")

    // finds and returns the range of the first occurrence
    if let range = text.range(of: "Swift") {
        let replaced = text.replacingCharacters(in: range, with: "SwiftUI")
        print(" 9| replaced:'\(replaced)', range=\(range), type:\(type(of:range))")
    }
    
    // read it as a logical &&, so both must be non-nil
    if let startIndex = text.firstIndex(of: "S"), let endIndex = text.firstIndex(of: "t") {
        let range = startIndex...endIndex
        let substring = text[range]
        print("10| extracted:'\(substring)'")
    }
    
    if let startIndex = text.firstIndex(of: "S") {
        // let endIndex = text.index(startIndex, offsetBy: 5)  // if too big, we have a runtime crash
        let endIndex = text.index(startIndex, offsetBy: 5, limitedBy: text.endIndex) ?? text.endIndex
        let range = startIndex..<endIndex
        let substring = text[range]
        print("11| extracted:'\(substring)', chars:", terminator: "")
        for c in substring {
            print(" '\(c)'", terminator: "")
        }
        print()
    }

    print("---")

    let words = text.split(separator: " ")
    print("12| words:\(words), type:\(type(of:words))")

    print("---")

    // remember: a String.Index is only valid for the specific string it came from
    var mutableText = text

    if let index = mutableText.firstIndex(of: ",") {
        mutableText.insert(contentsOf: " wonderful", at: mutableText.index(after: index))
        print("13| inserted:'\(mutableText)'")
    }

    if let index = mutableText.firstIndex(of: "!") {
        mutableText.remove(at: index)
        print("14| removed:'\(mutableText)'")
    }
}


//----------------------


/**
 In general, you need to know the basic collection types, their most common operations, and their complexity.
 
 Arrays are similar to C++ vectors or Java ArrayList. They manage dynamic memory, can grow or shrink. The 'let' just makes it read-only, but under the hood it is such a structure.
 
 Same for sets. Remember, that an element only exists once.
 
 Finally, we have dictionaries as associated containers.
 
 Excluded
  - set functions: union, intersection, subtracting, symmetricDifference
 */
func workingWithCollections() {
    introduce(topic: "Collections")
    
    var numbers = [1, 2, 3, 4, 5]
    // var numbers = Array<Int>([1, 2, 3, 4, 5])    // long form
    print(" 1| numbers=\(numbers), count:\(numbers.count)")
    
    numbers.append(6)
    numbers.insert(0, at: 0)
    print(" 2| numbers=\(numbers)")
 
    numbers.removeLast()
    numbers.remove(at: 0)
    print(" 3| numbers=\(numbers)")
    
    let element = 3
    if let index = numbers.firstIndex(of: element) {
        print(" 4| index of \(element):\(index)")
    }

    print(" 5| numbers=[", terminator: "")
    for number in numbers {
        print(" \(number)", terminator: "")
    }
    print(" ]")

    print(" 6| numbers=[", terminator: "")
    for i in 0..<numbers.count {            // a range a..<b, or a...b
        print(" \(numbers[i])", terminator: "")
    }
    print(" ]")
    
    let fives = Array(repeating: 5, count: 3)
    print(" 7| fives=\(fives)")

    print("---")

    var primes: Set = [2, 3, 5, 7]
    print(" 8| primes=\(primes)")
    
    primes.insert(5)
    primes.insert(11)
    print(" 9| primes=\(primes)")

    primes.remove(2)
    print("10| primes=\(primes)")
    
    if primes.contains(element) {
        print("11| \(element) is (in) primes")
    }

    print("12| primes=[", terminator: "")
    for number in primes {
        print(" \(number)", terminator: "")
    }
    print(" ]")

    print("---")

    var codes = ["US": "United States", "FR": "France", "JP": "Japan"]
    print("13| codes=\(codes)")
    
    codes["GB"] = "United Kingdom"          // new element
    codes["US"] = "USA"                     // new value
    print("14| codes=\(codes)")
    
    codes["JP"] = nil
    print("15| codes=\(codes)")
    
    if let name = codes["FR"] {
        print("16| value of 'FR': \(name)")
    }

    print("17| codes=[", terminator: "")
    for (short, country) in codes {
        print(" '\(short)':'\(country)'", terminator: "")
    }
    print()

    print("18| codes.keys:\(codes.keys), type:\(type(of: codes.keys))") // can be converted to Array
    print("    codes.values:\(codes.values), type:\(type(of: codes.values))")
}


//----------------------


/**
 Sometimes we need to convert between different types. Here are some examples.
 */
func convertTypes() {
    introduce(topic: "Conversions")
    
    let n = Int("42") ?? -1                 // string to int
    let d = Double("3.14") ?? -1.0          // string to double
    let s = String(n)
    print(" 1| n=\(n), d=\(d), s='\(s)'")
    
    print("---")
    
    let chars: [Character] = Array("Hello")
    print(" 2| chars=\(chars)")
    
    let words = "one two  three".components(separatedBy: " ")
    print(" 3| words=\(words)")

    let parts = "one,,three".split(separator: ",")
    print(" 4| parts=\(parts)")

    let joined = ["apple", "banana"].joined(separator: ", ")
    print(" 5| joined=\(joined)")
}


//----------------------


declaringVariables()
workingWithOptionals()
workingWithStrings()
workingWithCollections()
convertTypes()


//----------------------


/// print helper function
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
