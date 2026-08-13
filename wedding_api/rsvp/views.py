from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Guest

@api_view(['GET'])
def home(request):
    return Response({"message": "Wedding Invite API is running 💍"}, status=200)

@api_view(['POST'])
def rsvp(request):
    try:
        data = request.data

        name = data.get('name')
        attending = data.get('attending')
        guests = data.get('guests')

        # 🔥 HARD VALIDATION
        if not name:
            return Response({"error": "Name required"}, status=400)

        if guests is None:
            return Response({"error": "Guests required"}, status=400)

        # 🔥 convert safely
        try:
            guests = int(guests)
        except:
            return Response({"error": "Guests must be number"}, status=400)

        Guest.objects.create(
            name=name,
            attending=bool(attending),
            guests_count=guests
        )

        return Response({"message": "Saved"}, status=201)

    except Exception as e:
        print("ERROR:", str(e))  # 👈 VERY IMPORTANT (shows in Render logs)
        return Response({"error": str(e)}, status=400)