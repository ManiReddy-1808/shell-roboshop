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

Environment values are handled using `.env` files for each service 📄

---

### ⚙️ Decoupled Configuration
Application code and environment config are separated (best DevOps practice):

- Uses **SystemD EnvironmentFile**
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

## 📖 Deployment Guide

---

## 1️⃣ Prerequisites

Before running scripts, you MUST create environment files on each server.

This keeps secrets & configuration outside the code 🔐

| Service | File Location | Required Variables |
|------|------|------|
| Cart / User | `/etc/roboshop/cart.env` | REDIS_HOST, CATALOGUE_HOST, CATALOGUE_PORT |
| Shipping | `/etc/roboshop/shipping.env` | CART_ENDPOINT, DB_HOST |
| Payment | `/etc/roboshop/payment.env` | CART_HOST, USER_HOST, AMQP_HOST, AMQP_USER, AMQP_PASS |
| Dispatch | `/etc/roboshop/dispatch.env` | AMQP_HOST, AMQP_USER, AMQP_PASS |

---

## 2️⃣ Running the Deployment

Sensitive data like passwords are **never hardcoded**.  
They are passed at runtime using positional parameters 🔐

Example:
```bash
sudo sh mysql.sh <db_password>


aws-automation/
├── common.sh       # Shared reusable functions (validation, logging, user creation)
├── mongodb.sh      # MongoDB setup
├── mysql.sh        # MySQL setup (password passed dynamically)
├── redis.sh        # Redis configuration
├── rabbitmq.sh     # RabbitMQ setup with safe user creation
├── catalogue.sh    # Node.js service
├── cart.sh         # Node.js service
├── user.sh         # Node.js service
├── shipping.sh     # Java build + DB schema loading
├── payment.sh      # Python + uWSGI deployment
└── dispatch.sh     # GoLang compile & deploy
