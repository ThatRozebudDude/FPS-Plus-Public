import json
import sys
import pyperclip

def processEvents(data, bpm):
    sectionTime = ((60 / bpm) * 1000) * 4
    curSectionTime = 0

    curSection = 0

    output = "{\"events\":{\"events\":[\n"
    output += "[0, 0, 3, \"toggleCamMovement\"]\n"

    for event in data["events"]:
        while(event["t"] >= curSectionTime + (sectionTime * 0.99)):
            curSectionTime += sectionTime
            curSection += 1
        
        skipAdd = False

        column = 0

        eventToAdd = ",[" + str(curSection) + ", " + str(event["t"]) + ", "

        tag = ""

        match event["e"]:
            case "FocusCamera":

                focusedCharacter = -1
                if type(event["v"]) is int:
                    focusedCharacter = event["v"]
                else:
                    focusedCharacter = event["v"]["char"]

                match focusedCharacter:
                        case 0 | "0":
                            tag += "camFocusBf;"
                        case 1 | "1":
                            tag += "camFocusDad;"
                        case 2 | "2":
                            tag += "camFocusGf;"

                x = 0
                y = 0
                if type(event["v"]) is not int:
                    if "x" in event["v"]:
                        x = event["v"]["x"]
                    if "y" in event["v"]:
                        y = event["v"]["y"]
                            
                tag += str(column) + ", "
                tag += str(x) + ";" + str(y)

                if type(event["v"]) is not int:
                    if "ease" in event["v"]:
                        if not event["v"]["ease"] == "CLASSIC":
                            tag += ";" + str(event["v"]["duration"]) + "s;" + str(event["v"]["ease"])

                print(event["e"] + "\t->\t" + tag)

            case "ZoomCamera":
                tag += str(column) + ", "
                tag += "camZoom;" + str(event["v"]["zoom"]) + ";" + str(event["v"]["duration"]) + "s;" + event["v"]["ease"]

                if "mode" in event["v"]:
                    if event["v"]["mode"] == "stage":
                        tag += ";true"

                print(event["e"] + "\t->\t" + tag)

            case "SetCameraBop":
                #does not support intensity
                tag += str(column) + ", "
                tag += "camBopFreq;" + str(event["v"]["rate"])
                print(event["e"] + "\t->\t" + tag)

            case "PlayAnimation":
                column = 1
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

                tag += str(column) + ", "
                tag += "playAnim;" + target + ";" + event["v"]["anim"] + ";" + force

                print(event["e"] + "\t->\t" + tag)

            case _:
                skipAdd = True
                print(event["e"] + "\tXX\tEvent not supported, skipping.")

        if not skipAdd:
            eventToAdd += "\"" + tag + "\"]"
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