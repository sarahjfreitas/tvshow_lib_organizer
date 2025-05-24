# Lib Organizer

Automatic TV series organizer for Kodi libraries, using TMDB metadata.

## Description
This project automates the processing of TV series video files, downloading metadata and images from TMDB, and organizing them into a structure compatible with Kodi.

## Requirements
- Ruby 3.2+
- Bundler
- Docker (optional)

## Installation
1. Install Ruby dependencies:
   ```powershell
   bundle install
   ```
2. Set environment variables in a `.env` file:
   ```env
   TMDB_API_KEY=YOUR_TMDB_KEY
   INCOMING_PATH=/incoming
   LIBRARY_PATH=/library
   ```

## Usage
- To run locally:
  ```powershell
  ruby handle_incoming.rb
  ```
- Or using Docker Compose:
  ```powershell
  docker-compose up --build
  ```

## Structure
- `handle_incoming.rb`: Main organization script.
- `organizer.rb`: File organization and movement logic.
- `tmdb_client.rb`: TMDB API integration.
- `image_manager.rb`: Image management.
- `nfo_writer.rb`: NFO file writing.
- `exceptions.yml`: Special episode mapping exceptions. Change depending on your needs. 

## License
This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0) License.

You are free to share and adapt the material for any non-commercial purpose, as long as you give appropriate credit.  
See the full license at [https://creativecommons.org/licenses/by-nc/4.0/](https://creativecommons.org/licenses/by-nc/4.0/)