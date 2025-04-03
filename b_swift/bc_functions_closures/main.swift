// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


/**
 Parameters not only have a name but also a 'label'. This greatly improves readability. Choose your naming so that calling a function with arguments reads like a command or a statement.
 
 '_' usually stands for: 'not used' (discard). When used as a label, you can call the function without, e.g. sin(3.14).
 */
func callingFunctions() {
    introduce(topic: "Functions")
 
    // local functions
    func twice1(number: Int) -> Int {       //  argument label same as parameter name
        return number+number
    }

    func twice2(of number: Int) -> Int {    //  argument label 'of', parameter name 'number'
        return number+number
    }

    func twice3(_ number: Int) -> Int {     // no argument label
        return number+number
    }

    let n = 23
    let n1 = twice1(number: n)              // 'number' is mandatory
    let n2 = twice2(of: n)                  // 'of' is mandatory
    let n3 = twice3(n)                      // without label (technically you can use '_')
    print(" 1| n=\(n), n1=\(n1), n2=\(n2), n3=\(n3)")
    
    // this way params are optional
    func createInt(fromText s: String? = nil,
                   fromNumber d: Double? = nil,
                   withDefault defValue: Int = -1) -> Int {
        
        if let stringValue = s, let intValue = Int(stringValue) {
            return intValue
        } else if let doubleValue = d {
            return Int(doubleValue)
        }
        return defValue
    }
    
    // cmp that to twice
    let m1 = createInt(fromText: "12")
    let m2 = createInt(fromNumber: 3.14)
    let m3 = createInt(fromText: "12a", withDefault: 42)
    print(" 2| m1=\(m1), m2=\(m2), m3=\(m3)")
}


//----------------------


/**
 Working with functions as entities.
 
 Using closures (lambdas), also as last parameter, aka trailing closure/lambda.
 
 Swift says
  - Global functions are closures that have a name and don’t capture any values.
  - Nested functions are closures that have a name and can capture values from their enclosing function.
  - Closure expressions are unnamed closures written in a lightweight syntax that can capture values from their surrounding context.
 
 Excluded
  - in-out params
  - capture self in classes
  - lazy evaluation, @autoclosure
 */
func workingWithClosures() {
    introduce(topic: "Closures")
    
    let names = ["Cam", "Ari", "Eve", "Ben", "Dan"]             // array
    print(" 1| names=\(names)")
    
    func backwards(_ s1: String, _ s2: String) -> Bool { return s1 > s2 }
    
    let reversedNames1 = names.sorted(by: backwards)            // pro/con?
    print(" 2| sort with function:       \(reversedNames1)")
    
    let reversedNames2 = names.sorted(by: { (s1: String, s2: String) -> Bool in return s1 > s2 })
    print(" 3| sort with closure:        \(reversedNames2)")
    
    let reversedNames3 = names.sorted(by: { s1, s2 in s1 > s2 })// infering types from context
    print(" 4| sort with short closure:  \(reversedNames3)")

    let reversedNames4 = names.sorted { s1, s2 in s1 > s2 }     // trailing/outside ()
    print(" 5| sort trailing closure:    \(reversedNames4)")

    let reversedNames5 = names.sorted { $0 > $1 }               // with shorthand argument names
    print(" 6| sort with shorthand names:\(reversedNames5)")
    
    print("---")

    func myApply(_ a: Int, _ b: Int, _ ops: (Int, Int) -> Int) -> Int { return ops(a, b) }
    func myAdd(_ a: Int, _ b: Int) -> Int { return a + b }

    let myOps = myAdd                                           // type: (Int, Int) -> Int
    print(" 7| type myOps:\(type(of: myOps)), 2+3=\(myOps(2,3))")

    let a=2, b=3
    
    let res1 = myApply(a,b,myOps)                               // a function as argument
    let res2 = myApply(a,b,{op1,op2 in op1+op2})                // a lambda or closure
    let res3 = myApply(a,b) {op1,op2 in op1+op2}                // trailing
    let res4 = myApply(a,b) { $0+$1 }                           // trailing, shorthand arguments
    print(" 8| res1=\(res1), res2=\(res2), res3=\(res3), res4=\(res4)")

    print("---")
    
    // remaining args can still be given by func(a,b) { lambda }
    func loadPicture(from server: String,
                     onCompletion: (String) -> Void,
                     onFailure: () -> Void) {
        //        if let picture = download("photo.jpg", from: server) {
        //            onCompletion(picture)
        //        } else {
        //            onFailure()
        //        }
    }
    
    // multiple closures
    loadPicture(from: "www.adobe.com") { picture in
        // ...
    } onFailure: {
        // ...
    }
}


//----------------------


callingFunctions()
workingWithClosures()


//----------------------


/// print helper function
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
