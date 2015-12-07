#!/usr/bin/env xcrun swift

import Foundation

/*  output filetypes  */
enum FileType {
    case tweet
    case newsletter
}

/*  I/O file names  */
enum FileName: String {
    case input = "newLibs.txt"
    case tweets = "tweets.txt"
    case newsletter = "newsletter.txt"
}

struct Library {
    enum Category: String {
        case database = "Database"
        case networking = "Networking"
        case xmljson = "XML/JSON"
        case security = "Security"
        case animation = "Animation"
        case image = "Image"
        case uiux = "UI/UX"
        case charts = "Charts"
        case autolayout = "Autolayout"
        case permissions = "Permissions"
        case audio = "Audio"
        case math = "Math"
        case logging = "Logging"
        case colors = "Colors"
        case cache = "Cache"
        case opensourceapps = "Open source apps"
        
        static let allValues = [database, networking, xmljson, security, animation, image, uiux, charts, autolayout, permissions, audio, math, logging, colors, cache, opensourceapps]
    }
    let title: String
    let descriptionForNewsletter: String
    let descriptionForTweet: String
    let link: String
    var category: Category?
    let categoryLink: String
    
}

var libraries = Array<Library>()
var html = Array<String>()

/*  Regex helper method  */
func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func parseFile() -> Array<Library> {
    
    var libs = [String]()
    
    if let content = try? String(contentsOfFile: FileName.input.rawValue, usedEncoding: nil) {
        libs = content.componentsSeparatedByString("\n")
    }
    
    let linesCount = libs.count
    let libsCount = linesCount/4
    
    var titleStepper = 1
    var categoryStepper = 2
    var descriptionStepper = 3
    var linkStepper = 4
    
    for _ in 1...libsCount {
        let line1 = libs[titleStepper-1]
        let line2 = libs[categoryStepper-1]
        let line3 = libs[descriptionStepper-1]
        let line4 = libs[linkStepper-1]
        
        titleStepper = titleStepper+4
        categoryStepper = categoryStepper+4
        descriptionStepper = descriptionStepper+4
        linkStepper = linkStepper+4
        
        let titleRange = line1.startIndex.advancedBy(12)..<line1.endIndex.advancedBy(-1)
        let title = line1[titleRange]
        
        let categoryRange = line2.startIndex.advancedBy(14)..<line2.endIndex
        let category = line2[categoryRange]
        
        let descriptionRange = line3.startIndex.advancedBy(18)..<line3.endIndex.advancedBy(-1)
        let description = line3[descriptionRange]
        var descriptionForNewsletter = ""
        var descriptionForTweet = ""
        var linkTitle = ""
        var linkHref = ""
        
        // getting rid of [] and (link) in description with regex
        let matches = matchesForRegexInText("\\[(.*?)\\]\\(", text: description)
        if !matches.isEmpty {
            let linkTitleRange = matches[0].startIndex.advancedBy(1)..<matches[0].endIndex.advancedBy(-2)
            linkTitle = matches[0][linkTitleRange]
            
            let hrefMatches = matchesForRegexInText("\\]\\((.*?)\\)", text: description)
            if !hrefMatches.isEmpty {
                let linkHrefRange = hrefMatches[0].startIndex.advancedBy(2)..<hrefMatches[0].endIndex.advancedBy(-1)
                linkHref = hrefMatches[0][linkHrefRange]
                
                descriptionForNewsletter = description.stringByReplacingOccurrencesOfString("[\(linkTitle)]", withString: "<a href=\"\(linkHref)\" target=\"_blank\">\(linkTitle)</a>")
                descriptionForNewsletter = descriptionForNewsletter.stringByReplacingOccurrencesOfString("(\(linkHref))", withString: "")
                
                descriptionForTweet = description.stringByReplacingOccurrencesOfString("[\(linkTitle)]", withString: "\(linkTitle)")
                descriptionForTweet = descriptionForTweet.stringByReplacingOccurrencesOfString("(\(linkHref))", withString: "")
            }
        }
        else {
            descriptionForNewsletter = description
            descriptionForTweet = description
        }
        
        let linkRange = line4.startIndex.advancedBy(10)..<line4.endIndex
        let link = line4[linkRange]
        
        var library = Library(title: title, descriptionForNewsletter: descriptionForNewsletter, descriptionForTweet: descriptionForTweet, link: link, category: nil, categoryLink: category)
        
        // get nice category string
        switch category {
        case "database":
            library.category = .database
        case "networking":
            library.category = .networking
        case "xml-json":
            library.category = .xmljson
        case "security":
            library.category = .security
        case "animation":
            library.category = .animation
        case "image":
            library.category = .image
        case "ui-ux":
            library.category = .uiux
        case "charts":
            library.category = .charts
        case "autolayout":
            library.category = .autolayout
        case "permissions":
            library.category = .permissions
        case "audio":
            library.category = .audio
        case "math":
            library.category = .math
        case "logging":
            library.category = .logging
        case "colors":
            library.category = .colors
        case "cache":
            library.category = .cache
        case "open-source-apps":
            library.category = .opensourceapps
        default:
            library.category = nil
        }
        
        libraries.append(library)
    }
    
    return libraries
}

/* write output to file based on file type   */
func writeToFile(fileType: FileType, string: String) {
    
    switch fileType {
    case .newsletter:
        do {
            try string.writeToFile(FileName.newsletter.rawValue, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch let error as NSError {
            print("\(error)")
        }
    case .tweet:
        do {
            try string.writeToFile(FileName.tweets.rawValue, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch let error as NSError {
            print("\(error)")
        }
    }
}

libraries = parseFile()


func getNewsletter() {
    for category in Library.Category.allValues{
        
        var categoryLibsCounter = 0
        var libsHtml = Array<String>()
        var categoryLink = ""
        
        // how many libraries for each category?
        for lib in libraries {
            if lib.category == category {
                categoryLibsCounter++
                libsHtml.append("<p><a href=\"\(lib.link)\" target=\"_blank\">\(lib.title)</a>&nbsp;-&nbsp;\(lib.descriptionForNewsletter)</p>")
                categoryLink = lib.categoryLink
            }
        }
        // HTML for each category
        if categoryLibsCounter > 0 {
            html.append("<br />")
            html.append("<h2 class=\"null\" style=\"text-align: center;\">")
            if category == .cache {
                html.append("<strong><span style=\"font-size:20px\"><a href=\"http://www.ioscookies.com/ccache/\"><span style=\"color:#30d1b5\">\(category.rawValue)</span></a></span></strong>")
            }
            else {
                html.append("<strong><span style=\"font-size:20px\"><a href=\"http://www.ioscookies.com/\(categoryLink)/\"><span style=\"color:#30d1b5\">\(category.rawValue)</span></a></span></strong>")
            }
            html.append("</h2>")
            html.appendContentsOf(libsHtml)
        }
    }
    
    writeToFile(.newsletter, string: html.joinWithSeparator("\n"))
}


func libIntoTweet(library: Library) -> String {
    guard let category = library.category?.rawValue
    else {
        return ""
    }
    return "New library in \(category) category: \(library.title) - \(library.descriptionForTweet)\n\(library.link)"
}

func getTweets() {
    writeToFile(.tweet, string: libraries.map(libIntoTweet).joinWithSeparator("\n"))
}


func run() throws {
    
    getTweets()
    getNewsletter()
}


func main() {
    do {
        try run()
    } catch let error as NSError {
        print(error.localizedDescription)
    }
}

main()
