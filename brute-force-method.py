import urllib.request
import urllib

import json

def scrape(num, letter):

    if int(num) <= 99 and int(num) >= 10:
        num = "0"+str(num)
    if int(num) <= 9:
        num = "00"+str(num)

    print(str(num)+letter)

    if letter == "none":
        urlData = urllib.request.urlopen("http://map.iu.edu/common/helpers/jsonBuilding.php?bldgCode=BL"+str(num)).read().decode("utf-8")
    else:
        urlData = urllib.request.urlopen("http://map.iu.edu/common/helpers/jsonBuilding.php?bldgCode=BL"+str(num)+letter).read().decode("utf-8")

    jsonData = json.loads(urlData)

    if len(jsonData["DATA"]) == 0:
        return True

    buildingObject = jsonData["DATA"][0]

    description = buildingObject[13]
    if buildingObject[13] is not None:
        description = buildingObject[13].strip()

    architects = buildingObject[11]
    if buildingObject[11] is not None:
        architects = buildingObject[11].strip()

    if buildingObject[2] == 0 or buildingObject[2] == 0:
        print("Skip")
    else:
        globalArray.append({
            "id":buildingObject[0].strip(),
            "lat":buildingObject[2],
            "lng":buildingObject[3],
            "address":buildingObject[4].strip(),
            "name":buildingObject[5].strip(),
            "bld_code":buildingObject[8].strip(),
            "category":buildingObject[7].strip(),
            "year":buildingObject[9],
            "description":description,
            "floors":buildingObject[12].strip(),
            "architects":architects
        })





globalArray = []
globalLetterArray = ["none","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

file = open('data.json', 'w')

for i in range(900,1000):

    for letter in globalLetterArray:
        scrape(i, letter)


tempString = json.dumps(globalArray)
print(tempString)
file.write(tempString)
file.close()
