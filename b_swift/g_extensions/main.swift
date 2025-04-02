// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


/// struct holds a temperature (see snippet before)
struct Celsius: CustomStringConvertible {
    var temperatureInCelsius: Double = 0.0
    
    init(fromKelvin kelvin: Double) {
        temperatureInCelsius = kelvin - 273.15
    }

    var description: String {
        return "\(temperatureInCelsius)C"
    }
}

/// new functionality
extension Celsius {
    func asFahrenheit() -> Double { self.temperatureInCelsius * 1.8 + 32.0 }
    var asKelvin: Double { get { return self.temperatureInCelsius + 273.15 } }
}

/// new functionality
extension Double {
    var km: Double { return self * 1_000.0 }
    var m: Double { return self }
}

/// something with a name that can greet
protocol Greetable {
    var name: String { get }
    func greet()
}

/// implement default behaviour
extension Greetable {
    func greet() {
        print(" a|   Hello, my name is \(name).")
    }
}

// Person uses it
struct Person: Greetable {
    var name: String
}

/**
 Extensions add new functionality to an existing class, structure, enumeration, or protocol type.
 Extensions can’t override existing functionality.
 
 Use extensions for protocols to add default behavior, you cannot define in the definition.
 */
func usingExtensions() {
    introduce(topic: "Extensions")
    
    let freezingC = Celsius(fromKelvin: 273.15)
    let freezingK = freezingC.asKelvin
    print(" 1| freezingC=\(freezingC), freezingK=\(freezingK)")
    
    let aMarathon = 42.km + 195.m
    print(" 2| marathon length: \(aMarathon)m")
    
    let alice = Person(name: "Alice")
    alice.greet()
}


//----------------------


usingExtensions()


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
