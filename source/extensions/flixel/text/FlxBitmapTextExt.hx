package extensions.flixel.text;

import flixel.graphics.frames.FlxBitmapFont;
import openfl.display.BitmapData;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxBitmapText;

class FlxBitmapTextExt extends FlxBitmapText
{

	var ignoreJustify:Bool = false; //Fix for final line with justify.

	public function new(?x = 0.0, ?y = 0.0, text:UnicodeString = "", ?font:FlxBitmapFont){
		super(x, y, text, font);
	}

	override function updateTextBitmap(useTiles:Bool = false):Void{
		computeTextSize();
	
		if(FlxG.renderBlit){
			useTiles = false;
		}
	
		if(!useTiles){
			textBitmap = FlxDestroyUtil.disposeIfNotEqual(textBitmap, frameWidth, frameHeight);
	
			if(textBitmap == null){
				textBitmap = new BitmapData(frameWidth, frameHeight, true, FlxColor.TRANSPARENT);
			}
			else{
				textBitmap.fillRect(textBitmap.rect, FlxColor.TRANSPARENT);
			}
	
			textBitmap.lock();
		}
		else if(FlxG.renderTile){
			textData.clear();
		}
	
		_fieldWidth = frameWidth;
	
		var numLines:Int = _lines.length;
		var line:UnicodeString;
		var lineWidth:Int;
	
		var ox:Int, oy:Int;
	
		for(i in 0...numLines){
			line = _lines[i];
			lineWidth = _linesWidth[i];
	
			// LEFT
			ox = font.minOffsetX;
			oy = i * (font.lineHeight + lineSpacing) + padding;
	
			if(alignment == FlxTextAlign.CENTER){
				ox += Std.int((frameWidth - lineWidth) / 2);
			}
			else if(alignment == FlxTextAlign.RIGHT){
				ox += (frameWidth - lineWidth) - padding;
			}
			else{ // LEFT OR JUSTIFY
					ox += padding;
			}
	
			ignoreJustify = (i == numLines-1);
			drawLine(_lines[i], ox, oy, useTiles);
			ignoreJustify = false;
		}
	
		if(!useTiles){
			textBitmap.unlock();
		}
	
		pendingTextBitmapChange = false;
	}

	override function addLineData(line:UnicodeString, startX:Int, startY:Int, data:CharList){
		var curX:Float = startX;
		var curY:Int = startY;

		final lineLength:Int = line.length;
		final textWidth:Int = this.textWidth;

		var spaceWidth:Int = font.spaceWidth;
		if(alignment == FlxTextAlign.JUSTIFY && !ignoreJustify){
			final lineWidth:Int = getStringWidth(line);
			final numSpaces = countSpaces(line);
			final totalSpacesWidth:Int = numSpaces * font.spaceWidth;
			spaceWidth = Std.int((fieldWidth - lineWidth + totalSpacesWidth) / numSpaces);
		}

		final tabWidth:Int = spaceWidth * numSpacesInTab;

		for(i in 0...lineLength){
			final charCode = line.charCodeAt(i);
			final isSpace = isSpaceChar(charCode);
			final hasFrame = font.charExists(charCode);
			if(hasFrame && !isSpace)
				data.push(charCode, curX, curY);

			if(hasFrame || isSpace){
				if(i + 1 < lineLength){
					final nextCode = line.charCodeAt(i + 1);
					curX += getCharPairAdvance(charCode, nextCode, spaceWidth) + letterSpacing;
				}
				else{
					curX += getCharAdvance(charCode, spaceWidth) + letterSpacing;
				}
			}
		}
	}

	static inline function isSpaceChar(charCode:Int){
		return charCode == FlxBitmapFont.SPACE_CODE || charCode == FlxBitmapFont.TAB_CODE;
	}

}