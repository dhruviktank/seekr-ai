# server/services/search_service.py
import os
import requests
from fastapi import HTTPException

class SearchService:
    def __init__(self):
        self.api_key = os.getenv("GOOGLE_API_KEY")
        self.cx = os.getenv("GOOGLE_SEARCH_ENGINE_ID")
        self.base_url = "https://www.googleapis.com/customsearch/v1"

    def perform_search(self, query: str):
        """
        Queries Google Custom Search API and returns formatted results.
        """
        if not self.api_key or not self.cx:
            raise HTTPException(status_code=500, detail="Search credentials missing.")

        params = {
            "key": self.api_key,
            "cx": self.cx,
            "q": query
        }

        try:
            response = requests.get(self.base_url, params=params)
            response.raise_for_status() # Raises error for 4xx or 5xx status codes
            
            data = response.json()
            items = data.get("items", [])

            # Formatting results as per Task 3 requirements
            formatted_results = [
                {
                    "title": item.get("title"),
                    "link": item.get("link"),
                    "snippet": item.get("snippet")
                }
                for item in items
            ]

            return formatted_results

        except requests.exceptions.RequestException as e:
            print(f"Search API Error: {e}")
            raise HTTPException(status_code=502, detail="External Search API unreachable.")