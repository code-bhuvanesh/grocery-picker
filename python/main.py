import firebase_admin
from firebase_admin import credentials, firestore
import json

cred = credentials.Certificate("E:\Projects\\flutterApp\grocery_picker\python\google-services.json")
firebase_admin.initialize_app(cred)

db = firestore.client()
collection = db.collection("groceryPicker")


dat = {}
with open("E:\Projects\\flutterApp\grocery_picker\python\grocerypicker.json") as json_file:
    data = json.load(json_file)

# for i in data:
#     doc = collection.document(i).set(data[i])


# doc = collection.document("stores").set(data["stores"])

# for i in data:
#     if i == "stores":
#         continue
#     for j in data[i]:
#         for k in data[i][j]:
#             collection.document(i).collection(j).document(k).set(data[i][j][k])



col = db.collection("stores")

for i in data["stores"]:
    col.document(i).set(data["stores"][i]);



# print(collection.document("a").get()._data)

# out = collection.document("users").get()
# print(out._data)