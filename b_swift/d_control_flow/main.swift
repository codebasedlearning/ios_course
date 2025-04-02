// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


/**
 Most of the flow-control commands are clear. Some of them we have already seen (if, if let, else, for), so only a few examples here.
 
 Excluded
  - switch with multiple values / tuples
  - labeled statements
 */
func controllingFlow(temperature: Int, someInt: Int?) {
    introduce(topic: "Controlling Flow")
    
    guard temperature > 0 else {            // use it as a precondition
        print(" 1| guard, wrong temperature: \(temperature)")
        return
    }
    guard let n = someInt else {            // or with optional binding
        print(" 2| guard, missing value")
        return
    }
    print(" 3| temperature=\(temperature), n=\(n)")
    
    let condition1 = if temperature < 10 {  // 'if' as an expression
        "cold"
    } else if temperature < 30 {
        "ok"
    } else {
        "hot"
    }
    print(" 4| condition1=\(condition1)")
    
    let condition2 = switch temperature {   // 'switch' as an expression
    case 1..<10:
        "cold"
    case 10..<30:
        "ok"
    default:
        "hot"
    }
    print(" 5| condition2=\(condition2)")

    print("---")

    print(" 6| countdown:", terminator: "")
    var counter = 3
    while counter > 0 {
        print(" \(counter)", terminator: "")
        counter -= 1
    }
    print()
    
    print(" 7| countdown:", terminator: "")
    counter = 3
    repeat {
        print(" \(counter)", terminator: "")
        counter -= 1
    } while counter > 0
    print()
    
    print("---")

    /// a simple enum with errors (inheriting from Error)
    enum MyError: Error {
        case simpleError
        case complexError(String)
    }

    /// simple function throwing en error, must be marked with 'throws'
    func canThrowAnError(shouldThrow: Bool) throws {
        if shouldThrow {
            print(" a|   throw error in canThrowAnError")
            // throw MyError.simpleError
            throw MyError.complexError("errors are complex...")
        }
        print(" b|   no error in canThrowAnError")
    }

    do {
        try canThrowAnError(shouldThrow: true)
    } catch MyError.simpleError {
        print(" 8| caught simpleError")
    } catch MyError.complexError(let message) {
        print(" 9| caught complexError: '\(message)'")
    } catch {
        print("10| caught")
    }
}


//----------------------


controllingFlow(temperature: 12, someInt: 23)


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
