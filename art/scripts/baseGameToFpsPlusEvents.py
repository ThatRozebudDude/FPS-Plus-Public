import json
import sys
import pyperclip

def processEvents(data, bpm):
    sectionTime = ((60 / bpm) * 1000) * 4
    curSectionTime = 0

    curSection = 0

    #Set up json structure and disable automatic camera movements since base game uses events for cameras.
    output = "{\"events\":{\"events\":[\n"
    output += "[0, 0, 3, \"toggleCamMovement\"]\n"

    for event in data["events"]:
        while(event["t"] >= curSectionTime + (sectionTime * 0.99)):
            curSectionTime += sectionTime
            curSection += 1
        
        skipAdd = False

        tag = [""]
        column = [0]
        timeOffset = [0]

        match event["e"]:
            case "FocusCamera":

                focusedCharacter = -1
                if type(event["v"]) is int:
                    focusedCharacter = event["v"]
                else:
                    focusedCharacter = event["v"]["char"]

                match focusedCharacter:
                        case 0 | "0":
                            tag[0] += "camFocusBf;"
                        case 1 | "1":
                            tag[0] += "camFocusDad;"
                        case 2 | "2":
                            tag[0] += "camFocusGf;"

                x = 0
                y = 0
                if type(event["v"]) is not int:
                    if "x" in event["v"]:
                        x = event["v"]["x"]
                    if "y" in event["v"]:
                        y = event["v"]["y"]
                            
                tag[0] += str(x) + ";" + str(y)

                if type(event["v"]) is not int:
                    if "ease" in event["v"]:
                        if not event["v"]["ease"] == "CLASSIC":
                            tag[0] += ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"])

                print(event["e"] + "\t->\t" + tag[0])

            case "ZoomCamera":
                tag[0] += "camZoom;" + str(event["v"]["zoom"]) + ";" + str(event["v"]["duration"]) + "s;" + event["v"]["ease"]

                if "mode" in event["v"]:
                    if event["v"]["mode"] == "stage":
                        tag[0] += ";true"

                print(event["e"] + "\t->\t" + tag[0])

            case "SetCameraBop":
                tag[0] += "camBopFreq;" + str(event["v"]["rate"])

                instensity = 1
                if "intensity" in event["v"]:
                    instensity = event["v"]["intensity"]

                tag.append("")
                tag[1] += "camBopIntensity;" + str(instensity)
                timeOffset.append(-20)
                column.append(2)

                print(event["e"] + "\t->\t" + tag[0] + "\t&\t" + tag[1])

            case "PlayAnimation":
                column[0] = 1
                target = "bf"
                match event["v"]["target"]:
                    case "dad":
                        target = "dad"
                    case "girlfriend" | "gf": #idk which one it is
                        target = "gf"

                force = "false"
                if "force" in event["v"]:
                    if event["v"]["force"] == "true":
                        force = "true"

                tag[0] += "playAnim;" + target + ";" + event["v"]["anim"] + ";" + force

                print(event["e"] + "\t->\t" + tag[0])

            case _:
                skipAdd = True
                print(event["e"] + "\tXX\tEvent not supported, skipping.")

        if not skipAdd:
            for i in range(len(tag)):
                eventTime = event["t"] + timeOffset[i]
                if(eventTime < 0):
                    eventTime = 0

                eventToAdd = ",[" + str(curSection) + ", " + str(eventTime) + ", " + str(column[i]) + ", "
                eventToAdd += "\"" + tag[i] + "\"]"
                output += eventToAdd + "\n"

    output += "]}}"

    return output

if(__name__ == "__main__"):
    print("BPM: ")
    inputBPM = float(input())

    f = open(sys.argv[1])
    chartJson = json.load(f)
    f.close()

    result = processEvents(chartJson, inputBPM)

    pyperclip.copy(result)
    print("events copied to clipbaord!!")