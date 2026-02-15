# 🛒 RoboShop Microservices Deployment Automation (AWS ☁️)

This repository contains a **real-world DevOps automation setup** that installs, configures, and deploys the full **RoboShop microservices application** on:

👉 **RHEL / Amazon Linux 9**

The goal:  
Spin up servers ➜ Run scripts ➜ Entire application becomes live 🚀

No manual configuration headaches 😄

---

## 🏗️ Architecture Overview

The automation deploys multiple application services built using different technologies:

- 🌐 Node.js
- ☕ Java
- 🐍 Python
- 🐹 GoLang

And connects them with distributed backend systems:

- 🍃 MongoDB (NoSQL DB)
- 🐬 MySQL (SQL DB)
- ⚡ Redis (Cache)
- 🐰 RabbitMQ (Message Queue)

This simulates a **real enterprise microservices architecture**.

---

## 🛠 Features & Engineering Practices

### 🔁 Idempotent Scripts (Run Anytime Safely)
Scripts can be executed again and again without breaking the system:

✔ No duplicate users  
✔ No duplicate folders  
✔ No repeated installations  
✔ No inconsistent configuration  

---

### ⚙️ Decoupled Configuration
Application code and environment config are separated (best DevOps practice):

- Keeps code reusable across environments (DEV / SIT / PROD)

---

### 📝 Centralized Logging
All automation logs are stored here:


So debugging becomes super easy 🔍

---

### 🛡️ Defensive Scripting
Scripts are written safely like production automation:

- Root user validation 👮
- Live execution checks 🧠
- Step-by-step error handling ❌

---