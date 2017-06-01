import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()

routes.add(method: .get, uri: "/") { (request, response) in
    response.setBody(string: "Hello, Perfect!")
        .completed()
}

func returnJSONMessage(message: String, response: HTTPResponse) {
    do {
        try response.setBody(json: ["message": message])
          .setHeader(.contentType, value: "application/json")
          .completed()
    } catch {
        response.setBody(string: "Error handling request: \(error)")
          .completed()
    }
}

routes.add(method: .get, uri: "/hello") { (request, response) in
    returnJSONMessage(message: "Hello, JSON!", response: response)
}

routes.add(method: .get, uri: "/hello/there") { (request, response) in
    returnJSONMessage(message: "I am tired of saying hello!", response: response)
}

routes.add(method: .get, uri: "/beers/{num_beers}") { (request, response) in
    guard let numBeersString = request.urlVariables["num_beers"],
        let numBeersInt = Int(numBeersString) else {
            response.completed(status: .badRequest)
            return
    }
    returnJSONMessage(message: "Take one down, pass it around, \(numBeersInt - 1) bottles of beer on the wall...", response: response)
}

routes.add(method: .post, uri: "post") { (request, response) in
    guard let name = request.param(name: "name") else {
        response.completed(status: .badRequest)
        return
    }
    returnJSONMessage(message: "Hello, \(name)!", response: response)
}


server.addRoutes(routes)

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("抛出网络错误\(err) \(msg)")
}
