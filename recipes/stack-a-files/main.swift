import Cocoa
import WebKit

class AppSchemeHandler: NSObject, WKURLSchemeHandler {
  func webView(_ webView: WKWebView, start task: WKURLSchemeTask) {
    guard let url = task.request.url,
          let resources = Bundle.main.resourceURL else { return }
    let name = url.path.isEmpty || url.path == "/" ? "index.html"
             : String(url.path.dropFirst())
    let fileURL = resources.appendingPathComponent(name)
    guard let data = try? Data(contentsOf: fileURL) else {
      task.didFailWithError(URLError(.fileDoesNotExist))
      return
    }
    let mime = ["html":"text/html", "js":"text/javascript",
                "m4a":"audio/mp4", "css":"text/css"][fileURL.pathExtension] ?? "application/octet-stream"
    let resp = URLResponse(url: url, mimeType: mime,
                           expectedContentLength: data.count, textEncodingName: "utf-8")
    task.didReceive(resp)
    task.didReceive(data)
    task.didFinish()
  }

  func webView(_ webView: WKWebView, stop task: WKURLSchemeTask) {}
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    let rect = NSRect(x: 0, y: 0, width: 1120, height: 860)
    let window = NSWindow(contentRect: rect,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: false)
    window.title = "Compás Flamenco — DS"
    window.minSize = NSSize(width: 700, height: 600)
    window.setFrameAutosaveName("main")

    let config = WKWebViewConfiguration()
    config.mediaTypesRequiringUserActionForPlayback = []
    config.setURLSchemeHandler(AppSchemeHandler(), forURLScheme: "app")

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.load(URLRequest(url: URL(string: "app://main/index.html")!))

    window.contentView = webView
    window.makeKeyAndOrderFront(nil)

    // main menu so Cmd+Q/Cmd+W/copy/paste work
    let mainMenu = NSMenu()
    let appMenu = NSMenu()
    appMenu.addItem(NSMenuItem(title: "Quit FlamencoCompas-DS",
                               action: #selector(NSApplication.terminate(_:)),
                               keyEquivalent: "q"))
    let appItem = NSMenuItem()
    appItem.submenu = appMenu
    mainMenu.addItem(appItem)

    let editMenu = NSMenu(title: "Edit")
    editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
    editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
    editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
    let editItem = NSMenuItem()
    editItem.submenu = editMenu
    mainMenu.addItem(editItem)

    let windowMenu = NSMenu(title: "Window")
    windowMenu.addItem(NSMenuItem(title: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w"))
    let windowItem = NSMenuItem()
    windowItem.submenu = windowMenu
    mainMenu.addItem(windowItem)

    NSApplication.shared.mainMenu = mainMenu
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
