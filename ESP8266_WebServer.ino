/*
 * MeraGhar - ESP8266 Web Server for Smart Home Control
 * 
 * This code creates a web server on ESP8266 that controls a servo motor
 * The servo moves to 90° when turned ON and returns to 0° when turned OFF
 * 
 * Hardware Connections:
 * - Servo Signal Pin -> GPIO2 (labeled as D4 on NodeMCU board)
 * - Servo VCC -> 5V (or 3.3V depending on your servo)
 * - Servo GND -> GND
 * 
 * Author: Created for MeraGhar Smart Home App
 * Date: October 5, 2025
 */

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <Servo.h>

// ========== WiFi Configuration ==========
// Replace with your WiFi credentials
const char* ssid = "Sujeet's MacBook Pro";        // Change this to your WiFi name
const char* password = "12345678"; // Change this to your WiFi password

// ========== Hardware Configuration ==========
#define SERVO_PIN 2  // GPIO2 (D4 on NodeMCU) - Connect servo signal wire here
Servo myServo;       // Create servo object

// ========== Server Configuration ==========
ESP8266WebServer server(80);  // Create web server on port 80

// ========== Device State ==========
bool deviceState = false;  // false = OFF (0°), true = ON (90°)

// ========== Setup Function ==========
void setup() {
  // Initialize Serial Monitor for debugging
  Serial.begin(115200);
  delay(100);
  Serial.println("\n\n=================================");
  Serial.println("MeraGhar Smart Home System");
  Serial.println("=================================\n");
  
  // Initialize Servo
  myServo.attach(SERVO_PIN);
  myServo.write(0);  // Start at 0° (OFF position)
  Serial.println("✓ Servo initialized at 0°");
  
  // Connect to WiFi
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  
  // Wait for connection with visual feedback
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✓ WiFi Connected!");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
    Serial.print("MAC Address: ");
    Serial.println(WiFi.macAddress());
    Serial.println("\n=================================");
    Serial.println("Server is ready!");
    Serial.println("=================================\n");
  } else {
    Serial.println("\n✗ WiFi Connection Failed!");
    Serial.println("Please check your credentials and restart.");
  }
  
  // Define server routes
  server.on("/", handleRoot);           // Root page
  server.on("/status", handleStatus);   // Get device status
  server.on("/on", handleOn);           // Turn device ON
  server.on("/off", handleOff);         // Turn device OFF
  server.on("/toggle", handleToggle);   // Toggle device state
  server.onNotFound(handleNotFound);    // 404 handler
  
  // Start the server
  server.begin();
  Serial.println("HTTP server started");
  Serial.println("Available endpoints:");
  Serial.println("  GET /         - Home page");
  Serial.println("  GET /status   - Get device status");
  Serial.println("  GET /on       - Turn servo to 90° (ON)");
  Serial.println("  GET /off      - Turn servo to 0° (OFF)");
  Serial.println("  GET /toggle   - Toggle servo position");
  Serial.println("\n");
}

// ========== Main Loop ==========
void loop() {
  server.handleClient();  // Handle incoming client requests
}

// ========== Web Server Handlers ==========

// Root page - Simple web interface
void handleRoot() {
  String html = "<!DOCTYPE html><html><head>";
  html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
  html += "<style>";
  html += "body { font-family: Arial; text-align: center; background: #000; color: #fff; padding: 50px; }";
  html += "h1 { font-weight: 100; letter-spacing: 4px; }";
  html += "button { background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.3); ";
  html += "color: white; padding: 20px 40px; font-size: 18px; margin: 10px; cursor: pointer; ";
  html += "border-radius: 12px; transition: 0.3s; }";
  html += "button:hover { background: rgba(255,255,255,0.2); }";
  html += ".status { font-size: 24px; margin: 30px; padding: 20px; ";
  html += "background: rgba(255,255,255,0.05); border-radius: 12px; }";
  html += "</style></head><body>";
  html += "<h1>MERAGHAR</h1>";
  html += "<p style='letter-spacing: 2px; opacity: 0.6;'>Smart Home Control</p>";
  html += "<div class='status'>Status: <strong>" + String(deviceState ? "ON (90°)" : "OFF (0°)") + "</strong></div>";
  html += "<button onclick=\"location.href='/on'\">TURN ON</button>";
  html += "<button onclick=\"location.href='/off'\">TURN OFF</button>";
  html += "<button onclick=\"location.href='/toggle'\">TOGGLE</button>";
  html += "<p style='margin-top: 50px; opacity: 0.4; font-size: 12px;'>IP: " + WiFi.localIP().toString() + "</p>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
  Serial.println("→ Root page accessed");
}

