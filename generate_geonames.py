import os
import sqlite3
import urllib.request
import zipfile

def download_and_build_db():
    data_dir = "assets/data"
    os.makedirs(data_dir, exist_ok=True)
    db_path = os.path.join(data_dir, "geonames.db")
    
    if os.path.exists(db_path):
        print(f"{db_path} already exists. Deleting it to rebuild.")
        os.remove(db_path)
    
    zip_url = "http://download.geonames.org/export/dump/cities1000.zip"
    zip_path = "cities1000.zip"
    txt_path = "cities1000.txt"
    
    print(f"Downloading {zip_url}...")
    urllib.request.urlretrieve(zip_url, zip_path)
    
    print("Extracting...")
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall()
        
    print("Building SQLite database...")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    cursor.execute('''
    CREATE TABLE cities (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      ascii_name TEXT NOT NULL,
      country_code TEXT NOT NULL,
      country_name TEXT NOT NULL,
      latitude REAL NOT NULL,
      longitude REAL NOT NULL,
      timezone_id TEXT NOT NULL,
      alternate_names TEXT,
      population INTEGER DEFAULT 0
    )
    ''')
    
    # Country code to name mapping (simplified)
    # A robust app would use the countryInfo.txt, but for simplicity we'll map common ones or just use the code
    
    count = 0
    with open(txt_path, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.split('\t')
            if len(parts) > 17:
                geonameid = int(parts[0])
                name = parts[1]
                ascii_name = parts[2]
                alternate_names = parts[3]
                latitude = float(parts[4])
                longitude = float(parts[5])
                country_code = parts[8]
                population = int(parts[14]) if parts[14] else 0
                timezone = parts[17]
                
                cursor.execute('''
                INSERT INTO cities (id, name, ascii_name, country_code, country_name, latitude, longitude, timezone_id, alternate_names, population)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (geonameid, name, ascii_name, country_code, country_code, latitude, longitude, timezone, alternate_names, population))
                count += 1
                
    cursor.execute('CREATE INDEX idx_cities_name ON cities(ascii_name COLLATE NOCASE)')
    cursor.execute('CREATE INDEX idx_cities_country ON cities(country_code)')
    
    conn.commit()
    conn.close()
    
    # Cleanup
    os.remove(zip_path)
    os.remove(txt_path)
    
    print(f"Successfully inserted {count} cities into {db_path}")

if __name__ == "__main__":
    download_and_build_db()
