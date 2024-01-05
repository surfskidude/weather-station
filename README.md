# Xedge32 Weather Station App

The Xedge32 ESP32 Weather Station App is a Lua-based application designed to collect and manage weather data using a BME280 sensor. It interfaces with the sensor via I2C to collect temperature, humidity, and pressure data, storing this information in a local time series database.

![Weather Station](doc/weatherstation.jpg "Weather Station")

## Features

* BME280 Sensor Integration: Collects weather data like temperature, humidity, and pressure.
* Time Series Database: Manages and stores weather data over time.
* Regular Data Collection: A timer function that collects data every two seconds with intelligent data filtering.
* Email Notifications: Optionally sends updates and error messages via email.
* Error Handling: Handling for sensor and data processing issues.

## File Description

* `.preload`: Initializes the BME280 sensor and sets up the timer function for data collection.
* `.lua/tsdb.lua`: Manages the time series database, including data saving, reading, and removing old files.
* `getwd.lsp` : REST service used by index.html
* `index.html` : Example code for fetching TS data

## Setup

1. Sensor Setup: Connect the BME280 sensor to your ESP32 via the I2C interface.
2. Firmware: [Install Xedge32](https://realtimelogic.com/downloads/bas/ESP32/) on your ESP32.
3. SD Card configuration: See the first part of the tutorial [ESP32 WebDAV Server](https://realtimelogic.com/articles/ESP32-WebDAV-Server) for how to enable the SD card.
2. Upload Weather Station App: Upload the code in the src directory to a new directory, such as weatherstation, using the WebDAV plugin i.e. mount http://xedge32.local/rtl/apps/
3. Configuration: Modify the `.preload` file to match your I2C GPIO settings.
4. In the Xedge32 IDE, right-click the weatherstation directory and create an app. You must also LSP enable the app.

## Usage
* Data Collection: The app automatically collects data from the BME280 sensor and stores it in the time series database.
* Accessing Data: Access the collected data via the time series database for analysis and reporting.

## Dependencies
* ESP32 (preferably the new ESP32-S3) with SD card slot
* SD Card
* BME280 sensor
* Breadboard
* Jumper Wires

## Contributing

We welcome contributions! Please fork the repository and submit a pull request if you have suggestions or improvements. The code is currently missing the HTML UI, which should preferably be designed as a SPA.