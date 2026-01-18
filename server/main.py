import os
import firebase_admin
from dotenv import load_dotenv
from firebase_admin import credentials, auth, firestore
from fastapi import FastAPI, Depends, HTTPException, Header, Query
import requests
from typing import Optional
from pydantic import BaseModel
from google import genai
from google.genai import types
from datetime import datetime
import services.search_service as search_service
load_dotenv()

firebase_creds = {
  "type": "service_account",
  "project_id": os.getenv("FIREBASE_PROJECT_ID"),
  "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
  "private_key": os.getenv("FIREBASE_PRIVATE_KEY"),
  "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
  "client_id": os.getenv("CLIENT_ID"),
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40woc-seekr-ai.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"), http_options={'api_version': 'v1'})
# 1. Initialize Firebase Admin SDK
if not firebase_admin._apps:
    cred = credentials.Certificate(firebase_creds)
    firebase_admin.initialize_app(cred)
db = firestore.client()
app = FastAPI()

# 2. Dependency for Token Verification
async def verify_token(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid or missing token")
    
    token = authorization.split("Bearer ")[1]
    try:
        # Verify the token against Firebase
        decoded_token = auth.verify_id_token(token)
        return decoded_token # Returns user info (uid, email, etc.)
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid tokens return 401 error")

# 3. Protected Endpoint
@app.post("/summon")
async def protected_summon(message: str, user=Depends(verify_token)):
    return {
        "reply": f"Welcome, {user.get('email')}. The Void hears your message: {message}",
        "user_id": user['uid']
    }

@app.get("/health")
def health_check():
    return {"status": "online"}

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
SEARCH_ENGINE_ID = os.getenv("GOOGLE_SEARCH_ENGINE_ID")

@app.get("/search")
async def google_search(
    q: str = Query(..., description="The search query"),
    user=Depends(verify_token) # This satisfies the "Protected by authentication" requirement
):
    url = f"https://www.googleapis.com/customsearch/v1"
    params = {
        "key": GOOGLE_API_KEY,
        "cx": SEARCH_ENGINE_ID,
        "q": q
    }

    response = requests.get(url, params=params)
    
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="Google API Error")

    data = response.json()
    items = data.get("items", [])

    # Format the results to include only title, link, and snippet
    results = [
        {
            "title": item.get("title"),
            "link": item.get("link"),
            "snippet": item.get("snippet")
        }
        for item in items
    ]

    return {"results": results}

# Use 'gemini-1.5-flash' for speed or 'gemini-1.5-pro' for complex reasoning
# model = genai.GenerativeModel('models/gemini-1.5-flash')

class ChatMessage(BaseModel):
    prompt: str

app = FastAPI()

@app.post("/chat/generate")
async def generate_ai_response(
    data: ChatMessage, 
    user=Depends(verify_token) # Satisfies "Protected by authentication"
):
    try:
        # Generate content
        # response = model.generate_content(data.prompt)
        
        # if not response.text:
        #     raise ValueError("Empty response from AI")

        # return {
        #     "reply": response.text,
        #     "user": user.get("email"),
        #     "status": "success"
        # }
        return None

    except Exception as e:
        # Error handling for API failures
        print(f"Gemini API Error: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail="The Void is currently silent. Please try your summoning later."
        )
    
@app.post("/chat/summon")
async def combined_chat_logic(data: ChatMessage, user=Depends(verify_token)):
    try:
        print(f"--- Summoning started for: {user['email']} ---")
        # 1. Search (Task 3 Logic)
        search_results = search_service.SearchService().perform_search(data.prompt)
        # context = "\n".join([f"Source: {r['link']}\nContent: {r['snippet']}" for r in search_results])

        # 2. LLM Generation with Context (Task 4 Logic)
        # full_prompt = f"""
        # You are Seekr AI. Use the following context to answer the user's question. 
        # If the answer isn't in the context, use your own knowledge but mention you are searching the void.
        # Include citations (source links) at the end.

        # Context: {context}
        # User Question: {data.prompt}
        # """
        # response = client.models.generate_content(
        #     model="gemini-1.5-flash",
        #     contents=[
        #         types.Part.from_text(text="SYSTEM: You are Seekr AI."),
        #         types.Part.from_text(text=f"Context: {context}\n\nUser Question: {data.prompt}")
        #     ]
        # )

        # ai_reply = response.candidates[0].content

        # 3. Save to Firestore (Task 5 Persistence)
        chat_doc = {
            "user_id": user['uid'],
            "user_email": user['email'],
            "prompt": data.prompt,
            "response": "ai_reply",
            "sources": search_results,
            "timestamp": datetime.utcnow()
        }
        # Save in a subcollection under the user for better session management
        db.collection("users").document(user['uid']).collection("chats").add(chat_doc)

        return {
            "reply": "ai_reply",
            "sources": search_results,
            "status": "archived_in_void"
        }

    except Exception as e:
        print(f"Combined Chat Logic Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/chat/history")
async def get_chat_history(user=Depends(verify_token)):
    chats_ref = db.collection("users").document(user['uid']).collection("chats")
    # Order by newest first
    docs = chats_ref.order_by("timestamp", direction=firestore.Query.DESCENDING).limit(20).stream()
    
    history = []
    for doc in docs:
        history.append(doc.to_dict())
    
    return {"history": history}