import os
import requests

def get_travel_time(start_lat, start_lng, end_lat, end_lng, mode='DRIVE'):
    """
    Get travel time between two points using Google Maps Routes API
    
    Args:
        start_lat (float): Starting point latitude
        start_lng (float): Starting point longitude 
        end_lat (float): Ending point latitude
        end_lng (float): Ending point longitude
        mode (str): Mode of transportation ('DRIVE', 'WALK', 'BICYCLE', 'TRANSIT')
        
    Returns:
        dict: Dictionary containing duration and distance information
    """
    GMAPS_API_KEY=AIzaSyAQg0TD-laWVKxHvQcnlsydUep9CvJOUqM
    API_KEY = AIzaSyAQg0TD-laWVKxHvQcnlsydUep9CvJOUqM
    # API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")
    url = "https://routes.googleapis.com/directions/v2:computeRoutes"

    headers = {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": API_KEY,
        "X-Goog-FieldMask": "routes.duration,routes.distanceMeters"
    }

    data = {
        "origin": {"location": {"latLng": {"latitude": start_lat, "longitude": start_lng}}},
        "destination": {"location": {"latLng": {"latitude": end_lat, "longitude": end_lng}}},
        "travelMode": mode
    }

    try:
        response = requests.post(url, json=data, headers=headers)
        result = response.json()

        if "routes" in result and len(result["routes"]) > 0:
            route = result["routes"][0]
            return {
                "status": "OK",
                "duration": {
                    "value": route["duration"][:-1],  # Duration in seconds (strip 's' from API response)
                    "text": f"{int(route['duration'][:-1]) // 60} mins"
                },
                "distance": {
                    "value": route["distanceMeters"],  # Distance in meters
                    "text": f"{route['distanceMeters'] / 1000:.2f} km"
                }
            }
        else:
            return {
                "status": "ZERO_RESULTS",
                "error": "No route found"
            }

    except Exception as e:
        return {
            "status": "ERROR",
            "error": str(e)
        }