// Get current status (JSON response for iOS app)
void handleStatus() {
  String json = "{";
  json += "\"status\":\"" + String(deviceState ? "on" : "off") + "\",";
  json += "\"angle\":" + String(deviceState ? 90 : 0) + ",";
  json += "\"device\":\"servo\",";
  json += "\"ip\":\"" + WiFi.localIP().toString() + "\"";
  json += "}";
  
  server.send(200, "application/json", json);
  Serial.println("→ Status requested: " + String(deviceState ? "ON" : "OFF"));
}

// Turn servo ON (move to 90°)
void handleOn() {
  deviceState = true;
  myServo.write(90);  // Move servo to 90°
  
  Serial.println("✓ Device turned ON - Servo at 90°");
  
  String json = "{\"status\":\"on\",\"angle\":90,\"message\":\"Device turned ON\"}";
  server.send(200, "application/json", json);
}

// Turn servo OFF (move to 0°)
void handleOff() {
  deviceState = false;
  myServo.write(0);  // Move servo to 0°
  
  Serial.println("✓ Device turned OFF - Servo at 0°");
  
  String json = "{\"status\":\"off\",\"angle\":0,\"message\":\"Device turned OFF\"}";
  server.send(200, "application/json", json);
}

// Toggle servo position
void handleToggle() {
  deviceState = !deviceState;
  int angle = deviceState ? 90 : 0;
  myServo.write(angle);
  
  Serial.println("✓ Device toggled - Servo at " + String(angle) + "°");
  
  String json = "{\"status\":\"" + String(deviceState ? "on" : "off") + "\",";
  json += "\"angle\":" + String(angle) + ",";
  json += "\"message\":\"Device toggled\"}";
  server.send(200, "application/json", json);
}

// Handle 404 errors
void handleNotFound() {
  String message = "{\"error\":\"Endpoint not found\",\"code\":404}";
  server.send(404, "application/json", message);
  Serial.println("✗ 404 - Invalid endpoint accessed");
}

/*
 * ========================================
 * HOW TO USE THIS CODE:
 * ========================================
 * 
 * 1. INSTALL REQUIRED LIBRARIES:
 *    - Open Arduino IDE
 *    - Go to: Sketch → Include Library → Manage Libraries
 *    - Search and install: "ESP8266" board package
 *    - The Servo library is built-in
 * 
 * 2. CONFIGURE WIFI:
 *    - Change "YOUR_WIFI_NAME" to your WiFi network name
 *    - Change "YOUR_WIFI_PASSWORD" to your WiFi password
 * 
 * 3. HARDWARE SETUP:
 *    - Connect servo signal wire to GPIO2 (D4 on NodeMCU)
 *    - Connect servo VCC to 5V or 3.3V (use external power for better performance)
 *    - Connect servo GND to GND (common ground with ESP)
 * 
 * 4. UPLOAD CODE:
 *    - Select board: Tools → Board → ESP8266 Boards → NodeMCU 1.0
 *    - Select correct COM port
 *    - Click Upload
 * 
 * 5. GET IP ADDRESS:
 *    - Open Serial Monitor (115200 baud)
 *    - Note the IP address displayed
 *    - Enter this IP in your iOS app settings
 * 
 * 6. TEST THE SERVER:
 *    - Open browser and go to: http://YOUR_ESP_IP/
 *    - Try the buttons to test servo movement
 * 
 * 7. CONNECT iOS APP:
 *    - Open MeraGhar app
 *    - Go to Settings
 *    - Enter the ESP IP address
 *    - Test connection
 *    - Control your servo from the app!
 * 
 * ========================================
 * API ENDPOINTS FOR iOS APP:
 * ========================================
 * 
 * GET http://YOUR_ESP_IP/status
 *   → Returns: {"status":"on/off","angle":0/90,"device":"servo","ip":"..."}
 * 
 * GET http://YOUR_ESP_IP/on
 *   → Turns servo to 90° (ON)
 *   → Returns: {"status":"on","angle":90,"message":"Device turned ON"}
 * 
 * GET http://YOUR_ESP_IP/off
 *   → Turns servo to 0° (OFF)
 *   → Returns: {"status":"off","angle":0,"message":"Device turned OFF"}
 * 
 * GET http://YOUR_ESP_IP/toggle
 *   → Toggles servo between 0° and 90°
 *   → Returns: {"status":"on/off","angle":0/90,"message":"Device toggled"}
 * 
 * ========================================
 * TROUBLESHOOTING:
 * ========================================
 * 
 * Problem: WiFi won't connect
 * Solution: Check WiFi credentials, ensure 2.4GHz network (ESP8266 doesn't support 5GHz)
 * 
 * Problem: Servo not moving
 * Solution: Check connections, ensure servo has proper power supply
 * 
 * Problem: Can't access from iOS app
 * Solution: Ensure phone and ESP are on same WiFi network, check IP address
 * 
 * Problem: Servo jitters
 * Solution: Add external power supply for servo (don't power from ESP pin)
 * 
 * ========================================
 */
