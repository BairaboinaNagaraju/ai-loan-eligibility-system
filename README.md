# AI Loan Eligibility Prediction System

An end-to-end, production-ready credit scoring sandbox and loan prediction web application built using FastAPI, React (Vite), Tailwind CSS, Framer Motion, Recharts, and Scikit-Learn.

The application functions like a professional FinTech dashboard, providing client sandboxes for loan simulation, automated ML model retraining, interactive calculators, Local Explainable AI (XAI) insights, and PDF credit certificate generation.

---

## 🏗️ Project Architecture

```mermaid
graph TD
    Client[React Frontend - Vite/Tailwind] <-->|JWT / JSON APIs| FastAPI[FastAPI Backend Server]
    FastAPI <-->|SQLAlchemy ORM| SQLite[(SQLite Database)]
    FastAPI <-->|Inference Pipelines| MLModel[Logistic Regression / XGBoost Model]
    TrainScript[train.py Script] -->|Fetches & Cleans| Dataset[Kaggle Loan Dataset]
    TrainScript -->|Fits & Selects Best| MLModel
```

### Folder Structure
- `backend/app/`: FastAPI application code
  - `api/`: Auth routers, prediction handlers, and dashboard aggregation logic
  - `models/`: SQLAlchemy database models and Pydantic schemas
  - `services/`: Inference engines, local Explainable AI generators, and chat simulation rules
  - `utils/`: JWT generation and bcrypt password security configurations
- `backend/scripts/`: Script (`train.py`) to scrape Kaggle source CSVs, build preprocessor pipes, train 6 classifiers, and save the champion model
- `backend/models/`: Trained model binaries (`.joblib`) and metrics records
- `backend/dataset/`: CSV dataset location
- `frontend/src/`: React source code
  - `components/`: UI components (Multistep Application Form, Probability Gauge, EMI/Affordability calculators, AI Chatbot)
  - `pages/`: Page containers (Landing Page, Client Dashboard, Admin Panel, Profile Settings, Login/Register)
  - `services/`: Base HTTP API client for backend communications
  - `index.css`: Tailwind base styles and glassmorphism styling utilities

---

## 🛠️ Installation Guide

### Prerequisites
- **Python**: 3.10+ (Checked and verified on Python 3.13)
- **Node.js & npm**: Node.js v22 (LTS) (A portable Node version is automatically provisioned inside the workspace root `C:/Users/ADMIN/.gemini/antigravity/scratch/node-v22.12.0-win-x64/` to avoid script block policies)

### 1. Backend Setup & Launch
Navigate to the `backend` folder, install requirements, and run the FastAPI server:
```bash
cd backend
pip install -r requirements.txt
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```
*The server will boot on `http://127.0.0.1:8000`. Database tables (`users`, `loan_applications`) are auto-created in SQLite (`loan_system.db`) on startup.*

### 2. Frontend Setup & Launch
Prepend the portable node directory to your session PATH, install Node modules, and launch the Vite dev server:
```powershell
# In PowerShell (Prepend portable Node to PATH)
$env:PATH = "C:\Users\ADMIN\.gemini\antigravity\scratch\node-v22.12.0-win-x64;" + $env:PATH
cd frontend
npm install
npm run dev
```
*The React app will boot on `http://localhost:5173`. Open this URL in your web browser.*

---

## 📊 Machine Learning Pipeline

The training system is located in `backend/scripts/train.py`.

1. **Preprocessing Pipeline**:
   - Encapsulated within a single Scikit-Learn `Pipeline` combined with a `ColumnTransformer`.
   - **Numerical Features** (`ApplicantIncome`, `CoapplicantIncome`, `LoanAmount`, `Loan_Amount_Term`, `Credit_History`): SimpleImputer (median) + StandardScaler.
   - **Categorical Features** (`Gender`, `Married`, `Dependents`, `Education`, `Self_Employed`, `Property_Area`): SimpleImputer (most frequent) + OneHotEncoder.
2. **Model Training & Comparison**:
   - Cross-trains 5 standard classifiers + XGBoost (Logistic Regression, Decision Tree, Random Forest, Gradient Boosting, SVM, XGBoost).
   - Generates Accuracy, Precision, Recall, F1-Score, and ROC-AUC curves on a 20% stratified test split.
   - Selects the champion model based on F1-Score and exports it to `backend/models/best_model.joblib`.
3. **Execution**:
   - Run the script manually: `python backend/scripts/train.py`
   - Trigger retraining from the Admin UI: Invokes `POST /api/dashboard/admin/retrain` which executes training in a backend subprocess and hot-reloads the active model.

---

## 🔒 API Documentation

All endpoints are fully authenticated via standard OAuth2 Bearer Tokens (JWT).

### Authentication Endpoints
- `POST /api/auth/register`: Create a new user. *The first user registered or any account with username `admin` is automatically granted global admin privileges.*
- `POST /api/auth/login`: Authenticate credentials, returns a JWT token and user info.
- `GET /api/auth/me`: Get active user profile details.
- `PUT /api/auth/profile`: Update email, full name, or passwords.

### Application Endpoints
- `POST /api/applications`: Submit loan features, run prediction model, save application, and return prediction results with Explainable AI factors.
- `GET /api/applications`: Fetch application logs. *Users view their own records; administrators see all global logs.* Support searching by location and filtering by status.
- `DELETE /api/applications/{id}`: Delete application record (allowed for administrators or owner).

### Prediction Sandbox Endpoints
- `POST /api/predict`: Sandbox endpoint to score loan eligibility features without saving record logs.

### Dashboard Endpoints
- `GET /api/dashboard`: Aggregates user total applications, approved/rejected rates, recent runs, and formatting details for Recharts charts.
- `GET /api/dashboard/admin`: Global stats for total users, applications, system approval rates, active model accuracy, and active model names.
- `GET /api/dashboard/admin/users`: Fetch list of all system users.
- `POST /api/dashboard/admin/retrain`: Executes `train.py` training script, compiles preprocessors, hot-reloads model inference singleton, and updates JSON metrics.

---

## 🌐 Deployment Guide

### Production Configuration
1. **Database**: Swap SQLite with PostgreSQL in `backend/app/database.py` by modifying `SQLALCHEMY_DATABASE_URL` to pull connection strings from environment variables:
   ```python
   import os
   SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:pass@host:5432/dbname")
   ```
2. **Environment Variables**:
   - Configure `JWT_SECRET_KEY` for secure SHA-256 token hashing.
   - Configure `CORS_ORIGINS` to limit frontend domain access.
3. **Static File Hosting**: FastAPI can serve built React assets directory directly in production:
   ```python
   from fastapi.staticfiles import StaticFiles
   app.mount("/", StaticFiles(directory="../frontend/dist", html=True), name="static")
   ```
4. **Dockerization**: Create a unified `Dockerfile` to compile React assets, deploy Gunicorn/Uvicorn ASGI processes, and host databases.
