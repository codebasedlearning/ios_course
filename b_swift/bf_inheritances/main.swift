// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev


/// make some noise, no implementation
protocol Noiseable {
    func makeNoise()
}

/// loud vehicle, implementing Noiseable
class Vehicle: Noiseable {
    var currentSpeed = 0.0
    var doc: String { return "traveling at \(currentSpeed)" }
    
    func makeNoise() { }                    // for the protocol
}

/// loud train
class Train: Vehicle {
    override func makeNoise() { print(" a|   Choo Choo") }
}

/// loud car, with 'super' and 'override' for a stored property
class Car: Vehicle {
    var gear = 1
    override var doc: String { return super.doc + " in gear \(gear)" }
}

/// special car, 'didSet' added
class AutomaticCar: Car {
    override var currentSpeed: Double {
        didSet {
            print(" b|   didSet")
            gear = Int(currentSpeed / 10.0) + 1
        }
    }
}

/**
 A class can inherit methods, properties, and other characteristics from another class. When one class inherits from another, the inheriting class is known as a subclass, and the class it inherits from is known as its superclass. Inheritance is a fundamental behavior that differentiates classes from other types in Swift.
 
 Swift classes don’t inherit from a universal base class.
 
 Prevent a method, property, or subscript from being overridden by marking it as 'final'.
 
 Swift does not support multiple inheritance for classes, only multiple protocols (interfaces).
 
 Similarities                       Class   Struct
  - Can conform to protocols        Y       Y       sharing behavior
  - default protocol requirements   Y       Y       via protocol extensions
  - property observers (didSet,..)  Y       Y       if a var stored property
  - initializers                    Y       Y       classes with inheritance-based init rules
  - define methods, properties      Y       Y       nearly identical

 Differences in Inheritance         Class   Struct
  - Inheritance of implementation   Y       N       Structs can't inherit from other structs
  - override methods/properties     Y       N       Structs can't use override, don't have base types
  - super                           Y       N       No superclass in a struct
  - Supports polymorphism           Y       (Y)     Structs need protocol types for dynamic dispatch
  - Reference type (shared inst.)   Y       N
  - Value type (copy on assignment) N       Y
  - Deinitializers (deinit)         Y       N       Structs don't support deinit
  - Identity (===) comparison       Y       N       Structs donâ€™t have identity, only value equality
 */
func usingInheritance() {
    introduce(topic: "Inheritance")
    
    let vehicle = Vehicle()
    print(" 1| vehicle: \(vehicle.doc)")
    
    let train = Train()
    train.makeNoise()
    
    let car = Car()
    car.currentSpeed = 25.0
    car.gear = 3
    print(" 2| car: \(car.doc)")
    
    let automatic = AutomaticCar()
    automatic.currentSpeed = 35.0
    print(" 3| automatic: \(automatic.doc)")
}


//----------------------


usingInheritance()


//----------------------


/// print function intro
func introduce(topic: String) { print("\n\n\(topic)\n\(String(repeating: "=", count: topic.count))\n") }
