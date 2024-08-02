package note.types;

import flixel.tweens.FlxEase;
import flixel.FlxG;

class BlazinNotes extends NoteType
{

    override function defineTypes():Void{
        addNoteType("weekend-1-punchlow", punchlowHit, punchlowMiss);
        addNoteType("weekend-1-punchlowblocked", punchlowblockedHit, punchlowblockedMiss);
        addNoteType("weekend-1-punchlowdodged", punchlowdodgedHit, punchlowdodgedMiss);
        addNoteType("weekend-1-punchlowspin", punchlowspinHit, punchlowspinMiss);

        addNoteType("weekend-1-punchhigh", punchhighHit, punchhighMiss);
        addNoteType("weekend-1-punchhighblocked", punchhighblockedHit, punchhighblockedMiss);
        addNoteType("weekend-1-punchhighdodged", punchhighdodgedHit, punchhighdodgedMiss);
        addNoteType("weekend-1-punchhighspin", punchhighspinHit, punchhighspinMiss);
        
        addNoteType("weekend-1-blockhigh", blockhighHit, blockhighMiss);
        addNoteType("weekend-1-blocklow", blocklowHit, blocklowMiss);
        addNoteType("weekend-1-blockspin", blockspinHit, blockspinMiss);

        addNoteType("weekend-1-dodgehigh", dodgehighHit, dodgehighMiss);
        addNoteType("weekend-1-dodgelow", dodgelowHit, dodgelowMiss);
        addNoteType("weekend-1-dodgespin", dodgespinHit, dodgespinMiss);

        addNoteType("weekend-1-hithigh", hithighHit, hithighMiss);
        addNoteType("weekend-1-hitlow", hitlowHit, hitlowMiss);
        addNoteType("weekend-1-hitspin", hitspinHit, hitspinMiss);

        addNoteType("weekend-1-picouppercutprep", picouppercutprepHit, picouppercutprepMiss);
        addNoteType("weekend-1-picouppercut", picouppercutHit, picouppercutMiss);
        addNoteType("weekend-1-darnelluppercutprep", darnelluppercutprepHit, darnelluppercutprepMiss);
        addNoteType("weekend-1-darnelluppercut", darnelluppercutHit, darnelluppercutMiss);

        addNoteType("weekend-1-idle", idleHit, idleMiss);
        addNoteType("weekend-1-fakeout", fakeoutHit, fakeoutMiss);
        addNoteType("weekend-1-taunt", tauntHit, tauntMiss);
    }

	function alternating():Int{
        if(!data().exists("blazin-alternating")){
            data().set("blazin-alternating", true);
        }
		data()["blazin-alternating"] = !data()["blazin-alternating"];
		return (data()["blazin-alternating"]) ? 2 : 1;
	}

    function punchlowHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchLow' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('hitLow', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
        playstate().setBfOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
    }

    function punchlowblockedHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchLow' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('block', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
        playstate().setBfOnTop();
        playstate().camShake(0.002, 1/30, 0.1);
    }

    function punchlowdodgedHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchLow' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('dodge', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
        playstate().setBfOnTop();
    }

    function punchlowspinHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchLow' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('hitSpin', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
        playstate().setBfOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
    }

    function punchhighHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchHigh' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('hitHigh', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0);
        playstate().setBfOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
    }

    function punchhighblockedHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchHigh' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('block', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0);
        playstate().setBfOnTop();
        playstate().camShake(0.002, 1/30, 0.1);
    }

    function punchhighdodgedHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchHigh' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('dodge', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0);
        playstate().setBfOnTop();
    }

    function punchhighspinHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchHigh' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('hitSpin', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0);
        playstate().setBfOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
    }

    function blockhighHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('block', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
        playstate().setOppOnTop();
        playstate().camShake(0.002, 1/30, 0.1);
    }

    function blocklowHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('block', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
        playstate().setOppOnTop();
        playstate().camShake(0.002, 1/30, 0.1);
    }

    function blockspinHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('block', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
        playstate().setOppOnTop();
        playstate().camShake(0.002, 1/30, 0.1);
    }

    function dodgehighHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('dodge', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
        playstate().setOppOnTop();
    }

    function dodgelowHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('dodge', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
        playstate().setOppOnTop();
    }

    function dodgespinHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('dodge', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
        playstate().setOppOnTop();
    }

    function hithighHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitHigh', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
    }

    function hitlowHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
    }

    function hitspinHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
    }

    function picouppercutprepHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('uppercutPrep', true);
        }
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 1 * playstate().camOffsetAmount);
        playstate().setBfOnTop();
    }

    function picouppercutHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('uppercutPunch', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('uppercutHit', true);
        }
        playstate().changeCamOffset(0, -1 * playstate().camOffsetAmount);
        playstate().setBfOnTop();
        playstate().camShake(0.005, 1/30, 0.25);
    }

    function darnelluppercutprepHit(note:Note, character:Character){
        if(dad().canAutoAnim){
            dad().playAnim('uppercutPrep', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 1 * playstate().camOffsetAmount);
        playstate().setOppOnTop();
    }

    function darnelluppercutHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('uppercutHit', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('uppercutPunch', true);
        }
        playstate().changeCamOffset(0, -1 * playstate().camOffsetAmount);
        playstate().setOppOnTop();
        playstate().camShake(0.005, 1/30, 0.25);
    }

    function idleHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('idle', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('idle', true);
        }
        playstate().changeCamOffset(0, 0);
        playstate().setBfOnTop();
    }

    function fakeoutHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('fakeHit', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('cringe', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0);
        playstate().setBfOnTop();
    }

    function tauntHit(note:Note, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('taunt', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('pissed', true);
        }
        playstate().changeCamOffset(0, 0);
        playstate().setBfOnTop();
    }

    function punchlowMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function punchlowblockedMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function punchlowdodgedMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function punchlowspinMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function punchhighMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitHigh', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function punchhighblockedMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitHigh', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function punchhighdodgedMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitHigh', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function punchhighspinMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function blockhighMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitHigh', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function blocklowMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function blockspinMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function dodgehighMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitHigh', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function dodgelowMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function dodgespinMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function hithighMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitHigh', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function hitlowMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function hitspinMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function picouppercutprepMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitLow', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchLow' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0.5 * playstate().camOffsetAmount);
    }

    function picouppercutMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

    function darnelluppercutprepMiss(direction:Int, character:Character){
        if(dad().canAutoAnim){
            dad().playAnim('uppercutPrep', true);
        }
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 1 * playstate().camOffsetAmount);
        playstate().setOppOnTop();
    }

    function darnelluppercutMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('uppercutHit', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('uppercutPunch', true);
        }
        playstate().changeCamOffset(0, -1 * playstate().camOffsetAmount);
        playstate().setOppOnTop();
        playstate().camShake(0.005, 1/30, 0.25);
    }

    function idleMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('idle', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('idle', true);
        }
        playstate().changeCamOffset(0, 0);
        playstate().setBfOnTop();
    }

    function fakeoutMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('punchHigh' + alternating(), true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('dodge', true);
        }
        playstate().setBfOnTop();
        playstate().changeCamOffset(-1 * playstate().camOffsetAmount, 0);
    }

    function tauntMiss(direction:Int, character:Character){
        if(boyfriend().canAutoAnim){
            boyfriend().playAnim('hitSpin', true);
        }
        if(dad().canAutoAnim){
            dad().playAnim('punchHigh' + alternating(), true);
        }
        playstate().setOppOnTop();
        playstate().camShake(0.0025, 1/30, 0.15);
        playstate().changeCamOffset(1 * playstate().camOffsetAmount, 0);
    }

}