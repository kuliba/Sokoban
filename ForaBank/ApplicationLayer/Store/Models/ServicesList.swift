import Mapper

class Operations {
 
    
    var name: String?
    var details: Details?
    var code: String?
    var operators: Operators?
    var value: String?
    var codeOperators: String?
    var nameOperators:String?
    var nameList: String?
    init(name: String? = nil, details:[Details], code: String? = nil, value: String? = nil, codeOperators: String? = nil, nameOperators: String? = nil, nameList: String? = nil ) {
        self.name = name
        self.value = value
        self.code = code
        self.codeOperators = codeOperators
        self.nameOperators = nameOperators
        self.nameList = nameList
        
        
    }
}

struct Details {
    
    let code: String?
    init(code: String? = "1") {
        self.code = code
        }

    }

    struct Operators {
    var code: String?
        var codeOperators: String?
        init(code: String? = nil, codeOperators: String? = nil) {
        self.code = code
            self.codeOperators = codeOperators
            
        
    }
    struct nameList {
        var value: String?
        init(value: String? = nil) {
            self.value = value
          }
        }
    
    }



