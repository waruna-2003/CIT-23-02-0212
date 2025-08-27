# CIT-23-02-0212

## Deployment Requirements
- Operating System: Linux (tested on Ubuntu).  
  Also works on Windows/macOS with Docker Desktop.  
- Required Software:  
  - Docker (version 20.10 or higher)  
  - Docker Compose (optional, not required for this submission)  
  - Git (optional, for version control)  
- Ports Used:  
  - 5000 → Flask web application  
  - 3306 → MySQL database  

---

## Application Description
This project is a Docker-based web application called **People Collector**.  
- Users can enter their **name** and **age** using a simple web form.  
- The submitted data is stored in a **MySQL database**.  
- The application displays all stored records in a web page.  
- A Docker **named volume** ensures the data persists across restarts.  

---

## Network and Volume Details
- Docker Network: `myapp-network`  
  A custom bridge network used so the Flask container and MySQL container can communicate.  
- Docker Volume: `myapp-db-data`  
  A named volume mounted inside MySQL at `/var/lib/mysql`.  
  This stores the user data persistently.  

---

## Container Configuration
### MySQL Database (`my-database`)
- Image: `mysql:8.0`  
- Environment Variables:  
  - `MYSQL_ROOT_PASSWORD=rootpass`  
  - `MYSQL_DATABASE=mydb`  
  - `MYSQL_USER=myuser`  
  - `MYSQL_PASSWORD=mypassword`  
- Port: 3306  
- Volume: `myapp-db-data`  
- Restart policy: `unless-stopped`  

### Flask Web Application (`my-webapp`)
- Image: Custom-built (`my-flask-app`) from `app/Dockerfile`  
- Environment Variables:  
  - `DB_HOST=my-database`  
  - `DB_USER=myuser`  
  - `DB_PASSWORD=mypassword`  
  - `DB_NAME=mydb`  
- Port: 5000  
- Restart policy: `unless-stopped`  

---

## Container List
- **my-database** → MySQL database container  
- **my-webapp** → Flask web application container  

---

## Instructions

### 1. Prepare the application
```bash
./prepare-app.sh
