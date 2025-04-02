// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation


/* Work in progress... */


func workingWithNamedReturnTuples() {
    introduce(topic: "Named Tuples")
    
    // use case: combined return value, also named
    func f() -> (a: Int, b: Int) {          // local function
        return (a:1, b:2)
    }
    let g = f()
    print(" 1| g.a=\(g.a), g.b=\(g.b)")
    
    let (a,b): (Int,Int) = f()              // with types
    print(" 2| a=\(a), b=\(b)")
}


//----------------------


func workingWithRanges() {
    introduce(topic: "Ranges")
    
    // an open range
    let rg1 = 2..<5
    print(" 1| rg2=\(rg1), count: \(rg1.count)" +
          ", lowerBound: \(rg1.lowerBound), upperBound: \(rg1.upperBound)" +
          ", startIndex: \(rg1.startIndex), endIndex: \(rg1.endIndex)")
    
    print(" 2| entries:", terminator: "")
    for i in rg1 {
        print(" \(i)", terminator: "")
    }
    print()
    
    // partial range, there is also a ...10, but no count or upperBound
    let rg2 = 10...
    print(" 3| rg3=\(rg2), count: -" +
          ", lowerBound: \(rg2.lowerBound), upperBound: -" +
          ", startIndex: -, endIndex: -")
    
    print(" 4| entries:", terminator: "")
    for i in rg2 {
        print(" \(i)", terminator: "")
        if i==15 { break }
    }
}


//----------------------


/**
 Computed properties on top-level?
 
 Usually used in classes, but also works outside 'sometimes'. Setter is optional. If not given, property is read-only.
 
 See some use cases.
 */
func usingComputedProperties() {
    introduce(topic: "Computed Properties")
    
    // this is a getter
    var today: String {
        DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
    }
    print(" 1| today=\(today)")
    
    //    var today: String {
    //        get {
    //            DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
    //        }
    //    }
    //
    
    // just for the syntax; this just works in scripts outside of a struct or class;
    // see 'minutes' as some sort of a backing field, a place to store the value
    var minutes = 210
    var hours: Double {
        get { print(" a|   get hours"); return Double(minutes) / 60.0 }
        set { print(" b|   set hours, minutes old=\(minutes), new=\(newValue)"); minutes = Int(newValue * 60.0) }
    }
    print(" 2| minutes=\(minutes), hours=\(hours)")
    hours = 2.5
    print(" 3| minutes=\(minutes), hours=\(hours)")
}


//----------------------


/**
 Functions that accept zero or more values of a certain type — aka, a non-fixed number of arguments.
 */
func usingVariadicParameters() {
    introduce(topic: "Variadic Parameters")
    
    // Type... (variadic parameters)
    func arithmeticMean(_ numbers: Double...) -> Double {
        var total = 0.0
        for number in numbers {
            total += number
        }
        return total / Double(numbers.count)
    }

    let mean = arithmeticMean(1, 2, 3, 4, 5)
    print(" 1| mean=\(mean)")
}


//----------------------


workingWithNamedReturnTuples()
workingWithRanges()
usingComputedProperties()
usingVariadicParameters()


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
