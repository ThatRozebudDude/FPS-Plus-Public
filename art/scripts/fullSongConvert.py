import json
import os
import sys
import shutil

import baseGameToFpsPlus
import baseGameToFpsPlusEvents

def convertDiffNameToSuffix(diff):
    match diff:
        case "erect":
            diff = "normal"
        case "nightmare":
            diff = "hard"
        
    if diff != "normal":
        return "-" + diff
    
    return ""

if(__name__ == "__main__"):

    f = open(sys.argv[1])
    chartJson = json.load(f)
    f.close()

    f = open(sys.argv[2])
    metaJson = json.load(f)
    f.close()

    print("Player Character: ")
    playerCharacter = input()

    print("Opponent Character: ")
    opponentCharacter = input()

    print("Girlfriend Character: ")
    gfCharacter = input()

    print("Stage: ")
    stage = input()

    print("Song Name (File): ")
    songName = input()

    # This is in the metadata but I use a different name for the albums and I don't feel like changing all the other songs.
    print("Album (For Freeplay): ")
    album = input()

    # Makes the folder for the song export if it doesn't exist already or clear it if it does.
    dir = os.path.dirname(os.path.realpath(__file__))
    outputFolder = dir + "\\convertedSongs\\" + songName.lower()
    if not os.path.exists(outputFolder):
        os.makedirs(outputFolder)
    else:
        try:
            shutil.rmtree(outputFolder)
        except OSError as e:
            print("Error: %s - %s." % (e.filename, e.strerror))
            exit(1)
        os.makedirs(outputFolder)

    listedDifficulties = metaJson["playData"]["difficulties"]
    diffNumberArray = []

    # Get difficulties from metadata. FPS Plus treats "erect" and "nightmare" as "normal" and "hard" in Erect songs.
    if "easy" in metaJson["playData"]["ratings"]:
        diffNumberArray.append(metaJson["playData"]["ratings"]["easy"])
    else:
        diffNumberArray.append(0)

    if "normal" in metaJson["playData"]["ratings"]:
        diffNumberArray.append(metaJson["playData"]["ratings"]["normal"])
    elif "erect" in metaJson["playData"]["ratings"]:
        diffNumberArray.append(metaJson["playData"]["ratings"]["erect"])
    else:
        diffNumberArray.append(0)

    if "hard" in metaJson["playData"]["ratings"]:
        diffNumberArray.append(metaJson["playData"]["ratings"]["hard"])
    elif "nightmare" in metaJson["playData"]["ratings"]:
        diffNumberArray.append(metaJson["playData"]["ratings"]["nightmare"])
    else:
        diffNumberArray.append(0)

    metaOutput = "{"
    metaOutput += "\"name\": \"" + metaJson["songName"] + "\",\n"
    metaOutput += "\"artist\": \"" + metaJson["artist"] + "\",\n"
    metaOutput += f"\"album\": \"{album}\",\n"
    metaOutput += f"\"difficulties\": {diffNumberArray},\n"
    metaOutput += "\"bfBeats\": [1, 3],\n"
    metaOutput += "\"dadBeats\": [0, 2]}"

    metaOutputJson = json.loads(metaOutput)
    metaOutput = json.dumps(metaOutputJson, indent=4)

    f = open(outputFolder + "\\meta.json", "w")
    f.write(metaOutput)
    f.close()

    bpm = 100

    for timeChange in metaJson["timeChanges"]:
        if timeChange["t"] == 0:
            bpm = timeChange["bpm"]

    eventsOutput = baseGameToFpsPlusEvents.processEvents(chartJson, bpm)

    eventsOutputJson = json.loads(eventsOutput)
    eventsOutput = json.dumps(eventsOutputJson, indent=4)

    f = open(outputFolder + "\\events.json", "w")
    f.write(eventsOutput)
    f.close()

    for diff in listedDifficulties:
        scrollSpeed = chartJson["scrollSpeed"][diff]
        chartNotes = baseGameToFpsPlus.processNotes(chartJson, bpm, diff)

        output = "{\"song\":{\n"
        output += "\"speed\": \"" + str(scrollSpeed) + "\",\n"
        output += f"\"stage\": \"{stage}\",\n"
        output += f"\"player1\": \"{playerCharacter}\",\n"
        output += f"\"player2\": \"{opponentCharacter}\",\n"
        output += f"\"gf\": \"{gfCharacter}\",\n"
        output += f"\"song\": \"{songName}\",\n"
        output += f"\"bpm\": {bpm},\n"
        output += chartNotes
        output = output[:-1]
        output += "}}"

        outputJson = json.loads(output)
        output = json.dumps(outputJson, indent=4)

        f = open(outputFolder + "\\" + songName.lower() + convertDiffNameToSuffix(diff) + ".json", "w")
        f.write(output)
        f.close()