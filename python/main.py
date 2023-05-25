import requests

import firebase_admin
from firebase_admin import credentials, firestore, messaging
import json
import random


cred = credentials.Certificate("E:\Projects\Flutter_projects\grocery_picker\python\google-services.json")
firebase_admin.initialize_app(cred)

db = firestore.client()
# collection = db.collection("groceryPicker")


dat = {}
data = None
def load_json():
  with open("grocerypicker.json") as json_file:
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



def shuffle_dict(dictToShuffle):
    keys = list(dictToShuffle.keys())
    random.shuffle(keys)

    ShuffledDict = dict()
    for key in keys:
        ShuffledDict.update({key: dictToShuffle[key]})

    return ShuffledDict



def setSearchParam(name):
  caseSearchList = list()
  temp = ""
  for i in name:
    temp = temp + i
    caseSearchList.append(temp)
  return caseSearchList


# for i in data["stores"]:
#   col = db.collection("stores")
#   data["stores"][i]["searchCase"] = setSearchParam(i.lower())
#   print(data["stores"][i]["items"])
#   print("  ")
#   data["stores"][i]["items"] = shuffle_dict(data["stores"][i]["items"])
#   print(data["stores"][i]["items"])
#   col.document(i).set(data["stores"][i])



# print(collection.document("a").get()._data)

# out = collection.document("users").get()
# print(out._data)


def delete_collection(coll_ref):
        docs = coll_ref.list_documents()

        for doc in docs:
            print(f'Deleting doc {doc.id} => {doc.get().to_dict()}')
            doc.delete()

        


def updateData():
  map = {}
  data = db.collection("stores").stream()
  # print(type(data))
  # print(data)
  for doc in data:
    map[doc.id] = doc.to_dict()
    # del_col =  db.collection("stores").document(doc.id).collection("items")
    # delete_collection(del_col)
    items = doc.to_dict()["items"]
    for item in items:
      # print({item: items[item]})
      items[item]["imageLink"] = f"https://firebasestorage.googleapis.com/v0/b/grocerypicker-862b3.appspot.com/o/items%20images%2F{item}.jpg?alt=media&token=b252239b-4a3f-4355-92a8-c2f46cfe9332"
      db.collection("stores").document(doc.id).collection("items").add({item: items[item]})
  print("completed")

    # print(f'{doc.id} => {doc.to_dict()["items"]}')
    # print("\n\n")

def send_notification(token, title, message):
    message = messaging.Message(
    notification=messaging.Notification(
        title=title,
        body=message
    ),
    data={
        'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    },
    token=token
    )
    response = messaging.send(message)
    print('Notification sent successfully:', response)

device_notication_token = "eiVQq5mqRCKMIccVQPsVtY:APA91bErwLg8eWcCwyUFOT2qJQXIpk9TugrNDTIxwCEVoPdFtYMYIyKX4bMIXORekoSTObahFDQm6aUbSocBkBMEFRclsEexs6d9oYdeiO6A0w8rwf48x1HYiMO8f6nLaOyRpDmBx_YR"
send_notification(device_notication_token,"first notification","this is a test notification delete it once you got!")

# updateData()